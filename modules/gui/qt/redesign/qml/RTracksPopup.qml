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

// Floating panel opened from the audio / subtitles buttons of the control bar.
// Three tabs: Video, Audio (tracks + output device), Subtitles (embedded + external).
Rectangle {
    id: root

    // 0: video, 1: audio, 2: subtitles
    property alias currentIndex: tabs.currentIndex

    // effects of the current tab instead of its tracks
    property bool effects: false

    signal closeRequested()

    onVisibleChanged: if (!visible) effects = false
    Connections {
        target: RPresets
        function onApplied() {
            if (root.effects) { root.effects = false; Qt.callLater(() => root.effects = true) }
        }
    }

    implicitWidth: Theme.popupWidth
    implicitHeight: effects ? Theme.dp(640) : Theme.dp(524)
    radius: Theme.radiusLarge
    color: Theme.panelBackground
    clip: true

    // swallow clicks so they don't reach the video
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onWheel: (w) => w.accepted = true }

    ColumnLayout {
        anchors.fill: parent
        spacing: 1

        RPresetPicker {
            Layout.fillWidth: true
            Layout.margins: Theme.dp(12)
        }

        RTabBar {
            id: tabs
            Layout.fillWidth: true
            model: [
                { text: qsTr("Video"), icon: "tab_video" },
                { text: qsTr("Audio"), icon: "tab_audio" },
                { text: qsTr("Subtitles"), icon: "tab_subtitles" }
            ]
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.effects && tabs.currentIndex < 2 ? 3 + tabs.currentIndex : tabs.currentIndex

            // --- Video ------------------------------------------------------
            ColumnLayout {
                spacing: 0
                RSectionHeader { Layout.fillWidth: true; text: qsTr("Embedded Tracks") }
                RTrackPage {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    trackModel: Player.videoTracks
                }
                Item { Layout.fillHeight: true }
            }

            // --- Audio ------------------------------------------------------
            ColumnLayout {
                spacing: 0
                RSectionHeader { Layout.fillWidth: true; text: qsTr("Embedded Tracks")
                    RIconButton {
                        iconName: "add"
                        toolTip: qsTr("Add audio file")
                        onClicked: DialogsProvider.loadAudioFile()
                    }
                }
                RTrackPage {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    trackModel: Player.audioTracks
                }
                RSectionHeader { Layout.fillWidth: true; text: qsTr("Output Device") }
                RTrackList {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: Player.audioDevices
                }
            }

            // --- Subtitles --------------------------------------------------
            ColumnLayout {
                spacing: 0
                RSectionHeader { Layout.fillWidth: true; text: qsTr("Tracks")
                    RIconButton {
                        iconName: "edit"
                        toolTip: qsTr("Synchronization")
                        onClicked: RWindows.subtitleTimelineRequested()
                    }
                    RIconButton {
                        iconName: "add"
                        toolTip: qsTr("Add subtitle file")
                        onClicked: DialogsProvider.loadSubtitlesFile()
                    }
                    RIconButton {
                        iconName: "folder"
                        toolTip: qsTr("Add subtitles to the whole folder")
                        onClicked: {
                            root.closeRequested()
                            RWindows.addSubtitlesRequested(Player.isStarted ? String(Player.url) : "")
                        }
                    }
                }
                RTrackPage {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    trackModel: Player.subtitleTracks
                }
            }

            // --- Effects (3: video, 4: audio), created when first shown -----
            Loader {
                active: root.effects && tabs.currentIndex === 0
                sourceComponent: RVideoEffects { }
            }
            Loader {
                active: root.effects && tabs.currentIndex === 1
                sourceComponent: RAudioEffects { }
            }
        }

        // "Show Preferences"
        Item {
            Layout.fillWidth: true
            implicitHeight: Theme.dp(72)

            T.AbstractButton {
                id: prefsBtn
                anchors.fill: parent
                anchors.margins: Theme.margin
                hoverEnabled: true
                onClicked: {
                    if (tabs.currentIndex === 2) {
                        // subtitle look and timing live in the settings
                        root.closeRequested()
                        RWindows.settingsRequested("subtitles")
                    } else {
                        root.effects = !root.effects
                    }
                }
                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: prefsBtn.hovered ? Theme.p.bgA1 : Theme.trackBackground
                }
                contentItem: RText {
                    text: root.effects ? qsTr("Back to tracks")
                        : tabs.currentIndex === 0 ? qsTr("Video effects")
                        : tabs.currentIndex === 1 ? qsTr("Audio effects and equalizer")
                        : qsTr("Subtitle appearance")
                    color: Theme.textDim
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
