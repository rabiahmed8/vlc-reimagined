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

// Single line input of the settings: dark field, value committed on Enter or focus loss.
T.TextField {
    id: root

    // emitted with the final text when editing is finished
    signal committed(string value)

    implicitWidth: Theme.dp(318)
    implicitHeight: Theme.dp(32)
    leftPadding: Theme.dp(12)
    rightPadding: Theme.dp(12)
    verticalAlignment: TextInput.AlignVCenter
    selectByMouse: true
    hoverEnabled: true

    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    color: enabled ? Theme.textItem : Theme.iconDisabled
    placeholderTextColor: Theme.textDim
    selectionColor: Theme.trackFill
    selectedTextColor: Theme.textStrong

    onEditingFinished: root.committed(text)

    // Templates do not draw the placeholder
    RText {
        x: root.leftPadding
        width: root.width - root.leftPadding - root.rightPadding
        anchors.verticalCenter: parent.verticalCenter
        text: root.placeholderText
        color: root.placeholderTextColor
        font: root.font
        visible: root.text.length === 0 && root.preeditText.length === 0
    }

    background: Rectangle {
        radius: Theme.radiusSmall
        color: Theme.p.bgB1Transparent
        border.color: root.activeFocus ? Theme.p.dividerBright
                    : root.hovered ? Theme.p.dividerDim : "transparent"
        border.width: 1
        opacity: root.enabled ? 1 : 0.4
    }
}
