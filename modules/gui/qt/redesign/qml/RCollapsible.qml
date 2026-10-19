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

// Collapsible block of the effect panels (Figma "Expand Settings" / "Collapse Settings"):
// a header with the title, an optional on/off switch, and the content below when expanded.
Rectangle {
    id: root

    property string title
    property bool expanded: false
    property bool checkable: false
    property bool checked: false
    default property alias content: body.data

    signal toggled(bool checked)

    width: parent ? parent.width : implicitWidth
    implicitWidth: Theme.dp(360)
    implicitHeight: header.height + (expanded ? body.childrenRect.height + Theme.dp(14) : 0)
    radius: Theme.radius
    color: expanded ? Theme.p.bgA3 : Theme.p.bgB2
    clip: true

    data: [
        T.AbstractButton {
            id: header
            width: root.width
            height: Theme.dp(48)
            hoverEnabled: true
            onClicked: root.expanded = !root.expanded

            background: Rectangle {
                radius: root.radius
                color: header.hovered ? Theme.hover : "transparent"
            }
            contentItem: Item {
                RText {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.dp(16)
                    anchors.right: sw.visible ? sw.left : chevron.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.title
                    color: root.expanded || root.checked ? Theme.textItem : Theme.textDim
                }
                RSwitch {
                    id: sw
                    visible: root.checkable
                    anchors.right: chevron.left
                    anchors.rightMargin: Theme.dp(10)
                    anchors.verticalCenter: parent.verticalCenter
                    checked: root.checked
                    onToggled: root.toggled(checked)
                }
                RIcon {
                    id: chevron
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.dp(14)
                    anchors.verticalCenter: parent.verticalCenter
                    name: root.expanded ? "chevron_down" : "chevron_right"
                    size: Theme.iconSizeSmall
                    color: Theme.textDim
                }
            }
        },
        Column {
            id: body
            x: Theme.dp(16)
            y: header.height
            width: root.width - Theme.dp(32)
            spacing: Theme.dp(6)
            visible: root.expanded
        }
    ]
}
