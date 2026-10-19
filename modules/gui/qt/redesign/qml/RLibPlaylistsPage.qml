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

// Library > Playlists: the playlists of the media library, then their media.
Item {
    id: root

    property var library
    readonly property var params: {
        const p = library ? library.route.params : ({})
        return typeof p.id === "string" ? Object.assign({}, p, { id: MediaLib.deserializeMlItemIdFromString(p.id) }) : p
    }
    readonly property bool inPlaylist: params.id !== undefined

    Binding { target: root.library; property: "itemCount"; value: root.inPlaylist ? content.count : playlists.count; when: !!root.library }

    Binding { target: root.library; property: "sortKeys"; when: !!root.library
        value: root.inPlaylist ? [{ key: "title", text: qsTr("Title") }, { key: "duration", text: qsTr("Duration") }, { key: "playcount", text: qsTr("Watched") }] : [] }

    MLPlaylistListModel {
        id: playlists
        ml: MediaLib
        searchPattern: root.library ? root.library.searchPattern : ""
        sortCriteria: root.library ? root.library.sortCriteria : ""
        sortOrder: root.library ? root.library.sortOrder : Qt.AscendingOrder
    }
    MLPlaylistModel {
        id: content
        ml: MediaLib
        parentId: root.inPlaylist ? root.params.id : MediaLib.deserializeMlItemIdFromString("")
        searchPattern: root.library ? root.library.searchPattern : ""
        sortCriteria: root.library ? root.library.sortCriteria : ""
        sortOrder: root.library ? root.library.sortOrder : Qt.AscendingOrder
    }

    Row {
        id: actions
        spacing: Theme.dp(10)
        RButton {
            primary: root.inPlaylist
            text: root.inPlaylist ? qsTr("Play all") : qsTr("New playlist")
            onClicked: root.inPlaylist ? MediaLib.addAndPlay(root.params.id) : RWindows.newPlaylistRequested()
        }
    }

    RMediaView {
        anchors.top: actions.bottom
        anchors.topMargin: Theme.dp(16)
        anchors.bottom: parent.bottom
        width: parent.width
        grid: root.library ? root.library.grid : true
        square: !root.inPlaylist
        fallbackIcon: root.inPlaylist ? "file" : "playlist"
        model: root.inPlaylist ? content : playlists
        currentMrl: Player.isStarted ? String(Player.url) : ""
        onEnqueueRequested: (index, item) => MediaLib.addToPlaylist(item.id)
        onActivated: (index, item) => {
            if (root.inPlaylist)
                MediaLib.addAndPlay(item.id)
            else
                root.library.openChild(item.name, { id: item.id })
        }
        onContextMenuRequested: (index, item, pos) => { menu.itemIndex = index; menu.openFor(item, pos, !root.inPlaylist) }
    }

    RText {
        anchors.centerIn: parent
        visible: (root.inPlaylist ? content.count : playlists.count) === 0
        text: root.inPlaylist ? qsTr("This playlist is empty") : qsTr("No playlists yet")
        color: Theme.textDim
    }

    RDialogWindow {
        id: deleteDialog
        property var playlistId
        heading: qsTr("Delete playlist")
        acceptText: qsTr("Delete playlist")
        width: Theme.dp(480); height: Theme.dp(240)
        onAccepted: playlists.deletePlaylists([playlistId])
        RText { anchors.fill: parent; wrapMode: Text.Wrap; text: qsTr("Delete this playlist from the library? Your media files will stay on disk.") }
    }
    RMediaMenu {
        id: menu
        RMenuSeparator { visible: !root.inPlaylist }
        RAction {
            text: qsTr("Rename playlist")
            enabled: !root.inPlaylist
            onTriggered: playlists.showDialogRename(playlists.index(menu.itemIndex, 0))
        }
        RAction {
            text: qsTr("Delete playlist")
            enabled: !root.inPlaylist
            onTriggered: { deleteDialog.playlistId = menu.item.id; deleteDialog.open() }
        }
    }
}
