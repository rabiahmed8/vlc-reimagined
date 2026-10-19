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
    RSettingsSection { text: qsTr("Opening Files") }

    ROption { id: oneInstance; name: "one-instance"; title: qsTr("Only allow one VLC window") }
    ROption {
        name: "one-instance-when-started-from-file"
        title: qsTr("Apply to files opened from the file manager")
        enabled: oneInstance.value === true
    }
    ROption {
        name: "playlist-enqueue"
        title: qsTr("Add to the playlist instead of replacing it")
        enabled: oneInstance.value === true
    }
    ROption { name: "recursive"; title: qsTr("When opening a folder") }
    ROption { name: "show-hiddenfiles"; title: qsTr("Show hidden files") }
    ROption { name: "ignore-filetypes"; title: qsTr("Ignore files with these extensions") }
    ROption { name: "auto-preparse"; title: qsTr("Read file information when they are added") }

    RSettingsSection { text: qsTr("Metadata & Artwork") }

    ROption { name: "metadata-network-access"; title: qsTr("Fetch titles and artwork from the internet") }
    ROption { name: "media-library"; title: qsTr("Use the media library") }
    ROption { name: "playlist-tree"; title: qsTr("Show playlists as a tree") }

    // SUBCAT_PLAYLIST_EXPORT
    RAdvancedOptions { subcats: [703] }
}
