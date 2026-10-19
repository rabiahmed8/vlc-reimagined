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

#include "redesign_settings.hpp"

#include <QColor>
#include <QColorDialog>
#include <QDir>
#include <QFileDialog>
#include <QFileInfo>
#include <QFile>
#include <QSaveFile>
#include <QRegularExpression>
#include <QUrl>
#include <QFontDialog>
#include <QHash>
#include <QKeyEvent>
#include <QSet>

#include <algorithm>

#include "util/vlchotkeyconverter.hpp"

#include <vlc_actions.h>
#include <vlc_configuration.h>
#include <vlc_config_cat.h>
#include <vlc_modules.h>
#include <vlc_plugin.h>

namespace {

QString typeName(int type)
{
    switch (type)
    {
        case CONFIG_ITEM_BOOL:            return QStringLiteral("bool");
        case CONFIG_ITEM_INTEGER:         return QStringLiteral("int");
        case CONFIG_ITEM_RGB:             return QStringLiteral("color");
        case CONFIG_ITEM_FLOAT:           return QStringLiteral("float");
        case CONFIG_ITEM_PASSWORD:        return QStringLiteral("password");
        case CONFIG_ITEM_LOADFILE:        return QStringLiteral("file");
        case CONFIG_ITEM_SAVEFILE:        return QStringLiteral("savefile");
        case CONFIG_ITEM_DIRECTORY:       return QStringLiteral("directory");
        case CONFIG_ITEM_FONT:            return QStringLiteral("font");
        case CONFIG_ITEM_MODULE:
        case CONFIG_ITEM_MODULE_CAT:      return QStringLiteral("module");
        case CONFIG_ITEM_MODULE_LIST:
        case CONFIG_ITEM_MODULE_LIST_CAT: return QStringLiteral("modulelist");
        case CONFIG_ITEM_KEY:             return QStringLiteral("key");
        default:                          return QStringLiteral("string");
    }
}

QString tr8(const char *s)
{
    return (s && *s) ? qfu(vlc_gettext(s)) : QString();
}

QVariant currentValue(const char *name, int type)
{
    switch (CONFIG_CLASS(type))
    {
        case CONFIG_ITEM_BOOL:
            return QVariant::fromValue(config_GetInt(name) != 0);
        case CONFIG_ITEM_INTEGER:
            return QVariant::fromValue(static_cast<qlonglong>(config_GetInt(name)));
        case CONFIG_ITEM_FLOAT:
            return QVariant::fromValue(static_cast<double>(config_GetFloat(name)));
        case CONFIG_ITEM_STRING:
        {
            char *s = config_GetPsz(name);
            QString v = qfu(s);
            free(s);
            return v;
        }
        default:
            return {};
    }
}

QVariantList choices(const char *name, int type)
{
    QVariantList list;
    if (CONFIG_CLASS(type) == CONFIG_ITEM_INTEGER && type != CONFIG_ITEM_RGB)
    {
        int64_t *values;
        char **texts;
        ssize_t count = config_GetIntChoices(name, &values, &texts);
        for (ssize_t i = 0; i < count; i++)
        {
            list.append(QVariantMap{ { "value", static_cast<qlonglong>(values[i]) },
                                     { "text", qfu(texts[i]) } });
            free(texts[i]);
        }
        if (count >= 0)
        {
            free(values);
            free(texts);
        }
    }
    else if (CONFIG_CLASS(type) == CONFIG_ITEM_STRING && type != CONFIG_ITEM_KEY)
    {
        char **values, **texts;
        ssize_t count = config_GetPszChoices(name, &values, &texts);
        for (ssize_t i = 0; i < count; i++)
        {
            const QString text = qfu(texts[i]);
            const QString value = qfu(values[i]);
            list.append(QVariantMap{ { "value", value },
                                     { "text", text.isEmpty() ? value : text } });
            free(values[i]);
            free(texts[i]);
        }
        if (count >= 0)
        {
            free(values);
            free(texts);
        }
    }
    return list;
}

bool visibleType(int type)
{
    return CONFIG_ITEM(type) && type != CONFIG_ITEM_KEY;
}

} // namespace

