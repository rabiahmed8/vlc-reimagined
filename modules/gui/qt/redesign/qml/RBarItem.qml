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
import VLC.Player
import VLC.Playlist
import VLC.Dialogs

// One control of the control bar placed with "Customize Player" (RBarCatalog ids).
Item {
    id: root

    property string itemId
    readonly property var info: RBarCatalog.item(itemId)

    function jump(seconds) {
        const len = Player.length.toSeconds()
        if (len > 0)
            Player.jumpToPos(Math.max(0, Math.min(1, Player.position + seconds / len)))
    }

    function trigger() {
        switch (itemId) {
        case "speed": RWindows.panelRequested("playback", 0); break
        case "fwd10": jump(10); break
        case "back10": jump(-10); break
        case "fwd15": jump(15); break
        case "back15": jump(-15); break
        case "stop": MainPlaylistController.stop(); break
        case "repeat": MainPlaylistController.toggleRepeatMode(); break
        case "shuffle": MainPlaylistController.toggleRandom(); break
        case "record": Player.toggleRecord(); break
        case "snapshot": Player.snapshot(); break
        case "effects": RWindows.effectsRequested(0); break
        case "equalizer": RWindows.effectsRequested(1); break
        case "fullscreen": MainCtx.toggleInterfaceFullScreen(); break
        case "library": RWindows.libraryRequested("home"); break
        case "settings": DialogsProvider.prefsDialog(); break
        case "quit": DialogsProvider.quit(); break
        case "properties": DialogsProvider.mediaInfoDialog(); break
        case "replay": Player.position = 0; break
        case "chapters": RWindows.panelRequested("queue", 2); break
        case "bookmarks": RWindows.panelRequested("queue", 1); break
        case "playlists": RWindows.libraryRequested("playlists"); break
        }
    }

    readonly property bool isText: itemId === "fileName" || itemId === "artistName"
    readonly property bool checked: (itemId === "shuffle" && MainPlaylistController.random)
                                    || (itemId === "repeat" && MainPlaylistController.repeatMode !== 0)
                                    || (itemId === "record" && Player.recording)

    implicitWidth: itemId === "spacer" ? Theme.dp(24)
                 : itemId === "divider" ? Theme.dp(9)
                 : isText ? Math.min(Theme.dp(220), label.implicitWidth)
                 : itemId === "thumbnail" ? Theme.dp(34)
                 : button.implicitWidth
    implicitHeight: Theme.dp(30)

    Rectangle {
        visible: root.itemId === "divider"
        anchors.centerIn: parent
        width: 1
        height: Theme.dp(18)
        color: Theme.p.dividerBright
    }

    RText {
        id: label
        visible: root.isText
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        text: root.itemId === "fileName" ? (Player.title || Player.name) : (Player.artist || "")
        color: Theme.textItem
    }

    Image {
        visible: root.itemId === "thumbnail"
        anchors.fill: parent
        source: Player.artwork
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    RIconButton {
        id: button
        visible: root.itemId !== "spacer" && root.itemId !== "divider" && !root.isText && root.itemId !== "thumbnail"
        anchors.centerIn: parent
        iconName: root.itemId === "repeat" && MainPlaylistController.repeatMode === 1 ? "repeat_one"
                : root.info ? root.info.icon : ""
        toolTip: root.info ? root.info.text : ""
        checked: root.checked
        onClicked: root.trigger()
    }
}
