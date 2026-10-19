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
import VLC.MediaLibrary
import VLC.Player

// Library > Home (Figma "Player-5"): Continue Watching, recently played and
// recently added media, video folders, as horizontal rows.
Flickable {
    id: root

    property var library

    clip: true
    contentHeight: column.height + Theme.dp(40)
    boundsBehavior: Flickable.StopAtBounds
    T.ScrollBar.vertical: RScrollBar { }

    Binding { target: root.library; property: "itemCount"; value: continueModel.count + recentModel.count; when: !!root.library }

    Binding { target: root.library; property: "sortKeys"; value: []; when: !!root.library }

    MLRecentVideoModel { id: continueModel; ml: MediaLib; limit: 12 }
    MLRecentMediaModel { id: recentModel; ml: MediaLib; limit: 12 }
    MLAudioModel { id: newMusicModel; ml: MediaLib; limit: 12; sortCriteria: "insertion"; sortOrder: Qt.DescendingOrder }
    MLVideoFoldersModel { id: folderModel; ml: MediaLib; limit: 12 }

    component Section: Column {
        id: section
        property string title
        property alias model: row.model
        property bool square: false
        property string fallbackIcon: "video"
        property string seeAll: ""          // library page of "see all"
        signal activated(var item)

        width: root.width
        spacing: Theme.dp(14)
        visible: row.count > 0

        T.AbstractButton {
            id: titleBtn
            implicitWidth: titleRow.implicitWidth
            implicitHeight: Theme.dp(32)
            hoverEnabled: true
            enabled: section.seeAll.length > 0
            onClicked: root.library.openPage(section.seeAll)
            contentItem: Row {
                id: titleRow
                spacing: Theme.dp(10)
                RText {
                    text: section.title
                    font.pixelSize: Theme.dp(20)
                    color: titleBtn.hovered ? Theme.textStrong : Theme.textItem
                    anchors.verticalCenter: parent.verticalCenter
                }
                RIcon {
                    visible: section.seeAll.length > 0
                    name: "chevron_right"
                    size: Theme.iconSizeSmall
                    color: Theme.textItem
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        RMediaView {
            id: row
            onEnqueueRequested: (index, item) => MediaLib.addToPlaylist(item.id)
            width: parent.width
            height: cellHeight
            flow: GridView.FlowTopToBottom   // a single horizontal row
            interactive: true
            square: section.square
            fallbackIcon: section.fallbackIcon
            currentMrl: Player.isStarted ? String(Player.url) : ""
            cellWidth: square ? Theme.dp(220) : Theme.dp(336)
            onActivated: (index, item) => section.activated(item)
        }

        Item { width: 1; height: Theme.dp(20) }
    }

    Column {
        id: column
        width: root.width

        Section {
            title: qsTr("Continue Watching")
            model: continueModel
            seeAll: "videos"
            onActivated: (item) => MediaLib.addAndPlay(item.id)
        }
        Section {
            title: qsTr("Play Again")
            model: recentModel
            seeAll: "recent"
            onActivated: (item) => MediaLib.addAndPlay(item.id)
        }
        Section {
            title: qsTr("New Music")
            model: newMusicModel
            square: true
            fallbackIcon: "music"
            seeAll: "music"
            onActivated: (item) => MediaLib.addAndPlay(item.id)
        }
        Section {
            title: qsTr("Video Folders")
            model: folderModel
            square: true
            fallbackIcon: "folder"
            seeAll: "videos"
            onActivated: (item) => {
                root.library.openPage("videos")
                root.library.openChild(item.title, { folderId: item.id })
            }
        }

        RText {
            visible: continueModel.count + recentModel.count + newMusicModel.count + folderModel.count === 0
            width: root.width
            topPadding: Theme.dp(80)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: qsTr("Your library is empty. Use \"Add item\" to add the folders with your videos and music.")
            color: Theme.textDim
        }
    }
}
