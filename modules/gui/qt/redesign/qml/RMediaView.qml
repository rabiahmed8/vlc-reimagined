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

// Media of a library page, as tiles (Figma "Player-3": 16:9 thumbnails, progress bar,
// title) or as a compact list in columns (Figma "Player-1": small thumbnail + title).
// Works with the media library, network and playlist models: it reads the usual
// roles (title/name, thumbnail/cover/artwork, progress, main_artist, count...).
GridView {
    id: root

    property bool grid: true
    property bool square: false          // square tiles (albums, artists, audio)
    property string fallbackIcon: "video"
    // the item shown as playing (orange title), compared with the "mrl" role
    property string currentMrl: ""

    signal activated(int index, var item)
    signal enqueueRequested(int index, var item)
    signal contextMenuRequested(int index, var item, point globalPos)

    readonly property int columns: grid ? Math.max(1, Math.floor((width + Theme.dp(20)) / (square ? Theme.dp(220) : Theme.dp(336))))
                                        : Math.max(1, Math.floor(width / Theme.dp(400)))

    clip: true
    boundsBehavior: Flickable.StopAtBounds
    cellWidth: Math.floor(width / columns)
    cellHeight: grid ? (square ? cellWidth - Theme.dp(20) + Theme.dp(78) : (cellWidth - Theme.dp(20)) * 9 / 16 + Theme.dp(70))
                     : Theme.dp(42)
    cacheBuffer: Theme.dp(400)
    T.ScrollBar.vertical: RScrollBar { }

    function titleOf(m) {
        return m.title || m.name || m.fileName || m.display_url || m.url || ""
    }
    function imageOf(m) {
        const s = m.thumbnail || m.cover || m.small_cover || m.artwork || ""
        return String(s)
    }
    function subtitleOf(m) {
        if (m.main_artist !== undefined && m.main_artist)
            return m.main_artist
        if (m.nb_videos !== undefined)
            return qsTr("%n videos", "", m.nb_videos)
        if (m.nb_tracks !== undefined)
            return qsTr("%n tracks", "", m.nb_tracks)
        if (m.nb_albums !== undefined)
            return qsTr("%n albums", "", m.nb_albums)
        if (m.count !== undefined && m.name !== undefined)
            return qsTr("%n items", "", m.count)
        return ""
    }

    delegate: T.AbstractButton {
        id: cell
        required property var model
        required property int index

        readonly property real progress: model.progress !== undefined ? Number(model.progress) : 0
        // watched media are dimmed (Figma: the first episodes of the season)
        readonly property bool watched: progress >= 0.95 || (model.playcount !== undefined && model.playcount > 0 && progress === 0 && model.isVideo !== false)
        readonly property bool current: root.currentMrl.length > 0 && String(model.mrl || model.url || "") === root.currentMrl
        readonly property string image: root.imageOf(model)

        width: root.cellWidth
        height: root.cellHeight
        hoverEnabled: true
        onClicked: root.activated(index, model)
        Accessible.name: root.titleOf(model)
        function enqueueForDrop() { root.enqueueRequested(index, model) }
        Item {
            id: dragProxy
            parent: cell
            x: mediaDrag.centroid.position.x
            y: mediaDrag.centroid.position.y
            width: 1; height: 1
            Drag.active: false
            Drag.keys: ["vlc-redesign-media"]
            Drag.source: cell
        }
        DragHandler {
            id: mediaDrag
            target: null
            acceptedButtons: Qt.LeftButton
            onActiveChanged: { if (active) dragProxy.Drag.active = true; else dragProxy.Drag.drop() }
        }

        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: (point) => root.contextMenuRequested(cell.index, cell.model, cell.mapToGlobal(point.position.x, point.position.y))
        }

        // ---- tile
        Item {
            visible: root.grid
            anchors.fill: parent
            anchors.rightMargin: Theme.dp(20)

            Rectangle {
                id: thumb
                width: parent.width
                height: root.square ? width : width * 9 / 16
                radius: Theme.radiusLarge
                color: Theme.p.bgA1
                clip: true
                border.color: cell.hovered ? Theme.p.dividerBright : "transparent"

                Image {
                    id: tileImage
                    anchors.fill: parent
                    source: cell.image
                    visible: cell.image.length > 0 && status === Image.Ready
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    sourceSize.width: width
                    opacity: cell.watched ? 0.5 : 1
                }
                RIcon {
                    anchors.centerIn: parent
                    visible: tileImage.status !== Image.Ready
                    name: cell.model.isVideo === false ? "music" : cell.model.isVideo === true ? "video" : root.fallbackIcon
                    size: Theme.dp(40)
                    color: Theme.textDim
                }
                Rectangle {
                    visible: cell.progress > 0
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Theme.dp(3)
                    x: Theme.dp(4)
                    width: (parent.width - Theme.dp(8)) * Math.min(1, cell.progress)
                    height: Theme.dp(3)
                    radius: height / 2
                    color: Theme.accent
                }
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: cell.pressed ? Theme.pressed : cell.hovered ? Theme.hover : "transparent"
                }
            }

            RText {
                id: tileTitle
                anchors.top: thumb.bottom
                anchors.topMargin: Theme.dp(12)
                width: parent.width
                text: root.titleOf(cell.model)
                color: cell.current ? Theme.accent : cell.watched ? Theme.textDim : Theme.textItem
                font.pixelSize: Theme.fontSizeLarge
            }
            RText {
                anchors.top: tileTitle.bottom
                anchors.topMargin: Theme.dp(4)
                width: parent.width
                text: root.subtitleOf(cell.model)
                visible: text.length > 0
                color: Theme.textDim
            }
        }

        // ---- compact list
        Item {
            visible: !root.grid
            anchors.fill: parent
            anchors.rightMargin: Theme.dp(16)

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusSmall
                color: cell.pressed ? Theme.pressed : cell.hovered ? Theme.hover : "transparent"
            }
            Rectangle {
                id: small
                width: Theme.dp(32)
                height: Theme.dp(32)
                anchors.verticalCenter: parent.verticalCenter
                radius: Theme.radiusSmall
                color: Theme.p.bgA1
                clip: true
                Image {
                    id: smallImage
                    anchors.fill: parent
                    source: cell.image
                    visible: cell.image.length > 0 && status === Image.Ready
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    sourceSize.width: Theme.dp(64)
                    opacity: cell.watched ? 0.5 : 1
                }
                RIcon {
                    anchors.centerIn: parent
                    visible: smallImage.status !== Image.Ready
                    name: cell.current ? "playing" : root.fallbackIcon
                    size: Theme.iconSizeSmall
                    color: cell.current ? Theme.accent : Theme.textDim
                }
                Rectangle {
                    visible: cell.progress > 0
                    anchors.bottom: parent.bottom
                    width: parent.width * Math.min(1, cell.progress)
                    height: Theme.dp(2)
                    color: Theme.accent
                }
            }
            RText {
                anchors.left: small.right
                anchors.leftMargin: Theme.dp(10)
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: root.titleOf(cell.model)
                color: cell.current ? Theme.accent : cell.watched ? Theme.textDim : Theme.textItem
            }
        }
    }
}
