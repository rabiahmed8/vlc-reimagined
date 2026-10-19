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

// Thin value slider with a center line, double click resets
T.Slider {
    id: root

    signal reset()

    implicitHeight: Theme.dp(24)
    implicitWidth: Theme.dp(300)
    hoverEnabled: true
    live: true

    TapHandler {
        onDoubleTapped: root.reset()
    }

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + (root.availableHeight - height) / 2
        width: root.availableWidth
        height: Theme.dp(6)
        radius: height / 2
        color: Theme.trackBackground

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: root.enabled ? Theme.trackFill : "transparent"
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + (root.availableHeight - height) / 2
        width: Theme.dp(8)
        height: Theme.dp(18)
        radius: Theme.radiusSmall
        color: root.enabled ? Theme.accent : Theme.iconDisabled
    }
}
