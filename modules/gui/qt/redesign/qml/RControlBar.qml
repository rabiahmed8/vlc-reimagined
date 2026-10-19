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
import VLC.Playlist

// Bottom control bar of the redesign (54px):
//   prev [play] next | time [=====seek=====] duration | vol cone | audio subs settings | queue
Rectangle {
    id: root

    // which side panel / popup is currently open ("", "audio", "subtitles", "playback", "queue")
    property string openPanel: ""
    readonly property bool narrow: width < Theme.dp(720)
    signal panelRequested(string name)

    implicitHeight: Theme.controlBarHeight
    color: Qt.rgba(Theme.barBackground.r, Theme.barBackground.g, Theme.barBackground.b, 0.95)

    // top divider
    Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: 1
        color: Theme.p.dividerDim
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.margin
        anchors.rightMargin: Theme.margin
        spacing: root.narrow ? Theme.dp(6) : Theme.margin

        // --- transport -----------------------------------------------------
        RowLayout {
            spacing: Theme.spacing

            RIconButton {
                visible: !root.narrow
                iconName: "previous"
                toolTip: qsTr("Previous")
                enabled: MainPlaylistController.hasPrev || Player.isStarted
                onClicked: MainPlaylistController.prev()
            }

            T.AbstractButton {
                id: playButton

                readonly property bool playing: Player.playingState === Player.PLAYING_STATE_PLAYING

                implicitWidth: Theme.dp(54)
                implicitHeight: Theme.controlHeight
                hoverEnabled: true
                focusPolicy: Qt.TabFocus
                Accessible.name: playing ? qsTr("Pause") : qsTr("Play")

                onClicked: MainPlaylistController.togglePlayPause()

                background: Rectangle {
                    radius: Theme.radius
                    color: playButton.pressed ? Theme.p.accentDim
                         : playButton.hovered ? Qt.lighter(Theme.accent, 1.1)
                         : Theme.accent
                }
                contentItem: Item {
                    RIcon {
                        anchors.centerIn: parent
                        // the glyph is optically shifted to the right in the design (pl 17 / pr 15)
                        anchors.horizontalCenterOffset: playButton.playing ? 0 : Theme.dp(1)
                        name: playButton.playing ? "pause" : "play"
                        color: Theme.iconOnAccent
                    }
                }
            }

            RIconButton {
                visible: !root.narrow
                iconName: "next"
                toolTip: qsTr("Next")
                enabled: MainPlaylistController.hasNext
                onClicked: MainPlaylistController.next()
            }
        }

        // --- time / seek ---------------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing

            RTimeLabel {
                text: Player.isStarted ? Player.time.formatHMS() : "--:--"
            }

            RSeekBar {
                id: seekBar
                Layout.fillWidth: true
                Layout.minimumWidth: Theme.dp(40)
            }

            RTimeLabel {
                visible: !root.narrow
                clickable: true
                text: {
                    if (!Player.isStarted || !Player.length.valid())
                        return "--:--"
                    return MainCtx.showRemainingTime
                        ? "-" + Player.remainingTime.formatHMS()
                        : Player.length.formatHMS()
                }
                onClicked: MainCtx.showRemainingTime = !MainCtx.showRemainingTime
            }
        }

        // --- volume --------------------------------------------------------
        RowLayout {
            spacing: Theme.spacing

            RIconButton {
                iconName: Player.muted || Player.volume === 0 ? "volume_mute" : "volume_high"
                toolTip: Player.muted ? qsTr("Unmute") : qsTr("Mute")
                onClicked: Player.toggleMuted()
            }

            RVolumeCone { visible: !root.narrow }
        }

        // --- controls placed with "Customize Player" ------------------------
        RowLayout {
            spacing: Theme.dp(8)
            visible: RBarCatalog.extras.length > 0
            Repeater {
                model: RBarCatalog.extras
                delegate: RBarItem {
                    required property string modelData
                    itemId: modelData
                }
            }
        }

        // --- tracks / settings --------------------------------------------
        RowLayout {
            spacing: root.narrow ? Theme.dp(4) : Theme.dp(12)

            RIconButton {
                iconName: root.openPanel === "audio" ? "audio_active" : "audio"
                toolTip: qsTr("Audio tracks and output")
                checked: root.openPanel === "audio"
                onClicked: root.panelRequested("audio")
            }

            RIconButton {
                iconName: root.openPanel === "subtitles" ? "subtitles_active" : "subtitles"
                toolTip: qsTr("Subtitles")
                checked: root.openPanel === "subtitles"
                onClicked: root.panelRequested("subtitles")
            }

            RIconButton {
                iconName: root.openPanel === "playback" ? "playback-settings_active" : "playback-settings"
                toolTip: qsTr("Playback settings")
                checked: root.openPanel === "playback"
                onClicked: root.panelRequested("playback")
            }
        }

        RIconButton {
            iconName: root.openPanel === "queue" ? "lists_active" : "lists"
            toolTip: qsTr("Queue")
            checked: root.openPanel === "queue"
            onClicked: root.panelRequested("queue")
        }
    }
}
