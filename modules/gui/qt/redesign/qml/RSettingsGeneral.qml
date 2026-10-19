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
import VLC.Dialogs

RSettingsPage {
    id: page

    RSettingsSection { text: qsTr("Appearance") }

    ROption { name: "language"; title: qsTr("Interface language") }

    RSettingRow {
        width: parent.width
        label: qsTr("Theme")
        RSegmented {
            width: parent.width
            model: [{ value: "dark", text: qsTr("Dark") },
                    { value: "light", text: qsTr("Light") },
                    { value: "system", text: qsTr("System") }]
            currentValue: Theme.mode
            onPicked: (v) => Theme.setMode(v)
        }
    }

    RSettingRow {
        width: parent.width
        label: qsTr("Accent color")
        RAccentPicker {
            width: parent.width
            onPicked: (c) => Theme.setAccent(c)
        }
    }

    ROption {
        name: "qt-interface-scale"
        title: qsTr("Interface scale")
        choices: [{ value: -1, text: qsTr("Automatic") }, { value: 0.75, text: "75%" }, { value: 1, text: "100%" },
                  { value: 1.25, text: "125%" }, { value: 1.5, text: "150%" }, { value: 1.75, text: "175%" },
                  { value: 2, text: "200%" }]
    }

    RSettingsSection { text: qsTr("Startup") }

    ROption { name: "qt-error-dialogs"; title: qsTr("Show confirmation and error dialogs") }
    ROption { name: "qt-updates-notif"; title: qsTr("Check for updates automatically") }
    ROption { name: "qt-privacy-ask"; title: qsTr("Ask for network access on first start") }

    RSettingsSection { text: qsTr("Diagnostics") }

    ROption { name: "qt-verbose"; title: qsTr("Developer mode") }
    ROption { name: "file-logging"; title: qsTr("Save a log") }
    ROption { name: "logfile"; title: qsTr("Log file") }
    ROption {
        name: "log-verbose"
        title: qsTr("Log details")
        choices: [{ value: -1, text: qsTr("Same as the console") },
                  { value: 0, text: qsTr("Errors only") },
                  { value: 1, text: qsTr("Errors and warnings") },
                  { value: 2, text: qsTr("Everything (debug)") }]
    }

    RSettingsSection { text: qsTr("All settings") }

    RSettingRow {
        width: parent.width
        label: qsTr("Classic preferences window")
        info: qsTr("Opens the preferences window of the classic interface, with every option of every module.")
        RButton {
            width: parent.width
            text: qsTr("Open")
            onClicked: DialogsProvider.classicPrefsDialog()
        }
    }

    RSettingRow {
        width: parent.width
        label: qsTr("Reset all settings")
        info: qsTr("Restores every VLC option to its default value.")
        RButton {
            id: resetButton
            property bool armed: false
            width: parent.width
            text: armed ? qsTr("Click again to reset everything") : qsTr("Reset")
            onClicked: {
                if (armed) {
                    RedesignSettings.resetAll()
                    armed = false
                } else {
                    armed = true
                    disarm.restart()
                }
            }
            Timer { id: disarm; interval: 4000; onTriggered: resetButton.armed = false }
        }
    }

    // SUBCAT_INTERFACE_GENERAL, SUBCAT_ADVANCED_MISC
    RAdvancedOptions { subcats: [101, 602] }
}
