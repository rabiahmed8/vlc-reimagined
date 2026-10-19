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

import VLC.Playlist

// One row of the queue: small icon, title, duration
T.AbstractButton {
    id: root

    required property var model
    required property int index

    implicitHeight: Theme.dp(36)
    hoverEnabled: true
    leftPadding: Theme.margin
    rightPadding: Theme.margin

    onDoubleClicked: MainPlaylistController.goTo(index, true)

    background: Rectangle {
        color: root.hovered ? Theme.hover : "transparent"
    }

    contentItem: Item {
        RIcon {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            name: root.model.isCurrent ? "playing" : "media"
            color: Theme.textDim
            size: Theme.iconSizeSmall
        }
        RText {
            anchors.left: icon.right
            anchors.leftMargin: Theme.dp(10)
            anchors.right: duration.left
            anchors.rightMargin: Theme.dp(10)
            anchors.verticalCenter: parent.verticalCenter
            text: root.model.title
            color: root.model.isCurrent ? Theme.accent : Theme.textItem
        }
        RText {
            id: duration
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.textDim
            font.pixelSize: Theme.fontSizeSmall
            text: root.model.duration && root.model.duration.valid() ? root.model.duration.formatHMS() : ""
        }
        RIconButton {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: root.hovered
            iconName: "close"
            iconSize: Theme.iconSizeSmall
            toolTip: qsTr("Remove from queue")
            onClicked: root.ListView.view.model.removeItems([root.index])
        }
    }
}
