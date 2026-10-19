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

// One line of a settings page: label, optional (i) with the long description,
// and the control on the right (the children of the row).
Item {
    id: root

    property string label
    property string info
    property bool dimmed: !enabled
    default property alias control: slot.data

    readonly property int controlWidth: Theme.dp(318)

    implicitWidth: Theme.dp(780)
    width: parent ? parent.width : implicitWidth
    implicitHeight: Math.max(Theme.dp(42), slot.childrenRect.height + Theme.dp(10))

    // explicit list: plain children would land in the default property (the control slot)
    data: [
    Row {
        id: labelRow
        anchors.left: parent.left
        anchors.right: slot.left
        anchors.rightMargin: Theme.dp(16)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.dp(10)

        RText {
            id: labelText
            width: Math.min(implicitWidth, labelRow.width - (infoIcon.visible ? infoIcon.width + labelRow.spacing : 0))
            text: root.label
            color: root.dimmed ? Theme.iconDisabled : Theme.textItem
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            id: infoIcon
            visible: root.info.length > 0
            width: Theme.dp(16)
            height: Theme.dp(16)
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.color: infoHover.hovered ? Theme.textItem : Theme.textDim
                border.width: 1
                RText {
                    anchors.centerIn: parent
                    text: "i"
                    font.pixelSize: Theme.dp(10)
                    color: infoHover.hovered ? Theme.textItem : Theme.textDim
                }
            }

            HoverHandler { id: infoHover }

            RToolTip {
                text: root.info
                visible: infoHover.hovered
                delay: 200
                timeout: -1
                width: Math.min(implicitWidth, Theme.dp(360))
                contentItem: Text {
                    text: root.info
                    wrapMode: Text.Wrap
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.textStrong
                }
            }
        }
    },

    Item {
        id: slot
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: root.controlWidth
        height: childrenRect.height
    }
    ]
}
