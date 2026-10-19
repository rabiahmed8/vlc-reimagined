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

T.AbstractButton {
    id: root

    property string iconName

    implicitHeight: Theme.dp(32)
    implicitWidth: row.implicitWidth + Theme.dp(20)
    hoverEnabled: true
    checkable: false

    background: Rectangle {
        radius: Theme.radius
        color: root.checked ? Theme.trackFill : root.hovered ? Theme.p.bgA1 : Theme.trackBackground
    }
    contentItem: Item {
        Row {
            id: row
            anchors.centerIn: parent
            spacing: Theme.dp(6)
            RIcon {
                name: root.iconName
                size: Theme.iconSizeSmall
                anchors.verticalCenter: parent.verticalCenter
                color: root.enabled ? Theme.text : Theme.iconDisabled
                accentColor: root.enabled ? Theme.accent : Theme.iconDisabled
            }
            RText {
                text: root.text
                anchors.verticalCenter: parent.verticalCenter
                color: root.enabled ? (root.checked ? Theme.accent : Theme.text) : Theme.iconDisabled
            }
        }
    }
}
