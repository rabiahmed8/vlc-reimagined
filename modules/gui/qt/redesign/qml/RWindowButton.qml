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
// The fullscreen button is part of the CSD button model, so this delegate only
// renders the button it is given (the old version inserted a second fullscreen
// button before close, which left an empty slot in the title bar).
T.AbstractButton {
    id: root

    property var csdButton

    visible: csdButton && csdButton.type !== CSDButton.SystemMenu

    readonly property bool isClose: csdButton && csdButton.type === CSDButton.Close
    readonly property bool maximized: MainCtx.intfMainWindow.visibility === Window.Maximized
    readonly property bool fullscreen: MainCtx.intfMainWindow.visibility === Window.FullScreen

    // A maximized window has no frame to keep the close button away from the
    // screen corner, so let it fill the corner like the design reference.
    readonly property bool flushToCorner: isClose && maximized

    implicitWidth: Theme.dp(flushToCorner ? 42 : 36)
    implicitHeight: Theme.dp(flushToCorner ? 40 : 36)

    padding: 0
    focusPolicy: Qt.TabFocus
    hoverEnabled: true

    readonly property bool hot: hovered || (csdButton && csdButton.showHovered)

    readonly property string label: {
        if (!csdButton)
            return ""
        switch (csdButton.type) {
        case CSDButton.Minimize: return qsTr("Minimize")
        case CSDButton.MaximizeRestore: return maximized ? qsTr("Restore") : qsTr("Maximize")
        case CSDButton.Fullscreen: return fullscreen ? qsTr("Exit fullscreen") : qsTr("Fullscreen")
        case CSDButton.Close: return qsTr("Close")
        }
        return ""
    }

    Accessible.name: label

    onClicked: if (csdButton) csdButton.click()

    // let the platform know where the button is (Windows snap layouts)
    onXChanged: Qt.callLater(updateRect)
    onWidthChanged: Qt.callLater(updateRect)
    Component.onCompleted: Qt.callLater(updateRect)

    Connections {
        target: root.Window.window
        function onWidthChanged() { Qt.callLater(root.updateRect) }
        function onHeightChanged() { Qt.callLater(root.updateRect) }
    }

    function updateRect() {
        if (!root.csdButton)
            return
        const p = root.mapToItem(null, 0, 0)
        root.csdButton.rect = Qt.rect(p.x, p.y, root.width, root.height)
    }

    background: Rectangle {
        radius: Theme.radius
        color: root.hot ? Theme.hover
             : root.visualFocus ? Theme.pressed
             : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.durationShort } }
    }

    contentItem: Item {
        RIcon {
            anchors.centerIn: parent
            color: root.hot || root.visualFocus ? Theme.textStrong : Theme.text
            name: {
                if (!root.csdButton)
                    return ""
                switch (root.csdButton.type) {
                case CSDButton.Minimize: return "minimize"
                case CSDButton.MaximizeRestore: return root.maximized ? "restore" : "maximize"
                case CSDButton.Fullscreen: return root.fullscreen ? "fullscreen_active" : "fullscreen"
                case CSDButton.Close: return "close"
                }
                return ""
            }
        }
    }

    RToolTip {
        text: root.label
        visible: root.hovered && root.label.length > 0
    }
}
