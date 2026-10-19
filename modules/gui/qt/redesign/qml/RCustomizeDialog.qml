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

// "Customize Player" (Figma "Player - customize"): drag controls from the box into the
// control bar strip, drag them around in the strip to reorder, back into the box to
// remove them. A click on a control of the box also adds it.
RDialogWindow {
    id: root

    property var working: []
    property var bottomWorking: []
    property var topWorking: []
    property bool editingTop: false

    function switchBar(top) {
        if (editingTop) topWorking = working.slice()
        else bottomWorking = working.slice()
        editingTop = top
        working = (top ? topWorking : bottomWorking).slice()
    }

    function open() {
        bottomWorking = RBarCatalog.extras.slice()
        topWorking = RBarCatalog.topExtras.slice()
        editingTop = false
        working = bottomWorking.slice()
        show()
        raise()
        requestActivate()
    }

    // index in the strip for a drop at x (strip coordinates)
    function dropIndex(x) {
        for (let i = 0; i < stripRow.children.length; ++i) {
            const c = stripRow.children[i]
            if (c.stripIndex !== undefined && x < c.x + c.width / 2)
                return c.stripIndex
        }
        return working.length
    }

    function insertAt(id, index) {
        const l = working.slice()
        l.splice(index, 0, id)
        working = l
    }
    function moveTo(from, index) {
        const l = working.slice()
        const id = l.splice(from, 1)[0]
        l.splice(index > from ? index - 1 : index, 0, id)
        working = l
    }
    function removeAt(index) {
        const l = working.slice()
        l.splice(index, 1)
        working = l
    }

    heading: qsTr("Customize Player")
    acceptEnabled: true
    width: Theme.dp(1048)
    height: Theme.dp(760)
    minimumWidth: Theme.dp(700)
    minimumHeight: Theme.dp(560)
    onAccepted: {
        if (editingTop) topWorking = working.slice()
        else bottomWorking = working.slice()
        RBarCatalog.setExtras(bottomWorking)
        RBarCatalog.setTopExtras(topWorking)
    }

    component Tile: Item {
        id: tile
        property string itemId
        property int stripIndex: -1           // >= 0 for items of the strip
        readonly property var info: RBarCatalog.item(itemId)

        width: Theme.dp(110)
        height: Theme.dp(100)

        Item {
            id: dragged
            width: tile.width
            height: tile.height
            Drag.active: mouse.drag.active
            Drag.hotSpot.x: width / 2
            Drag.hotSpot.y: height / 2
            Drag.keys: ["vlc-redesign-control"]
            property string itemId: tile.itemId
            property int stripIndex: tile.stripIndex

            Rectangle {
                id: box
                anchors.horizontalCenter: parent.horizontalCenter
                y: Theme.dp(10)
                width: Theme.dp(36)
                height: Theme.dp(36)
                radius: Theme.radiusSmall
                color: mouse.containsMouse ? Theme.hover : "transparent"
                RDashedLine { width: parent.width; height: 1; dash: Theme.dp(3); gap: Theme.dp(3) }
                RDashedLine { y: parent.height - 1; width: parent.width; height: 1; dash: Theme.dp(3); gap: Theme.dp(3) }
                RDashedLine { vertical: true; width: 1; height: parent.height; dash: Theme.dp(3); gap: Theme.dp(3) }
                RDashedLine { vertical: true; x: parent.width - 1; width: 1; height: parent.height; dash: Theme.dp(3); gap: Theme.dp(3) }
                RIcon {
                    anchors.centerIn: parent
                    name: tile.info ? tile.info.icon : ""
                    size: Theme.iconSizeSmall
                    color: Theme.textItem
                }
            }
            RText {
                anchors.top: box.bottom
                anchors.topMargin: Theme.dp(8)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                maximumLineCount: 2
                text: tile.info ? tile.info.text : tile.itemId
                color: Theme.textItem
                font.pixelSize: Theme.fontSizeSmall + Theme.dp(1)
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                drag.target: dragged
                onReleased: {
                    if (drag.active || dragged.Drag.target)
                        dragged.Drag.drop()
                    dragged.x = 0
                    dragged.y = 0
                }
                onClicked: if (tile.stripIndex < 0) root.insertAt(tile.itemId, root.working.length)
            }

            states: State {
                when: mouse.drag.active
                ParentChange { target: dragged; parent: dragLayer }
            }
        }
    }

    Item {
        anchors.fill: parent

        RText {
            id: hint
            width: parent.width
            wrapMode: Text.Wrap
            text: qsTr("Drag controls into the control bar below, drag them around to re-order them, and back into the box to remove them.")
            color: Theme.textItem
        }

        // ---- the box: every control
        Rectangle {
            id: catalog
            anchors.top: hint.bottom
            anchors.topMargin: Theme.dp(16)
            anchors.bottom: barSelector.top
            anchors.bottomMargin: Theme.dp(16)
            width: parent.width
            radius: Theme.radius
            color: catalogDrop.containsDrag ? Theme.p.bgA1 : Theme.p.bgB1Transparent

            DropArea {
                id: catalogDrop
                anchors.fill: parent
                keys: ["vlc-redesign-control"]
                onDropped: (drop) => {
                    if (drop.source && drop.source.stripIndex >= 0)
                        root.removeAt(drop.source.stripIndex)
                    drop.accept()
                }
            }

            Flickable {
                anchors.fill: parent
                anchors.margins: Theme.dp(12)
                clip: true
                contentHeight: flow.height
                T.ScrollBar.vertical: RScrollBar { }
                Flow {
                    id: flow
                    width: parent.width
                    Repeater {
                        model: RBarCatalog.items
                        delegate: Tile {
                            required property var modelData
                            itemId: modelData.id
                        }
                    }
                }
            }
        }

        RSegmented {
            id: barSelector
            anchors.bottom: stripTitle.top
            anchors.bottomMargin: Theme.dp(12)
            width: Theme.dp(360)
            height: Theme.dp(34)
            model: [{ value: "bottom", text: qsTr("Control bar") }, { value: "top", text: qsTr("Top bar") }]
            currentValue: root.editingTop ? "top" : "bottom"
            onPicked: (v) => root.switchBar(v === "top")
        }

        RText {
            id: stripTitle
            anchors.bottom: strip.top
            anchors.bottomMargin: Theme.dp(8)
            text: root.editingTop ? qsTr("Top bar (before the window controls)") : qsTr("Control bar (between the volume and the audio button)")
            color: Theme.textDim
        }

        // ---- the strip: controls placed in the bar
        Rectangle {
            id: strip
            anchors.bottom: parent.bottom
            width: parent.width
            height: Theme.dp(110)
            radius: Theme.radius
            color: stripDrop.containsDrag ? Theme.trackFill : Theme.p.bgA1

            DropArea {
                id: stripDrop
                anchors.fill: parent
                keys: ["vlc-redesign-control"]
                onDropped: (drop) => {
                    const p = mapToItem(stripRow, drop.x, drop.y)
                    const index = root.dropIndex(p.x)
                    if (drop.source.stripIndex >= 0)
                        root.moveTo(drop.source.stripIndex, index)
                    else
                        root.insertAt(drop.source.itemId, index)
                    drop.accept()
                }
            }

            RText {
                anchors.centerIn: parent
                visible: root.working.length === 0
                text: qsTr("Drop controls here")
                color: Theme.textDim
            }

            Flickable {
                anchors.fill: parent
                clip: true
                contentWidth: stripRow.width + Theme.dp(20)
                contentHeight: height
                flickableDirection: Flickable.HorizontalFlick
                T.ScrollBar.horizontal: RScrollBar { }
            Row {
                id: stripRow
                x: Theme.dp(10)
                anchors.verticalCenter: parent.verticalCenter
                Repeater {
                    model: root.working
                    delegate: Tile {
                        required property string modelData
                        required property int index
                        itemId: modelData
                        stripIndex: index
                    }
                }
            }
        }

        }

        // dragged tiles are reparented here so they float above everything
        Item { id: dragLayer; anchors.fill: parent; z: 100 }
    }
}
