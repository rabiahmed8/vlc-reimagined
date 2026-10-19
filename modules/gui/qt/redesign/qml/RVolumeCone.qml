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
import VLC.Player

// Volume slider shaped as a lying traffic cone (green -> orange -> red).
T.Slider {
    id: root

    from: 0
    to: MainCtx.maxVolume / 100
    stepSize: 0.05
    wheelEnabled: true
    hoverEnabled: true
    focusPolicy: Qt.NoFocus

    implicitWidth: Theme.dp(88)
    implicitHeight: Theme.controlHeight

    Binding on value {
        when: !root.pressed
        value: Player.muted ? 0 : Math.max(0, Player.volume)
        restoreMode: Binding.RestoreNone
    }

    onMoved: {
        if (Player.muted && value > 0)
            Player.muted = false
        Player.volume = value
    }

    HoverHandler { cursorShape: Qt.PointingHandCursor }

    background: Item {
        width: root.width
        height: root.height

        Image {
            id: coneBg
            anchors.fill: parent
            source: "image://redesignicon/vol_cone_bg?c=" + encodeURIComponent(String(Theme.trackBackground))
            sourceSize: Qt.size(Math.max(1, width), Math.max(1, height))
            smooth: true
        }

        // filled part, clipped at the current value
        Item {
            x: Theme.dp(1)
            y: Theme.dp(2)
            height: parent.height - Theme.dp(4)
            width: (parent.width - Theme.dp(2)) * root.visualPosition
            clip: true

            Image {
                width: root.width - Theme.dp(2)
                height: parent.height
                source: Theme.icon("vol_cone_fill")
                sourceSize: Qt.size(Math.max(1, width), Math.max(1, height))
                smooth: true
            }
        }
    }

    handle: Item {}

    RToolTip {
        visible: root.hovered || root.pressed
        delay: 0
        text: Math.round(root.value * 100) + "%"
    }
}
