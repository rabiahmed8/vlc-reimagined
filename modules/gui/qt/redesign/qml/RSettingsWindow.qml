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
import VLC.Dialogs

// Settings window of the redesign (Figma "Settings - *"): search and categories on the
// left, the page of the selected category on the right. Frameless, with its own title row.
Window {
    id: root

    property string category: "general"

    function openCategory(key) {
        if (key)
            category = key
        searchField.text = ""
        show()
        raise()
        requestActivate()
    }

    readonly property var categories: [
        { group: qsTr("App") },
        { key: "general",     text: qsTr("General"),     icon: "preferences", title: qsTr("Global Settings"),                    page: "RSettingsGeneral.qml" },
        { key: "interface",   text: qsTr("Interface"),   icon: "interface",   title: qsTr("Interface Settings"),                 page: "RSettingsInterface.qml" },
        { key: "privacy",     text: qsTr("Privacy"),     icon: "privacy",     title: qsTr("Privacy Settings"),                   page: "RSettingsPrivacy.qml" },
        { key: "controls",    text: qsTr("Controls"),    icon: "hotkeys",     title: qsTr("Mouse, Keyboard & Remote Controls"),  page: "RSettingsControls.qml" },
        { group: qsTr("Media") },
        { key: "playback",    text: qsTr("Playback"),    icon: "playback",    title: qsTr("Playback Preferences"),               page: "RSettingsPlayback.qml" },
        { key: "video",       text: qsTr("Video"),       icon: "video",       title: qsTr("Video Defaults"),                     page: "RSettingsVideo.qml" },
        { key: "audio",       text: qsTr("Audio"),       icon: "audio",       title: qsTr("Audio Defaults"),                     page: "RSettingsAudio.qml" },
        { key: "subtitles",   text: qsTr("Subtitles"),   icon: "subtitles",   title: qsTr("Subtitle Defaults"),                  page: "RSettingsSubtitles.qml" },
        { key: "library",     text: qsTr("Library"),     icon: "folder",      title: qsTr("Playlists, Folders & Files"),         page: "RSettingsLibrary.qml" },
        { group: qsTr("System") },
        { key: "network",     text: qsTr("Network"),     icon: "streaming",   title: qsTr("Network Connections & Security"),     page: "RSettingsNetwork.qml" },
        { key: "performance", text: qsTr("Performance"), icon: "settings",    title: qsTr("Performance Settings"),               page: "RSettingsPerformance.qml" },
        { key: "recording",   text: qsTr("Recording"),   icon: "record",      title: qsTr("Recording, Casting & Streaming Out"), page: "RSettingsRecording.qml" },
        { key: "extensions",  text: qsTr("Extensions"),  icon: "plugins",     title: qsTr("Add-ons & Scripts"),                  page: "RSettingsExtensions.qml" }
    ]

    readonly property var current: {
        for (const c of categories)
            if (c.key === category)
                return c
        return categories[1]
    }

    title: qsTr("Settings")
    width: Theme.dp(1048)
    height: Theme.dp(864)
    minimumWidth: Theme.dp(760)
    minimumHeight: Theme.dp(480)
    flags: Qt.Window | Qt.FramelessWindowHint
    color: Theme.p.bgA5

    onClosing: RedesignSettings.save()

    Shortcut { sequence: "Esc"; onActivated: root.close() }
    Shortcut { sequence: StandardKey.Find; onActivated: searchField.forceActiveFocus() }

    // resize from the edges and corners (the window has no system frame)
    Repeater {
        model: [
            { e: Qt.LeftEdge, x: 0, y: 6, w: 6, h: -12, c: Qt.SizeHorCursor },
            { e: Qt.RightEdge, x: -6, y: 6, w: 6, h: -12, c: Qt.SizeHorCursor },
            { e: Qt.TopEdge, x: 6, y: 0, w: -12, h: 6, c: Qt.SizeVerCursor },
            { e: Qt.BottomEdge, x: 6, y: -6, w: -12, h: 6, c: Qt.SizeVerCursor },
            { e: Qt.LeftEdge | Qt.TopEdge, x: 0, y: 0, w: 6, h: 6, c: Qt.SizeFDiagCursor },
            { e: Qt.RightEdge | Qt.BottomEdge, x: -6, y: -6, w: 6, h: 6, c: Qt.SizeFDiagCursor },
            { e: Qt.RightEdge | Qt.TopEdge, x: -6, y: 0, w: 6, h: 6, c: Qt.SizeBDiagCursor },
            { e: Qt.LeftEdge | Qt.BottomEdge, x: 0, y: -6, w: 6, h: 6, c: Qt.SizeBDiagCursor }
        ]
        delegate: MouseArea {
            required property var modelData
            z: 10
            x: modelData.x < 0 ? root.width + modelData.x : modelData.x
            y: modelData.y < 0 ? root.height + modelData.y : modelData.y
            width: modelData.w < 0 ? root.width + modelData.w : modelData.w
            height: modelData.h < 0 ? root.height + modelData.h : modelData.h
            cursorShape: modelData.c
            onPressed: root.startSystemResize(modelData.e)
        }
    }

    Rectangle {
        id: frame
        anchors.fill: parent
        color: Theme.p.bgA3
        border.color: Theme.p.dividerDim
        border.width: 1

        // ---- left column: search + categories
        Item {
            id: side
            width: Theme.dp(208)
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left

            Rectangle {
                anchors.fill: parent
                color: Theme.p.bgB1Transparent
            }

            Item {
                id: searchBox
                height: Theme.dp(50)
                width: parent.width

                DragHandler {
                    target: null
                    onActiveChanged: if (active) root.startSystemMove()
                }

                RTextField {
                    id: searchField
                    anchors.fill: parent
                    anchors.margins: Theme.dp(8)
                    leftPadding: Theme.dp(36)
                    placeholderText: qsTr("Search")
                    background: Rectangle {
                        radius: Theme.radius
                        color: Theme.p.bgA3
                        border.color: searchField.activeFocus ? Theme.p.dividerBright : "transparent"
                    }
                    RIcon {
                        x: Theme.dp(10)
                        anchors.verticalCenter: parent.verticalCenter
                        name: "search"
                        size: Theme.iconSizeSmall
                        color: Theme.textDim
                    }
                }
            }

            Rectangle {
                anchors.top: searchBox.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Theme.dp(8)
                anchors.topMargin: 0
                radius: Theme.radiusLarge
                color: Theme.p.bgA3

                ListView {
                    id: categoryList
                    anchors.fill: parent
                    anchors.margins: Theme.dp(6)
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.categories
                    keyNavigationEnabled: true

                    delegate: Loader {
                        id: entry
                        required property var modelData
                        width: ListView.view.width
                        sourceComponent: modelData.group !== undefined ? groupComponent : itemComponent

                        Component {
                            id: groupComponent
                            RText {
                                height: Theme.dp(42)
                                leftPadding: Theme.dp(10)
                                text: entry.modelData.group
                                color: Theme.textDim
                            }
                        }

                        Component {
                            id: itemComponent
                            T.AbstractButton {
                                id: btn
                                readonly property bool selected: root.category === entry.modelData.key && searchField.text.length === 0
                                height: Theme.dp(44)
                                hoverEnabled: true
                                onClicked: { searchField.text = ""; root.category = entry.modelData.key }

                                background: Rectangle {
                                    radius: Theme.radius
                                    color: btn.selected ? Theme.p.bgA1 : btn.hovered ? Theme.hover : "transparent"
                                }
                                contentItem: Item {
                                    RIcon {
                                        id: icon
                                        x: Theme.dp(8)
                                        anchors.verticalCenter: parent.verticalCenter
                                        name: btn.selected ? entry.modelData.icon + "_active" : entry.modelData.icon
                                        color: btn.selected ? Theme.accent : Theme.textItem
                                    }
                                    RText {
                                        anchors.left: icon.right
                                        anchors.leftMargin: Theme.dp(12)
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: entry.modelData.text
                                        color: btn.selected ? Theme.textStrong : Theme.textItem
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ---- right column: title row + page
        Item {
            id: main
            anchors.left: side.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            Rectangle {
                id: header
                width: parent.width
                height: Theme.dp(50)
                color: Theme.p.bgB1Transparent

                DragHandler {
                    target: null
                    onActiveChanged: if (active) root.startSystemMove()
                }

                RText {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.dp(24)
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.textStrong
                    text: searchField.text.length > 0 ? qsTr("Search results") : root.current.title
                }

                RIconButton {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.dp(14)
                    anchors.verticalCenter: parent.verticalCenter
                    iconName: "close"
                    toolTip: qsTr("Close")
                    onClicked: root.close()
                }
            }

            Loader {
                id: pageLoader
                anchors.top: header.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                active: root.visible && searchField.text.length === 0
                source: root.current.page
            }

            RSettingsSearchPage {
                anchors.fill: pageLoader
                visible: searchField.text.length > 0
                text: searchField.text
            }
        }
    }
}
