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
import VLC.Playlist

// Requests for the secondary windows and dialogs of the redesign. Any item can
// emit them; RMainInterface owns the windows and opens them.
QtObject {
    id: root
    property int sleepMinutes: 0
    property double sleepDeadline: 0
    property int sleepRemaining: 0
    function setSleepTimer(minutes) {
        sleepMinutes = minutes
        sleepDeadline = minutes > 0 ? Date.now() + minutes * 60000 : 0
        sleepRemaining = minutes * 60
    }
    property Timer sleepTimer: Timer {
        interval: 1000
        repeat: true
        running: root.sleepDeadline > 0
        onTriggered: {
            root.sleepRemaining = Math.max(0, Math.ceil((root.sleepDeadline - Date.now()) / 1000))
            if (root.sleepRemaining === 0) {
                root.setSleepTimer(0)
                MainPlaylistController.stop()
            }
        }
    }
    signal settingsRequested(string category)
    signal shortcutsRequested()
    signal subtitleTimelineRequested()
    // tab: 0 video effects, 1 audio effects (tracks popup of the player)
    signal effectsRequested(int tab)
    // a panel of the player ("queue", "playback"...) with its tab
    signal panelRequested(string name, int tab)
    // the library on a page ("home", "playlists"...)
    signal libraryRequested(string page)
    signal customizeRequested()
    signal miniPlayerRequested()
    signal networkStreamRequested()
    signal newPlaylistRequested()
    signal addToPlaylistRequested(var mediaIds)
    // url: a media of the folder to pair with subtitles ("" = ask for the folder)
    signal addSubtitlesRequested(string url)
    signal addSubtitlesToMediaRequested(var urls)
    signal addAudioToMediaRequested(var urls)
}
