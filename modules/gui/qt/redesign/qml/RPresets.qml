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
import VLC.MainInterface
import VLC.Player

QtObject {
    id: root
    property var names: {
        try { const list = JSON.parse(String(MainCtx.settingValue("Redesign/presetNames", "[]"))); return Array.isArray(list) ? list.filter(n => typeof n === "string") : [] }
        catch (e) { return [] }
    }
    property string current: ""
    signal applied()
    readonly property var audioOptions: ["compressor-attack", "compressor-knee", "compressor-makeup-gain", "compressor-ratio", "compressor-release", "compressor-rms-peak", "compressor-threshold", "equalizer-2pass", "equalizer-bands", "equalizer-preamp", "equalizer-preset", "pitch-shift", "spatializer-damp", "spatializer-dry", "spatializer-roomsize", "spatializer-wet", "spatializer-width", "stereowiden-crossfeed", "stereowiden-delay", "stereowiden-dry-mix", "stereowiden-feedback"]
    readonly property var videoOptions: ["brightness", "colorthres-saturationthres", "colorthres-similaritythres", "contrast", "crop-bottom", "crop-left", "crop-right", "crop-top", "gamma", "gradfun-radius", "gradient-cartoon", "grain-variance", "hue", "saturation", "sepia-intensity", "sharpen-sigma"]
    readonly property var subtitleOptions: ["freetype-font", "freetype-rel-fontsize", "freetype-fontsize", "freetype-color", "freetype-outline-thickness", "freetype-outline-color", "sub-margin", "sub-language", "audio-language", "subsdec-encoding"]
    readonly property var audioFilters: ["equalizer", "compressor", "spatializer", "stereo_widen", "scaletempo_pitch", "normvol", "headphone", "karaoke", "mono"]
    readonly property var videoFilters: ["adjust", "sharpen", "gradfun", "grain", "invert", "posterize", "sepia", "gradient", "colorthres", "transform", "magnify", "motionblur", "ripple", "wave", "psychedelic"]
    function key(name) { return "Redesign/presets/" + encodeURIComponent(name) }
    function capture() {
        let s = { audio: {}, video: {}, subtitles: {}, af: {}, vf: {}, rate: Player.rate,
                  audioDelay: Player.audioDelayMS, subtitleDelay: Player.subtitleDelayMS, fps: Player.subtitleFPS }
        for (const n of audioOptions) s.audio[n] = RedesignEffects.audioValue(n)
        for (const n of videoOptions) s.video[n] = RedesignEffects.videoValue(n)
        for (const n of subtitleOptions) if (RedesignSettings.option(n).exists) s.subtitles[n] = RedesignSettings.value(n)
        for (const n of audioFilters) s.af[n] = RedesignEffects.audioFilterEnabled(n)
        for (const n of videoFilters) s.vf[n] = RedesignEffects.videoFilterEnabled(n)
        return s
    }
    function store(name) {
        name = name.trim()
        if (!name.length) return
        if (names.indexOf(name) < 0) names = names.concat([name])
        MainCtx.setSettingValue("Redesign/presetNames", JSON.stringify(names))
        MainCtx.setSettingValue(key(name), JSON.stringify(capture()))
        current = name
    }
    function remove(name) {
        names = names.filter(n => n !== name)
        MainCtx.setSettingValue("Redesign/presetNames", JSON.stringify(names))
        MainCtx.setSettingValue(key(name), "")
        if (current === name) current = ""
    }
    function applyDefault() {
        const s = { audio: {}, video: {}, subtitles: {}, af: {}, vf: {}, rate: 1, audioDelay: 0, subtitleDelay: 0, fps: 0 }
        for (const n of audioOptions) { const o = RedesignSettings.option(n); if (o.exists) s.audio[n] = o.defaultValue }
        for (const n of videoOptions) { const o = RedesignSettings.option(n); s.video[n] = o.exists ? o.defaultValue : 0 }
        for (const n of subtitleOptions) { const o = RedesignSettings.option(n); if (o.exists) s.subtitles[n] = o.defaultValue }
        for (const n of audioFilters) s.af[n] = false
        for (const n of videoFilters) s.vf[n] = false
        applySnapshot(s, "")
    }
    function apply(name) {
        let s
        try { s = JSON.parse(String(MainCtx.settingValue(key(name), ""))) } catch (e) { return }
        if (!s) return
        applySnapshot(s, name)
    }
    function applySnapshot(s, name) {
        // Values first so newly enabled filters inherit the stored parameters.
        for (const n in s.audio) if (s.audio[n] !== null) RedesignEffects.setAudioValue(n, s.audio[n])
        for (const n in s.video) if (s.video[n] !== null) RedesignEffects.setVideoValue(n, s.video[n])
        for (const n in s.subtitles) RedesignSettings.setValue(n, s.subtitles[n])
        for (const n in s.af) if (RedesignSettings.moduleAvailable(n)) RedesignEffects.setAudioFilterEnabled(n, s.af[n])
        for (const n in s.vf) if (RedesignSettings.moduleAvailable(n)) RedesignEffects.setVideoFilterEnabled(n, s.vf[n])
        Player.rate = s.rate
        Player.audioDelayMS = s.audioDelay
        Player.subtitleDelayMS = s.subtitleDelay
        Player.subtitleFPS = s.fps
        RedesignSettings.save()
        current = name
        applied()
    }
}
