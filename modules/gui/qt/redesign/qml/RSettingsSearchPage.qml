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

import VLC.MainInterface

// Results of the settings search: every VLC option whose name, label or
// description matches, editable in place.
RSettingsPage {
    id: root

    property string text

    // the search runs a little after the last key press
    property string query
    onTextChanged: delay.restart()
    Timer { id: delay; interval: 250; onTriggered: root.query = root.text }

    readonly property var results: query.length > 1 ? RedesignSettings.search(query, 60) : []

    RText {
        visible: root.query.length > 1 && root.results.length === 0
        topPadding: Theme.dp(20)
        text: qsTr("Nothing found for \"%1\"").arg(root.query)
        color: Theme.textDim
    }

    Repeater {
        model: root.results
        delegate: ROption {
            required property var modelData
            width: parent ? parent.width : 0
            name: modelData.name
        }
    }
}
