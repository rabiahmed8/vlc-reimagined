/*****************************************************************************
 * Copyright (C) 2026 VLC authors and VideoLAN
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * ( at your option ) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/
#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include "redesign_effects.hpp"

#include "player/player_controller.hpp"

#include "playlist/playlist_controller.hpp"
#include "playlist/media.hpp"

#include <QDir>
#include <QRegularExpression>
#include <QUrl>

#include <vlc_aout.h>
#include <vlc_configuration.h>
#include <vlc_modules.h>
#include <vlc_player.h>
#include <vlc_vout.h>

#include "../../../audio_filter/equalizer_presets.h"

namespace {

// "video-filter", "sub-source"... for a video filter module, nullptr if unknown
const char *videoFilterType(const char *module)
{
    module_t *mod = module_find(module);
    if (!mod)
        return nullptr;
    if (module_provides(mod, "video splitter"))
        return "video-splitter";
    if (module_provides(mod, "video filter"))
        return "video-filter";
    if (module_provides(mod, "sub source"))
        return "sub-source";
    if (module_provides(mod, "sub filter"))
        return "sub-filter";
    return nullptr;
}

QStringList splitChain(const char *chain)
{
    return QString(chain ? chain : "").split(QRegularExpression("[:,]"), Qt::SkipEmptyParts);
}

QString chainWith(QStringList list, const QString &module, bool enabled)
{
    list.removeAll(module);
    if (enabled)
        list.append(module);
    return list.join(':');
}

QVariant readVar(vlc_object_t *obj, const char *name)
{
    int type = obj ? var_Type(obj, name) & VLC_VAR_CLASS : 0;
    if (type == 0)
    {
        // not created on the output yet: the configuration has the value
        switch (config_GetType(name))
        {
            case VLC_VAR_BOOL:    return config_GetInt(name) != 0;
            case VLC_VAR_INTEGER: return static_cast<qlonglong>(config_GetInt(name));
            case VLC_VAR_FLOAT:   return static_cast<double>(config_GetFloat(name));
            case VLC_VAR_STRING:
            {
                char *s = config_GetPsz(name);
                QString v = qfu(s);
                free(s);
                return v;
            }
            default: return {};
        }
    }
    switch (type)
    {
        case VLC_VAR_BOOL:    return var_GetBool(obj, name);
        case VLC_VAR_INTEGER: return static_cast<qlonglong>(var_GetInteger(obj, name));
        case VLC_VAR_FLOAT:   return static_cast<double>(var_GetFloat(obj, name));
        case VLC_VAR_STRING:
        {
            char *s = var_GetString(obj, name);
            QString v = qfu(s);
            free(s);
            return v;
        }
        default: return {};
    }
}

void writeValue(vlc_object_t *obj, const char *name, const QVariant &value)
{
    const int cfgType = config_GetType(name); // a VLC_VAR_* type, 0 when not an option
    int varType = obj ? var_Type(obj, name) & VLC_VAR_CLASS : 0;

    switch (cfgType)
    {
        case VLC_VAR_BOOL:    config_PutInt(name, value.toBool()); break;
        case VLC_VAR_INTEGER: config_PutInt(name, value.toLongLong()); break;
        case VLC_VAR_FLOAT:   config_PutFloat(name, value.toFloat()); break;
        case VLC_VAR_STRING:  config_PutPsz(name, qtu(value.toString())); break;
        default: break;
    }
    if (varType == 0)
        return;

    switch (varType)
    {
        case VLC_VAR_BOOL:    var_SetBool(obj, name, value.toBool()); break;
        case VLC_VAR_INTEGER: var_SetInteger(obj, name, value.toLongLong()); break;
        case VLC_VAR_FLOAT:   var_SetFloat(obj, name, value.toFloat()); break;
        case VLC_VAR_STRING:  var_SetString(obj, name, qtu(value.toString())); break;
        default: break;
    }
}

} // namespace

RedesignEffects::RedesignEffects(qt_intf_t *intf, QObject *parent)
    : QObject(parent), p_intf(intf)
{
}

bool RedesignEffects::videoFilterEnabled(const QString &module) const
{
    const char *type = videoFilterType(qtu(module));
    if (!type)
        return false;
    char *chain = nullptr;
    if (auto vout = THEMIM->getVout())
        chain = var_GetString(vout.get(), type);
    else
        chain = config_GetPsz(type);
    const bool on = splitChain(chain).contains(module);
    free(chain);
    return on;
}

void RedesignEffects::setVideoFilterEnabled(const QString &module, bool enabled)
{
    const char *type = videoFilterType(qtu(module));
    if (!type)
    {
        msg_Err(p_intf, "unknown video filter \"%s\"", qtu(module));
        return;
    }
    char *configChain = config_GetPsz(type);
    config_PutPsz(type, qtu(chainWith(splitChain(configChain), module, enabled)));
    free(configChain);

    // splitters need a new video output, they only apply to the next media
    if (strcmp(type, "video-splitter"))
    {
        for (const auto &vout : THEMIM->getVouts())
        {
            char *chain = var_GetString(vout.get(), type);
            var_SetString(vout.get(), type, qtu(chainWith(splitChain(chain), module, enabled)));
            free(chain);
        }
    }
    emit changed();
}

bool RedesignEffects::audioFilterEnabled(const QString &module) const
{
    char *chain = nullptr;
    if (auto aout = THEMIM->getAout())
        chain = var_GetString(aout.get(), "audio-filter");
    else
        chain = config_GetPsz("audio-filter");
    const bool on = splitChain(chain).contains(module);
    free(chain);
    return on;
}

void RedesignEffects::setAudioFilterEnabled(const QString &module, bool enabled)
{
    if (!module_find(qtu(module)))
    {
        msg_Err(p_intf, "unknown audio filter \"%s\"", qtu(module));
        return;
    }
    char *configChain = config_GetPsz("audio-filter");
    config_PutPsz("audio-filter", qtu(chainWith(splitChain(configChain), module, enabled)));
    free(configChain);
    vlc_player_aout_EnableFilter(p_intf->p_player, qtu(module), enabled);
    emit changed();
}

QVariant RedesignEffects::videoValue(const QString &name) const
{
    auto vout = THEMIM->getVout();
    return readVar(vout ? VLC_OBJECT(vout.get()) : nullptr, qtu(name));
}

void RedesignEffects::setVideoValue(const QString &name, const QVariant &value)
{
    const QByteArray n = name.toUtf8();
    const auto vouts = THEMIM->getVouts();
    if (vouts.isEmpty())
        writeValue(nullptr, n.constData(), value);
    for (const auto &vout : vouts)
        writeValue(VLC_OBJECT(vout.get()), n.constData(), value);
    emit changed();
}

QVariant RedesignEffects::audioValue(const QString &name) const
{
    auto aout = THEMIM->getAout();
    return readVar(aout ? VLC_OBJECT(aout.get()) : nullptr, qtu(name));
}

void RedesignEffects::setAudioValue(const QString &name, const QVariant &value)
{
    auto aout = THEMIM->getAout();
    writeValue(aout ? VLC_OBJECT(aout.get()) : nullptr, qtu(name), value);
    emit changed();
}

bool RedesignEffects::hasAssociatedMedia(const QString &url) const
{
    vlc_player_t *player = THEMIM->getPlayer();
    vlc_player_locker playerLock{player};
    input_item_t *item = vlc_player_GetCurrentMedia(player);
    if (!item) return false;
    const QUrl wanted(url);
    bool found = false;
    vlc_mutex_lock(&item->lock);
    for (int i = 0; i < item->i_slaves; ++i) {
        if (QUrl(qfu(item->pp_slaves[i]->psz_uri)).matches(wanted, QUrl::NormalizePathSegments)) {
            found = true;
            break;
        }
    }
    // Explicit input options can be pending while startup loads native slaves.
    // Do not enqueue the same file again through the per-file restore timer.
    for (int i = 0; !found && i < item->i_options; ++i) {
        QString option = qfu(item->ppsz_options[i]);
        if (option.startsWith(':')) option.remove(0, 1);
        if (option.startsWith(QLatin1String("sub-file=")))
            found = QUrl::fromLocalFile(option.mid(9)).matches(wanted, QUrl::NormalizePathSegments);
        else if (option.startsWith(QLatin1String("input-slave="))) {
            for (const auto &slave : option.mid(12).split('#'))
                if (QUrl(slave).matches(wanted, QUrl::NormalizePathSegments)) { found = true; break; }
        }
    }
    vlc_mutex_unlock(&item->lock);
    return found;
}

bool RedesignEffects::associateSubtitleFile(const QString &url)
{
    return hasAssociatedMedia(url) || THEMIM->associateSubtitleFile(url);
}

bool RedesignEffects::associateAudioFile(const QString &url)
{
    if (hasAssociatedMedia(url)) return true;
    return THEMIM->AddAssociatedMedia(AUDIO_ES, url, true, true, true) == VLC_SUCCESS;
}

void RedesignEffects::enqueueWithSubtitles(const QVariantList &pairs, bool play)
{
    QVector<vlc::playlist::Media> medias;
    for (const QVariant &v : pairs)
    {
        const QVariantMap m = v.toMap();
        const QUrl video(m.value("video").toString());
        const QUrl sub(m.value("subtitle").toString());
        const QUrl audio(m.value("audio").toString());
        QStringList options;
        if (sub.isLocalFile())
            options.append(QStringLiteral(":sub-file=") + QDir::toNativeSeparators(sub.toLocalFile()));
        if (audio.isLocalFile())
            options.append(QStringLiteral(":input-slave=") + audio.toString(QUrl::FullyEncoded));
        medias.append(vlc::playlist::Media(video.toString(QUrl::FullyEncoded), video.fileName(), options));
    }
    if (!medias.isEmpty())
        THEMPL->append(medias, play);
}

QVariantList RedesignEffects::equalizerPresets() const
{
    QVariantList list;
    for (int i = 0; i < NB_PRESETS; i++)
        list.append(QVariantMap{ { "value", QString(preset_list[i]) },
                                 { "text", qfu(vlc_gettext(preset_list_text[i])) } });
    return list;
}

QVariantMap RedesignEffects::applyEqualizerPreset(const QString &preset)
{
    for (int i = 0; i < NB_PRESETS; i++)
    {
        if (preset != QLatin1String(eqz_preset_10b[i].psz_name))
            continue;
        QStringList bands;
        QVariantList values;
        for (int b = 0; b < eqz_preset_10b[i].i_band; b++)
        {
            bands.append(QString::number(eqz_preset_10b[i].f_amp[b], 'f', 1));
            values.append(QString::number(eqz_preset_10b[i].f_amp[b], 'f', 1).toDouble());
        }
        setAudioValue("equalizer-preset", preset);
        setAudioValue("equalizer-preamp", eqz_preset_10b[i].f_preamp);
        setAudioValue("equalizer-bands", bands.join(' '));
        return { { "preamp", static_cast<double>(eqz_preset_10b[i].f_preamp) }, { "bands", values } };
    }
    return {};
}
