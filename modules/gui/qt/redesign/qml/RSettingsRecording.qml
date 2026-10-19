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
    RSettingsSection { text: qsTr("Recording") }

    ROption { name: "input-record-path"; title: qsTr("Save recordings to") }
    ROption { name: "input-record-native"; title: qsTr("Record without re-encoding when possible") }

    RSettingsSection { text: qsTr("Casting") }

    ROption { name: "demux-filter"; title: qsTr("Stream filters") }
    ROption { name: "sout-chromecast-conversion-quality"; title: qsTr("Cast quality") }

    RSettingsSection { text: qsTr("Streaming") }

    ROption { name: "sout-display"; title: qsTr("Play locally while streaming") }
    ROption { name: "sout-keep"; title: qsTr("Keep the stream open between items") }
    ROption { name: "sout-audio"; title: qsTr("Include audio") }
    ROption { name: "sout-video"; title: qsTr("Include video") }
    ROption { name: "sout-spu"; title: qsTr("Include subtitles") }
    ROption { name: "sout-x264-preset"; title: qsTr("Encoding preset") }
    ROption { name: "sout-x264-tune"; title: qsTr("Tuning") }

    // SUBCAT_SOUT_*
    RAdvancedOptions { subcats: [501, 502, 503, 504, 505, 507, 508] }
}
