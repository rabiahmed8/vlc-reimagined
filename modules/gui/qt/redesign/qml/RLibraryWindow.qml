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
import VLC.MainInterface

Window {
    id: root
    title: qsTr("VLC Library")
    width: Theme.dp(1100); height: Theme.dp(760)
    minimumWidth: Theme.dp(760); minimumHeight: Theme.dp(480)
    flags: Qt.Window | Qt.FramelessWindowHint
    color: Theme.barBackground
    function openPage(page) {
        if (page.length) library.openPage(page)
        show(); raise(); requestActivate()
    }
    Rectangle {
        id: header
        width: parent.width; height: Theme.topBarHeight
        color: Theme.barBackground
        DragHandler { target: null; onActiveChanged: if (active) root.startSystemMove() }
        RIconButton { id: menuButton; iconName: "more"; onClicked: menu.popup(this, 0, height) }
        RText { anchors.centerIn: parent; text: qsTr("Library") }
        Row {
            anchors.right: parent.right
            RIconButton { iconName: "minimize"; toolTip: qsTr("Minimize"); onClicked: root.showMinimized() }
            RIconButton { iconName: "close"; toolTip: qsTr("Close library"); onClicked: root.close() }
        }
    }
    RMainMenu { id: menu }
    RLibraryView {
        id: library
        anchors.top: header.bottom; anchors.bottom: parent.bottom
        width: parent.width
        standalone: true
        onBackToPlayer: root.close()
    }
}
