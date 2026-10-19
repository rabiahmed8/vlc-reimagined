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
import VLC.Dialogs

RSettingsPage {
    RSettingsSection { text: qsTr("Add-ons") }

    RText {
        width: parent.width
        wrapMode: Text.Wrap
        color: Theme.textDim
        bottomPadding: Theme.dp(8)
        text: qsTr("Add-ons are extensions, skins, playlist parsers and service discovery scripts you can install. "
                   + "Plugins are internal parts of VLC; their settings are in Advanced Options.")
    }

    RSettingRow {
        label: qsTr("Installed add-ons and plugins")
        RButton {
            width: parent.width
            text: qsTr("Manage")
            onClicked: DialogsProvider.pluginDialog()
        }
    }

    ROption { name: "qt-autoload-extensions"; title: qsTr("Load add-ons on startup") }

    RSettingsSection { text: qsTr("Scripts") }

    ROption { name: "lua-intf"; title: qsTr("Lua interface") }
    ROption { name: "lua-config"; title: qsTr("Lua interface configuration") }

}
