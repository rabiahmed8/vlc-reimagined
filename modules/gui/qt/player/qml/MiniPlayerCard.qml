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
import VLC.Style
import VLC.Widgets as Widgets
import VLC.Playlist
import VLC.Player
import VLC.Util

// Juxtopposed: the floating "now playing" card shown over the library, in
// place of the full width mini player bar. Shows the video (or the cover),
// a seekable progress line, the title, the media's folder and artist, and
// a play queue toggle. Playback buttons appear when hovering the media.
T.Control {
    id: root

    // Properties

    // Show the video in the card rather than the cover (this used to be
    // the separate PIP player).
    property bool showVideo: false

    readonly property bool _videoShown: showVideo && MainCtx.canShowVideoPIP
                                        && MainCtx.hasEmbededVideo && Player.hasVideoOutput

    readonly property string _folderName: {
        const url = Player.url.toString()
        if (!url.startsWith("file://"))
            return ""
        const parts = decodeURIComponent(url).split("/")
        return (parts.length > 1) ? parts[parts.length - 2] : ""
    }

    readonly property string _coverSource: (Player.artwork && Player.artwork.toString())
                                           ? Player.artwork
                                           : (Player.hasVideoOutput ? VLCStyle.noArtVideoCover
                                                                    : VLCStyle.noArtAlbumCover)

    readonly property bool _mediaHovered: mediaHover.hovered || playButton.hovered
                                          || openButton.hovered || stopButton.hovered

    // Settings

    width: VLCStyle.juxtMiniCard_width
    implicitHeight: implicitContentHeight + topPadding + bottomPadding

    padding: VLCStyle.juxtMiniCard_padding
    bottomPadding: VLCStyle.dp(16, VLCStyle.scale)

    visible: opacity > 0
    opacity: Player.isStarted ? 1 : 0

    focusPolicy: Qt.TabFocus

    Accessible.role: Accessible.Pane
    Accessible.name: qsTr("Mini player")
    AccessibleCompat.id: "miniplayerCard"

    Behavior on opacity {
        NumberAnimation {
            easing.type: Easing.InOutSine
            duration: VLCStyle.duration_long
        }
    }

    readonly property ColorContext colorContext: ColorContext {
        id: theme
        colorSet: ColorContext.Window
    }

    readonly property ColorContext _sliderTheme: ColorContext {
        id: sliderTheme
        colorSet: ColorContext.Slider
    }

    // Children

    background: Rectangle {
        color: theme.bg.primary
        radius: VLCStyle.juxtStage_radius

        Widgets.DefaultShadow { }
    }

    contentItem: ColumnLayout {
        spacing: 0

        // Video or cover, with the playback buttons on hover
        Item {
            id: media

            Layout.fillWidth: true
            Layout.preferredHeight: Math.round(width * 9 / 16)

            Rectangle {
                anchors.fill: parent
                radius: VLCStyle.juxtMiniCard_mediaRadius
                color: theme.bg.secondary
                visible: !root._videoShown
            }

            Widgets.ImageExt {
                anchors.fill: parent

                visible: !root._videoShown

                source: VLCAccessImage.uri(root._coverSource)
                sourceSize: Qt.size(width * Screen.devicePixelRatio, height * Screen.devicePixelRatio)
                fillMode: Image.PreserveAspectFit
                radius: VLCStyle.juxtMiniCard_mediaRadius
                cache: false
            }

            Loader {
                anchors.fill: parent

                active: root._videoShown && root.visible

                sourceComponent: VideoSurface {
                    videoSurfaceProvider: MainCtx.videoSurfaceProvider
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: VLCStyle.juxtMiniCard_mediaRadius
                color: Qt.rgba(0, 0, 0, 0.35)
                visible: root._mediaHovered
            }

            HoverHandler {
                id: mediaHover
            }

            TapHandler {
                // Open the player, like double clicking the old PIP player
                onTapped: MainCtx.playerView = true
            }

            Widgets.IconButton {
                id: playButton

                anchors.centerIn: parent

                visible: root._mediaHovered || visualFocus

                font.pixelSize: VLCStyle.icon_normal * 2
                description: qsTr("play/pause")
                AccessibleCompat.id: "miniplayerCardPlayButton"

                text: (Player.playingState !== Player.PLAYING_STATE_PAUSED
                       && Player.playingState !== Player.PLAYING_STATE_STOPPED)
                      ? VLCIcons.pause_filled
                      : VLCIcons.play_filled

                onClicked: MainPlaylistController.togglePlayPause()
            }

            Widgets.IconButton {
                id: openButton

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: VLCStyle.margin_xsmall

                visible: root._mediaHovered || visualFocus

                font.pixelSize: VLCStyle.icon_normal
                description: qsTr("maximize player")
                AccessibleCompat.id: "miniplayerCardOpenButton"

                text: VLCIcons.fullscreen

                onClicked: MainCtx.playerView = true
            }

            Widgets.IconButton {
                id: stopButton

                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: VLCStyle.margin_xsmall

                visible: root._mediaHovered || visualFocus

                font.pixelSize: VLCStyle.icon_normal
                description: qsTr("stop")
                AccessibleCompat.id: "miniplayerCardStopButton"

                text: VLCIcons.close

                onClicked: MainPlaylistController.stop()
            }
        }

        // Progress, click or drag to seek
        Rectangle {
            id: progress

            Layout.fillWidth: true
            Layout.topMargin: VLCStyle.dp(6, VLCStyle.scale)
            Layout.preferredHeight: VLCStyle.dp(14, VLCStyle.scale)

            radius: VLCStyle.dp(4, VLCStyle.scale)
            color: sliderTheme.bg.primary

            Accessible.role: Accessible.ProgressBar
            Accessible.name: qsTr("Playback position")

            Rectangle {
                width: Math.max(height, parent.width * Helpers.clamp(Player.position, 0, 1))
                height: parent.height
                radius: parent.radius
                color: sliderTheme.bg.secondary
                visible: Player.position > 0
            }

            MouseArea {
                anchors.fill: parent

                enabled: Player.seekable
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                function seek(x) {
                    Player.position = Helpers.clamp(x / width, 0, 1)
                }

                onPressed: (mouse) => seek(mouse.x)
                onPositionChanged: (mouse) => { if (pressed) seek(mouse.x) }
            }
        }

        Widgets.MenuCaption {
            Layout.fillWidth: true
            Layout.topMargin: VLCStyle.dp(22, VLCStyle.scale)
            Layout.leftMargin: VLCStyle.juxtMiniCard_textInset
            Layout.rightMargin: VLCStyle.juxtMiniCard_textInset

            text: Player.title
            font.pixelSize: VLCStyle.fontSize_large
            color: theme.fg.primary
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: VLCStyle.dp(12, VLCStyle.scale)
            Layout.leftMargin: VLCStyle.juxtMiniCard_textInset

            spacing: VLCStyle.margin_xsmall

            MetaLabel {
                icon: VLCIcons.folder
                text: root._folderName
                color: theme.fg.primary
                Layout.fillWidth: true
                Layout.maximumWidth: Math.min(implicitWidth, (parent.width - queueButton.width) / 2)
            }

            MetaLabel {
                Layout.leftMargin: VLCStyle.margin_small
                icon: VLCIcons.artist
                text: Player.artist
                color: theme.fg.primary
                Layout.fillWidth: true
                Layout.maximumWidth: Math.min(implicitWidth, (parent.width - queueButton.width) / 2)
            }

            Item {
                Layout.fillWidth: true
            }

            Widgets.IconToolButton {
                id: queueButton

                focus: true

                text: VLCIcons.lists
                description: qsTr("Play Queue")
                AccessibleCompat.id: "miniplayerCardQueueButton"

                checked: MainCtx.playqueuePanel.visible
                onClicked: MainCtx.playqueuePanel.visible = !MainCtx.playqueuePanel.visible
            }
        }
    }

    component MetaLabel: RowLayout {
        id: metaLabel

        property string icon
        property string text
        property color color

        visible: text.length > 0
        spacing: VLCStyle.margin_xxsmall

        Widgets.IconLabel {
            text: metaLabel.icon
            color: metaLabel.color
            font.pixelSize: VLCStyle.icon_normal
        }

        Widgets.MenuCaption {
            Layout.fillWidth: true
            Layout.maximumWidth: implicitWidth
            text: metaLabel.text
            font.pixelSize: VLCStyle.fontSize_large
            color: metaLabel.color
        }
    }
}
