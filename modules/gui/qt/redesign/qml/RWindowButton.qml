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
import QtQuick.Window
import QtQuick.Templates as T

import VLC.MainInterface

// Client side window button using the redesign icons.
// The fullscreen button of the design is inserted before "close".
Row {
    id: root

    property var csdButton

    visible: csdButton && csdButton.type !== CSDButton.SystemMenu

    readonly property bool isClose: csdButton && csdButton.type === CSDButton.Close
    readonly property bool fullscreen: MainCtx.intfMainWindow.visibility === Window.FullScreen

    RIconButton {
        visible: root.isClose
        iconName: root.fullscreen ? "fullscreen_active" : "fullscreen"
        toolTip: qsTr("Fullscreen")
        implicitWidth: Theme.dp(36)
        onClicked: MainCtx.toggleInterfaceFullScreen()
    }

    T.AbstractButton {
        id: btn

        implicitWidth: Theme.dp(36)
        implicitHeight: Theme.dp(28)
        hoverEnabled: true

        // let the platform know where the button is (Windows snap layouts)
        onXChanged: Qt.callLater(updateRect)
        onWidthChanged: Qt.callLater(updateRect)
        Component.onCompleted: Qt.callLater(updateRect)

        Connections {
            target: btn.Window.window
            function onWidthChanged() { Qt.callLater(btn.updateRect) }
            function onHeightChanged() { Qt.callLater(btn.updateRect) }
        }

        function updateRect() {
            if (!root.csdButton)
                return
            const p = btn.mapToItem(null, 0, 0)
            root.csdButton.rect = Qt.rect(p.x, p.y, btn.width, btn.height)
        }

        onClicked: root.csdButton.click()

        readonly property bool hot: hovered || (root.csdButton && root.csdButton.showHovered)

        background: Rectangle {
            radius: Theme.radiusSmall
            color: btn.hot ? (root.isClose ? "#C42B1C" : Theme.hover) : "transparent"
        }

        contentItem: Item {
            RIcon {
                anchors.centerIn: parent
                color: btn.hot && root.isClose ? "white" : Theme.text
                name: {
                    if (!root.csdButton)
                        return ""
                    switch (root.csdButton.type) {
                    case CSDButton.Minimize: return "minimize"
                    case CSDButton.MaximizeRestore: return "maximize"
                    case CSDButton.Close: return "close"
                    }
                    return ""
                }
            }
        }
    }
}
