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

// Square icon button ("Icon Wrapper" in the design: 30px wide, 4px padding)
T.AbstractButton {
    id: root

    property string iconName
    property color iconColor: checked ? Theme.accent : Theme.text
    property int iconSize: Theme.iconSize
    property string toolTip
    // shows the hover state when a larger area around the button is hovered
    property bool forceHovered: false

    implicitWidth: iconSize + Theme.dp(6)
    implicitHeight: iconSize + Theme.dp(6)

    padding: 0
    focusPolicy: Qt.TabFocus
    hoverEnabled: true

    Accessible.name: toolTip

    background: Rectangle {
        radius: Theme.radiusSmall
        color: root.pressed ? Theme.pressed
             : (root.hovered || root.forceHovered || root.visualFocus) ? Theme.hover
             : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.durationShort } }
    }

    contentItem: Item {
        RIcon {
            anchors.centerIn: parent
            name: root.iconName
            size: root.iconSize
            color: root.enabled ? root.iconColor : Theme.iconDisabled
        }
    }

    RToolTip {
        text: root.toolTip
        visible: root.hovered && root.toolTip.length > 0
    }
}
