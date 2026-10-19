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

// "None" entry followed by the tracks of a TrackListModel
Flickable {
    id: root

    property var trackModel
    property bool noneSelected: true

    function _update() {
        let any = false
        if (trackModel) {
            for (let i = 0; i < trackModel.count; ++i)
                if (trackModel.data(trackModel.index(i, 0), Qt.CheckStateRole)) { any = true; break }
        }
        noneSelected = !any
    }
    function _unselectAll() {
        for (let i = 0; i < trackModel.count; ++i) {
            const idx = trackModel.index(i, 0)
            if (trackModel.data(idx, Qt.CheckStateRole))
                trackModel.setData(idx, false, Qt.CheckStateRole)
        }
    }

    onTrackModelChanged: _update()
    Component.onCompleted: _update()

    Connections {
        target: root.trackModel
        function onDataChanged() { root._update() }
        function onModelReset() { root._update() }
        function onRowsInserted() { root._update() }
        function onRowsRemoved() { root._update() }
    }

    clip: true
    contentHeight: col.implicitHeight
    boundsBehavior: Flickable.StopAtBounds
    implicitHeight: Math.min(contentHeight, Theme.dp(200))

    Column {
        id: col
        x: Theme.margin
        width: root.width - 2 * Theme.margin
        spacing: Theme.dp(4)

        RCheckItem {
            width: parent.width
            text: qsTr("None")
            selected: root.noneSelected
            onClicked: root._unselectAll()
        }

        Repeater {
            model: root.trackModel
            delegate: RCheckItem {
                required property var model
                width: col.width
                text: model.display
                selected: model.checked
                onClicked: model.checked = true
            }
        }
    }
}
