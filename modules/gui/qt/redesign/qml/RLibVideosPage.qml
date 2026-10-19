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

// Library > Videos: the folders that hold videos, then the videos of a folder
// (Figma "Player-1/3/4": Videos > ... > S01).
Item {
    id: root

    property var library
    readonly property var params: library ? library.route.params : ({})
    readonly property var folderId: typeof params.folderId === "string" ? MediaLib.deserializeMlItemIdFromString(params.folderId) : params.folderId
    readonly property bool inFolder: params.folderId !== undefined || params.all === true

    Binding {
        target: root.library
        property: "itemCount"
        value: root.inFolder ? videos.count + (root.params.all ? 0 : folders.count) : folders.count + 1
        when: !!root.library
    }

    Binding { target: root.library; property: "sortKeys"; when: !!root.library
        value: root.inFolder ? [{ key: "playcount", text: qsTr("Watched") }, { key: "insertion", text: qsTr("Date added") }, { key: "title", text: qsTr("Title") }, { key: "duration", text: qsTr("Duration") }] : [{ key: "title", text: qsTr("Title") }] }

    MLVideoFoldersModel {
        id: folders
        ml: MediaLib
        hierarchical: true
        parentId: root.params.folderId !== undefined ? root.folderId : MediaLib.deserializeMlItemIdFromString("")
        searchPattern: root.library ? root.library.searchPattern : ""
        sortCriteria: root.library && root.library.sortCriteria.length > 0 ? root.library.sortCriteria : "title"
        sortOrder: root.library ? root.library.sortOrder : Qt.AscendingOrder
    }

    MLVideoModel {
        id: videos
        ml: MediaLib
        parentId: root.params.folderId !== undefined ? root.folderId : MediaLib.deserializeMlItemIdFromString("")
        searchPattern: root.library ? root.library.searchPattern : ""
        sortCriteria: root.library && root.library.sortCriteria.length > 0 ? root.library.sortCriteria : "title"
        sortOrder: root.library ? root.library.sortOrder : Qt.AscendingOrder
    }

    // ---- folders (root of Videos): "All videos" first
    RMediaView {
        id: folderView
        anchors.fill: parent
        visible: !root.inFolder
        grid: root.library ? root.library.grid : true
        fallbackIcon: "folder"
        model: folders

        header: Item {
            width: folderView.width
            height: allBtn.height + Theme.dp(16)
            RChip {
                id: allBtn
                iconName: "videos"
                text: qsTr("All videos")
                onClicked: root.library.openChild(qsTr("All videos"), { all: true })
            }
        }

        onEnqueueRequested: (index, item) => MediaLib.addToPlaylist(item.id)
        onActivated: (index, item) => root.library.openChild(item.title, { folderId: item.id })
        onContextMenuRequested: (index, item, pos) => menu.openFor(item, pos, true)
    }

    // ---- videos of a folder, with its real subfolders above the media
    RMediaView {
        id: videoView
        header: RMediaView {
            width: videoView.width
            height: root.params.all ? 0 : Math.ceil(count / columns) * cellHeight
            visible: !root.params.all && count > 0
            interactive: false
            grid: videoView.grid
            fallbackIcon: "folder"
            model: folders
            onActivated: (index, item) => root.library.openChild(item.title, { folderId: item.id })
            onEnqueueRequested: (index, item) => MediaLib.addToPlaylist(item.id)
            onContextMenuRequested: (index, item, pos) => menu.openFor(item, pos, true)
        }
        anchors.fill: parent
        visible: root.inFolder
        grid: root.library ? root.library.grid : true
        model: videos
        currentMrl: Player.isStarted ? String(Player.url) : ""

        onEnqueueRequested: (index, item) => MediaLib.addToPlaylist(item.id)
        onActivated: (index, item) => MediaLib.addAndPlay(item.id)
        onContextMenuRequested: (index, item, pos) => menu.openFor(item, pos, false, () => videos.setItemPlayed(videos.index(index, 0), !(item.progress > 0 || item.playcount > 0)))
    }

    RText {
        anchors.centerIn: parent
        visible: (root.inFolder ? videos.count : folders.count) === 0 && !(root.inFolder ? videos.loading : folders.loading)
        text: root.library && root.library.searchPattern.length > 0 ? qsTr("Nothing found")
              : qsTr("No videos yet. Use \"Add item\" to add a folder to the library.")
        color: Theme.textDim
    }

    RMediaMenu { id: menu }
}
