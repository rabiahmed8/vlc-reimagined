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

// Label + switch for a live filter: module (turns a video/audio filter on and off)
// or option (a boolean parameter of a filter).
Item {
    id: root

    property string label
    property string module
    property string option
    property bool audio: false
    property bool checked: false

    function reload() {
        if (module.length > 0)
            checked = audio ? RedesignEffects.audioFilterEnabled(module) : RedesignEffects.videoFilterEnabled(module)
        else
            checked = (audio ? RedesignEffects.audioValue(option) : RedesignEffects.videoValue(option)) === true
    }

    width: parent ? parent.width : implicitWidth
    implicitWidth: Theme.dp(320)
    visible: module.length > 0 ? RedesignSettings.moduleAvailable(module) : RedesignSettings.option(option).exists
    height: visible ? Theme.dp(40) : 0
    Component.onCompleted: reload()

    RText {
        anchors.left: parent.left
        anchors.right: sw.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        color: Theme.textItem
    }
    RSwitch {
        id: sw
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        checked: root.checked
        onToggled: {
            root.checked = checked
            if (root.module.length > 0) {
                if (root.audio)
                    RedesignEffects.setAudioFilterEnabled(root.module, checked)
                else
                    RedesignEffects.setVideoFilterEnabled(root.module, checked)
            } else if (root.audio) {
                RedesignEffects.setAudioValue(root.option, checked)
            } else {
                RedesignEffects.setVideoValue(root.option, checked)
            }
        }
    }
}
