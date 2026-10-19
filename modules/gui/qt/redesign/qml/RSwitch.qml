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

// ON/OFF switch of the settings ("Toggle" component in Figma):
// a dark track with a square knob, "ON" left of the knob or "OFF" right of it.
T.Switch {
    id: root

    implicitWidth: Theme.dp(66)
    implicitHeight: Theme.dp(30)
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    indicator: Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: root.checked ? Theme.trackFill : Theme.trackBackground
        border.color: (root.hovered || root.visualFocus) ? Theme.p.dividerBright : Theme.p.bgB2
        border.width: Theme.dp(2)
        opacity: root.enabled ? 1 : 0.4

        Rectangle {
            id: knob
            width: Theme.dp(24)
            height: Theme.dp(24)
            radius: Theme.radiusSmall
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? parent.width - width - Theme.dp(3) : Theme.dp(3)
            color: root.checked ? Theme.accent : Theme.p.fgA4
            Behavior on x { NumberAnimation { duration: Theme.durationShort } }
        }

        RText {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: root.checked ? parent.left : knob.right
            anchors.right: root.checked ? knob.left : parent.right
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeSmall
            text: root.checked ? qsTr("ON") : qsTr("OFF")
            color: root.checked ? Theme.accent : Theme.textDim
        }
    }

    contentItem: Item { }
}
