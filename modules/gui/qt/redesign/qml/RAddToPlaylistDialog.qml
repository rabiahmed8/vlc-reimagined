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
import QtQuick.Layouts
import VLC.MainInterface
import VLC.MediaLibrary

RDialogWindow {
    id: root
    property var mediaIds: []
    property var selectedId: null
    heading: qsTr("Add to playlist")
    width: Theme.dp(560); height: Theme.dp(520)
    acceptText: qsTr("Add")
    acceptEnabled: mediaIds.length > 0 && (selectedId !== null || nameField.text.trim().length > 0)
    MLPlaylistListModel { id: playlists; ml: MediaLib }
    onAccepted: {
        if (nameField.text.trim().length) playlists.create(nameField.text.trim(), mediaIds)
        else playlists.append(selectedId, mediaIds)
    }
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.dp(12)
        RText { text: qsTr("Choose a playlist or create a new one") }
        ListView {
            id: list
            Layout.fillWidth: true; Layout.fillHeight: true
            clip: true; model: playlists
            delegate: RCheckItem {
                required property var model
                width: list.width
                text: model.name
                selected: root.selectedId !== null && root.selectedId.toString() === model.id.toString()
                onClicked: { root.selectedId = model.id; nameField.text = "" }
            }
        }
        RTextField { id: nameField; Layout.fillWidth: true; placeholderText: qsTr("New playlist name") }
    }
}
