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

// Labelled slider bound to a parameter of a live video or audio filter
// ("contrast", "compressor-ratio"...), with its value shown on the right.
Column {
    id: root

    property string label
    property string option
    property bool audio: false        // false: video output parameter
    property real from: 0
    property real to: 1
    property real stepSize: 0
    property int decimals: 1
    property string unit
    property int tickCount: 0
    property bool integer: false

    property real value: 0
    function reload() {
        const v = audio ? RedesignEffects.audioValue(option) : RedesignEffects.videoValue(option)
        value = v === undefined ? from : Number(v)
    }
    function set(v) {
        value = v
        const out = integer ? Math.round(v) : v
        if (audio)
            RedesignEffects.setAudioValue(option, out)
        else
            RedesignEffects.setVideoValue(option, out)
    }

    width: parent ? parent.width : implicitWidth
    spacing: Theme.dp(6)
    Component.onCompleted: reload()

    Item {
        width: parent.width
        height: Theme.dp(22)
        RText {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: Theme.textItem
        }
        RText {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.value.toFixed(root.integer ? 0 : root.decimals) + (root.unit ? " " + root.unit : "")
            color: Theme.textDim
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    RTickSlider {
        width: parent.width
        from: root.from
        to: root.to
        stepSize: root.stepSize
        tickCount: root.tickCount
        value: root.value
        onMoved: root.set(value)
    }
}
