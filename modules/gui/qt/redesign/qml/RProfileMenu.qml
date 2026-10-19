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

// "Profile (<name>)" submenu of the "..." menu (Figma "Profiles").
RMenu {
    id: root

    iconName: "profile_2t"
    title: RProfiles.current.length > 0 ? qsTr("Profile (%1)").arg(RProfiles.current) : qsTr("Profile")

    property Instantiator entries: Instantiator {
        model: RProfiles.names
        delegate: RAction {
            required property string modelData
            text: modelData
            checkable: true
            checked: RProfiles.current === modelData
            onTriggered: RProfiles.select(modelData)
        }
        onObjectAdded: (index, object) => root.insertAction(index, object)
        onObjectRemoved: (index, object) => root.removeAction(object)
    }

    RMenuSeparator { }
    RAction {
        iconName: "add"
        text: qsTr("New")
        onTriggered: {
            const r = DialogsProvider.getTextDialog(null, qsTr("New Profile"),
                                                    qsTr("Name of the new profile:"),
                                                    qsTr("Profile %1").arg(RProfiles.names.length + 1))
            if (r.ok)
                RProfiles.add(r.text)
        }
    }
}
