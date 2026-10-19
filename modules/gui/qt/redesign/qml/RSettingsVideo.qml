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
    id: page

    RSettingsSection { text: qsTr("Output") }

    ROption { name: "video"; title: qsTr("Enable video") }
    ROption { name: "fullscreen"; title: qsTr("Start videos in fullscreen") }
    ROption { name: "disable-screensaver"; title: qsTr("Stop the screensaver during playback") }
    ROption { name: "video-wallpaper"; title: qsTr("Play video as desktop wallpaper") }
    ROption { name: "vout"; title: qsTr("Video output") }

    RSettingsSection { text: qsTr("Picture") }

    ROption { id: hue; name: "hue"; title: qsTr("Hue"); kind: "slider" }
    ROption { id: brightness; name: "brightness"; title: qsTr("Brightness"); kind: "slider" }
    ROption { id: contrast; name: "contrast"; title: qsTr("Contrast"); kind: "slider" }
    ROption { id: saturation; name: "saturation"; title: qsTr("Saturation"); kind: "slider" }
    ROption { id: gamma; name: "gamma"; title: qsTr("Gamma"); kind: "slider"; sliderTicks: 10 }
    RSettingRow {
        label: qsTr("Reset picture")
        Item {
            width: parent.width
            height: resetPicture.height
            RButton {
                id: resetPicture
                anchors.right: parent.right
                text: qsTr("Reset")
                onClicked: ["hue", "brightness", "contrast", "saturation", "gamma"].forEach(n => RedesignSettings.resetValue(n))
            }
        }
    }

    RSettingsSection { text: qsTr("Deinterlacing") }

    ROption { name: "deinterlace"; title: qsTr("Deinterlacing") }
    ROption { name: "deinterlace-mode"; title: qsTr("Method") }

    RSettingsSection { text: qsTr("Framing") }

    ROption { name: "aspect-ratio"; title: qsTr("Aspect ratio") }
    ROption { name: "crop"; title: qsTr("Crop") }
    ROption { name: "autoscale"; title: qsTr("Fit video to the window") }
    ROption { name: "video-title-show"; title: qsTr("Show the media title on the video") }

    RSettingsSection { text: qsTr("Snapshots") }

    ROption { name: "snapshot-path"; title: qsTr("Save snapshots to") }
    ROption { name: "snapshot-format"; title: qsTr("Format") }

    // SUBCAT_VIDEO_GENERAL, SUBCAT_VIDEO_VOUT, SUBCAT_VIDEO_VFILTER, SUBCAT_VIDEO_SPLITTER
    RAdvancedOptions { subcats: [301, 302, 303, 306] }
}
