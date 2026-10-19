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
import QtQuick.Templates as T

import VLC.MainInterface
import VLC.Player

// Audio effects of the tracks popup (Figma "Audio - Equalizer", "Audio - Compressor
// Settings", "Audio - Spatializer Settings", "Audio - Stereo Widener", "EQ presets"):
// live filters on the playing audio, kept for the next media.
Flickable {
    id: root

    // icon of each equalizer preset (Figma "EQ presets")
    readonly property var presetIcons: ({
        flat: "", classical: "EQ_classical", club: "EQ_club", dance: "EQ_dance",
        fullbass: "EQ_full-bass", fullbasstreble: "EQ_full-bass-and-treble",
        fulltreble: "EQ_full-treble", headphones: "EQ_headphones", largehall: "EQ_large-hall",
        live: "EQ_live", party: "EQ_party", pop: "EQ_pop", reggae: "EQ_reggae", rock: "EQ_rock",
        ska: "EQ_ska", soft: "EQ_soft", softrock: "EQ_soft-rock", techno: "EQ_techno"
    })

    clip: true
    contentHeight: column.height + Theme.dp(20)
    boundsBehavior: Flickable.StopAtBounds
    T.ScrollBar.vertical: RScrollBar { }

    Column {
        id: column
        x: Theme.dp(16)
        y: Theme.dp(10)
        width: root.width - Theme.dp(32)
        spacing: Theme.dp(10)

        RCollapsible {
            id: eqBox
            title: qsTr("Equalizer")
            expanded: true
            checkable: true
            checked: RedesignEffects.audioFilterEnabled("equalizer")
            onToggled: (on) => { RedesignEffects.setAudioFilterEnabled("equalizer", on); checked = on }

            RDropdown {
                id: presets
                width: parent.width
                model: [{ value: "", text: qsTr("None") }].concat(
                           RedesignEffects.equalizerPresets().map(p => Object.assign(p, { icon: root.presetIcons[p.value] || "" })))
                Component.onCompleted: selectValue(String(RedesignEffects.audioValue("equalizer-preset") || ""))
                onPicked: (v) => {
                    if (v.length === 0)
                        return
                    const r = RedesignEffects.applyEqualizerPreset(v)
                    bands.preamp = r.preamp
                    bands.bands = r.bands
                }
            }

            REqualizerBands {
                id: bands
                width: parent.width
                sliderHeight: Theme.dp(170)

                Component.onCompleted: {
                    preamp = Number(RedesignEffects.audioValue("equalizer-preamp") || 0)
                    const s = String(RedesignEffects.audioValue("equalizer-bands") || "").trim()
                    const b = s.length > 0 ? s.split(/\s+/).map(Number) : []
                    while (b.length < 10) b.push(0)
                    bands.bands = b.slice(0, 10)
                }
                onPreampEdited: (v) => { preamp = v; RedesignEffects.setAudioValue("equalizer-preamp", v) }
                onBandsEdited: (b) => {
                    bands.bands = b
                    presets.currentIndex = 0
                    RedesignEffects.setAudioValue("equalizer-bands", b.map(x => x.toFixed(1)).join(" "))
                }
            }

            RFilterSwitch { label: qsTr("Two-pass"); option: "equalizer-2pass"; audio: true }
        }

        RCollapsible {
            title: qsTr("Compressor")
            checkable: true
            checked: RedesignEffects.audioFilterEnabled("compressor")
            onToggled: (on) => { RedesignEffects.setAudioFilterEnabled("compressor", on); checked = on }

            REffectSlider { audio: true; label: qsTr("RMS / Peak"); option: "compressor-rms-peak"; from: 0; to: 1; decimals: 1 }
            REffectSlider { audio: true; label: qsTr("Attack"); option: "compressor-attack"; from: 1.5; to: 400; unit: "ms" }
            REffectSlider { audio: true; label: qsTr("Release"); option: "compressor-release"; from: 2; to: 800; unit: "ms" }
            REffectSlider { audio: true; label: qsTr("Threshold"); option: "compressor-threshold"; from: -30; to: 0; unit: "dB" }
            REffectSlider { audio: true; label: qsTr("Ratio"); option: "compressor-ratio"; from: 1; to: 20; unit: ": 1" }
            REffectSlider { audio: true; label: qsTr("Knee radius"); option: "compressor-knee"; from: 1; to: 10; unit: "dB" }
            REffectSlider { audio: true; label: qsTr("Makeup gain"); option: "compressor-makeup-gain"; from: 0; to: 24; unit: "dB" }
        }

        RCollapsible {
            title: qsTr("Spatializer")
            checkable: true
            checked: RedesignEffects.audioFilterEnabled("spatializer")
            onToggled: (on) => { RedesignEffects.setAudioFilterEnabled("spatializer", on); checked = on }

            REffectSlider { audio: true; label: qsTr("Room size"); option: "spatializer-roomsize"; from: 0; to: 1.1; decimals: 2 }
            REffectSlider { audio: true; label: qsTr("Width"); option: "spatializer-width"; from: 0; to: 1; decimals: 2 }
            REffectSlider { audio: true; label: qsTr("Wet"); option: "spatializer-wet"; from: 0; to: 1; decimals: 2 }
            REffectSlider { audio: true; label: qsTr("Dry"); option: "spatializer-dry"; from: 0; to: 1; decimals: 2 }
            REffectSlider { audio: true; label: qsTr("Damp"); option: "spatializer-damp"; from: 0; to: 1; decimals: 2 }
        }

        RCollapsible {
            title: qsTr("Stereo widener")
            checkable: true
            checked: RedesignEffects.audioFilterEnabled("stereo_widen")
            onToggled: (on) => { RedesignEffects.setAudioFilterEnabled("stereo_widen", on); checked = on }

            REffectSlider { audio: true; label: qsTr("Delay"); option: "stereowiden-delay"; from: 1; to: 100; unit: "ms" }
            REffectSlider { audio: true; label: qsTr("Feedback"); option: "stereowiden-feedback"; from: 0; to: 0.9; decimals: 2 }
            REffectSlider { audio: true; label: qsTr("Crossfeed"); option: "stereowiden-crossfeed"; from: 0; to: 0.8; decimals: 2 }
            REffectSlider { audio: true; label: qsTr("Dry mix"); option: "stereowiden-dry-mix"; from: 0; to: 1; decimals: 2 }
        }

        RCollapsible {
            title: qsTr("Pitch")
            checkable: true
            checked: RedesignEffects.audioFilterEnabled("scaletempo_pitch")
            onToggled: (on) => { RedesignEffects.setAudioFilterEnabled("scaletempo_pitch", on); checked = on }

            REffectSlider { audio: true; label: qsTr("Pitch shift"); option: "pitch-shift"; from: -12; to: 12; decimals: 1; unit: qsTr("semitones"); tickCount: 24 }
        }

        RCollapsible {
            title: qsTr("Audio visualizer")
            RTrackList { width: parent.width; height: Theme.dp(210); model: Player.audioVisualization }
        }

        RCollapsible {
            title: qsTr("More")
            RFilterSwitch { audio: true; label: qsTr("Normalize loudness"); module: "normvol" }
            RFilterSwitch { audio: true; label: qsTr("Headphone virtualization"); module: "headphone" }
            RFilterSwitch { audio: true; label: qsTr("Karaoke (remove voice)"); module: "karaoke" }
            RFilterSwitch { audio: true; label: qsTr("Mono"); module: "mono" }
        }
    }
}
