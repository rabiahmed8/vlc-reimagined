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

RSettingsPage {
    RSettingsSection { text: qsTr("Skin") }

    ROption { name: "intf"; title: qsTr("Main interface") }
    ROption { name: "skins2-last"; title: qsTr("Skin file") }

    RSettingsSection { text: qsTr("Window") }

    ROption { name: "embedded-video"; title: qsTr("Play video inside main window") }
    ROption { name: "qt-video-autoresize"; title: qsTr("Resize window to fit video") }
    ROption { name: "video-on-top"; title: qsTr("Keep window above other windows") }
    ROption { name: "qt-titlebar"; title: qsTr("Show window decorations") }
    ROption { name: "qt-name-in-title"; title: qsTr("Show the file name in the title bar") }
    ROption {
        name: "qt-fullscreen-screennumber"
        title: qsTr("Open fullscreen on")
        choices: [{ value: -1, text: qsTr("Current screen") }].concat(
                     Array.from(Qt.application.screens, (s, i) => ({ value: i, text: (i + 1) + ": " + s.name })))
    }
    ROption { name: "qt-auto-raise"; title: qsTr("Raise the window when playback starts") }

    RSettingsSection { text: qsTr("Playback Controls") }

    ROption { name: "qt-minimal-view"; title: qsTr("Start in compact mode") }
    ROption { name: "qt-pin-controls"; title: qsTr("Keep the controls visible") }
    ROption {
        name: "mouse-hide-timeout"
        title: qsTr("Hide after")
        kind: "slider"
        sliderStep: 500
        sliderTicks: 20
        sliderLabels: [{ value: 0, text: "0 s" }, { value: 5000, text: "5 s" }, { value: 10000, text: "10 s" }]
        minimum: 0          // the range of the core option is too wide for a slider
        maximum: 10000
    }
    ROption { name: "qt-fs-controller"; title: qsTr("Show controls in fullscreen") }

    RSettingsSection { text: qsTr("Notifications and System Tray") }

    ROption { name: "qt-system-tray"; title: qsTr("Show an icon in the system tray") }
    ROption { name: "qt-notification"; title: qsTr("Notify when the track changes") }
    ROption { name: "qt-start-minimized"; title: qsTr("Start minimized to the tray") }
    ROption { name: "qt-close-to-system-tray"; title: qsTr("Closing the window keeps VLC in the tray") }
    ROption { name: "qt-pause-minimized"; title: qsTr("Pause when the window is minimized") }

    RSettingsSection { text: qsTr("Look") }

    ROption { name: "qt-bgcone"; title: qsTr("Show the cone when nothing plays") }
    ROption { name: "qt-icon-change"; title: qsTr("Seasonal cone") }
    ROption { name: "qt-backdrop-blur"; title: qsTr("Blur behind panels") }
    ROption { name: "qt-smooth-scrolling"; title: qsTr("Smooth scrolling") }
    ROption { name: "qt-pip-mode"; title: qsTr("Picture in picture") }

    // SUBCAT_INTERFACE_MAIN
    RAdvancedOptions { subcats: [102] }
}
