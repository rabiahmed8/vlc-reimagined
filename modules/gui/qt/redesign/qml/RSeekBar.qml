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

import VLC.Player

// Thick seek bar from the redesign: 28px track, filled part in "accent bright"
// and a solid 8px accent handle at the playback position.
T.Slider {
    id: root

    from: 0
    to: 1
    live: false
    enabled: Player.seekable
    hoverEnabled: true
    focusPolicy: Qt.NoFocus

    implicitHeight: Theme.controlHeight
    implicitWidth: Theme.dp(200)
    padding: Theme.dp(2)

    // follow the player unless the user is dragging
    Binding on value {
        when: !root.pressed
        value: Player.position
        restoreMode: Binding.RestoreNone
    }

    onMoved: {
        if (!pressed)
            Player.position = value
    }
    onPressedChanged: {
        if (!pressed)
            Player.position = value
    }

    readonly property real hoverPosition: hoverHandler.hovered
        ? Math.max(0, Math.min(1, (hoverHandler.point.position.x - leftPadding) / availableWidth))
        : -1

    HoverHandler {
        id: hoverHandler
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (event) => {
            if (event.angleDelta.y > 0) Player.jumpFwd()
            else if (event.angleDelta.y < 0) Player.jumpBwd()
        }
    }

    background: Rectangle {
        x: 0
        y: (root.height - height) / 2
        width: root.width
        height: Theme.controlHeight
        radius: Theme.radius
        color: Theme.trackBackground

        // chapters marks
        Repeater {
            model: Player.hasChapters ? Player.chapters : null
            delegate: Rectangle {
                required property var model
                visible: model.startPosition > 0
                x: root.leftPadding + model.startPosition * root.availableWidth
                y: Theme.dp(2)
                width: 1
                height: parent.height - Theme.dp(4)
                color: Theme.p.dividerBright
            }
        }

        // hovered position preview
        Rectangle {
            visible: root.hoverPosition >= 0 && root.enabled
            x: root.leftPadding + root.hoverPosition * root.availableWidth - width / 2
            y: Theme.dp(2)
            width: Theme.dp(2)
            height: parent.height - Theme.dp(4)
            radius: 1
            color: Theme.p.dividerBright
        }

        // played part
        Rectangle {
            x: root.leftPadding
            y: root.topPadding
            width: Math.max(handle.width, root.visualPosition * root.availableWidth)
            height: parent.height - root.topPadding - root.bottomPadding
            radius: Theme.radiusSmall
            color: Theme.trackFill
            visible: Player.isStarted
        }
    }

    handle: Rectangle {
        x: root.leftPadding + Math.max(0, root.visualPosition * root.availableWidth - width)
        y: root.topPadding + (root.availableHeight - height) / 2
        width: Theme.dp(8)
        height: Theme.controlHeight - Theme.dp(4)
        radius: Theme.radiusSmall
        color: Theme.accent
        visible: Player.isStarted
    }

    // time under the cursor
    Rectangle {
        id: timeBubble
        visible: root.hoverPosition >= 0 && root.enabled && Player.length.valid()
        color: Theme.p.bgA1
        border.color: Theme.p.dividerBright
        border.width: 1
        radius: Theme.radiusSmall
        width: bubbleText.implicitWidth + Theme.dp(12)
        height: bubbleText.implicitHeight + Theme.dp(8)
        y: -height - Theme.dp(8)
        x: Math.max(0, Math.min(root.width - width,
                                root.leftPadding + root.hoverPosition * root.availableWidth - width / 2))

        RText {
            id: bubbleText
            anchors.centerIn: parent
            color: Theme.textStrong
            font.pixelSize: Theme.fontSizeSmall
            text: visible ? Player.length.scale(root.hoverPosition).formatHMS() : ""
        }
    }
}
