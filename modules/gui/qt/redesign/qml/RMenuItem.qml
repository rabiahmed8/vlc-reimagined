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

T.MenuItem {
    id: root

    property string iconName: action && action.iconName !== undefined ? action.iconName : subMenu && subMenu.iconName !== undefined ? subMenu.iconName : ""
    property string shortcutText: action && action.shortcutText !== undefined ? action.shortcutText : ""

    implicitWidth: Math.max(Theme.dp(244), leftPadding + Theme.iconSize + Theme.dp(14) + label.implicitWidth
                            + Theme.dp(32) + shortcut.implicitWidth + rightPadding)
    implicitHeight: Theme.dp(48)

    leftPadding: Theme.dp(12)
    rightPadding: Theme.dp(16)
    hoverEnabled: true

    background: Rectangle {
        radius: Theme.radius
        color: root.highlighted || root.hovered ? Theme.hover : "transparent"
    }

    arrow: RIcon {
        x: root.width - width - Theme.dp(12)
        anchors.verticalCenter: parent.verticalCenter
        visible: !!root.subMenu
        name: "chevron_right"
    }

    indicator: RIcon {
        x: root.width - width - Theme.dp(16)
        y: (root.height - height) / 2
        visible: root.checkable && root.checked
        name: "check"
        size: Theme.iconSizeSmall
        color: Theme.accent
    }

    contentItem: Item {
        RIcon {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            name: root.iconName
            visible: name.length > 0
            color: root.enabled ? (root.iconName.endsWith("_2t") ? Theme.text : Theme.accent) : Theme.iconDisabled
            accentColor: root.enabled ? Theme.accent : Theme.iconDisabled
        }
        RText {
            id: label
            anchors.left: parent.left
            anchors.leftMargin: Theme.iconSize + Theme.dp(14)
            anchors.right: shortcut.left
            anchors.rightMargin: Theme.dp(32)
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            font.pixelSize: Theme.fontSizeLarge - Theme.dp(1)
            color: root.enabled ? (root.checked ? Theme.accent : Theme.text) : Theme.iconDisabled
        }
        RText {
            id: shortcut
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: !root.subMenu && !root.checked
            text: root.shortcutText
            width: Math.max(implicitWidth, root.checked ? Theme.iconSize : 0)
            color: Theme.textDim
            font.pixelSize: Theme.fontSize
        }
    }
}
