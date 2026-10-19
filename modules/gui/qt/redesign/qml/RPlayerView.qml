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
import QtQuick.Window

import VLC.MainInterface
import VLC.Player
import VLC.Playlist
import VLC.Dialogs

// Main screen of the redesign: the video is always full window, the top bar
// and the control bar float above it and only show while the cursor moves
// over the window. They disappear as soon as the cursor leaves the window.
FocusScope {
    id: root

    // "", "audio", "subtitles", "video", "playback", "queue"
    property string openPanel: ""

    readonly property bool hasVideo: MainCtx.hasEmbededVideo
    readonly property bool playing: Player.playingState === Player.PLAYING_STATE_PLAYING
    // shown small in the corner of the library (mini player): no bars, no panels
    property bool mini: false
    readonly property bool hideUi: MainCtx.minimalView || mini

    // page: "" (last page) or a library page ("videos"...)
    signal libraryRequested(string page)
    signal sidebarRequested()

    onMiniChanged: if (mini) openPanel = ""

    // bars are pinned while nothing plays, a panel is open or a menu is shown
    readonly property bool pinned: MainCtx.pinVideoControls || !hasVideo || !playing || openPanel !== ""
                                   || mainMenu.visible || contextMenu.visible
                                   || topBar.hovered || controlBar.hovered

    property bool _active: true
    readonly property bool barsVisible: !hideUi && (pinned || _active)

    function poke() {
        _active = true
        hideTimer.restart()
    }

    // tab: 0 video, 1 audio
    function openEffects(tab) {
        openPanel = tab === 1 ? "audio" : "video"
        tracksPopup.currentIndex = tab
        tracksPopup.effects = true
    }

    function openMenu() {
        mainMenu.popup(topBar.menuButton, 0, topBar.menuButton.height + Theme.dp(6))
    }

    function togglePanel(name, tab) {
        if (openPanel === name) {
            openPanel = ""
            return
        }
        openPanel = name
        if (tab !== undefined) {
            if (name === "queue") queuePanel.currentIndex = tab
            else if (name !== "playback") tracksPopup.currentIndex = tab
        }
    }

    Timer {
        id: hideTimer
        interval: Math.max(800, MainCtx.mouseHideTimeout)
        onTriggered: root._active = false
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.p.videoBackground
    }

    // ---------------------------------------------------------------------
    // Video
    // ---------------------------------------------------------------------
    VideoSurface {
        id: videoSurface

        anchors.fill: parent
        visible: root.hasVideo
        focus: true
        videoSurfaceProvider: MainCtx.videoSurfaceProvider

        cursorShape: root.barsVisible || !root.hasVideo ? Qt.ArrowCursor : Qt.BlankCursor

        onMouseMoved: root.poke()
    }

    // idle / audio only background
    RIdleView {
        anchors.fill: parent
        visible: !root.hasVideo && !root.mini
    }

    HoverHandler {
        id: windowHover
        onPointChanged: root.poke()
        onHoveredChanged: {
            if (!hovered && !root.pinned)
                root._active = false
        }
    }

    // close popups when clicking outside of them
    TapHandler {
        enabled: root.openPanel !== ""
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: root.openPanel = ""
    }

    // right click when no video is displayed (the video surface forwards its
    // clicks to the core which asks for the menu through DialogsProvider)
    TapHandler {
        acceptedButtons: Qt.RightButton
        enabled: !root.hasVideo
        onTapped: (eventPoint) => contextMenu.popup(eventPoint.position.x, eventPoint.position.y)
    }

    Connections {
        target: DialogsProvider
        function onContextMenuRequested(show) {
            if (show && !root.mini) {
                // the video surface gets the click, not QML: hover handlers do not
                // know where the cursor is, ask Qt for its global position instead
                const g = MainCtx.cursorPos()
                const p = root.mapFromGlobal(g.x, g.y)
                contextMenu.popup(p.x, p.y)
            } else {
                contextMenu.close()
            }
        }
    }

    // rounded frame around the video while the bars are shown (design detail)
    Rectangle {
        anchors.fill: parent
        anchors.topMargin: topBar.height - Theme.dp(9)
        anchors.bottomMargin: controlBar.height - Theme.dp(9)
        anchors.leftMargin: -Theme.dp(11)
        anchors.rightMargin: -Theme.dp(11)
        color: "transparent"
        border.width: Theme.dp(20)
        border.color: Theme.barBackground
        radius: Theme.videoFrameRadius + Theme.dp(10)
        opacity: root.barsVisible && root.hasVideo ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal } }
    }

    // ---------------------------------------------------------------------
    // Bars
    // ---------------------------------------------------------------------
    RTopBar {
        id: topBar

        readonly property bool hovered: topHover.hovered

        anchors { left: parent.left; right: parent.right }
        y: root.barsVisible ? 0 : -height
        opacity: root.barsVisible ? 1 : 0
        Behavior on y { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal } }

        HoverHandler { id: topHover }

        onMenuRequested: mainMenu.popup(menuButton, 0, menuButton.height + Theme.dp(6))

        // library: sidebar button and folder of the current media (Figma "Player-6")
        libraryAvailable: true
        locationName: {
            const u = String(Player.url || "")
            const parts = u.split("/")
            return parts.length > 1 ? decodeURIComponent(parts[parts.length - 2]) : qsTr("Library")
        }
        onSidebarToggled: root.sidebarRequested()
        onLocationClicked: root.libraryRequested("videos")
    }

    RControlBar {
        id: controlBar

        readonly property bool hovered: bottomHover.hovered

        anchors { left: parent.left; right: parent.right }
        y: root.barsVisible ? root.height - height : root.height
        opacity: root.barsVisible ? 1 : 0
        Behavior on y { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal } }

        HoverHandler { id: bottomHover }

        openPanel: root.openPanel
        onPanelRequested: (name) => {
            switch (name) {
            case "audio": root.togglePanel("audio", 1); break
            case "subtitles": root.togglePanel("subtitles", 2); break
            default: root.togglePanel(name)
            }
        }
    }

    // ---------------------------------------------------------------------
    // Panels
    // ---------------------------------------------------------------------
    RTracksPopup {
        id: tracksPopup

        anchors.right: parent.right
        anchors.rightMargin: Theme.margin
        anchors.bottom: controlBar.top
        anchors.bottomMargin: Theme.margin

        height: Math.min(implicitHeight, root.height - topBar.height - controlBar.height - 2 * Theme.margin)
        visible: ["audio", "subtitles", "video"].indexOf(root.openPanel) >= 0 && root.barsVisible
        onCloseRequested: root.openPanel = ""
    }

    RPlaybackPopup {
        height: Math.min(implicitHeight, Math.max(0, root.height - topBar.height - controlBar.height - 2 * Theme.margin))
        anchors.right: parent.right
        anchors.rightMargin: Theme.margin + Theme.dp(42)
        anchors.bottom: controlBar.top
        anchors.bottomMargin: Theme.margin
        visible: root.openPanel === "playback" && root.barsVisible
        onCloseRequested: root.openPanel = ""
    }

    RQueuePanel {
        id: queuePanel

        anchors.right: parent.right
        anchors.rightMargin: Theme.margin
        anchors.top: topBar.bottom
        anchors.topMargin: Theme.dp(10)
        anchors.bottom: controlBar.top
        anchors.bottomMargin: Theme.margin
        visible: root.openPanel === "queue" && root.barsVisible
    }

    // ---------------------------------------------------------------------
    // Menus
    // ---------------------------------------------------------------------
    RMainMenu { id: mainMenu }

    RContextMenu {
        id: contextMenu
        onHideUiRequested: MainCtx.minimalView = !MainCtx.minimalView
        onPanelRequested: (name, tab) => root.togglePanel(name, tab)
    }

    // ---------------------------------------------------------------------
    // Keyboard
    // ---------------------------------------------------------------------
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape && root.openPanel !== "") {
            root.openPanel = ""
            event.accepted = true
            return
        }
        MainCtx.sendHotkey(event.key, event.modifiers)
        root.poke()
    }

    Component.onCompleted: poke()
}
