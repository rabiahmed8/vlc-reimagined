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

import VLC.MediaLibrary
import VLC.MainInterface
import VLC.Dialogs
import VLC.Playlist

// Right click menu of library items (Figma "file context menu", "folder context menu").
RMenu {
    id: root

    property int itemIndex: -1
    property var item
    property bool isFolder: false
    property bool favorite: false
    property var urls: []
    property var togglePlayed: null      // function, for videos

    function openFor(it, globalPos, folder, played) {
        item = it
        isFolder = folder === true
        togglePlayed = played || null
        favorite = false
        urls = []
        const id = it.id.toString()
        MediaLib.isFavorite(it.id, value => { if (root.item && root.item.id.toString() === id) root.favorite = value })
        MediaLib.mediaUrls(it.id, value => { if (root.item && root.item.id.toString() === id) root.urls = value })
        const p = parent ? parent.mapFromGlobal(globalPos.x, globalPos.y) : globalPos
        popup(p.x, p.y)
    }

    RAction {
        iconName: "play"
        text: root.isFolder ? qsTr("Play all") : qsTr("Play")
        onTriggered: MediaLib.addAndPlay(root.item.id)
    }
    RAction {
        iconName: "queue_2t"
        text: qsTr("Add to queue")
        onTriggered: MediaLib.addToPlaylist(root.item.id)
    }
    RAction {
        iconName: "check_selected_2t"
        text: qsTr("Mark as watched / unwatched")
        enabled: root.togglePlayed !== null
        onTriggered: root.togglePlayed()
    }

    RAction {
        text: root.favorite ? qsTr("Remove from favorites") : qsTr("Favorite")
        iconName: "favorite"
        checkable: true; checked: root.favorite
        onTriggered: { root.favorite = !root.favorite; MediaLib.setFavorite(root.item.id, root.favorite) }
    }
    RAction { text: qsTr("Shuffle"); iconName: "shuffle"; enabled: root.isFolder; onTriggered: { MainPlaylistController.random = true; MediaLib.addAndPlay(root.item.id) } }
    RAction { text: qsTr("Add to playlist"); iconName: "playlist_2t"; onTriggered: RWindows.addToPlaylistRequested([root.item.id]) }
    RMenuSeparator { }
    RAction { text: qsTr("Stream"); iconName: "streaming_2t"; enabled: root.urls.length > 0; onTriggered: DialogsProvider.streamingDialog(root.urls, false) }
    RAction { text: qsTr("Convert"); iconName: "swap_2t"; enabled: root.urls.length > 0; onTriggered: DialogsProvider.streamingDialog(root.urls, true) }
    RAction {
        text: qsTr("Export playlist"); iconName: "playlist_2t"; enabled: root.urls.length > 0
        onTriggered: {
            const path = RedesignSettings.browseFile("playlist.m3u8", true)
            if (path.length && !RedesignSettings.writePlaylist(path, root.urls))
                DialogsProvider.messageDialog(qsTr("The playlist could not be saved."))
        }
    }
    RMenuSeparator { }
    RAction {
        text: qsTr("Show in File Explorer"); iconName: "folder_2t"
        enabled: String(root.item && (root.item.mrl || root.item.url) || "").startsWith("file:")
        onTriggered: Qt.openUrlExternally(RedesignSettings.directoryOf(String(root.item.mrl || root.item.url)))
    }
    RAction { text: qsTr("Add subtitle tracks"); iconName: "subtitles_2t"; enabled: root.urls.length > 0; onTriggered: RWindows.addSubtitlesToMediaRequested(root.urls) }
    RAction { text: qsTr("Add audio tracks"); iconName: "audio_2t"; enabled: root.urls.length > 0; onTriggered: RWindows.addAudioToMediaRequested(root.urls) }
    RAction { text: qsTr("Properties & metadata"); iconName: "info_2t"; enabled: !root.isFolder; onTriggered: DialogsProvider.mediaInfoDialog(root.item.id) }
}
