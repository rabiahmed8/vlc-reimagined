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

RSettingsPage {
    RSettingsSection { text: qsTr("Startup") }

    ROption { name: "restore-playback-pos"; title: qsTr("Continue where you left off") }
    ROption { name: "playlist-autostart"; title: qsTr("Start playing as soon as a file opens") }
    ROption { name: "start-paused"; title: qsTr("Start paused") }
    ROption {
        name: "rate"
        title: qsTr("Default playback speed")
        kind: "slider"
        minimum: 0.25
        maximum: 2
        sliderStep: 0.25
        sliderTicks: 7
        sliderLabels: [{ value: 0.25, text: "0.25" }, { value: 0.5, text: "0.5" }, { value: 0.75, text: "0.75" },
                       { value: 1, text: "1" }, { value: 1.25, text: "1.25" }, { value: 1.5, text: "1.5" },
                       { value: 1.75, text: "1.75" }, { value: 2, text: "2" }]
    }

    RSettingsSection { text: qsTr("Tracks") }

    ROption { name: "preferred-resolution"; title: qsTr("Preferred video quality") }
    ROption { name: "menu-language"; title: qsTr("Preferred menu language") }
    ROption { name: "audio-language"; title: qsTr("Preferred audio language") }
    ROption { name: "audio-track"; title: qsTr("Default audio track") }
    ROption { name: "sub-track"; title: qsTr("Default subtitle track") }

    RSettingsSection { text: qsTr("Order") }

    ROption { name: "loop"; title: qsTr("Repeat all") }
    ROption { name: "repeat"; title: qsTr("Repeat current item") }
    ROption { name: "random"; title: qsTr("Shuffle") }
    ROption { name: "play-and-stop"; title: qsTr("Stop after each item") }
    ROption { name: "play-and-exit"; title: qsTr("Quit when playback finishes") }
    ROption { name: "play-and-pause"; title: qsTr("Pause on the last frame") }

    RSettingsSection { text: qsTr("Seeking") }

    ROption { name: "input-fast-seek"; title: qsTr("Seek faster, less precisely") }

    // SUBCAT_INPUT_GENERAL, SUBCAT_PLAYLIST_GENERAL, SUBCAT_PLAYLIST_SD
    RAdvancedOptions { subcats: [401, 701, 702] }
}
