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
import QtQuick.Templates as T

import VLC.MainInterface
import VLC.Playlist

// "Open Network Stream" (Figma): one or more URLs, optionally saved as a playlist
// of the media library.
RDialogWindow {
    id: root

    readonly property var urls: urlArea.text.split(/\s+/).map(s => s.trim()).filter(s => s.length > 0)

    heading: qsTr("Open Network Stream")
    acceptText: qsTr("Play")
    acceptEnabled: urls.length > 0
    width: Theme.dp(1048)
    height: Theme.dp(630)
    minimumWidth: Theme.dp(560)
    minimumHeight: Theme.dp(460)

    onVisibleChanged: if (visible) { urlArea.text = ""; nameField.text = ""; urlArea.forceActiveFocus() }

    onAccepted: {
        MainPlaylistController.append(urls, true)
        if (nameField.text.trim().length > 0 && MainCtx.mediaLibraryAvailable)
            playlistSaver.item.save(nameField.text.trim(), urls)
    }

    Loader {
        id: playlistSaver
        active: MainCtx.mediaLibraryAvailable
        source: "RPlaylistSaver.qml"
    }

    Column {
        anchors.fill: parent
        spacing: Theme.dp(8)

        RText { text: qsTr("Network URL"); font.pixelSize: Theme.fontSizeLarge; color: Theme.textStrong }
        RText { text: qsTr("You can enter multiple links to load, one per line."); color: Theme.textDim }

        Rectangle {
            width: parent.width
            height: Theme.dp(190)
            radius: Theme.radiusSmall
            color: Theme.p.bgB1Transparent
            border.color: urlArea.activeFocus ? Theme.p.dividerBright : Theme.p.dividerDim

            Flickable {
                id: urlFlick
                anchors.fill: parent
                anchors.margins: Theme.dp(12)
                clip: true
                contentHeight: urlArea.implicitHeight
                T.ScrollBar.vertical: RScrollBar { }

                TextEdit {
                    id: urlArea
                    width: urlFlick.width
                    wrapMode: TextEdit.WrapAnywhere
                    color: Theme.textStrong
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    selectByMouse: true
                    selectionColor: Theme.trackFill
                    RText {
                        visible: urlArea.text.length === 0
                        text: qsTr("e.g., https://www.example.com/stream.avi")
                        color: Theme.textDim
                    }
                }
            }
        }

        Item { width: 1; height: Theme.dp(20) }

        Row {
            spacing: Theme.dp(6)
            visible: MainCtx.mediaLibraryAvailable
            RText { text: qsTr("Playlist Name"); font.pixelSize: Theme.fontSizeLarge; color: Theme.textStrong }
            RText { text: qsTr("(optional)"); font.pixelSize: Theme.fontSizeLarge; color: Theme.textDim }
        }
        RText {
            visible: MainCtx.mediaLibraryAvailable
            text: qsTr("The playlist will be saved and displayed with this title.")
            color: Theme.textDim
        }
        RTextField {
            id: nameField
            visible: MainCtx.mediaLibraryAvailable
            width: parent.width
            height: Theme.dp(36)
            placeholderText: qsTr("e.g., Favorite TV Channels")
        }
    }
}
