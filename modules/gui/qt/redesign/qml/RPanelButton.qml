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

// Full width secondary button used at the bottom of panels (360x32, #090909)
T.AbstractButton {
    id: root

    implicitHeight: Theme.dp(32)
    implicitWidth: Theme.dp(360)
    hoverEnabled: true

    background: Rectangle {
        radius: Theme.radiusSmall
        color: root.pressed ? Theme.pressed : root.hovered ? Theme.p.bgA1 : Theme.trackBackground
    }
    contentItem: RText {
        text: root.text
        color: root.hovered ? Theme.text : Theme.textDim
        horizontalAlignment: Text.AlignHCenter
    }
}