RedesignSettings::RedesignSettings(qt_intf_t *intf, QObject *parent)
    : QObject(parent), m_intf(intf)
{
}

QVariantMap RedesignSettings::option(const QString &name) const
{
    const QByteArray n = name.toUtf8();
    const module_config_t *cfg = config_FindConfig(n.constData());
    if (!cfg)
        return { { "name", name }, { "exists", false } };

    QVariantMap m;
    m["name"] = name;
    m["exists"] = true;
    m["type"] = typeName(cfg->i_type);
    m["text"] = tr8(cfg->psz_text);
    m["longtext"] = tr8(cfg->psz_longtext);
    m["value"] = currentValue(cfg->psz_name, cfg->i_type);

    switch (CONFIG_CLASS(cfg->i_type))
    {
        case CONFIG_ITEM_BOOL:
            m["defaultValue"] = cfg->orig.i != 0;
            break;
        case CONFIG_ITEM_INTEGER:
            m["defaultValue"] = static_cast<qlonglong>(cfg->orig.i);
            m["min"] = static_cast<qlonglong>(cfg->min.i);
            m["max"] = static_cast<qlonglong>(cfg->max.i);
            break;
        case CONFIG_ITEM_FLOAT:
            m["defaultValue"] = static_cast<double>(cfg->orig.f);
            m["min"] = static_cast<double>(cfg->min.f);
            m["max"] = static_cast<double>(cfg->max.f);
            break;
        case CONFIG_ITEM_STRING:
            m["defaultValue"] = qfu(cfg->orig.psz);
            break;
    }
    m["choices"] = choices(cfg->psz_name, cfg->i_type);
    return m;
}

QVariant RedesignSettings::value(const QString &name) const
{
    const QByteArray n = name.toUtf8();
    const module_config_t *cfg = config_FindConfig(n.constData());
    if (!cfg)
        return {};
    return currentValue(cfg->psz_name, cfg->i_type);
}

QString RedesignSettings::inheritedString(const QString &name) const
{
    char *s = var_InheritString(m_intf, qtu(name));
    const QString v = qfu(s);
    free(s);
    return v;
}

bool RedesignSettings::setValue(const QString &name, const QVariant &value)
{
    const QByteArray n = name.toUtf8();
    const module_config_t *cfg = config_FindConfig(n.constData());
    if (!cfg)
        return false;

    switch (CONFIG_CLASS(cfg->i_type))
    {
        case CONFIG_ITEM_BOOL:
            config_PutInt(cfg->psz_name, value.toBool() ? 1 : 0);
            break;
        case CONFIG_ITEM_INTEGER:
            if (cfg->i_type == CONFIG_ITEM_RGB && value.typeId() != QMetaType::LongLong
                && value.typeId() != QMetaType::Int)
                config_PutInt(cfg->psz_name, QColor(value.toString()).rgb() & 0xFFFFFF);
            else
                config_PutInt(cfg->psz_name, value.toLongLong());
            break;
        case CONFIG_ITEM_FLOAT:
            config_PutFloat(cfg->psz_name, value.toFloat());
            break;
        case CONFIG_ITEM_STRING:
            config_PutPsz(cfg->psz_name, qtu(value.toString()));
            break;
        default:
            return false;
    }
    emit valueChanged(name);
    return true;
}

void RedesignSettings::resetValue(const QString &name)
{
    const QByteArray n = name.toUtf8();
    const module_config_t *cfg = config_FindConfig(n.constData());
    if (!cfg)
        return;

    switch (CONFIG_CLASS(cfg->i_type))
    {
        case CONFIG_ITEM_BOOL:
        case CONFIG_ITEM_INTEGER:
            config_PutInt(cfg->psz_name, cfg->orig.i);
            break;
        case CONFIG_ITEM_FLOAT:
            config_PutFloat(cfg->psz_name, cfg->orig.f);
            break;
        case CONFIG_ITEM_STRING:
            config_PutPsz(cfg->psz_name, cfg->orig.psz);
            break;
        default:
            return;
    }
    emit valueChanged(name);
}

