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
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Templates as T

import VLC.MainInterface
import VLC.Player
import VLC.Widgets as Widgets

// Top bar of the redesign (40px): app menu, library sidebar toggle,
// current folder, centered media title and window controls.
Rectangle {
    id: root

    property bool sidebarOpen: false
    // the library sidebar lands with the library stage of the redesign
    property bool libraryAvailable: false
    property string locationName: ""
    property alias menuButton: menuBtn

    signal menuRequested()
    signal sidebarToggled()
    signal locationClicked()

    readonly property bool fullscreen: MainCtx.intfMainWindow.visibility === Window.FullScreen
    readonly property bool showWindowButtons: MainCtx.clientSideDecoration && !fullscreen

    implicitHeight: Theme.topBarHeight
    color: Qt.rgba(Theme.barBackground.r, Theme.barBackground.g, Theme.barBackground.b, 0.95)

    // drag to move / double click to maximize (CSD only)
    Loader {
        anchors.fill: parent
        active: MainCtx.clientSideDecoration && !root.fullscreen
        sourceComponent: Widgets.CSDTitlebarTapNDrapHandler { }
    }

    // In fullscreen the menu sits in the screen corner: the whole corner, from the
    // screen edges to the "..." button and including the cone, opens the menu
    // (aiming at a 30 px button near the edge is hard, throwing the mouse into
    // the corner is easy).
    T.AbstractButton {
        id: cornerHit
        visible: root.fullscreen
        z: 1
        x: 0
        y: 0
        width: menuBtn.mapToItem(root, menuBtn.width, 0).x + Theme.dp(4)
        height: root.height
        hoverEnabled: true
        onClicked: root.menuRequested()
        Accessible.name: qsTr("Menu")
        background: Item { }
    }
    Binding { target: menuBtn; property: "forceHovered"; value: cornerHit.hovered; when: cornerHit.visible }

    Item {
        anchors.fill: parent
        anchors.margins: Theme.dp(6)

        RowLayout {
            id: leftGroup
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.dp(7)

            RIcon {
                Layout.leftMargin: Theme.dp(7)
                Layout.rightMargin: Theme.dp(7)
                name: "logo"
                color: Theme.p.logo
                accentColor: Theme.p.logo
            }

            RIconButton {
                id: menuBtn
                iconName: "more"
                toolTip: qsTr("Menu")
                onClicked: root.menuRequested()
            }

            RIconButton {
                visible: root.libraryAvailable
                iconName: "sidebar_left"
                toolTip: qsTr("Library")
                checked: root.sidebarOpen
                onClicked: root.sidebarToggled()
            }

            // vertical divider
            Rectangle {
                visible: root.libraryAvailable
                implicitWidth: 1
                implicitHeight: Theme.dp(16)
                color: Theme.p.dividerBright
                Layout.leftMargin: Theme.dp(4)
                Layout.rightMargin: Theme.dp(4)
            }

            T.AbstractButton {
                id: locationBtn
                visible: root.libraryAvailable && root.locationName.length > 0
                hoverEnabled: true
                implicitHeight: Theme.dp(28)
                implicitWidth: Math.min(locationRow.implicitWidth + Theme.dp(8), root.width * 0.26)
                onClicked: root.locationClicked()

                background: Rectangle {
                    radius: Theme.radius
                    color: locationBtn.hovered ? Theme.hover : "transparent"
                }
                contentItem: Item {
                    Row {
                        id: locationRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.dp(4)
                        RIcon { name: "folder"; anchors.verticalCenter: parent.verticalCenter }
                        RText { text: root.locationName; width: Math.max(0, locationBtn.width - Theme.dp(32)); anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }
        }

        RText {
            id: title
            anchors.centerIn: parent
            width: Math.max(0, Math.min(implicitWidth, parent.width - 2 * Math.max(leftGroup.width, rightGroup.width) - Theme.dp(24)))
            horizontalAlignment: Text.AlignHCenter
            text: {
                if (Player.isStarted && Player.title.length > 0)
                    return Player.title
                if (Player.isStarted && Player.name.length > 0)
                    return Player.name
                return qsTr("VLC Media Player")
            }
        }

        RowLayout {
            id: rightGroup
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Repeater {
                model: RBarCatalog.topExtras
                delegate: RBarItem {
                    required property string modelData
                    itemId: modelData
                    Layout.preferredWidth: implicitWidth
                    Layout.preferredHeight: implicitHeight
                }
            }

            Repeater {
                model: root.showWindowButtons ? MainCtx.csdButtonModel.windowCSDButtons : []

                delegate: RWindowButton {
                    required property var modelData
                    csdButton: modelData
                }
            }

            RIconButton {
                visible: !root.showWindowButtons
                iconName: root.fullscreen ? "fullscreen_active" : "fullscreen"
                toolTip: root.fullscreen ? qsTr("Exit fullscreen") : qsTr("Fullscreen")
                onClicked: MainCtx.toggleInterfaceFullScreen()
            }
        }
    }
}
