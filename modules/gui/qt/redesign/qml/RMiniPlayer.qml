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
import VLC.Player
import VLC.Playlist

// Mini player of the library (Figma "Player-1", "Miniplayer"): the playing video in a
// card (the video itself is RPlayerView, placed at videoRect), progress, title,
// folder, play/pause and the queue.
Rectangle {
    id: root

    property rect videoRect
    signal expandRequested()
    signal queueRequested()
    signal libraryRequested()

    x: videoRect.x - Theme.dp(8)
    y: videoRect.y - Theme.dp(8)
    width: videoRect.width + Theme.dp(16)
    height: videoRect.height + Theme.dp(138)
    radius: Theme.radiusLarge
    color: Theme.p.bgA3
    border.color: Theme.p.dividerDim

    // swallow clicks so they don't reach the library below
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onWheel: (w) => w.accepted = true }

    // audio only: cover in place of the video
    Rectangle {
        x: Theme.dp(8)
        y: Theme.dp(8)
        width: root.videoRect.width
        height: root.videoRect.height
        radius: Theme.radius
        color: Theme.p.videoBackground
        visible: !MainCtx.hasEmbededVideo
        Image {
            anchors.fill: parent
            anchors.margins: Theme.dp(12)
            source: Player.artwork
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            visible: status === Image.Ready
        }
    }

    Column {
        x: Theme.dp(8)
        y: root.videoRect.height + Theme.dp(18)
        width: root.videoRect.width
        spacing: Theme.dp(10)

        RValueSlider {
            width: parent.width
            from: 0
            to: 1
            value: Player.position
            onMoved: Player.position = value
        }

        RText {
            width: parent.width
            text: Player.title || Player.name
            color: Theme.textItem
            font.pixelSize: Theme.fontSizeLarge
        }

        Item {
            width: parent.width
            height: Theme.dp(30)

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.dp(4)
                RIconButton {
                    iconName: "previous"
                    iconSize: Theme.iconSizeSmall
                    toolTip: qsTr("Previous")
                    onClicked: MainPlaylistController.prev()
                }
                RIconButton {
                    iconName: Player.playingState === Player.PLAYING_STATE_PLAYING ? "pause" : "play"
                    iconSize: Theme.iconSizeSmall
                    toolTip: qsTr("Play / pause")
                    onClicked: MainPlaylistController.togglePlayPause()
                }
                RIconButton {
                    iconName: "next"
                    iconSize: Theme.iconSizeSmall
                    toolTip: qsTr("Next")
                    onClicked: MainPlaylistController.next()
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.dp(4)
                RIconButton {
                    iconName: "folder"
                    iconSize: Theme.iconSizeSmall
                    toolTip: qsTr("Open library")
                    onClicked: root.libraryRequested()
                }
                RIconButton {
                    iconName: "fullscreen"
                    iconSize: Theme.iconSizeSmall
                    toolTip: qsTr("Back to the player")
                    onClicked: root.expandRequested()
                }
                RIconButton {
                    iconName: "queue"
                    iconSize: Theme.iconSizeSmall
                    toolTip: qsTr("Queue")
                    onClicked: root.queueRequested()
                }
            }
        }
    }
}
