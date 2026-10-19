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
    RSettingsSection { text: qsTr("History") }

    ROption { name: "save-recentplay"; title: qsTr("Save recently played items") }
    ROption { name: "restore-playback-pos"; title: qsTr("Remember the playback position") }
    ROption { name: "restore-playback-states"; title: qsTr("Remember speed, tracks and delays of each media") }
    ROption { name: "qt-recentplay-filter"; title: qsTr("Never remember items matching") }

    RSettingRow {
        label: qsTr("Clear history now")
        info: qsTr("Removes the list of recently played media.")
        visible: MainCtx.mediaLibraryAvailable
        Loader {
            width: parent.width
            active: MainCtx.mediaLibraryAvailable
            source: "RClearHistoryButton.qml"
        }
    }

    RSettingsSection { text: qsTr("Network") }

    ROption { name: "metadata-network-access"; title: qsTr("Fetch titles and cover art from the internet") }
    ROption { name: "qt-privacy-ask"; title: qsTr("Ask before going online on first start") }
    ROption { name: "qt-updates-notif"; title: qsTr("Check for updates") }

    RSettingsSection { text: qsTr("Last.fm") }

    RModuleSwitch {
        module: "audioscrobbler"
        label: qsTr("Submit played tracks to last.fm")
        info: qsTr("Submits the songs you play to your last.fm profile.")
    }
    ROption { name: "lastfm-username"; title: qsTr("Last.fm username") }
    ROption { name: "lastfm-password"; title: qsTr("Last.fm password") }
    ROption { name: "scrobbler-url"; title: qsTr("Last.fm submission URL") }
}
