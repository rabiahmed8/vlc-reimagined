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

import VLC.MediaLibrary

// "Open Recent" submenu of the "..." menu (Figma "Profiles"): the last played media.
// Separate file: VLC.MediaLibrary only exists with the media library, RMainMenu
// loads it through a Loader.
RMenu {
    id: root

    iconName: "recent"
    title: qsTr("Open Recent")

    property MLRecentMediaModel recents: MLRecentMediaModel { ml: MediaLib; limit: 10 }

    property Instantiator entries: Instantiator {
        model: root.recents
        delegate: RAction {
            required property var model
            text: model.title || model.url
            onTriggered: MediaLib.addAndPlay(model.id)
        }
        onObjectAdded: (index, object) => root.insertAction(index, object)
        onObjectRemoved: (index, object) => root.removeAction(object)
    }

    RMenuSeparator { }
    RAction {
        iconName: "trash"
        text: qsTr("Clear")
        enabled: root.recents.count > 0
        onTriggered: root.recents.clearHistory()
    }
}
