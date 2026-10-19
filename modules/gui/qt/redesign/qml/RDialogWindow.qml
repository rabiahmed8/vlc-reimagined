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

// Modal dialog frame of the redesign (Figma "Open Network Stream", "New Playlist",
// "Add Subtitles"): dark title row with close, content, Cancel / Save at the bottom.
Window {
    id: root

    property string heading
    property string acceptText: qsTr("Save")
    property bool acceptEnabled: true
    default property alias content: body.data
    property alias headerExtra: headerExtraSlot.data   // controls under the title (Add Subtitles)
    property int headerExtraHeight: 0

    signal accepted()

    function open() {
        show()
        raise()
        requestActivate()
    }

    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: Theme.p.bgA3
    title: heading

    // explicit list: plain children would land in the default property (the body)
    data: [
    Shortcut { sequence: "Esc"; onActivated: root.close() },

    Rectangle {
        anchors.fill: parent
        color: Theme.p.bgA3
        border.color: Theme.p.dividerDim

        Rectangle {
            id: header
            width: parent.width
            height: Theme.dp(50) + root.headerExtraHeight
            color: Theme.p.bgB1Transparent

            DragHandler {
                target: null
                onActiveChanged: if (active) root.startSystemMove()
            }

            RText {
                x: Theme.dp(20)
                y: Theme.dp(15)
                text: root.heading
                color: Theme.textItem
            }
            RIconButton {
                anchors.right: parent.right
                anchors.rightMargin: Theme.dp(14)
                y: Theme.dp(11)
                iconName: "close"
                toolTip: qsTr("Close")
                onClicked: root.close()
            }
            Item {
                id: headerExtraSlot
                x: Theme.dp(10)
                y: Theme.dp(50)
                width: parent.width - Theme.dp(20)
                height: root.headerExtraHeight - Theme.dp(8)
            }
        }

        Item {
            id: body
            anchors.top: header.bottom
            anchors.bottom: footer.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.dp(20)
        }

        Item {
            id: footer
            anchors.bottom: parent.bottom
            width: parent.width
            height: Theme.dp(68)

            RButton {
                x: Theme.dp(20)
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Cancel")
                onClicked: root.close()
            }
            RButton {
                anchors.right: parent.right
                anchors.rightMargin: Theme.dp(20)
                anchors.verticalCenter: parent.verticalCenter
                text: root.acceptText
                primary: root.acceptEnabled
                enabled: root.acceptEnabled
                onClicked: {
                    root.accepted()
                    root.close()
                }
            }
        }
    }
    ]
}
