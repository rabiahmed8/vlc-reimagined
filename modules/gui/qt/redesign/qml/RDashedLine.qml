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

// Dashed line (the Canvas item is not part of the Qt build of the contribs).
Item {
    id: root

    property bool vertical: false
    property color color: Theme.p.fgA4
    property int dash: Theme.dp(6)
    property int gap: Theme.dp(4)

    implicitWidth: vertical ? 1 : Theme.dp(100)
    implicitHeight: vertical ? Theme.dp(100) : 1
    clip: true

    Repeater {
        model: Math.ceil((root.vertical ? root.height : root.width) / (root.dash + root.gap))
        delegate: Rectangle {
            required property int index
            x: root.vertical ? 0 : index * (root.dash + root.gap)
            y: root.vertical ? index * (root.dash + root.gap) : 0
            width: root.vertical ? root.width : root.dash
            height: root.vertical ? root.dash : root.height
            color: root.color
        }
    }
}
