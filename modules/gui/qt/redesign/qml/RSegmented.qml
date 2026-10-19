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

// Segmented choice ("Values" component in Figma): Dark | Light | System, Relative | Pixels...
// model: [{ value, text }, ...]
Rectangle {
    id: root

    property var model: []
    property var currentValue
    signal picked(var value)

    implicitWidth: Theme.dp(318)
    implicitHeight: Theme.dp(34)
    radius: Theme.radius
    color: Theme.p.bgB2
    opacity: enabled ? 1 : 0.4

    Row {
        anchors.fill: parent
        anchors.margins: Theme.dp(2)
        spacing: Theme.dp(2)

        Repeater {
            model: root.model
            delegate: T.AbstractButton {
                id: seg
                required property var modelData
                readonly property bool selected: modelData.value == root.currentValue
                width: (root.width - Theme.dp(4) - Theme.dp(2) * (root.model.length - 1)) / root.model.length
                height: parent.height
                hoverEnabled: true
                focusPolicy: Qt.TabFocus
                onClicked: root.picked(modelData.value)

                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: seg.selected ? Theme.trackFill
                         : seg.hovered ? Theme.p.bgA1 : Theme.p.bgA3
                    border.color: seg.visualFocus ? Theme.p.dividerBright : "transparent"
                }
                contentItem: RText {
                    text: seg.modelData.text
                    horizontalAlignment: Text.AlignHCenter
                    color: seg.selected ? Theme.accent : Theme.textDim
                }
            }
        }
    }
}
