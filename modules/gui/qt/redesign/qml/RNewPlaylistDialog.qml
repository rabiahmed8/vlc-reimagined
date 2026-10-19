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

// "New Playlist" (Figma): a name and files (drag and drop or picker), saved in the
// media library.
RDialogWindow {
    id: root

    property var files: []    // [{ url, name }]

    function addUrls(urls) {
        const list = files.slice()
        for (const u of urls) {
            const s = String(u)
            if (!list.some(f => f.url === s))
                list.push({ url: s, name: decodeURIComponent(s.split("/").pop()) })
        }
        files = list
    }

    heading: qsTr("New Playlist")
    acceptEnabled: nameField.text.trim().length > 0 && files.length > 0
    width: Theme.dp(712)
    height: Theme.dp(590)
    minimumWidth: Theme.dp(520)
    minimumHeight: Theme.dp(460)

    onVisibleChanged: if (visible) { nameField.text = ""; files = []; nameField.forceActiveFocus() }
    onAccepted: saver.item.save(nameField.text.trim(), files.map(f => f.url))

    Loader {
        id: saver
        active: MainCtx.mediaLibraryAvailable
        source: "RPlaylistSaver.qml"
    }

    Column {
        anchors.fill: parent
        spacing: Theme.dp(8)

        RText { text: qsTr("Playlist Details"); font.pixelSize: Theme.fontSizeLarge; color: Theme.textStrong }
        RText { text: qsTr("The playlist will be saved and displayed with this title."); color: Theme.textDim }
        RTextField {
            id: nameField
            width: parent.width
            height: Theme.dp(36)
            placeholderText: qsTr("e.g., Favorite Videos")
        }

        Item { width: 1; height: Theme.dp(16) }

        RText { text: qsTr("Select Files"); font.pixelSize: Theme.fontSizeLarge; color: Theme.textStrong }
        RText { text: qsTr("These files will be added to the playlist."); color: Theme.textDim }

        Rectangle {
            id: dropBox
            width: parent.width
            height: parent.height - y
            radius: Theme.radiusSmall
            color: drop.containsDrag ? Theme.p.bgA1 : Theme.p.bgB1Transparent

            // dashed border
            RDashedLine { width: parent.width; height: 1 }
            RDashedLine { y: parent.height - 1; width: parent.width; height: 1 }
            RDashedLine { vertical: true; width: 1; height: parent.height }
            RDashedLine { vertical: true; x: parent.width - 1; width: 1; height: parent.height }

            DropArea {
                id: drop
                anchors.fill: parent
                onEntered: (d) => d.accepted = d.hasUrls
                onDropped: (d) => { root.addUrls(d.urls); d.accept() }
            }

            Column {
                anchors.centerIn: parent
                spacing: Theme.dp(14)
                visible: root.files.length === 0
                RText { text: qsTr("Drag files into the box or click here to select files."); color: Theme.textDim }
                RIconButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    iconName: "add"
                    width: Theme.dp(84)
                    toolTip: qsTr("Select files")
                    onClicked: root.addUrls(RedesignSettings.browseFiles(qsTr("Select files")))
                }
            }

            ListView {
                anchors.fill: parent
                anchors.margins: Theme.dp(8)
                visible: root.files.length > 0
                clip: true
                model: root.files
                T.ScrollBar.vertical: RScrollBar { }
                footer: RButton {
                    text: qsTr("Add files")
                    onClicked: root.addUrls(RedesignSettings.browseFiles(qsTr("Select files")))
                }
                delegate: Item {
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    height: Theme.dp(36)
                    RIcon { id: fileIcon; x: Theme.dp(6); anchors.verticalCenter: parent.verticalCenter; name: "file"; size: Theme.iconSizeSmall; color: Theme.textDim }
                    RText { anchors.left: fileIcon.right; anchors.leftMargin: Theme.dp(10); anchors.right: rm.left; anchors.verticalCenter: parent.verticalCenter; text: modelData.name; color: Theme.textItem }
                    RIconButton {
                        id: rm
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        iconName: "close"
                        iconSize: Theme.iconSizeSmall
                        toolTip: qsTr("Remove")
                        onClicked: { const l = root.files.slice(); l.splice(index, 1); root.files = l }
                    }
                }
            }
        }
    }
}