QVariantList RedesignSettings::advancedOptions(const QVariantList &subcats,
                                               const QStringList &exclude) const
{
    QSet<int> wanted;
    for (const QVariant &v : subcats)
        wanted.insert(v.toInt());
    const QSet<QString> skip(exclude.cbegin(), exclude.cend());

    QVariantList core;     // core options, one group per subcategory
    QVariantList plugins;  // one group per module

    size_t count;
    module_t **list = module_list_get(&count);
    for (size_t i = 0; i < count; i++)
    {
        module_t *mod = list[i];
        unsigned confsize;
        module_config_t *config = module_config_get(mod, &confsize);
        const bool isCore = module_is_main(mod);

        int subcat = SUBCAT_UNKNOWN;
        QVariantMap group;
        QStringList names;
        auto flush = [&]() {
            if (names.isEmpty())
                return;
            group["options"] = names;
            (isCore ? core : plugins).append(group);
            names.clear();
        };

        for (unsigned j = 0; j < confsize; j++)
        {
            const module_config_t *item = config + j;
            if (item->i_type == CONFIG_SUBCATEGORY)
            {
                if (isCore)
                    flush();
                subcat = item->value.i;
                if (isCore)
                {
                    // vlc_config_subcat_GetName() would pass a NULL name to vlc_gettext()
                    const config_subcategory_t *sc =
                        vlc_config_subcat_Find(static_cast<vlc_config_subcat>(subcat));
                    group["title"] = (sc && sc->name) ? tr8(sc->name) : qtr("Core");
                }
                continue;
            }
            if (!wanted.contains(subcat) || !visibleType(item->i_type))
                continue;
            const QString name = qfu(item->psz_name);
            if (skip.contains(name))
                continue;
            names.append(name);
        }
        if (!isCore)
            group["title"] = qfu(module_GetLongName(mod));
        flush();
        module_config_free(config);
    }
    module_list_free(list);

    std::sort(plugins.begin(), plugins.end(), [](const QVariant &a, const QVariant &b) {
        return a.toMap()["title"].toString().localeAwareCompare(b.toMap()["title"].toString()) < 0;
    });
    return core + plugins;
}

QVariantList RedesignSettings::search(const QString &text, int max) const
{
    QVariantList result;
    const QString needle = text.trimmed();
    if (needle.isEmpty())
        return result;

    size_t count;
    module_t **list = module_list_get(&count);
    for (size_t i = 0; i < count && result.size() < max; i++)
    {
        unsigned confsize;
        module_config_t *config = module_config_get(list[i], &confsize);
        int subcat = SUBCAT_UNKNOWN;
        for (unsigned j = 0; j < confsize && result.size() < max; j++)
        {
            const module_config_t *item = config + j;
            if (item->i_type == CONFIG_SUBCATEGORY)
            {
                subcat = item->value.i;
                continue;
            }
            if (subcat == SUBCAT_UNKNOWN || subcat == SUBCAT_HIDDEN || !visibleType(item->i_type))
                continue;
            const QString label = tr8(item->psz_text);
            if (label.contains(needle, Qt::CaseInsensitive)
                || qfu(item->psz_name).contains(needle, Qt::CaseInsensitive)
                || tr8(item->psz_longtext).contains(needle, Qt::CaseInsensitive))
            {
                result.append(QVariantMap{ { "name", qfu(item->psz_name) },
                                           { "text", label },
                                           { "subcat", subcat } });
            }
        }
        module_config_free(config);
    }
    module_list_free(list);
    return result;
}

void RedesignSettings::save()
{
    config_SaveConfigFile(m_intf);
}

void RedesignSettings::resetAll()
{
    config_ResetAll();
    config_SaveConfigFile(m_intf);
    emit allValuesChanged();
}

