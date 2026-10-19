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
    RSettingsSection { text: qsTr("Keyboard Shortcuts") }

    RSettingRow {
        label: qsTr("Shortcuts")
        RButton {
            width: parent.width
            text: qsTr("Edit Keyboard Shortcuts")
            onClicked: RWindows.shortcutsRequested()
        }
    }
    RSettingRow {
        label: qsTr("Reset all shortcuts")
        RButton {
            id: resetKeys
            width: parent.width
            text: qsTr("Reset")
            onClicked: {
                RedesignSettings.resetHotkeys()
                text = qsTr("Shortcuts restored")
            }
        }
    }

    RSettingsSection { text: qsTr("Skip Amounts") }

    ROption { name: "extrashort-jump-size"; title: qsTr("Very short skip"); suffix: "s" }
    ROption { name: "short-jump-size"; title: qsTr("Short skip"); suffix: "s" }
    ROption { name: "medium-jump-size"; title: qsTr("Medium skip"); suffix: "s" }
    ROption { name: "long-jump-size"; title: qsTr("Long skip"); suffix: "s" }

    RSettingsSection { text: qsTr("Mouse") }

    ROption { name: "hotkeys-y-wheel-mode"; title: qsTr("Scroll wheel") }
    ROption { name: "hotkeys-x-wheel-mode"; title: qsTr("Horizontal scroll") }
    ROption { name: "hotkeys-mousewheel-mode"; title: qsTr("Mouse wheel behavior") }
    ROption { name: "qt-disable-volume-keys"; title: qsTr("Ignore the volume keys of the keyboard") }

    RSettingsSection { text: qsTr("Remotes") }

    RModuleSwitch {
        module: "http"
        label: qsTr("Web remote control")
        info: qsTr("Lets a browser or a phone app control VLC through the web interface.")
    }
    ROption { name: "http-host"; title: qsTr("Address") }
    ROption { name: "http-port"; title: qsTr("Port") }
    ROption { name: "http-password"; title: qsTr("Password") }

    // SUBCAT_INTERFACE_CONTROL
    RAdvancedOptions { subcats: [103] }
}
