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

// Slider of the settings: filled track, tick marks and optional labels under it
// (Default playback speed, Maximum volume, Hide after...).
// labels: [{ value, text }, ...] placed under the track at their value.
T.Slider {
    id: root

    property var labels: []
    property int tickCount: 0          // number of intervals, 0 = no ticks
    signal committed(real value)

    implicitWidth: Theme.dp(318)
    implicitHeight: labels.length > 0 ? Theme.dp(44) : Theme.dp(26)
    topPadding: 0
    bottomPadding: labels.length > 0 ? Theme.dp(18) : 0
    hoverEnabled: true
    live: true
    snapMode: stepSize > 0 ? T.Slider.SnapAlways : T.Slider.NoSnap

    onPressedChanged: if (!pressed) root.committed(value)
    Keys.onReleased: root.committed(value)

    background: Item {
        x: root.leftPadding
        y: root.topPadding
        width: root.availableWidth
        height: root.availableHeight

        Rectangle {
            id: track
            width: parent.width
            height: Theme.dp(18)
            anchors.verticalCenter: parent.verticalCenter
            radius: Theme.radiusSmall
            color: Theme.trackBackground
            opacity: root.enabled ? 1 : 0.4

            Rectangle {
                width: root.visualPosition * parent.width
                height: parent.height
                radius: parent.radius
                color: Theme.trackFill
            }

            Repeater {
                model: root.tickCount > 1 ? root.tickCount - 1 : 0
                delegate: Rectangle {
                    required property int index
                    x: (index + 1) * track.width / root.tickCount
                    width: 1
                    height: Theme.dp(8)
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.p.fgA4
                }
            }
        }

        Repeater {
            model: root.labels
            delegate: RText {
                required property var modelData
                readonly property real pos: (modelData.value - root.from) / (root.to - root.from)
                y: track.y + track.height + Theme.dp(4)
                x: Math.max(0, Math.min(parent.width - width, pos * parent.width - width / 2))
                text: modelData.text
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textDim
            }
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + (root.availableHeight - height) / 2
        width: Theme.dp(8)
        height: Theme.dp(24)
        radius: Theme.radiusSmall
        color: root.enabled ? Theme.accent : Theme.iconDisabled
    }
}
