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

// "Current Time" / "Duration" components: 76x28, 15px text
T.AbstractButton {
    id: root

    property bool clickable: false

    implicitWidth: Math.max(Theme.dp(76), label.implicitWidth + Theme.dp(16))
    implicitHeight: Theme.controlHeight
    enabled: clickable
    hoverEnabled: clickable
    focusPolicy: Qt.NoFocus

    background: Rectangle {
        radius: Theme.radius
        color: root.clickable && root.hovered ? Theme.hover : "transparent"
    }

    contentItem: RText {
        id: label
        text: root.text
        font.pixelSize: Theme.fontSizeTime
        horizontalAlignment: Text.AlignHCenter
    }
}
