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
import QtQuick.Window

import VLC.MainInterface
import VLC.Widgets as Widgets
import VLC.Player
import VLC.Playlist
import VLC.Dialogs

// Shown when there is no video: the music player (Figma "Player - Music"), a big
// rounded cover over a dimmed copy of itself, otherwise the cone and a call to
// action to open something.
Item {
    id: root

    readonly property bool music: Player.isStarted
    readonly property bool hasArtwork: music && Player.artwork.toString().length > 0

    // dimmed, enlarged cover filling the window
    Image {
        anchors.centerIn: parent
        width: Math.max(parent.width, parent.height) * 1.2
        height: width
        fillMode: Image.PreserveAspectCrop
        source: root.hasArtwork ? Player.artwork : ""
        visible: root.hasArtwork && status === Image.Ready
        asynchronous: true
        opacity: 0.18
    }

    Item {
        id: card
        visible: root.music
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.max(Theme.dp(56), (parent.height - height - caption.height - Theme.dp(80)) / 2)
        width: Math.max(Theme.dp(120), Math.min(parent.width - Theme.dp(80), parent.height * 0.68))
        height: width

        Widgets.ImageExt {
            id: artwork
            anchors.fill: parent
            radius: Theme.radiusLarge * 2
            fillMode: Image.PreserveAspectCrop
            source: root.hasArtwork ? Player.artwork : ""
            sourceSize: Qt.size(width * Screen.devicePixelRatio, height * Screen.devicePixelRatio)
            asynchronous: true
        }

        // no cover in the media
        Rectangle {
            anchors.fill: parent
            visible: !root.hasArtwork || artwork.status !== Image.Ready
            radius: Theme.radiusLarge * 2
            color: Theme.p.bgA4

            RIcon {
                anchors.centerIn: parent
                name: "music"
                size: parent.width * 0.3
                color: Theme.textDim
                accentColor: Theme.accent
            }
        }
    }

    RText {
        id: caption
        visible: root.music
        anchors.top: card.bottom
        anchors.topMargin: Theme.dp(36)
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(implicitWidth, parent.width - Theme.dp(40))
        elide: Text.ElideRight
        readonly property string trackTitle: Player.title.length > 0 ? Player.title : Player.name
        text: Player.artist.length > 0 ? Player.artist + " - " + trackTitle : trackTitle
        color: Theme.textStrong
        font.pixelSize: Theme.dp(22)
    }

    Column {
        anchors.centerIn: parent
        spacing: Theme.dp(18)
        visible: !root.music

        RIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: "logo"
            size: Theme.dp(96)
            color: Theme.p.logo
            accentColor: Theme.p.logo
            opacity: 0.9
        }

        RText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Drop media here to play it")
            color: Theme.textDim
            font.pixelSize: Theme.fontSizeLarge
        }

        RPanelButton {
            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: Theme.dp(200)
            text: qsTr("Open media…")
            onClicked: DialogsProvider.simpleOpenDialog()
        }
    }
}
