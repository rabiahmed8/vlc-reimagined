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

import VLC.MainInterface

// Crop in pixels (Figma "Video - Crop"): top/bottom and left/right, each pair can be
// linked so both sides change together.
Column {
    id: root

    property bool linkVertical: false
    property bool linkHorizontal: false

    spacing: Theme.dp(8)

    component Field: Rectangle {
        id: field
        property string label
        property string option
        signal edited(int value)
        function load() { input.text = String(Number(RedesignEffects.videoValue(option) || 0)) }
        function setValue(v) { input.text = String(v); RedesignEffects.setVideoValue(option, v) }

        width: (root.width - Theme.dp(44)) / 2
        height: Theme.dp(34)
        radius: Theme.radius
        color: Theme.p.bgB2
        Component.onCompleted: load()

        RText { x: Theme.dp(12); anchors.verticalCenter: parent.verticalCenter; text: field.label; color: Theme.textDim }
        TextInput {
            id: input
            anchors.right: px.left
            anchors.rightMargin: Theme.dp(4)
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.dp(50)
            horizontalAlignment: TextInput.AlignRight
            color: Theme.textStrong
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            selectByMouse: true
            validator: IntValidator { bottom: 0; top: 10000 }
            onEditingFinished: {
                const v = parseInt(text) || 0
                RedesignEffects.setVideoValue(field.option, v)
                field.edited(v)
            }
        }
        RText { id: px; anchors.right: parent.right; anchors.rightMargin: Theme.dp(12); anchors.verticalCenter: parent.verticalCenter; text: "px"; color: Theme.textDim }
    }

    component LinkButton: T.AbstractButton {
        id: link
        checkable: true
        width: Theme.dp(28)
        height: Theme.dp(34)
        hoverEnabled: true
        contentItem: RIcon {
            name: "link"
            size: Theme.iconSizeSmall
            color: link.checked ? Theme.accent : link.hovered ? Theme.textItem : Theme.textDim
        }
    }

    Row {
        spacing: Theme.dp(8)
        Field { id: top; label: qsTr("Top"); option: "crop-top"; onEdited: (v) => { if (root.linkVertical) bottom.setValue(v) } }
        Field { id: bottom; label: qsTr("Bottom"); option: "crop-bottom"; onEdited: (v) => { if (root.linkVertical) top.setValue(v) } }
        LinkButton { checked: root.linkVertical; onToggled: root.linkVertical = checked }
    }
    Row {
        spacing: Theme.dp(8)
        Field { id: left; label: qsTr("Left"); option: "crop-left"; onEdited: (v) => { if (root.linkHorizontal) right.setValue(v) } }
        Field { id: right; label: qsTr("Right"); option: "crop-right"; onEdited: (v) => { if (root.linkHorizontal) left.setValue(v) } }
        LinkButton { checked: root.linkHorizontal; onToggled: root.linkHorizontal = checked }
    }
}
