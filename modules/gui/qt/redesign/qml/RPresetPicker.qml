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
import VLC.Dialogs

Row {
    spacing: Theme.dp(8)
    RDropdown {
        id: dropdown
        width: parent.width - save.width - manage.width - 2 * parent.spacing
        model: [{ value: "", text: qsTr("Default preset") }].concat(RPresets.names.map(n => ({ value: n, text: n })))
        Component.onCompleted: selectValue(RPresets.current)
        onPicked: (v) => { if (v.length) RPresets.apply(v); else RPresets.applyDefault() }
        Connections { target: RPresets; function onCurrentChanged() { dropdown.selectValue(RPresets.current) } }
    }
    RIconButton {
        id: save
        iconName: "add"
        toolTip: qsTr("Save current settings as a preset")
        onClicked: {
            const r = DialogsProvider.getTextDialog(null, qsTr("New preset"), qsTr("Preset name:"), "")
            if (r.ok) RPresets.store(r.text)
        }
    }

    RIconButton {
        id: manage
        iconName: "more"
        toolTip: qsTr("Preset options")
        onClicked: menu.popup(this, 0, height)
    }
    RMenu {
        id: menu
        RAction { text: qsTr("Update current preset"); enabled: RPresets.current.length > 0; onTriggered: RPresets.store(RPresets.current) }
        RAction { text: qsTr("Delete current preset"); enabled: RPresets.current.length > 0; onTriggered: RPresets.remove(RPresets.current) }
        RAction { text: qsTr("Restore defaults"); onTriggered: RPresets.applyDefault() }
    }
}
