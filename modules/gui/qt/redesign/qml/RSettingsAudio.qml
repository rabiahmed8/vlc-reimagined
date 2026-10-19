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

    ROption { name: "audio"; title: qsTr("Enable audio") }
    ROption { name: "aout"; title: qsTr("Output module") }
    ROption { name: "stereo-mode"; title: qsTr("Speaker setup") }
    ROption { name: "spdif"; title: qsTr("Pass-through audio to the receiver (S/PDIF)") }

    RSettingsSection { text: qsTr("Volume") }

    ROption {
        name: "qt-max-volume"
        title: qsTr("Maximum volume")
        kind: "slider"
        minimum: 100
        maximum: 300
        sliderStep: 25
        sliderTicks: 8
        sliderLabels: [{ value: 100, text: "100%" }, { value: 200, text: "200%" }, { value: 300, text: "300%" }]
    }
    ROption { name: "volume-save"; title: qsTr("Remember last volume") }
    ROption { name: "gain"; title: qsTr("Startup gain") }
    ROption { name: "volume-step"; title: qsTr("Volume step") }

    RSettingsSection { text: qsTr("Loudness") }

    RModuleSwitch {
        list: "audio-filter"
        module: "normvol"
        label: qsTr("Normalize loudness")
        info: qsTr("Keeps the loudness of all media at the same level.")
    }
    ROption { name: "norm-max-level"; title: qsTr("Target level") }
    RModuleSwitch {
        list: "audio-filter"
        module: "compressor"
        label: qsTr("Night mode")
        info: qsTr("Compresses the dynamic range: quiet sounds are louder, loud sounds quieter.")
    }
    ROption { name: "audio-replay-gain-mode"; title: qsTr("Replay gain") }
    ROption { name: "audio-replay-gain-preamp"; title: qsTr("Replay gain preamp") }

    RSettingsSection { text: qsTr("Effects") }

    RModuleSwitch {
        list: "audio-filter"
        module: "equalizer"
        label: qsTr("Equalizer")
    }
    ROption { name: "equalizer-preset"; title: qsTr("Equalizer preset") }

    REqualizerBands {
        id: eq
        width: parent.width
        height: implicitHeight + Theme.dp(20)
        sliderHeight: Theme.dp(260)
        visible: RedesignSettings.option("equalizer-bands").exists === true

        function reload() {
            preamp = Number(RedesignSettings.value("equalizer-preamp") || 0)
            const s = String(RedesignSettings.value("equalizer-bands") || "").trim()
            const b = s.length > 0 ? s.split(/\s+/).map(Number) : []
            while (b.length < 10) b.push(0)
            bands = b.slice(0, 10)
        }
        Component.onCompleted: reload()
        onPreampEdited: (v) => RedesignSettings.setValue("equalizer-preamp", v)
        onBandsEdited: (b) => RedesignSettings.setValue("equalizer-bands", b.map(x => x.toFixed(1)).join(" "))
        Connections {
            target: RedesignSettings
            function onValueChanged(name) { if (name.startsWith("equalizer")) eq.reload() }
        }
    }

    ROption { name: "equalizer-2pass"; title: qsTr("Two-pass") }

    RModuleSwitch {
        list: "audio-filter"
        module: "spatializer"
        label: qsTr("Spatial audio")
        info: qsTr("Room simulation (spatializer).")
    }
    RModuleSwitch {
        list: "audio-filter"
        module: "stereo_widen"
        label: qsTr("Stereo widening")
    }
    RModuleSwitch {
        list: "audio-filter"
        module: "headphone"
        label: qsTr("Headphone virtualization")
    }

    RSettingsSection { text: qsTr("Visualization") }

    ROption { name: "audio-visual"; title: qsTr("Visualization") }

    // SUBCAT_AUDIO_GENERAL, SUBCAT_AUDIO_AOUT, SUBCAT_AUDIO_AFILTER, SUBCAT_AUDIO_VISUAL, SUBCAT_AUDIO_RESAMPLER
    RAdvancedOptions { subcats: [201, 202, 203, 204, 206] }
}
