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

// Library > Music: Albums, Artists, Tracks, Genres; an album or a genre shows its
// tracks, an artist shows its albums.
Item {
    id: root

    property var library
    readonly property var params: {
        const p = library ? library.route.params : ({})
        return typeof p.id === "string" ? Object.assign({}, p, { id: MediaLib.deserializeMlItemIdFromString(p.id) }) : p
    }
    // "albums", "artists", "tracks", "genres", "album" (tracks of params.id),
    // "artist" (albums of params.id), "genre" (tracks of params.id)
    readonly property string mode: params.mode || tabs.currentValue || "albums"

    readonly property string search: library ? library.searchPattern : ""
    readonly property string sortBy: library ? library.sortCriteria : ""
    readonly property int order: library ? library.sortOrder : Qt.AscendingOrder

    Binding { target: root.library; property: "itemCount"; value: view.count; when: !!root.library }

    onModeChanged: if (library) library.resetSort()
    Binding { target: root.library; property: "sortKeys"; when: !!root.library
        value: ["tracks", "album", "genre"].indexOf(root.mode) >= 0
            ? [{ key: "title", text: qsTr("Title") }, { key: "main_artist", text: qsTr("Artist") }, { key: "album_title", text: qsTr("Album") }, { key: "track_number", text: qsTr("Track number") }, { key: "insertion", text: qsTr("Date added") }, { key: "duration", text: qsTr("Duration") }]
            : [{ key: "title", text: qsTr("Title") }] }

    MLAlbumModel { id: albums; ml: MediaLib; searchPattern: root.search; sortCriteria: root.sortBy; sortOrder: root.order
                   parentId: root.mode === "artist" ? root.params.id : MediaLib.deserializeMlItemIdFromString("") }
    MLArtistModel { id: artists; ml: MediaLib; searchPattern: root.search; sortCriteria: root.sortBy; sortOrder: root.order }
    MLGenreModel { id: genres; ml: MediaLib; searchPattern: root.search; sortCriteria: root.sortBy; sortOrder: root.order }
    MLAudioModel { id: tracks; ml: MediaLib; searchPattern: root.search; sortCriteria: root.sortBy; sortOrder: root.order
                   parentId: root.mode === "album" || root.mode === "genre" ? root.params.id : MediaLib.deserializeMlItemIdFromString("") }

    RSegmented {
        id: tabs
        visible: root.params.mode === undefined
        width: Math.min(Theme.dp(480), parent.width)
        height: visible ? Theme.dp(34) : 0
        model: [{ value: "albums", text: qsTr("Albums") }, { value: "artists", text: qsTr("Artists") },
                { value: "tracks", text: qsTr("Tracks") }, { value: "genres", text: qsTr("Genres") }]
        currentValue: "albums"
        onPicked: (v) => currentValue = v
    }

    // play the whole album / artist / genre
    RButton {
        id: playAll
        visible: root.params.mode !== undefined
        height: visible ? implicitHeight : 0
        primary: true
        text: qsTr("Play all")
        onClicked: MediaLib.addAndPlay(root.params.id)
    }

    RMediaView {
        id: view
        anchors.top: tabs.visible ? tabs.bottom : playAll.bottom
        anchors.topMargin: Theme.dp(16)
        anchors.bottom: parent.bottom
        width: parent.width
        grid: root.library ? root.library.grid : true
        square: true
        fallbackIcon: root.mode === "artists" ? "artist" : root.mode === "genres" ? "genre" : root.mode === "albums" || root.mode === "artist" ? "album" : "music"
        currentMrl: Player.isStarted ? String(Player.url) : ""
        model: {
            switch (root.mode) {
            case "artists": return artists
            case "genres": return genres
            case "tracks": case "album": case "genre": return tracks
            default: return albums
            }
        }

        onEnqueueRequested: (index, item) => MediaLib.addToPlaylist(item.id)
        onActivated: (index, item) => {
            switch (root.mode) {
            case "albums": case "artist":
                root.library.openChild(item.title, { mode: "album", id: item.id }); break
            case "artists":
                root.library.openChild(item.name, { mode: "artist", id: item.id }); break
            case "genres":
                root.library.openChild(item.name, { mode: "genre", id: item.id }); break
            default:
                MediaLib.addAndPlay(item.id)
            }
        }
        onContextMenuRequested: (index, item, pos) => menu.openFor(item, pos, root.mode !== "tracks" && root.mode !== "album" && root.mode !== "genre")
    }

    RText {
        anchors.centerIn: view
        visible: view.count === 0
        text: root.search.length > 0 ? qsTr("Nothing found") : qsTr("No music yet. Use \"Add item\" to add your music folder.")
        color: Theme.textDim
    }

    RMediaMenu { id: menu }
}
