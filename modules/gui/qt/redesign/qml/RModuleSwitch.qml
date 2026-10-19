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

// Switch row that adds/removes a module in a module list option: a control interface
// in "extraintf" ("http", "audioscrobbler"), a filter in "audio-filter" ("equalizer")...
RSettingRow {
    id: root

    property string list: "extraintf"
    visible: RedesignSettings.moduleAvailable(module)
    property string module

    function modules() {
        return String(RedesignSettings.value(list) || "").split(/[:,]/).filter(s => s.length > 0)
    }

    RSwitch {
        id: sw
        anchors.right: parent.right
        checked: root.modules().indexOf(root.module) >= 0
        onToggled: {
            let list = root.modules().filter(s => s !== root.module)
            if (checked)
                list.push(root.module)
            RedesignSettings.setValue(root.list, list.join(":"))
        }
        Connections {
            target: RedesignSettings
            function onValueChanged(name) {
                if (name === root.list)
                    sw.checked = root.modules().indexOf(root.module) >= 0
            }
        }
    }
}
