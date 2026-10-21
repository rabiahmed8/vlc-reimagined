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

import VLC.MainInterface
import VLC.Player
import VLC.Playlist
import VLC.Util

// Library > Folders: a file explorer of the computer, independent of the media
// library. It browses the drives and the folders, lists the media files they
// contain and plays them (Figma "file explorer").
Item {
    id: root

    property var library

    function openPath(path) {
        dirModel.currentPath = String(path === undefined || path === null ? "" : path)
    }

    function itemName(item) {
        return item ? String(item.name || "") : ""
    }
    function itemPath(item) {
        return item ? String(item.path || "") : ""
    }
    function itemUrl(item) {
        return item ? String(item.url || "") : ""
    }
    function isFolder(item) {
        return !!(item && item.isFolder)
    }
    function isAudio(item) {
        return !!(item && item.isAudio)
    }
    function itemSize(item) {
        return item && !item.isFolder ? String(item.fileSize || "") : ""
    }
    function itemThumbnail(item) {
        return item ? String(item.thumbnail || "") : ""
    }
    function itemDate(item) {
        if (!item || !item.fileDate)
            return ""
        return Qt.formatDateTime(item.fileDate, "yyyy-MM-dd HH:mm")
    }

    function sameUrl(a, b) {
        try {
            return decodeURIComponent(String(a)) === decodeURIComponent(String(b))
        } catch (e) {
            return String(a) === String(b)
        }
    }
    function isCurrent(item) {
        return Player.isStarted && root.sameUrl(Player.url, root.itemUrl(item))
    }

    function activate(item) {
        if (!item)
            return
        if (root.isFolder(item))
            dirModel.currentPath = root.itemPath(item)
        else
            root.playUrl(root.itemUrl(item))
    }

    function playUrl(url) {
        if (String(url).length === 0)
            return
        MainPlaylistController.append([String(url)], true)
    }

    function playAll() {
        const urls = dirModel.mediaUrls()
        if (urls.length === 0)
            return
        MainPlaylistController.append(urls, true)
    }

    function enqueue(url) {
        if (String(url).length === 0)
            return
        MainPlaylistController.append([String(url)], false)
    }

    function openInExplorer(url) {
        const target = String(url === undefined || url === null || url === "" ? dirModel.currentUrl : url)
        if (target.length > 0)
            Qt.openUrlExternally(target)
    }

    function showInExplorer(url) {
        const directory = RedesignSettings.directoryOf(String(url || ""))
        if (directory.length > 0)
            Qt.openUrlExternally(directory)
        else
            root.openInExplorer(url)
    }

    function openContextMenu(item, globalPos) {
        contextMenu.item = item
        const p = root.mapFromGlobal(globalPos.x, globalPos.y)
        contextMenu.popup(p.x, p.y)
    }

    function focusGrid(index) {
        gridView.currentIndex = index
        gridView.forceActiveFocus()
    }
    function focusList(index) {
        listView.currentIndex = index
        listView.forceActiveFocus()
    }

    LocalDirectoryModel {
        id: dirModel
        thumbnailsEnabled: true
        searchPattern: root.library ? root.library.searchPattern : ""
        onCurrentPathChanged: {
            if (!root.library)
                return
            if (!root.library.route.params)
                root.library.route.params = ({})
            root.library.route.params.directory = dirModel.currentPath
        }
    }

    Binding { target: root.library; property: "itemCount"; value: dirModel.count; when: !!root.library }
    Binding { target: root.library; property: "sortKeys"; value: []; when: !!root.library }

    Component.onCompleted: {
        if (root.library && root.library.route.params
                && root.library.route.params.directory !== undefined)
            openPath(root.library.route.params.directory)
    }

    // ---- toolbar: up, breadcrumb, play all, open in explorer
    Item {
        id: toolbar
        width: parent.width
        height: Theme.dp(44)

        RIconButton {
            id: upButton
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            iconName: "arrow_up"
            toolTip: qsTr("Up")
            enabled: dirModel.canCdUp
            onClicked: dirModel.cdUp()
        }

        RIconButton {
            id: refreshButton
            anchors.right: openButton.left
            anchors.rightMargin: Theme.dp(2)
            anchors.verticalCenter: parent.verticalCenter
            iconName: "refresh"
            toolTip: qsTr("Refresh")
            onClicked: dirModel.refresh()
        }

        RIconButton {
            id: openButton
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            iconName: "folder_2t"
            toolTip: qsTr("Open in File Explorer")
            enabled: dirModel.currentPath.length > 0
            onClicked: root.openInExplorer()
        }

        RChip {
            id: playAllButton
            anchors.right: refreshButton.left
            anchors.rightMargin: Theme.dp(10)
            anchors.verticalCenter: parent.verticalCenter
            iconName: "play"
            text: qsTr("Play all")
            enabled: dirModel.mediaCount > 0
            onClicked: root.playAll()
        }

        Flickable {
            id: crumbs
            anchors.left: upButton.right
            anchors.leftMargin: Theme.dp(10)
            anchors.right: playAllButton.left
            anchors.rightMargin: Theme.dp(12)
            anchors.verticalCenter: parent.verticalCenter
            height: Theme.dp(30)
            contentWidth: crumbRow.width
            contentHeight: crumbRow.height
            clip: true
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds

            Row {
                id: crumbRow
                width: implicitWidth
                height: crumbs.height
                spacing: Theme.dp(2)

                Repeater {
                    model: dirModel.breadcrumbs
                    delegate: Row {
                        id: crumb
                        required property var modelData
                        required property int index
                        readonly property bool last: index === dirModel.breadcrumbs.length - 1
                        height: crumbRow.height
                        spacing: Theme.dp(2)

                        RIcon {
                            visible: crumb.index > 0
                            anchors.verticalCenter: parent.verticalCenter
                            name: "arrow_right"
                            size: Theme.dp(12)
                            color: Theme.textDim
                        }
                        T.AbstractButton {
                            id: crumbButton
                            anchors.verticalCenter: parent.verticalCenter
                            implicitWidth: crumbText.implicitWidth + Theme.dp(12)
                            implicitHeight: Theme.dp(26)
                            hoverEnabled: true
                            enabled: !crumb.last
                            onClicked: dirModel.currentPath = String(crumb.modelData.path || "")
                            Accessible.name: String(crumb.modelData.name || "")

                            background: Rectangle {
                                radius: Theme.radiusSmall
                                color: crumbButton.hovered && crumbButton.enabled ? Theme.hover : "transparent"
                            }
                            contentItem: RText {
                                id: crumbText
                                text: String(crumb.modelData.name || "")
                                horizontalAlignment: Text.AlignHCenter
                                font.weight: crumb.last ? Font.DemiBold : Font.Normal
                                color: crumb.last || crumbButton.hovered ? Theme.textStrong : Theme.textItem
                            }
                        }
                    }
                }
            }
        }
    }

    // ---- grid
    GridView {
        id: gridView
        anchors.top: toolbar.bottom
        anchors.topMargin: Theme.dp(10)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: !root.library || root.library.grid
        model: dirModel
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: Theme.dp(400)
        T.ScrollBar.vertical: RScrollBar { }

        readonly property int columns: Math.max(1, Math.floor((width + Theme.dp(20)) / Theme.dp(220)))
        cellWidth: Math.floor(width / columns)
        cellHeight: (cellWidth - Theme.dp(20)) * 9 / 16 + Theme.dp(66)

        delegate: T.AbstractButton {
            id: gridCell
            required property var model
            required property int index

            readonly property bool current: root.isCurrent(model)

            width: gridView.cellWidth
            height: gridView.cellHeight
            hoverEnabled: true
            onClicked: {
                root.focusGrid(index)
                root.activate(model)
            }
            Accessible.name: root.itemName(model)
            background: Item { }

            TapHandler {
                acceptedButtons: Qt.RightButton
                onTapped: (point) => {
                    gridView.currentIndex = gridCell.index
                    root.openContextMenu(gridCell.model,
                                         gridCell.mapToGlobal(point.position.x, point.position.y))
                }
            }

            Item {
                anchors.fill: parent
                anchors.rightMargin: Theme.dp(20)

                Rectangle {
                    id: thumb
                    width: parent.width
                    height: width * 9 / 16
                    radius: Theme.radiusLarge
                    color: Theme.p.bgA1
                    clip: true
                    border.color: gridCell.hovered ? Theme.p.dividerBright : "transparent"

                    Image {
                        id: thumbImage
                        anchors.fill: parent
                        source: root.itemThumbnail(gridCell.model)
                        visible: status === Image.Ready
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: width
                    }
                    RIcon {
                        anchors.centerIn: parent
                        visible: thumbImage.status !== Image.Ready
                        name: root.isFolder(gridCell.model) ? "folder"
                              : root.isAudio(gridCell.model) ? "music" : "video"
                        size: Theme.dp(40)
                        color: gridCell.current ? Theme.accent : Theme.textDim
                    }
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: gridCell.pressed ? Theme.pressed : gridCell.hovered ? Theme.hover : "transparent"
                    }
                }

                RText {
                    id: gridName
                    anchors.top: thumb.bottom
                    anchors.topMargin: Theme.dp(10)
                    width: parent.width
                    text: root.itemName(gridCell.model)
                    font.pixelSize: Theme.fontSizeLarge
                    color: gridCell.current ? Theme.accent : Theme.textItem
                }
                RText {
                    anchors.top: gridName.bottom
                    anchors.topMargin: Theme.dp(2)
                    width: parent.width
                    text: root.isFolder(gridCell.model) ? qsTr("Folder") : root.itemSize(gridCell.model)
                    color: Theme.textDim
                }
            }
        }
    }

    // ---- list
    ListView {
        id: listView
        anchors.top: toolbar.bottom
        anchors.topMargin: Theme.dp(10)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: root.library && !root.library.grid
        model: dirModel
        clip: true
        spacing: Theme.dp(2)
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: Theme.dp(400)
        T.ScrollBar.vertical: RScrollBar { }

        delegate: T.AbstractButton {
            id: listCell
            required property var model
            required property int index

            readonly property bool current: root.isCurrent(model)

            width: listView.width
            height: Theme.dp(44)
            hoverEnabled: true
            onClicked: {
                root.focusList(index)
                root.activate(model)
            }
            Accessible.name: root.itemName(model)

            background: Rectangle {
                radius: Theme.radiusSmall
                color: listCell.current ? Theme.trackBackground
                     : listCell.pressed ? Theme.pressed
                     : listCell.hovered ? Theme.hover : "transparent"
            }

            TapHandler {
                acceptedButtons: Qt.RightButton
                onTapped: (point) => {
                    listView.currentIndex = listCell.index
                    root.openContextMenu(listCell.model,
                                         listCell.mapToGlobal(point.position.x, point.position.y))
                }
            }

            contentItem: Item {
                Rectangle {
                    id: listIcon
                    width: Theme.dp(32)
                    height: Theme.dp(32)
                    anchors.verticalCenter: parent.verticalCenter
                    radius: Theme.radiusSmall
                    color: Theme.p.bgA1

                    RIcon {
                        anchors.centerIn: parent
                        name: root.isFolder(listCell.model) ? "folder"
                              : root.isAudio(listCell.model) ? "music" : "video"
                        size: Theme.iconSizeSmall
                        color: listCell.current ? Theme.accent : Theme.textDim
                    }
                }
                RText {
                    anchors.left: listIcon.right
                    anchors.leftMargin: Theme.dp(12)
                    anchors.right: listSize.left
                    anchors.rightMargin: Theme.dp(12)
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.itemName(listCell.model)
                    color: listCell.current ? Theme.accent : Theme.textItem
                }
                RText {
                    id: listSize
                    anchors.right: listDate.left
                    anchors.rightMargin: Theme.dp(16)
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.dp(90)
                    horizontalAlignment: Text.AlignRight
                    text: root.itemSize(listCell.model)
                    color: Theme.textDim
                }
                RText {
                    id: listDate
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.dp(130)
                    horizontalAlignment: Text.AlignRight
                    text: root.itemDate(listCell.model)
                    color: Theme.textDim
                }
            }
        }
    }

    RText {
        anchors.centerIn: gridView
        width: Math.min(implicitWidth, gridView.width - Theme.dp(40))
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        visible: dirModel.count === 0
        text: root.library && root.library.searchPattern.length > 0
              ? qsTr("Nothing found")
              : qsTr("No media files in this folder")
        color: Theme.textDim
    }

    RMenu {
        id: contextMenu

        property var item: null
        readonly property bool folder: root.isFolder(item)

        RAction {
            iconName: "play"
            text: contextMenu.folder ? qsTr("Open folder") : qsTr("Play")
            onTriggered: root.activate(contextMenu.item)
        }
        RAction {
            iconName: "queue_2t"
            text: qsTr("Add to queue")
            enabled: !contextMenu.folder
            onTriggered: root.enqueue(root.itemUrl(contextMenu.item))
        }
        RMenuSeparator { }
        RAction {
            iconName: "folder_2t"
            text: qsTr("Open in File Explorer")
            onTriggered: contextMenu.folder
                         ? root.openInExplorer(root.itemUrl(contextMenu.item))
                         : root.showInExplorer(root.itemUrl(contextMenu.item))
        }
        RAction {
            iconName: "refresh"
            text: qsTr("Refresh")
            onTriggered: dirModel.refresh()
        }
    }
}
