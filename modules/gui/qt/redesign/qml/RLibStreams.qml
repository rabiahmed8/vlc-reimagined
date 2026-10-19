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
import VLC.MediaLibrary

Column {
    id: root
    property var library
    width: parent ? parent.width : Theme.dp(600)
    spacing: Theme.dp(12)
    RText { text: qsTr("Network streams"); font.pixelSize: Theme.dp(20) }
    RButton { text: qsTr("Add a network stream"); onClicked: RWindows.networkStreamRequested() }
    MLUrlModel { id: streams; ml: MediaLib; searchPattern: root.library ? root.library.searchPattern : "" }
    RMediaView {
        width: parent.width
        height: Math.ceil(count / columns) * cellHeight
        interactive: false; grid: root.library ? root.library.grid : false
        square: true; fallbackIcon: "streaming"; model: streams
        onActivated: (index, item) => streams.addAndPlay(String(item.url))
        onEnqueueRequested: (index, item) => MediaLib.addToPlaylist(item.id)
        onContextMenuRequested: (index, item, pos) => menu.openFor(item, pos, false)
    }
    RMediaMenu { id: menu }
}
