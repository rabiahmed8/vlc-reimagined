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
import QtQuick

import VLC.MainInterface

RSettingsPage {
    RSettingsSection { text: qsTr("Buffering") }

    RSettingRow {
        id: preset
        label: qsTr("Buffering")
        info: qsTr("How much media is read ahead before playing. More buffering is smoother on slow networks, less is more responsive.")

        // the classic presets: the same delay for every source
        readonly property var levels: [
            { value: 0, text: qsTr("Custom") },
            { value: 30, text: qsTr("Lowest latency") },
            { value: 100, text: qsTr("Low latency") },
            { value: 1000, text: qsTr("Normal") },
            { value: 3000, text: qsTr("Higher latency") },
            { value: 10000, text: qsTr("Highest latency") }
        ]
        readonly property var caches: ["file-caching", "disc-caching", "network-caching", "live-caching"]

        function current() {
            const v = caches.map(n => Number(RedesignSettings.value(n)))
            if (v.every(x => x === v[2]))
                for (const l of levels)
                    if (l.value === v[2])
                        return l.value
            return 0
        }

        RDropdown {
            id: presetBox
            width: parent.width
            model: preset.levels
            Component.onCompleted: selectValue(preset.current())
            onPicked: (v) => {
                if (v > 0)
                    preset.caches.forEach(n => RedesignSettings.setValue(n, v))
            }
            Connections {
                target: RedesignSettings
                function onValueChanged(name) { if (preset.caches.indexOf(name) >= 0) presetBox.selectValue(preset.current()) }
            }
        }
    }
    ROption { name: "file-caching"; title: qsTr("Local files"); suffix: "ms" }
    ROption { name: "disc-caching"; title: qsTr("Discs"); suffix: "ms" }
    ROption { name: "network-caching"; title: qsTr("Network streams"); suffix: "ms" }
    ROption { name: "live-caching"; title: qsTr("Live capture"); suffix: "ms" }

    RSettingsSection { text: qsTr("Proxy") }

    ROption { name: "http-proxy"; title: qsTr("HTTP proxy") }
    ROption { name: "http-proxy-pwd"; title: qsTr("HTTP proxy password") }

    RSettingsSection { text: qsTr("Security") }

    ROption { name: "gnutls-system-trust"; title: qsTr("Verify certificates against the system trust store") }
    ROption { name: "gnutls-priorities"; title: qsTr("Cipher preference") }

    RSettingsSection { text: qsTr("Connections") }

    ROption { name: "ipv4-timeout"; title: qsTr("Connection timeout (ms)") }
    ROption { name: "http-user-agent"; title: qsTr("HTTP user agent") }

    // SUBCAT_INPUT_ACCESS, SUBCAT_ADVANCED_NETWORK
    RAdvancedOptions { subcats: [402, 603] }
}
