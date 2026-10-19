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

T.ToolTip {
    id: root

    delay: 600
    timeout: 4000
    padding: Theme.dp(6)
    leftPadding: Theme.dp(8)
    rightPadding: Theme.dp(8)

    y: -implicitHeight - Theme.dp(6)
    x: parent ? (parent.width - implicitWidth) / 2 : 0

    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeSmall

    contentItem: Text {
        text: root.text
        font: root.font
        color: Theme.textStrong
    }

    background: Rectangle {
        color: Theme.p.bgA1
        radius: Theme.radiusSmall
        border.color: Theme.p.dividerBright
        border.width: 1
    }
}
