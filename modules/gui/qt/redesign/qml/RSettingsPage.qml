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

// Scrollable content of one settings category. Children are stacked vertically:
// RSettingsSection, ROption, RSettingRow, RAdvancedOptions...
Item {
    id: root

    property string title
    default property alias content: column.data

    // names of the ROption rows of the page, for RAdvancedOptions.exclude
    function optionNames() {
        const names = []
        const walk = (item) => {
            for (let i = 0; i < item.children.length; ++i) {
                const c = item.children[i]
                // Generated advanced rows must not feed their own exclusion list.
                if (c.advancedOptionGroup === true) continue
                if (typeof c.name === "string" && c.reload !== undefined)
                    names.push(c.name)
                walk(c)
            }
        }
        walk(column)
        return names
    }

    // explicit list: plain children would land in the default property (the column)
    data: [
    Flickable {
        id: flick
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: column.implicitHeight + Theme.dp(40)
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: column
            x: Theme.dp(24)
            y: Theme.dp(18)
            width: flick.width - Theme.dp(48)
            spacing: 0
        }

        T.ScrollBar.vertical: RScrollBar { }
    }
    ]
}
