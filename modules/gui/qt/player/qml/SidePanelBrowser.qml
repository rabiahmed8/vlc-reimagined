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
import QtQuick.Controls

import VLC.MainInterface
import VLC.Style
import VLC.Widgets as Widgets
import VLC.Dialogs
import VLC.Util
import VLC.MediaLibrary

FocusScope {
    id: root

    signal closeRequested()

    property alias model: dirModel
    property bool searchActive: false

    readonly property ColorContext colorContext: ColorContext {
        id: theme
        colorSet: ColorContext.Window
    }

    LocalDirectoryModel {
        id: dirModel
    }

    function syncWithCurrentVideo() {
        if (Player.url && Player.url.toString() !== "") {
            dirModel.syncToUrl(Player.url)
        }
    }

    Component.onCompleted: {
        syncWithCurrentVideo()
    }

    Connections {
        target: Player
        function onInputChanged() {
            if (root.visible && Player.url && Player.url.toString() !== "") {
                dirModel.syncToUrl(Player.url)
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: VLCStyle.juxtSidePanel_padding
            spacing: VLCStyle.dp(8, VLCStyle.scale)

            // --- Header: Back + Breadcrumbs + Popout + Close ---
            RowLayout {
                Layout.fillWidth: true
                spacing: VLCStyle.dp(6, VLCStyle.scale)

                Widgets.IconToolButton {
                    id: backBtn
                    visible: dirModel.canCdUp
                    text: VLCIcons.back
                    description: qsTr("Go up to parent folder")
                    font.pixelSize: VLCStyle.icon_normal
                    onClicked: dirModel.cdUp()
                }

                // Breadcrumbs display
                Flickable {
                    id: breadcrumbFlickable
                    Layout.fillWidth: true
                    Layout.preferredHeight: VLCStyle.dp(30, VLCStyle.scale)
                    contentWidth: breadcrumbRow.width
                    contentHeight: height
                    clip: true
                    flickableDirection: Flickable.HorizontalFlick
                    boundsBehavior: Flickable.StopAtBounds

                    Row {
                        id: breadcrumbRow
                        spacing: VLCStyle.dp(4, VLCStyle.scale)
                        anchors.verticalCenter: parent.verticalCenter

                        Repeater {
                            model: dirModel.breadcrumbs

                            Row {
                                spacing: VLCStyle.dp(4, VLCStyle.scale)
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: "•"
                                    visible: index > 0
                                    color: theme.fg.secondary
                                    font.pixelSize: VLCStyle.fontSize_normal
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                MouseArea {
                                    id: crumbArea
                                    width: crumbText.implicitWidth + VLCStyle.dp(6, VLCStyle.scale)
                                    height: crumbText.implicitHeight + VLCStyle.dp(4, VLCStyle.scale)
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    anchors.verticalCenter: parent.verticalCenter

                                    onClicked: {
                                        dirModel.currentPath = modelData.path
                                    }

                                    Text {
                                        id: crumbText
                                        anchors.centerIn: parent
                                        text: modelData.name.length > 0 ? modelData.name : qsTr("This PC")
                                        color: (index === dirModel.breadcrumbs.length - 1)
                                               ? theme.fg.primary
                                               : (crumbArea.containsMouse ? VLCStyle.palette.orange500 : theme.fg.secondary)
                                        font.weight: (index === dirModel.breadcrumbs.length - 1) ? Font.DemiBold : Font.Normal
                                        font.pixelSize: VLCStyle.fontSize_normal
                                    }
                                }
                            }
                        }
                    }
                }

                Widgets.IconToolButton {
                    text: VLCIcons.popout
                    description: qsTr("Open in a separate window")
                    font.pixelSize: VLCStyle.icon_normal
                    onClicked: MainCtx.playqueuePanel.docked = false
                }

                Widgets.IconToolButton {
                    text: VLCIcons.close
                    description: qsTr("Close panel")
                    font.pixelSize: VLCStyle.icon_normal
                    onClicked: root.closeRequested()
                }
            }

            // --- Subheader: Item count + Sort + Search ---
            RowLayout {
                Layout.fillWidth: true
                spacing: VLCStyle.dp(8, VLCStyle.scale)

                Text {
                    Layout.fillWidth: true
                    text: qsTr("%1 items").arg(dirModel.count)
                    color: theme.fg.secondary
                    font.pixelSize: VLCStyle.fontSize_normal
                }

                Widgets.IconToolButton {
                    text: VLCIcons.search
                    description: qsTr("Search in folder")
                    font.pixelSize: VLCStyle.icon_normal
                    checked: root.searchActive
                    onClicked: {
                        root.searchActive = !root.searchActive
                        if (!root.searchActive)
                            dirModel.searchPattern = ""
                        else
                            searchField.forceActiveFocus()
                    }
                }
            }

            // --- Search Field (expandable) ---
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.searchActive ? VLCStyle.dp(32, VLCStyle.scale) : 0
                visible: root.searchActive
                color: theme.bg.secondary
                radius: VLCStyle.dp(4, VLCStyle.scale)
                border.width: 1
                border.color: VLCStyle.palette.neutral800

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: VLCStyle.dp(8, VLCStyle.scale)
                    anchors.rightMargin: VLCStyle.dp(8, VLCStyle.scale)
                    spacing: VLCStyle.dp(6, VLCStyle.scale)

                    Text {
                        text: VLCIcons.search
                        font.family: VLCIcons.fontFamily
                        font.pixelSize: VLCStyle.icon_small
                        color: theme.fg.secondary
                    }

                    TextInput {
                        id: searchField
                        Layout.fillWidth: true
                        color: theme.fg.primary
                        font.pixelSize: VLCStyle.fontSize_normal
                        clip: true
                        onTextChanged: dirModel.searchPattern = text
                    }

                    Text {
                        text: VLCIcons.close
                        font.family: VLCIcons.fontFamily
                        font.pixelSize: VLCStyle.icon_small
                        color: theme.fg.secondary
                        visible: searchField.text.length > 0
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                searchField.text = ""
                                dirModel.searchPattern = ""
                            }
                        }
                    }
                }
            }

            // --- Divider line ---
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: VLCStyle.border
                color: theme.separator
            }

            // --- Item List ---
            ListView {
                id: fileListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                focus: true
                model: dirModel
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: Widgets.ScrollBarExt { }

                header: Item {
                    width: fileListView.width
                    height: VLCStyle.dp(36, VLCStyle.scale)

                    Rectangle {
                        id: addBtnRect
                        anchors.fill: parent
                        radius: VLCStyle.dp(4, VLCStyle.scale)
                        color: addBtnArea.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VLCStyle.dp(8, VLCStyle.scale)
                            anchors.rightMargin: VLCStyle.dp(8, VLCStyle.scale)
                            spacing: VLCStyle.dp(10, VLCStyle.scale)

                            Text {
                                text: VLCIcons.add
                                font.family: VLCIcons.fontFamily
                                font.pixelSize: VLCStyle.icon_normal
                                color: VLCStyle.palette.orange500
                            }

                            Text {
                                Layout.fillWidth: true
                                text: qsTr("+ Add Media / Open File")
                                font.pixelSize: VLCStyle.fontSize_normal
                                font.weight: Font.DemiBold
                                color: VLCStyle.palette.orange500
                            }
                        }

                        MouseArea {
                            id: addBtnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: DialogsProvider.simpleOpenDialog(false)
                        }
                    }
                }

                delegate: Rectangle {
                    id: delegateRoot
                    width: fileListView.width
                    height: VLCStyle.dp(38, VLCStyle.scale)
                    radius: VLCStyle.dp(4, VLCStyle.scale)

                    readonly property bool isCurrentVideo: {
                        if (model.isFolder)
                            return false
                        if (Player.url && model.url) {
                            return Player.url.toString() === model.url ||
                                   Player.url.toString().endsWith("/" + model.name)
                        }
                        return false
                    }

                    color: {
                        if (isCurrentVideo)
                            return Qt.rgba(211/255, 121/255, 24/255, 0.15)
                        if (itemArea.containsMouse)
                            return Qt.rgba(1, 1, 1, 0.06)
                        return "transparent"
                    }

                    border.width: isCurrentVideo ? 1 : 0
                    border.color: VLCStyle.palette.orange500

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: VLCStyle.dp(8, VLCStyle.scale)
                        anchors.rightMargin: VLCStyle.dp(8, VLCStyle.scale)
                        spacing: VLCStyle.dp(10, VLCStyle.scale)

                        Text {
                            text: model.isFolder ? VLCIcons.folder : VLCIcons.topbar_video
                            font.family: VLCIcons.fontFamily
                            font.pixelSize: VLCStyle.icon_normal
                            color: {
                                if (delegateRoot.isCurrentVideo)
                                    return VLCStyle.palette.orange500
                                if (model.isFolder)
                                    return VLCStyle.palette.orange400
                                return theme.fg.secondary
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: model.name
                            elide: Text.ElideMiddle
                            font.pixelSize: VLCStyle.fontSize_normal
                            font.weight: delegateRoot.isCurrentVideo ? Font.DemiBold : Font.Normal
                            color: delegateRoot.isCurrentVideo ? VLCStyle.palette.orange500 : theme.fg.primary
                        }

                        Text {
                            visible: !model.isFolder && model.fileSize.length > 0
                            text: model.fileSize
                            color: theme.fg.secondary
                            font.pixelSize: VLCStyle.fontSize_small
                        }

                        Text {
                            visible: model.isFolder
                            text: VLCIcons.ic_fluent_chevron_right_24
                            font.family: VLCIcons.fontFamily
                            font.pixelSize: VLCStyle.icon_small
                            color: theme.fg.secondary
                        }
                    }

                    MouseArea {
                        id: itemArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (model.isFolder) {
                                dirModel.cd(model.name)
                            } else {
                                MediaLib.addAndPlay(model.url)
                            }
                        }
                    }
                }

                // Empty state
                Text {
                    anchors.centerIn: parent
                    visible: fileListView.count === 0
                    text: qsTr("No media files found")
                    color: theme.fg.secondary
                    font.pixelSize: VLCStyle.fontSize_large
                }
            }
        }
    }
}
