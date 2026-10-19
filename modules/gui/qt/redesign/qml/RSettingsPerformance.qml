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

RSettingsPage {
    RSettingsSection { text: qsTr("Decoding") }

    ROption { name: "avcodec-hw"; title: qsTr("Hardware-accelerated decoding") }
    ROption { name: "postproc-q"; title: qsTr("Video post-processing") }
    ROption { name: "avcodec-skiploopfilter"; title: qsTr("Skip the H.264 loop filter") }
    ROption { name: "avcodec-threads"; title: qsTr("Decoding threads") }
    ROption { name: "avcodec-fast"; title: qsTr("Faster decoding, lower quality") }

    RSettingsSection { text: qsTr("Smooth Playback") }

    ROption { name: "drop-late-frames"; title: qsTr("Drop frames when the system can't keep up") }
    ROption { name: "skip-frames"; title: qsTr("Skip frames") }
    ROption { name: "high-priority"; title: qsTr("Give VLC real-time priority") }
    ROption { name: "reset-plugins-cache"; title: qsTr("Rescan plugins on next start") }

    RSettingsSection { text: qsTr("Developer") }

    ROption { name: "codec"; title: qsTr("Decoder") }
    ROption { name: "encoder"; title: qsTr("Encoder") }
    ROption { name: "clock-synchro"; title: qsTr("Clock synchronisation") }
    ROption { name: "clock-jitter"; title: qsTr("Clock jitter"); suffix: "ms" }
    ROption { name: "clock-master"; title: qsTr("Clock source") }

    // SUBCAT_INPUT_VCODEC, SUBCAT_INPUT_ACODEC, SUBCAT_INPUT_DEMUX, SUBCAT_INPUT_STREAM_FILTER
    RAdvancedOptions { subcats: [404, 405, 403, 407] }
}