void RedesignSettings::resetHotkeys()
{
    module_t *core = module_get_main();
    unsigned confsize;
    module_config_t *config = module_config_get(core, &confsize);
    for (unsigned i = 0; i < confsize; i++)
    {
        const module_config_t *item = config + i;
        if (item->i_type == CONFIG_ITEM_KEY)
            config_PutPsz(item->psz_name, item->orig.psz);
    }
    module_config_free(config);
    config_SaveConfigFile(m_intf);
    emit allValuesChanged();
}

QVariantList RedesignSettings::hotkeys() const
{
    QVariantList list;
    QHash<QString, QString> globals;

    module_t *core = module_get_main();
    unsigned confsize;
    module_config_t *config = module_config_get(core, &confsize);
    for (unsigned i = 0; i < confsize; i++)
    {
        const module_config_t *item = config + i;
        if (item->i_type != CONFIG_ITEM_KEY || !item->psz_text || !*item->psz_text)
            continue;
        const QString name = qfu(item->psz_name);
        char *value = config_GetPsz(item->psz_name);
        const QString key = qfu(value);
        free(value);
        if (name.startsWith("global-"))
        {
            globals.insert(name.mid(7), key);
            continue;
        }
        list.append(QVariantMap{ { "name", name },
                                 { "text", tr8(item->psz_text) },
                                 { "key", key },
                                 { "keyText", keyDisplayText(key) } });
    }
    module_config_free(config);

    for (QVariant &v : list)
    {
        QVariantMap m = v.toMap();
        const QString g = globals.value(m["name"].toString());
        m["globalKey"] = g;
        m["globalKeyText"] = keyDisplayText(g);
        v = m;
    }
    return list;
}

QString RedesignSettings::keyFromEvent(int qtKey, int qtModifiers, const QString &text) const
{
    QKeyEvent event(QEvent::KeyPress, qtKey, Qt::KeyboardModifiers(qtModifiers), text);
    const int code = qtEventToVLCKey(&event);
    if (code == KEY_UNSET)
        return {};
    char *s = vlc_keycode2str(code, false);
    const QString key = qfu(s);
    free(s);
    return key;
}

QString RedesignSettings::keyDisplayText(const QString &key) const
{
    if (key.isEmpty() || key == QLatin1String("Unset"))
        return {};
    return VLCKeyToString(vlc_str2keycode(qtu(key)), true);
}

QString RedesignSettings::browseFile(const QString &current, bool forSaving) const
{
    const QString path = forSaving
        ? QFileDialog::getSaveFileName(nullptr, qtr("Select file"), current)
        : QFileDialog::getOpenFileName(nullptr, qtr("Select file"), current);
    return QDir::toNativeSeparators(path);
}

QString RedesignSettings::browseDirectory(const QString &current) const
{
    return QDir::toNativeSeparators(
        QFileDialog::getExistingDirectory(nullptr, qtr("Select directory"), current));
}

QStringList RedesignSettings::browseFiles(const QString &title) const
{
    QStringList urls;
    for (const QUrl &u : QFileDialog::getOpenFileUrls(nullptr, title))
        urls.append(u.toString(QUrl::FullyEncoded));
    return urls;
}

QVariantList RedesignSettings::listFiles(const QString &directory, const QStringList &extensions) const
{
    const QUrl url(directory);
    const QString path = url.isLocalFile() ? url.toLocalFile() : directory;
    QStringList patterns;
    for (const QString &e : extensions)
        patterns.append(QStringLiteral("*.") + e);

    QVariantList list;
    QDir dir(path);
    const QFileInfoList files = dir.entryInfoList(patterns, QDir::Files | QDir::Readable,
                                                  QDir::Name | QDir::IgnoreCase);
    for (const QFileInfo &f : files)
        list.append(QVariantMap{ { "url", QUrl::fromLocalFile(f.absoluteFilePath()).toString(QUrl::FullyEncoded) },
                                 { "name", f.fileName() } });
    return list;
}

