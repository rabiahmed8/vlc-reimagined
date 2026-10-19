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
pragma Singleton

import QtQuick

import VLC.MainInterface

// Controls that can be added to the control bar (Figma "Player - customize"), and the
// ones the user placed there ("Customize Player", kept in the Qt settings).
QtObject {
    id: root

    readonly property var items: [
        { id: "spacer", text: qsTr("Spacer"), icon: "" },
        { id: "divider", text: qsTr("Divider"), icon: "divider" },
        { id: "speed", text: qsTr("Playback Speed"), icon: "speed" },
        { id: "fwd10", text: qsTr("Forward 10s"), icon: "forward-10-sec" },
        { id: "back10", text: qsTr("Backward 10s"), icon: "backward-10-sec" },
        { id: "fwd15", text: qsTr("Forward 15s"), icon: "forward-15-sec" },
        { id: "back15", text: qsTr("Backward 15s"), icon: "backward-15-sec" },
        { id: "stop", text: qsTr("Stop"), icon: "stop" },
        { id: "repeat", text: qsTr("Repeat"), icon: "repeat" },
        { id: "shuffle", text: qsTr("Shuffle"), icon: "shuffle" },
        { id: "record", text: qsTr("Record"), icon: "record" },
        { id: "snapshot", text: qsTr("Snapshot"), icon: "snapshot" },
        { id: "effects", text: qsTr("Video Effects"), icon: "paint" },
        { id: "equalizer", text: qsTr("Equalizer"), icon: "EQ" },
        { id: "fullscreen", text: qsTr("Fullscreen"), icon: "fullscreen" },
        { id: "library", text: qsTr("Go Home"), icon: "home" },
        { id: "settings", text: qsTr("VLC Settings"), icon: "settings" },
        { id: "quit", text: qsTr("Quit VLC"), icon: "quit" },
        { id: "thumbnail", text: qsTr("Thumbnail"), icon: "thumbnail" },
        { id: "fileName", text: qsTr("File Name"), icon: "info" },
        { id: "artistName", text: qsTr("Artist Name"), icon: "info" },
        { id: "properties", text: qsTr("Properties"), icon: "info" },
        { id: "replay", text: qsTr("Replay"), icon: "replay" },
        { id: "chapters", text: qsTr("Chapters"), icon: "chapters" },
        { id: "bookmarks", text: qsTr("Bookmarks"), icon: "bookmarks" },
        { id: "playlists", text: qsTr("Playlists"), icon: "playlist" }
    ]

    function item(id) {
        for (const it of items)
            if (it.id === id)
                return it
        return null
    }

    // ids placed in the control bar, before the audio / subtitles / settings buttons
    property var extras: {
        try {
            const v = JSON.parse(String(MainCtx.settingValue("Redesign/controlbarExtras", "[]")))
            return Array.isArray(v) ? v.filter(id => root.item(id) !== null) : []
        } catch (e) {
            return []
        }
    }

    property var topExtras: {
        try {
            const v = JSON.parse(String(MainCtx.settingValue("Redesign/topbarExtras", "[]")))
            return Array.isArray(v) ? v.filter(id => root.item(id) !== null) : []
        } catch (e) { return [] }
    }

    function setTopExtras(list) {
        topExtras = list.filter(id => root.item(id) !== null)
        MainCtx.setSettingValue("Redesign/topbarExtras", JSON.stringify(topExtras))
    }

    function setExtras(list) {
        extras = list.filter(id => root.item(id) !== null)
        MainCtx.setSettingValue("Redesign/controlbarExtras", JSON.stringify(list))
    }
}
