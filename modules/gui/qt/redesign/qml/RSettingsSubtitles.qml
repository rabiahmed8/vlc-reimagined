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
    RSettingsSection { text: qsTr("Tracks & Languages") }

    ROption { name: "spu"; title: qsTr("Enable subtitles") }
    ROption { name: "sub-language"; title: qsTr("Preferred language") }
    ROption { name: "subsdec-encoding"; title: qsTr("Text encoding") }

    RSettingsSection { text: qsTr("Loading Subtitles") }

    ROption { name: "sub-autodetect-file"; title: qsTr("Load subtitle files automatically") }
    ROption { name: "sub-autodetect-fuzzy"; title: qsTr("File name matching") }
    ROption { name: "sub-autodetect-path"; title: qsTr("Also look in these folders") }

    RSettingsSection { text: qsTr("Appearance") }

    ROption { name: "freetype-font"; title: qsTr("Font") }
    RSettingRow {
        id: sizeMode
        label: qsTr("Size values")
        info: qsTr("Relative: the size follows the video height. Pixels: a fixed size.")
        property bool pixels: Number(RedesignSettings.value("freetype-fontsize")) > 0
        RSegmented {
            width: parent.width
            model: [{ value: false, text: qsTr("Relative") }, { value: true, text: qsTr("Pixels") }]
            currentValue: sizeMode.pixels
            onPicked: (v) => {
                sizeMode.pixels = v
                if (!v)
                    RedesignSettings.setValue("freetype-fontsize", 0)
                else if (Number(RedesignSettings.value("freetype-fontsize")) <= 0)
                    RedesignSettings.setValue("freetype-fontsize", 36)
            }
        }
    }
    ROption { name: "freetype-rel-fontsize"; title: qsTr("Font size"); visible: opt.exists === true && !sizeMode.pixels }
    ROption { name: "freetype-fontsize"; title: qsTr("Font size (pixels)"); visible: opt.exists === true && sizeMode.pixels }
    ROption { name: "freetype-bold"; title: qsTr("Bold") }
    ROption { name: "freetype-color"; title: qsTr("Text color") }
    ROption {
        name: "freetype-opacity"
        title: qsTr("Text opacity")
        kind: "slider"
        sliderTicks: 10
        sliderLabels: [{ value: 0, text: "0%" }, { value: 128, text: "50%" }, { value: 255, text: "100%" }]
    }
    ROption { name: "freetype-outline-thickness"; title: qsTr("Outline thickness") }
    ROption { name: "freetype-outline-color"; title: qsTr("Outline color") }
    ROption { name: "freetype-shadow-opacity"; title: qsTr("Shadow opacity"); kind: "slider" }
    ROption { name: "freetype-shadow-color"; title: qsTr("Shadow color") }
    ROption { name: "freetype-background-opacity"; title: qsTr("Background opacity"); kind: "slider" }
    ROption { name: "freetype-background-color"; title: qsTr("Background color") }

    RSettingsSection { text: qsTr("Position") }

    ROption { name: "sub-margin"; title: qsTr("Distance from the bottom (pixels)") }
    ROption { name: "secondary-sub-margin"; title: qsTr("Secondary subtitles distance") }

    RSettingsSection { text: qsTr("On Screen Display") }

    ROption { name: "osd"; title: qsTr("Show on screen messages") }
    ROption { name: "video-title-show"; title: qsTr("Show the media title when playback starts") }
    ROption { name: "video-title-timeout"; title: qsTr("Title duration (ms)") }

    // SUBCAT_VIDEO_SUBPIC, SUBCAT_INPUT_SCODEC
    RAdvancedOptions { subcats: [305, 406] }
}
