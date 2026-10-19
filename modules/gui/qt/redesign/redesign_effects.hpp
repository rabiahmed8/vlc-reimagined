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
#ifndef REDESIGN_EFFECTS_HPP
#define REDESIGN_EFFECTS_HPP

#include <QObject>
#include <QStringList>
#include <QVariant>

#include "qt.hpp"

/**
 * Live audio/video effects for the redesigned effect panels, like the classic
 * "Effects and Filters" dialog: a filter is switched on the running video/audio
 * output and its parameters are set on it, and everything is also written to the
 * configuration so the effect stays for the next media.
 *
 * Filters are module names ("adjust", "sharpen", "equalizer", "compressor"...),
 * parameters their option names ("contrast", "compressor-ratio"...).
 */
class RedesignEffects : public QObject
{
    Q_OBJECT

public:
    explicit RedesignEffects(qt_intf_t *intf, QObject *parent = nullptr);

    Q_INVOKABLE bool videoFilterEnabled(const QString &module) const;
    Q_INVOKABLE void setVideoFilterEnabled(const QString &module, bool enabled);
    Q_INVOKABLE bool audioFilterEnabled(const QString &module) const;
    Q_INVOKABLE void setAudioFilterEnabled(const QString &module, bool enabled);

    /// value of a filter parameter: from the running output when it has it, else the configuration
    Q_INVOKABLE QVariant videoValue(const QString &name) const;
    Q_INVOKABLE void setVideoValue(const QString &name, const QVariant &value);
    Q_INVOKABLE QVariant audioValue(const QString &name) const;
    Q_INVOKABLE void setAudioValue(const QString &name, const QVariant &value);

    /// equalizer presets: [{ value: "flat", text: "Flat" }, ...]
    Q_INVOKABLE QVariantList equalizerPresets() const;
    /// applies a preset: bands and preamp of the preset, returns { preamp, bands: [10 values] }
    Q_INVOKABLE QVariantMap applyEqualizerPreset(const QString &preset);

    /// enqueues videos with their subtitle file: [{ video: url, subtitle: url or "" }]
    Q_INVOKABLE bool hasAssociatedMedia(const QString &url) const;
    Q_INVOKABLE bool associateSubtitleFile(const QString &url);
    Q_INVOKABLE bool associateAudioFile(const QString &url);
    Q_INVOKABLE void enqueueWithSubtitles(const QVariantList &pairs, bool play);

signals:
    void changed();

private:
    qt_intf_t *p_intf;
};

#endif
