/*****************************************************************************
 * Copyright (C) 2019 VLC authors and VideoLAN
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
import QtQuick.Layouts
import QtQml.Models
import QtQuick.Window


import VLC.MainInterface
import VLC.Style
import VLC.Playlist
import VLC.Player
import VLC.Widgets as Widgets
import VLC.Menus as Menus
import VLC.Util

T.ToolBar {
    id: root

    Accessible.name: qsTr("Local top bar")
    AccessibleCompat.id: "localTopbar"

    property bool useAcrylic: true

    // For now, used for d&d functionality
    // Not strictly necessary to set
    property Item plListView

    property bool _showCSD: MainCtx.clientSideDecoration
        && !(MainCtx.intfMainWindow.visibility === Window.FullScreen)
        && !MainCtx.hasToolbarMenu

    //whether the navigation pannel is actually visible or not
    property alias navigationVisible: navigationVisibilty.checked
    property alias playqueueVisible: playlistBtn.checked

    property alias navigationButton: navigationVisibilty

    signal toggleNavigationVisibility()
    signal togglePlayqueueVisibility()

    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                             implicitContentWidth + leftPadding + rightPadding + (_showCSD ? csdButtons.implicitWidth : 0))

    readonly property ColorContext colorContext: ColorContext {
        id: theme
        colorSet: ColorContext.Window
    }

    // Juxtopposed: the title bar is solid chrome, like the player's.
    background: Rectangle {
        color: theme.bg.primary
    }

    contentItem: Item {

        implicitHeight: VLCStyle.globalToolbar_height
        implicitWidth: navigationButtons.implicitWidth
                     + playqueueButtonsTop.implicitWidth
                     + VLCStyle.margin_xsmall * 2

        Item {
            id: navigationButtons

            implicitWidth: navigationButtonsRow.implicitWidth

            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                leftMargin: VLCStyle.margin_xsmall
            }

            Navigation.parentItem: root

            Row {
                id: navigationButtonsRow

                anchors.verticalCenter: parent.verticalCenter
                spacing: VLCStyle.margin_normal

                Navigation.parentItem: root
                Navigation.rightItem: playqueueButtonsTop

                // Juxtopposed order: cone, menu, side bar toggle, back.
                Widgets.BannerCone {
                    id: logo

                    anchors.verticalCenter: parent.verticalCenter
                    color: theme.accent
                }

                Widgets.IconToolButton {
                    id: menuBtn

                    anchors.verticalCenter: parent.verticalCenter
                    visible: !MainCtx.hasToolbarMenu
                    font.pixelSize: VLCStyle.icon_normal
                    text: VLCIcons.more
                    description: qsTr("Menu")
                    checked: contextMenu.shown

                    Navigation.parentItem: navigationButtons
                    Navigation.rightItem: navigationVisibilty

                    onClicked: contextMenu.popup(this.mapToGlobal(0, height))

                    Menus.QmlGlobalMenu {
                        id: contextMenu
                        ctx: MainCtx
                    }
                }

                Widgets.IconToolButton {
                    id: navigationVisibilty

                    anchors.verticalCenter: parent.verticalCenter

                    focus: true

                    text: VLCIcons.panel_left
                    description: qsTr("Show navigation menu")

                    AccessibleCompat.id: "sidebarToggleButton"

                    font.pixelSize: VLCStyle.icon_normal

                    onClicked: root.toggleNavigationVisibility()

                    Navigation.parentItem: navigationButtons
                    Navigation.leftItem: menuBtn
                    Navigation.rightItem: historyBack
                }

                Widgets.IconToolButton {
                    id: historyBack

                    anchors.verticalCenter: parent.verticalCenter

                    font.pixelSize: VLCStyle.icon_normal
                    text: VLCIcons.back
                    description: qsTr("Previous")

                    AccessibleCompat.id: "historyBackButton"

                    onClicked: History.previous()
                    enabled: !History.previousEmpty

                    onEnabledChanged: {
                        if (historyBack.activeFocus)
                            navigationVisibilty.focus = true
                    }

                    Navigation.parentItem: navigationButtons
                    Navigation.leftItem: navigationVisibilty
                    Navigation.rightItem: playlistBtn
                }
            }
        }

        T.Label {
            id: windowTitle

            anchors.centerIn: parent
            width: Math.min(implicitWidth,
                            2 * Math.min(parent.width / 2 - navigationButtons.x - navigationButtons.width,
                                         playqueueButtonsTop.x - parent.width / 2) - VLCStyle.margin_normal)

            text: (Player.title !== "") ? Player.title : qsTr("VLC media player")
            color: theme.fg.primary
            font.pixelSize: VLCStyle.fontSize_large
            elide: Text.ElideRight
        }

        Item {
            id: playqueueButtonsTop

            implicitWidth: playqueueButtonsTopRow.implicitWidth

            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                //put the buttons below the CSD if we have enough space
                rightMargin: VLCStyle.margin_xsmall
                    + ((root._showCSD && root.topPadding < csdButtons.height)
                        ? Math.max(csdButtons.width - root.rightPadding, 0)
                        : 0)
            }

            Navigation.parentItem: root

            Row {
                id: playqueueButtonsTopRow

                anchors.verticalCenter: parent.verticalCenter
                spacing: VLCStyle.margin_normal

                Navigation.parentItem: root
                Navigation.leftItem: navigationButtons

                PlaylistPane.PlaylistToggleButton {
                    id: playlistBtn

                    plListView: root.plListView

                    Navigation.parentItem: playqueueButtonsTop
                    Navigation.leftItem: historyBack

                    onClicked:  root.togglePlayqueueVisibility()
                }
            }
        }

        Loader {
            z: -1

            anchors.fill: parent
            active: root._showCSD
            sourceComponent: Widgets.CSDTitlebarTapNDrapHandler {
            }
        }
    }

    Loader {
        id: csdButtons

        //csd button are
        parent:  root
        anchors {
            right: parent.right
            top: parent.top
        }

        height: VLCStyle.globalToolbar_height
        active: root._showCSD
        source: VLCStyle.palette.hasCSDImage
                  ? "qrc:///qt/qml/VLC/Widgets/CSDThemeButtonSet.qml"
                  : "qrc:///qt/qml/VLC/Widgets/CSDWindowButtonSet.qml"
    }
}
