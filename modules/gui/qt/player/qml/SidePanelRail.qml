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
import VLC.Style
import VLC.Widgets as Widgets
import VLC.Dialogs
import VLC.Util

// Juxtopposed: the icon rail on the left of the player side panel. The
// library sections open in the main window; the play queue is the panel
// itself, so its button is shown as the current one.
Rectangle {
    id: root

    implicitWidth: VLCStyle.juxtSideRail_width

    color: theme.bg.secondary

    readonly property ColorContext colorContext: ColorContext {
        id: theme
        colorSet: ColorContext.Window
    }

    function _openLibrary(uri) {
        History.push(uri)
        MainCtx.playerView = false
    }

    Column {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: VLCStyle.dp(8, VLCStyle.scale)

        spacing: VLCStyle.dp(14, VLCStyle.scale)

        RailButton {
            text: VLCIcons.home
            description: qsTr("Home")
            onClicked: root._openLibrary(["home"])
        }

        RailButton {
            visible: MainCtx.mediaLibraryAvailable
            text: VLCIcons.topbar_video
            description: qsTr("Video")
            onClicked: root._openLibrary(["video"])
        }

        RailButton {
            visible: MainCtx.mediaLibraryAvailable
            text: VLCIcons.topbar_music
            description: qsTr("Music")
            onClicked: root._openLibrary(["music"])
        }

        RailButton {
            text: VLCIcons.topbar_network
            description: qsTr("Browse")
            onClicked: root._openLibrary(["network"])
        }

        RailButton {
            text: VLCIcons.playlist
            description: qsTr("Play Queue")
            checked: true
        }

        RailButton {
            text: VLCIcons.add
            description: qsTr("Open media")
            onClicked: DialogsProvider.simpleOpenDialog()
        }
    }

    component RailButton: Widgets.IconToolButton {
        width: VLCStyle.dp(30, VLCStyle.scale)
        height: VLCStyle.dp(30, VLCStyle.scale)

        font.pixelSize: VLCStyle.icon_normal
    }
}
