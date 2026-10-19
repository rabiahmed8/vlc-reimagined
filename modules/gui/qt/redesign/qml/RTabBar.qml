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
import QtQuick.Layouts
import QtQuick.Templates as T

// Tab header used by the player popups ("Video / Audio / Subtitles",
// "Queue / Bookmarks / Chapters"): 50px, icon + label, 2px underline.
Rectangle {
    id: root

    // [{ text: "", icon: "" }, ...]
    property var model: []
    property int currentIndex: 0

    implicitHeight: Theme.dp(50)
    color: Theme.trackBackground

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.dp(6)
        anchors.rightMargin: Theme.dp(6)
        spacing: 1

        Repeater {
            model: root.model

            delegate: T.AbstractButton {
                id: tab

                required property var modelData
                required property int index

                readonly property bool current: index === root.currentIndex

                Layout.fillWidth: true
                Layout.fillHeight: true
                hoverEnabled: true
                focusPolicy: Qt.TabFocus
                Accessible.name: modelData.text

                onClicked: root.currentIndex = index

                contentItem: Item {
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: Theme.dp(14)
                        spacing: Theme.spacing

                        RIcon {
                            name: tab.modelData.icon
                            size: Theme.iconSizeSmall
                            color: tab.current ? Theme.text : Theme.textDim
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        RText {
                            text: tab.modelData.text
                            font.pixelSize: Theme.fontSizeSmall
                            color: tab.current || tab.hovered ? Theme.text : Theme.textDim
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Rectangle {
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                        height: Theme.dp(2)
                        color: tab.current ? Theme.accent : "transparent"
                    }
                }
            }
        }
    }
}
