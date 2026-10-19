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
#ifndef REDESIGN_SETTINGS_HPP
#define REDESIGN_SETTINGS_HPP

#include <QObject>
#include <QVariant>
#include <QStringList>

#include "qt.hpp"

/**
 * Access to the VLC configuration for the redesigned settings window.
 *
 * Options are addressed by their VLC name ("fullscreen", "qt-max-volume"...).
 * option() describes one option so that QML can pick a control for it:
 *   name, exists, type (bool, int, float, string, color, password, file,
 *   savefile, directory, font, module, modulelist), text, longtext, value,
 *   defaultValue, min, max, choices: [{ value, text }]
 *
 * Changes are written to the configuration immediately (config_Put*) and
 * saved to vlcrc by save(), which the window calls when it closes.
 */
class RedesignSettings : public QObject
{
    Q_OBJECT

public:
    explicit RedesignSettings(qt_intf_t *intf, QObject *parent = nullptr);

    Q_INVOKABLE QVariantMap option(const QString &name) const;
    Q_INVOKABLE QVariant value(const QString &name) const;
    /// value seen by the interface: command line first, then the configuration
    Q_INVOKABLE QString inheritedString(const QString &name) const;
    Q_INVOKABLE bool setValue(const QString &name, const QVariant &value);
    Q_INVOKABLE void resetValue(const QString &name);

    /// options of the given subcategories (vlc_config_subcat values) that are not
    /// in exclude, grouped by module: [{ title, options: [name, ...] }, ...]
    Q_INVOKABLE QVariantList advancedOptions(const QVariantList &subcats,
                                             const QStringList &exclude) const;

    /// options whose name, label or description contain text: [{ name, text, subcat }]
    Q_INVOKABLE QVariantList search(const QString &text, int max = 50) const;

    Q_INVOKABLE bool writePlaylist(const QString &path, const QStringList &urls) const;
    Q_INVOKABLE bool moduleAvailable(const QString &name) const;
    Q_INVOKABLE QVariantMap snapshot() const;
    Q_INVOKABLE void restore(const QVariantMap &values);
    Q_INVOKABLE QVariantList subtitleCues(const QString &url) const;
    Q_INVOKABLE void save();
    Q_INVOKABLE void resetAll();
    /// restores the default of every hotkey option ("key-*", "global-key-*")
    Q_INVOKABLE void resetHotkeys();

    /// every hotkey action of the core:
    /// [{ name ("key-play-pause"), text, key, keyText, globalKey, globalKeyText }]
    /// key/globalKey are the config strings ("Ctrl+o"), *Text the localized display
    Q_INVOKABLE QVariantList hotkeys() const;
    /// config string of a key press seen by QML (Keys.onPressed), "" if unusable
    Q_INVOKABLE QString keyFromEvent(int qtKey, int qtModifiers, const QString &text) const;
    Q_INVOKABLE QString keyDisplayText(const QString &key) const;

    /// native pickers (QtQuick.Dialogs is not part of the contribs);
    /// they return an empty string when cancelled
    Q_INVOKABLE QString browseFile(const QString &current, bool forSaving = false) const;
    Q_INVOKABLE QString browseDirectory(const QString &current) const;
    /// several files, as URLs ("file:///...")
    Q_INVOKABLE QStringList browseFiles(const QString &title) const;
    /// files of a directory (by URL or path) whose extension is in extensions,
    /// sorted by name: [{ url, name }]
    Q_INVOKABLE QVariantList listFiles(const QString &directory, const QStringList &extensions) const;
    /// directory of a media URL, as a URL
    Q_INVOKABLE QString directoryOf(const QString &url) const;
    Q_INVOKABLE QString pickColor(const QString &current) const;
    Q_INVOKABLE QString pickFont(const QString &current) const;

signals:
    void valueChanged(const QString &name);
    void allValuesChanged();

private:
    qt_intf_t *m_intf;
};

#endif
