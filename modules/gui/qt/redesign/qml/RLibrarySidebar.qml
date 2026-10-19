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

// Sidebar of the library (Figma "Player-1"): Home, Videos, Music, Network,
// Playlists, Recent and "Add item".
Rectangle {
    id: root

    property string currentPage: "home"
    property bool compact: false
    property var pinnedRoutes: []
    signal pinnedRequested(int index)
    signal unpinRequested(int index)
    signal pageRequested(string page)
    signal addRequested()

    radius: Theme.radiusLarge
    color: Theme.p.bgA3

    // icons that have a filled "_active" variant
    readonly property var activeIcons: ["home", "videos", "songs", "streaming", "playlist"]

    readonly property var entries: [
        { page: "home", text: qsTr("Home"), icon: "home" },
        { page: "videos", text: qsTr("Videos"), icon: "videos" },
        { page: "music", text: qsTr("Music"), icon: "songs" },
        { page: "network", text: qsTr("Network"), icon: "streaming" },
        { page: "playlists", text: qsTr("Playlists"), icon: "playlist" },
        { page: "recent", text: qsTr("Recent"), icon: "recent" },
        { page: "", text: qsTr("Add item"), icon: "add" }
    ]

    Flickable {
        anchors.fill: parent
        clip: true
        contentHeight: sidebarColumn.height + Theme.dp(20)
    Column {
        id: sidebarColumn
        x: Theme.dp(8)
        y: Theme.dp(10)
        width: root.width - Theme.dp(16)
        spacing: Theme.dp(2)

        Repeater {
            model: root.entries
            delegate: T.AbstractButton {
                id: btn
                required property var modelData
                readonly property bool selected: modelData.page === root.currentPage
                width: parent.width
                height: Theme.dp(44)
                hoverEnabled: true
                onClicked: modelData.page.length > 0 ? root.pageRequested(modelData.page) : root.addRequested()
                Accessible.name: modelData.text

                background: Rectangle {
                    radius: Theme.radius
                    color: btn.selected ? Theme.p.bgA1 : btn.hovered ? Theme.hover : "transparent"
                }
                contentItem: Item {
                    RIcon {
                        id: icon
                        x: root.compact ? (parent.width - width) / 2 : Theme.dp(10)
                        anchors.verticalCenter: parent.verticalCenter
                        name: btn.selected && root.activeIcons.indexOf(btn.modelData.icon) >= 0 ? btn.modelData.icon + "_active" : btn.modelData.icon
                        color: btn.selected ? Theme.accent : Theme.textItem
                        size: Theme.iconSizeSmall + Theme.dp(2)
                    }
                    RText {
                        visible: !root.compact
                        anchors.left: icon.right
                        anchors.leftMargin: Theme.dp(12)
                        anchors.verticalCenter: parent.verticalCenter
                        text: btn.modelData.text
                        color: btn.selected ? Theme.textStrong : Theme.textItem
                    }
                }
            }
        }
        RText { visible: root.pinnedRoutes.length > 0 && !root.compact; text: qsTr("Pinned"); color: Theme.textDim }
        Repeater {
            model: root.pinnedRoutes
            delegate: Item {
                required property var modelData
                required property int index
                width: sidebarColumn.width
                height: Theme.dp(40)
                RButton {
                    width: parent.width - (root.compact ? 0 : Theme.dp(30))
                    text: root.compact ? "★" : parent.modelData.title
                    onClicked: root.pinnedRequested(parent.index)
                }
                RIconButton {
                    visible: !root.compact
                    anchors.right: parent.right
                    iconName: "close"
                    toolTip: qsTr("Unpin")
                    onClicked: root.unpinRequested(parent.index)
                }
            }
        }
    }
    }
}
