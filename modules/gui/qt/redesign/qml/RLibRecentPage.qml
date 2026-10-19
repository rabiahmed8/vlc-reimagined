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
import VLC.Player

// Library > Recent: recently played media, newest first.
Item {
    id: root

    property var library

    Binding { target: root.library; property: "itemCount"; value: recent.count; when: !!root.library }

    Binding { target: root.library; property: "sortKeys"; value: []; when: !!root.library }

    MLRecentMediaModel {
        id: recent
        ml: MediaLib
        searchPattern: root.library ? root.library.searchPattern : ""
    }

    RButton {
        id: clear
        text: qsTr("Clear history")
        onClicked: recent.clearHistory()
    }

    RMediaView {
        anchors.top: clear.bottom
        anchors.topMargin: Theme.dp(16)
        anchors.bottom: parent.bottom
        width: parent.width
        grid: root.library ? root.library.grid : true
        model: recent
        currentMrl: Player.isStarted ? String(Player.url) : ""
        onEnqueueRequested: (index, item) => MediaLib.addToPlaylist(item.id)
        onActivated: (index, item) => MediaLib.addAndPlay(item.id)
        onContextMenuRequested: (index, item, pos) => menu.openFor(item, pos, false)
    }

    RText {
        anchors.centerIn: parent
        visible: recent.count === 0
        text: qsTr("Nothing played yet")
        color: Theme.textDim
    }

    RMediaMenu { id: menu }
}
