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

// List row with an accent check mark on the left (track lists, devices...)
T.AbstractButton {
    id: root

    property bool selected: false

    implicitHeight: Theme.dp(32)
    implicitWidth: Theme.dp(200)
    hoverEnabled: true
    focusPolicy: Qt.TabFocus
    leftPadding: 0

    Accessible.role: Accessible.RadioButton
    Accessible.checked: selected

    background: Rectangle {
        radius: Theme.radiusSmall
        color: root.pressed ? Theme.pressed : (root.hovered || root.visualFocus) ? Theme.hover : "transparent"
    }

    contentItem: Item {
        RIcon {
            id: mark
            x: Theme.dp(4)
            anchors.verticalCenter: parent.verticalCenter
            name: "check"
            visible: root.selected
        }
        RText {
            anchors.left: parent.left
            anchors.leftMargin: Theme.dp(4) + Theme.iconSize + Theme.dp(10)
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: root.selected ? Theme.textStrong : Theme.textItem
        }
    }
}
