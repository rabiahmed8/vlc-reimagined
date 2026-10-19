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
import VLC.MainInterface
import VLC.Player
import VLC.Playlist

RDialogWindow {
    id: root
    heading: qsTr("Subtitle timeline")
    width: Theme.dp(800)
    height: Theme.dp(620)
    acceptText: qsTr("Done")
    property var cues: []
    property string filename: ""
    property int selected: -1
    property real pixelsPerSecond: 40
    readonly property real durationSeconds: Math.max(Player.length.toSeconds(), cues.length ? cues[cues.length - 1].end / 1000 + 5 : 20)
    function alignSelectedCue() {
        if (selected >= 0 && Player.isStarted)
            Player.subtitleDelayMS = Math.round(Player.position * Player.length.toSeconds() * 1000 - cues[selected].start)
    }
    function loadFile() {
        const files = RedesignSettings.browseFiles(qsTr("Open SRT or WebVTT subtitles"))
        if (!files.length) return
        filename = String(files[0])
        cues = RedesignSettings.subtitleCues(filename)
        if (Player.isStarted && cues.length) RedesignEffects.associateSubtitleFile(filename)
        selected = -1
    }
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.dp(12)
        RButton { text: qsTr("Open subtitle file"); onClicked: root.loadFile() }
        RText { Layout.fillWidth: true; text: root.filename.length ? decodeURIComponent(root.filename.split("/").pop()) : qsTr("Open an SRT or WebVTT file to align a cue with the paused video.") }
        RText { visible: root.filename.length > 0 && root.cues.length === 0; text: qsTr("No SRT / WebVTT cues found in this file."); color: Theme.textDim }
        RText { text: qsTr("Drag a subtitle along the timeline to change its delay."); color: Theme.textDim }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(116)
            color: Theme.p.bgA1
            radius: Theme.radius
            Flickable {
                id: timeline
                anchors.fill: parent
                clip: true
                contentWidth: Math.max(width, root.durationSeconds * root.pixelsPerSecond)
                contentHeight: height
                flickableDirection: Flickable.HorizontalFlick
                Repeater {
                    model: Math.ceil(root.durationSeconds / 5)
                    delegate: RText {
                        required property int index
                        x: index * 5 * root.pixelsPerSecond
                        y: Theme.dp(8)
                        text: index * 5 + " s"
                        color: Theme.textDim
                    }
                }
                Repeater {
                    model: root.cues
                    delegate: Rectangle {
                        id: cue
                        required property var modelData
                        required property int index
                        x: (modelData.start + Player.subtitleDelayMS) / 1000 * root.pixelsPerSecond
                        y: Theme.dp(36)
                        width: Math.max(Theme.dp(16), (modelData.end - modelData.start) / 1000 * root.pixelsPerSecond - Theme.dp(2))
                        height: Theme.dp(48)
                        color: root.selected === index ? Theme.accent : Theme.trackFill
                        radius: Theme.radiusSmall
                        RText { anchors.fill: parent; anchors.margins: Theme.dp(6); text: cue.modelData.text; wrapMode: Text.Wrap; maximumLineCount: 2 }
                        MouseArea {
                            anchors.fill: parent
                            preventStealing: true
                            cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                            property real startX: 0
                            property real startDelay: 0
                            onPressed: (mouse) => {
                                root.selected = cue.index
                                startX = mouse.x + cue.x
                                startDelay = Player.subtitleDelayMS
                            }
                            onPositionChanged: (mouse) => {
                                if (pressed) Player.subtitleDelayMS = Math.round(startDelay + (mouse.x + cue.x - startX) / root.pixelsPerSecond * 1000)
                            }
                        }
                    }
                }
                Rectangle {
                    x: Player.position * Player.length.toSeconds() * root.pixelsPerSecond
                    height: parent.height
                    width: Theme.dp(2)
                    color: Theme.textStrong
                }
            }
        }
        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Theme.dp(4)
            model: root.cues
            delegate: Rectangle {
                required property var modelData
                required property int index
                width: list.width
                height: cueText.implicitHeight + Theme.dp(24)
                color: root.selected === index ? Theme.hover : Theme.p.bgA1
                radius: Theme.radius
                RText {
                    id: cueText
                    x: Theme.dp(12); y: Theme.dp(12); width: parent.width - Theme.dp(24)
                    wrapMode: Text.Wrap
                    text: (modelData.start / 1000).toFixed(3) + " s — " + modelData.text
                }
                MouseArea { anchors.fill: parent; onClicked: root.selected = index }
            }
        }
        RText { text: qsTr("Subtitle delay: %1 ms").arg(Player.subtitleDelayMS) }
        RValueSlider { Layout.fillWidth: true; from: -30000; to: 30000; stepSize: 50; value: Player.subtitleDelayMS; onMoved: Player.subtitleDelayMS = value; onReset: Player.subtitleDelayMS = 0 }
        Row {
            spacing: Theme.dp(12)
            RButton { text: qsTr("Play / pause"); onClicked: MainPlaylistController.togglePlayPause() }
            RButton {
                text: qsTr("Align selected cue here")
                enabled: root.selected >= 0 && Player.isStarted
                onClicked: root.alignSelectedCue()
            }
        }
        Row {
            spacing: Theme.dp(12)
            RText { text: qsTr("Subtitle frame rate") }
            RTextField {
                width: Theme.dp(100)
                text: String(Player.subtitleFPS)
                validator: DoubleValidator { bottom: 0; top: 240; locale: "C" }
                onEditingFinished: if (acceptableInput) Player.subtitleFPS = Number(text)
            }
        }
    }
}
