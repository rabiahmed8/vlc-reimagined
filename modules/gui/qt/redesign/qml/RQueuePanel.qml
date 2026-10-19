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
import QtQuick.Templates as T

import VLC.MainInterface
import VLC.Player
import VLC.Playlist
import VLC.Dialogs

// Right side panel opened by the queue button: Queue / Bookmarks / Chapters.
// The queue plays files automatically one after another; drag files from the
// desktop or the library into it.
Rectangle {
    id: root

    property alias currentIndex: tabs.currentIndex

    implicitWidth: Theme.popupWidth
    color: Theme.panelBackground
    radius: Theme.radiusLarge
    clip: true

    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onWheel: (w) => w.accepted = true }

    PlaylistListModel {
        id: queueModel
        playlist: MainPlaylistController.playlist
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 1

        RTabBar {
            id: tabs
            Layout.fillWidth: true
            model: [
                { text: qsTr("Queue"), icon: "queue" },
                { text: qsTr("Bookmarks"), icon: "bookmarks" },
                { text: qsTr("Chapters"), icon: "chapters" }
            ]
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabs.currentIndex

            // --- Queue ------------------------------------------------------
            ColumnLayout {
                spacing: 0

                Item {
                    Layout.fillWidth: true
                    implicitHeight: Theme.dp(48)

                    RText {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.margin
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.textDim
                        text: {
                            const n = queueModel.count
                            let s = n === 1 ? qsTr("1 item") : qsTr("%1 items").arg(n)
                            const d = queueModel.duration
                            if (d && d.valid() && d.toSeconds() > 0)
                                s += "  ·  " + d.formatLong()
                            return s
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.dp(14)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.dp(6)

                        RIconButton {
                            iconName: "shuffle"
                            toolTip: qsTr("Shuffle")
                            checked: MainPlaylistController.random
                            onClicked: MainPlaylistController.toggleRandom()
                        }
                        RIconButton {
                            iconName: MainPlaylistController.repeatMode === PlaylistController.PLAYBACK_REPEAT_CURRENT
                                      ? "repeat_one" : "repeat"
                            toolTip: qsTr("Repeat")
                            checked: MainPlaylistController.repeatMode !== PlaylistController.PLAYBACK_REPEAT_NONE
                            onClicked: MainPlaylistController.toggleRepeatMode()
                        }
                        RIconButton {
                            iconName: "trash"
                            toolTip: qsTr("Clear the queue")
                            enabled: !MainPlaylistController.empty
                            onClicked: MainPlaylistController.clear()
                        }
                        RIconButton {
                            iconName: "add"
                            toolTip: qsTr("Add files to the queue")
                            onClicked: DialogsProvider.PLAppendDialog()
                        }
                    }
                }

                ListView {
                    id: queueList

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: queueModel
                    boundsBehavior: Flickable.StopAtBounds
                    spacing: Theme.dp(2)

                    delegate: RQueueItem {
                        width: queueList.width
                    }

                    RText {
                        anchors.centerIn: parent
                        visible: queueList.count === 0
                        width: parent.width - 2 * Theme.margin
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        color: Theme.textDim
                        text: qsTr("The queue is empty.\nDrop files here or use + to add them.")
                    }

                    DropArea {
                        anchors.fill: parent
                        keys: ["text/uri-list", "vlc-redesign-media"]
                        onDropped: (drop) => {
                            if (drop.source && drop.source.enqueueForDrop) {
                                drop.source.enqueueForDrop()
                                drop.accept()
                            } else if (drop.hasUrls) {
                                let urls = []
                                for (let i = 0; i < drop.urls.length; ++i)
                                    urls.push(drop.urls[i])
                                MainPlaylistController.append(urls, MainPlaylistController.empty)
                                drop.accept()
                            }
                        }
                    }
                }
            }

            // --- Bookmarks --------------------------------------------------
            ColumnLayout {
                spacing: 0
                RSectionHeader {
                    Layout.fillWidth: true
                    text: qsTr("Bookmarks")
                }
                RText {
                    Layout.fillWidth: true
                    Layout.leftMargin: Theme.dp(28)
                    Layout.rightMargin: Theme.dp(28)
                    wrapMode: Text.WordWrap
                    color: Theme.textDim
                    text: qsTr("Bookmarks let you jump back to a moment of the video.")
                }
                Item { Layout.fillHeight: true }
                RPanelButton {
                    Layout.fillWidth: true
                    Layout.margins: Theme.margin
                    text: qsTr("Manage bookmarks")
                    onClicked: DialogsProvider.bookmarksDialog()
                }
            }

            // --- Chapters ---------------------------------------------------
            ColumnLayout {
                spacing: 0
                RSectionHeader { Layout.fillWidth: true; text: qsTr("Chapters") }
                RText {
                    visible: !Player.hasChapters
                    Layout.leftMargin: Theme.dp(28)
                    color: Theme.textDim
                    text: qsTr("This media has no chapters")
                }
                ListView {
                    id: chapterList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: Player.chapters
                    spacing: Theme.dp(4)
                    delegate: RCheckItem {
                        required property var model
                        required property int index
                        x: Theme.margin
                        width: chapterList.width - 2 * Theme.margin
                        text: model.display + "    " + model.time.formatHMS()
                        selected: model.checked
                        onClicked: Player.chapters.selectChapter(index)
                    }
                }
            }
        }
    }
}
