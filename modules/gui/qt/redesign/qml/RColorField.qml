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

import VLC.MainInterface

// "#FFFFFF [swatch]" field of the settings; the swatch opens the color picker.
Item {
    id: root

    property color color: "white"
    signal picked(color color)

    implicitWidth: Theme.dp(318)
    implicitHeight: Theme.dp(32)

    RTextField {
        id: field
        anchors.fill: parent
        rightPadding: Theme.dp(44)
        text: String(root.color).toUpperCase().slice(0, 7)
        onCommitted: (t) => {
            const c = t.startsWith("#") ? t : "#" + t
            if (/^#[0-9A-Fa-f]{6}$/.test(c))
                root.picked(c)
            else
                text = Qt.binding(() => String(root.color).toUpperCase().slice(0, 7))
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: Theme.dp(8)
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.dp(22)
        height: Theme.dp(22)
        radius: Theme.radiusSmall
        color: root.color
        border.color: Theme.p.dividerBright
        border.width: 1

        TapHandler {
            onTapped: {
                const c = RedesignSettings.pickColor(String(root.color))
                if (c.length > 0)
                    root.picked(c)
            }
        }
        HoverHandler { cursorShape: Qt.PointingHandCursor }
    }
}