QString RedesignSettings::directoryOf(const QString &url) const
{
    const QUrl u(url);
    if (!u.isLocalFile())
        return {};
    const QFileInfo file(u.toLocalFile());
    return QUrl::fromLocalFile(file.isDir() ? file.absoluteFilePath() : file.absolutePath()).toString(QUrl::FullyEncoded);
}

QString RedesignSettings::pickColor(const QString &current) const
{
    const QColor c = QColorDialog::getColor(QColor(current), nullptr, qtr("Select color"));
    return c.isValid() ? c.name(QColor::HexRgb).toUpper() : QString();
}

QString RedesignSettings::pickFont(const QString &current) const
{
    bool ok = false;
    const QFont f = QFontDialog::getFont(&ok, QFont(current), nullptr, qtr("Select font"));
    return ok ? f.family() : QString();
}

bool RedesignSettings::moduleAvailable(const QString &name) const
{
    return module_exists(qtu(name));
}

QVariantMap RedesignSettings::snapshot() const
{
    QVariantMap result;
    size_t count;
    module_t **list = module_list_get(&count);
    for (size_t i = 0; i < count; ++i)
    {
        unsigned size;
        module_config_t *config = module_config_get(list[i], &size);
        for (unsigned j = 0; j < size; ++j)
        {
            const auto &item = config[j];
            if (!CONFIG_ITEM(item.i_type) || item.i_type == CONFIG_ITEM_PASSWORD
                || !item.psz_name)
                continue;
            result[qfu(item.psz_name)] = currentValue(item.psz_name, item.i_type);
        }
        module_config_free(config);
    }
    module_list_free(list);
    return result;
}

void RedesignSettings::restore(const QVariantMap &values)
{
    for (auto it = values.cbegin(); it != values.cend(); ++it)
        if (value(it.key()) != it.value())
            setValue(it.key(), it.value());
    save();
    emit allValuesChanged();
}

QVariantList RedesignSettings::subtitleCues(const QString &url) const
{
    const QUrl source(url);
    if (!source.isLocalFile())
        return {};
    QFile file(source.toLocalFile());
    if (!file.open(QIODevice::ReadOnly) || file.size() > 8 * 1024 * 1024)
        return {};
    QString text = QString::fromUtf8(file.readAll());
    text.replace(QStringLiteral("\r"), QString());
    // SRT and WebVTT timestamps, with optional cue identifiers/settings.
    const QRegularExpression stamp(QStringLiteral(
        "(?:(\\d+):)?(\\d{2}):(\\d{2})[,.](\\d{3})"));
    QVariantList result;
    const auto blocks = text.split(QStringLiteral("\n\n"), Qt::SkipEmptyParts);
    for (const auto &block : blocks)
    {
        const auto lines = block.split('\n');
        for (int i = 0; i < lines.size(); ++i)
        {
            if (!lines[i].contains(QStringLiteral("-->")))
                continue;
            auto matches = stamp.globalMatch(lines[i]);
            if (!matches.hasNext()) break;
            const auto start = matches.next();
            if (!matches.hasNext()) break;
            const auto end = matches.next();
            auto ms = [](const QRegularExpressionMatch &m) {
                return ((m.captured(1).toLongLong() * 60 + m.captured(2).toInt()) * 60
                        + m.captured(3).toInt()) * 1000 + m.captured(4).toInt();
            };
            if (ms(end) <= ms(start)) break;
            result.append(QVariantMap{{"start", ms(start)}, {"end", ms(end)},
                                      {"text", lines.mid(i + 1).join('\n')}});
            break;
        }
    }
    return result;
}

bool RedesignSettings::writePlaylist(const QString &path, const QStringList &urls) const
{
    QSaveFile file(path);
    if (!file.open(QIODevice::WriteOnly)) return false;
    QByteArray data("#EXTM3U\n");
    for (const auto &url : urls) {
        if (url.contains('\n') || url.contains('\r')) return false;
        data += QUrl(url).toEncoded() + '\n';
    }
    return file.write(data) == data.size() && file.commit();
}
