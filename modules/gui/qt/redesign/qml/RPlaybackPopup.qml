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
import QtQuick.Layouts
import QtQuick.Templates as T

import VLC.MainInterface
import VLC.Player
import VLC.Dialogs

// Playback settings: speed, A-B loop, snapshot, record and subtitle/audio delay.
Rectangle {
    id: root

    signal closeRequested()

    implicitWidth: Theme.popupWidth
    implicitHeight: col.implicitHeight
    radius: Theme.radiusLarge
    color: Theme.panelBackground
    clip: true

    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onWheel: (w) => w.accepted = true }

    Flickable {
        anchors.fill: parent
        contentHeight: col.implicitHeight
        clip: true
        T.ScrollBar.vertical: RScrollBar { }
    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        RPresetPicker { Layout.fillWidth: true; Layout.margins: Theme.dp(12) }
        RSectionHeader {
            Layout.fillWidth: true
            text: qsTr("Speed")
            RText { text: Player.rate.toFixed(2) + "×"; color: Theme.text }
        }

        RValueSlider {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.margin
            Layout.rightMargin: Theme.margin
            enabled: Player.ratechangable
            from: 0.25; to: 4; stepSize: 0.05
            value: Player.rate
            onMoved: Player.rate = value
            onReset: Player.normalRate()
        }

        RSectionHeader { Layout.fillWidth: true; text: qsTr("Subtitle delay")
            RText { text: Player.subtitleDelayMS + " ms"; color: Theme.text }
        }
        RValueSlider {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.margin
            Layout.rightMargin: Theme.margin
            enabled: Player.isStarted
            from: -10000; to: 10000; stepSize: 50
            value: Player.subtitleDelayMS
            onMoved: Player.subtitleDelayMS = value
            onReset: Player.subtitleDelayMS = 0
        }

        RSectionHeader { Layout.fillWidth: true; text: qsTr("Audio delay")
            RText { text: Player.audioDelayMS + " ms"; color: Theme.text }
        }
        RValueSlider {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.margin
            Layout.rightMargin: Theme.margin
            enabled: Player.isStarted
            from: -10000; to: 10000; stepSize: 50
            value: Player.audioDelayMS
            onMoved: Player.audioDelayMS = value
            onReset: Player.audioDelayMS = 0
        }

        RSectionHeader {
            Layout.fillWidth: true
            text: qsTr("Sleep timer")
            RText { text: RWindows.sleepDeadline > 0 ? qsTr("%1 min remaining").arg(Math.ceil(RWindows.sleepRemaining / 60)) : qsTr("Off") }
        }
        RDropdown {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.margin
            Layout.rightMargin: Theme.margin
            model: [{ value: 0, text: qsTr("Off") }, { value: 15, text: qsTr("15 minutes") },
                    { value: 30, text: qsTr("30 minutes") }, { value: 60, text: qsTr("1 hour") },
                    { value: 90, text: qsTr("90 minutes") }, { value: 120, text: qsTr("2 hours") }]
            Component.onCompleted: selectValue(RWindows.sleepMinutes)
            onPicked: (minutes) => RWindows.setSleepTimer(Number(minutes))
        }

        RSectionHeader { Layout.fillWidth: true; text: qsTr("Tools") }

        Flow {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.margin
            Layout.rightMargin: Theme.margin
            spacing: Theme.spacing

            RChip {
                iconName: "repeat"
                text: Player.ABloopState === Player.ABLOOP_STATE_NONE ? qsTr("A-B loop")
                    : Player.ABloopState === Player.ABLOOP_STATE_A ? qsTr("Set B")
                    : qsTr("Clear loop")
                checked: Player.ABloopState !== Player.ABLOOP_STATE_NONE
                enabled: Player.isStarted
                onClicked: Player.toggleABloopState()
            }
            RChip {
                iconName: "snapshot"
                text: qsTr("Snapshot")
                enabled: Player.hasVideoOutput
                onClicked: Player.snapshot()
            }
            RChip {
                iconName: "record_2t"
                text: qsTr("Record")
                checked: Player.recording
                enabled: Player.isStarted
                onClicked: Player.toggleRecord()
            }
            RChip {
                iconName: "speed"
                text: qsTr("Reverse")
                enabled: Player.rewindable
                onClicked: Player.reverse()
            }
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: Theme.dp(72)
            RPanelButton {
                anchors.fill: parent
                anchors.margins: Theme.margin
                text: qsTr("Effects and Filters")
                onClicked: { root.closeRequested(); RWindows.effectsRequested(0) }
            }
        }
    }
    }
}
