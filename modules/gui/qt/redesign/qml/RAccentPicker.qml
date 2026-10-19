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

// Accent color choice (Settings > General): orange is the VLC default.
Rectangle {
    id: root

    readonly property var colors: ["", "#B5432F", "#9C8424", "#2D8A34", "#1F8EA3",
                                   "#2050A6", "#7A3BC4", "#C2408C", "#8A8A8A"]
    property string current: Theme.accentSetting
    signal picked(string color)

    implicitWidth: Theme.dp(318)
    implicitHeight: Theme.dp(34)
    radius: Theme.radius
    color: Theme.p.bgB2

    Row {
        anchors.centerIn: parent
        spacing: Theme.dp(4)

        Repeater {
            model: root.colors
            delegate: T.AbstractButton {
                id: sw
                required property string modelData
                required property int index
                readonly property bool selected: modelData === root.current
                width: Theme.dp(31)
                height: Theme.dp(30)
                hoverEnabled: true
                onClicked: root.picked(modelData)
                Accessible.name: index === 0 ? qsTr("Default") : modelData

                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: sw.selected ? Theme.trackFill : sw.hovered ? Theme.p.bgA1 : "transparent"
                }
                contentItem: Item {
                    Rectangle {
                        anchors.centerIn: parent
                        width: Theme.dp(18)
                        height: Theme.dp(18)
                        radius: Theme.dp(2)
                        color: sw.modelData.length > 0 ? sw.modelData : Theme.p.accent
                    }
                }
            }
        }
    }
}
