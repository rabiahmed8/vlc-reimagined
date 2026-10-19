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
import VLC.Network
import VLC.Player

// Library > Network: this computer, devices and local network shares, then the
// folders inside (the breadcrumb follows the browsed folders).
Item {
    id: root

    property var library
    readonly property var params: library ? library.route.params : ({})
    readonly property bool browsing: params.tree !== undefined

    Binding { target: root.library; property: "itemCount"; value: root.browsing ? media.count : computer.count + devices.count + lan.count; when: !!root.library }

    NetworkDeviceModel { id: computer; ctx: MainCtx; sd_source: NetworkDeviceModel.CAT_MYCOMPUTER; source_name: "*" }
    NetworkDeviceModel { id: devices; ctx: MainCtx; sd_source: NetworkDeviceModel.CAT_DEVICES; source_name: "*" }
    NetworkDeviceModel { id: lan; ctx: MainCtx; sd_source: NetworkDeviceModel.CAT_LAN; source_name: "*" }

    NetworkMediaModel {
        id: media
        ctx: MainCtx
        tree: root.browsing ? root.params.tree : undefined
        searchPattern: root.library ? root.library.searchPattern : ""
        sortCriteria: root.library ? root.library.sortCriteria : ""
        sortOrder: root.library ? root.library.sortOrder : Qt.AscendingOrder
    }

    function open(model, index, item) {
        const t = item.type
        if (item.tree !== undefined && (t === NetworkMediaModel.TYPE_DIRECTORY || t === NetworkMediaModel.TYPE_NODE
                                        || t === NetworkMediaModel.TYPE_PLAYLIST || t === undefined))
            root.library.openChild(item.name, { tree: item.tree })
        else
            model.addAndPlay(index)
    }

    // ---- sources
    Flickable {
        anchors.fill: parent
        visible: !root.browsing
        clip: true
        contentHeight: sources.height
        T.ScrollBar.vertical: RScrollBar { }

        Column {
            id: sources
            width: parent.width
            spacing: Theme.dp(12)

            Loader {
                width: parent.width
                active: MainCtx.mediaLibraryAvailable
                source: "RLibStreams.qml"
                onLoaded: item.library = root.library
            }
            Repeater {
                model: [{ title: qsTr("This Computer"), model: computer, icon: "folder" },
                        { title: qsTr("Devices"), model: devices, icon: "disc" },
                        { title: qsTr("Local Network"), model: lan, icon: "streaming" }]
                delegate: Column {
                    required property var modelData
                    width: sources.width
                    spacing: Theme.dp(10)
                    visible: modelData.model.count > 0

                    RText { text: modelData.title; font.pixelSize: Theme.dp(20); color: Theme.textItem }
                    RMediaView {
                        width: parent.width
                        height: Math.ceil(count / columns) * cellHeight
                        interactive: false
                        square: true
                        fallbackIcon: modelData.icon
                        grid: root.library ? root.library.grid : true
                        model: modelData.model
                        onActivated: (index, item) => root.library.openChild(item.name, { tree: item.tree })
                    }
                    Item { width: 1; height: Theme.dp(12) }
                }
            }
        }
    }

    // ---- inside a source / folder
    RMediaView {
        anchors.fill: parent
        visible: root.browsing
        grid: root.library ? root.library.grid : false
        square: true
        fallbackIcon: "file"
        model: media
        currentMrl: Player.isStarted ? String(Player.url) : ""
        onEnqueueRequested: (index, item) => media.addToPlaylist(index)
        onActivated: (index, item) => root.open(media, index, item)
    }

    RText {
        anchors.centerIn: parent
        visible: root.browsing && media.count === 0 && !media.loading
        text: qsTr("This folder is empty")
        color: Theme.textDim
    }
}
