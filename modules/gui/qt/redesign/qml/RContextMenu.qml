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

// Right click menu on the video, tidied up version of the classic one.
RMenu {
    id: root

    // forwarded to the player view
    signal hideUiRequested()
    signal panelRequested(string name, int tab)

    readonly property bool playing: Player.playingState === Player.PLAYING_STATE_PLAYING

    RAction {
        iconName: root.playing ? "pause" : "play"
        text: root.playing ? qsTr("Pause") : qsTr("Play")
        shortcutText: qsTr("Space")
        onTriggered: MainPlaylistController.togglePlayPause()
    }
    RAction { iconName: "stop_2t"; text: qsTr("Stop"); shortcutText: "S"; enabled: Player.isStarted; onTriggered: MainPlaylistController.stop() }
    RAction { iconName: "previous_2t"; text: qsTr("Previous Item"); shortcutText: "P"; onTriggered: MainPlaylistController.prev() }
    RAction { iconName: "next_2t"; text: qsTr("Next Item"); shortcutText: "N"; enabled: MainPlaylistController.hasNext; onTriggered: MainPlaylistController.next() }
    RAction {
        iconName: "record_2t"
        text: Player.recording ? qsTr("Stop Recording") : qsTr("Record")
        shortcutText: "R"
        enabled: Player.isStarted
        onTriggered: Player.toggleRecord()
    }

    RMenuSeparator { }

    RAction { iconName: "ui_2t"; text: qsTr("Hide UI"); shortcutText: "Ctrl + H"; onTriggered: root.hideUiRequested() }

    RMenuSeparator { }

    RAction { iconName: "playback_2t"; text: qsTr("Playback");  onTriggered: root.panelRequested("playback", 0) }
    RAction { iconName: "video_2t";    text: qsTr("Video");     onTriggered: root.panelRequested("video", 0) }
    RAction { iconName: "audio_2t";    text: qsTr("Audio");     onTriggered: root.panelRequested("audio", 1) }
    RAction { iconName: "subtitles_2t"; text: qsTr("Subtitle");  onTriggered: root.panelRequested("subtitles", 2) }

    RMenuSeparator { }

    RAction { iconName: "settings_2t"; text: qsTr("More Settings"); onTriggered: DialogsProvider.prefsDialog() }
    RAction { iconName: "playlist_2t"; text: qsTr("Queue");         onTriggered: root.panelRequested("queue", 0) }
    RAction { iconName: "file_2t";     text: qsTr("Open Media");    shortcutText: "Ctrl + O"; onTriggered: DialogsProvider.simpleOpenDialog() }
    RAction { iconName: "quit_2t";     text: qsTr("Quit VLC");      shortcutText: "Ctrl + Q"; onTriggered: DialogsProvider.quit() }
}
