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
// NOTE: all modules used throughout the redesigned interface must be imported
//       here, so that if one of them can not be imported the interface can
//       close gracefully.
import QtQml
import QtQml.Models
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates
import QtQuick.Window

import VLC.MainInterface
import VLC.Widgets as Widgets
import VLC.Style
import VLC.Util
import VLC.Playlist
import VLC.Player
import VLC.Dialogs
import VLC.Menus
import VLC.Redesign

// Root item of the redesigned interface ("--qt-redesign").
Item {
    id: root

    Accessible.role: Accessible.Client
    Accessible.name: qsTr("Main interface")

    Binding { target: Theme; property: "scale"; value: MainCtx.intfScaleFactor }
    // dark/light/system and the accent are chosen in Settings > General (see Theme.mode)

    // ---- secondary windows of the redesign, created on first use

    function openSettings(category) {
        settingsLoader.active = true
        settingsLoader.item.openCategory(category)
    }

    Loader {
        id: settingsLoader
        active: false
        sourceComponent: RSettingsWindow {
            transientParent: root.Window.window
        }
    }

    function openShortcuts() {
        shortcutsLoader.active = true
        shortcutsLoader.item.open()
    }

    Loader {
        id: shortcutsLoader
        active: false
        sourceComponent: RShortcutsWindow {
            transientParent: root.Window.window
        }
    }

    Connections {
        target: DialogsProvider
        function onRedesignSettingsRequested() { root.openSettings("") }
    }

    // --qt-redesign-open=settings[:category] | shortcuts (development helper)
    Component.onCompleted: {
        const open = RedesignSettings.inheritedString("qt-redesign-open")
        if (open.startsWith("settings"))
            Qt.callLater(root.openSettings, open.split(":")[1] || "")
        else if (open === "mini")
            Qt.callLater(root.enterMiniPlayer)
        else if (open === "timeline")
            Qt.callLater(RWindows.subtitleTimelineRequested)
        else if (open === "shortcuts")
            Qt.callLater(root.openShortcuts)
        else if (open === "network")
            Qt.callLater(RWindows.networkStreamRequested)
        else if (open === "playlist")
            Qt.callLater(RWindows.newPlaylistRequested)
        else if (open.startsWith("subtitles"))
            Qt.callLater(RWindows.addSubtitlesRequested, open.substring(10))
        else if (open.startsWith("extras:")) {
            // control bar extras for this run only (not saved): extras:back10,fwd10
            RBarCatalog.extras = open.substring(7).split(",")
            onboarding.active = false
        }
        else if (open === "menu")
            Qt.callLater(playerView.openMenu)
        else if (open === "customize")
            Qt.callLater(RWindows.customizeRequested)
        else if (open === "onboarding")
            onboarding.active = true
        else if (open.startsWith("library")) {
            root.libraryMode = true
            if (open.length > 8)
                Qt.callLater(library.openPage, open.substring(8))
        }
        else if (open.startsWith("effects"))
            Qt.callLater(playerView.openEffects, open === "effects:audio" ? 1 : 0)
    }

    Loader { id: detachedLibraryLoader; active: false; sourceComponent: RLibraryWindow { } }
    Loader { id: timelineLoader; active: false; sourceComponent: RSubtitleTimeline { transientParent: root.Window.window } }

    Loader { id: customizeLoader; active: false; sourceComponent: RCustomizeDialog { transientParent: root.Window.window } }
    Loader { id: networkLoader; active: false; sourceComponent: RNetworkStreamDialog { transientParent: root.Window.window } }
    Loader { id: addToPlaylistLoader; active: false; source: "" }
    Loader { id: newPlaylistLoader; active: false; sourceComponent: RNewPlaylistDialog { transientParent: root.Window.window } }
    Loader { id: addAudioLoader; active: false; sourceComponent: RAddSubtitlesDialog { audioMode: true; transientParent: root.Window.window } }
    Loader { id: addSubtitlesLoader; active: false; sourceComponent: RAddSubtitlesDialog { transientParent: root.Window.window } }

    Connections {
        target: RWindows
        function onSettingsRequested(category) { root.openSettings(category) }
        function onSubtitleTimelineRequested() { timelineLoader.active = true; timelineLoader.item.open() }
        function onShortcutsRequested() { root.openShortcuts() }
        function onEffectsRequested(tab) { root.libraryMode = false; playerView.openEffects(tab) }
        function onPanelRequested(name, tab) { root.libraryMode = false; playerView.togglePanel(name, tab) }
        function onLibraryRequested(page) {
            if (root.compactMode) {
                detachedLibraryLoader.active = true
                detachedLibraryLoader.item.openPage(page)
            } else {
                root.sidebarVisible = false
                root.libraryMode = true
                library.openPage(page)
            }
        }
        function onMiniPlayerRequested() { root.enterMiniPlayer() }
        function onCustomizeRequested() { customizeLoader.active = true; customizeLoader.item.open() }
        function onNetworkStreamRequested() { networkLoader.active = true; networkLoader.item.open() }
        function onAddToPlaylistRequested(ids) {
            if (!MainCtx.mediaLibraryAvailable) return
            addToPlaylistLoader.active = false
            addToPlaylistLoader.setSource("RAddToPlaylistDialog.qml", { transientParent: root.Window.window, mediaIds: ids })
            addToPlaylistLoader.active = true
            addToPlaylistLoader.item.open()
        }
        function onNewPlaylistRequested() { newPlaylistLoader.active = true; newPlaylistLoader.item.open() }
        function onAddAudioToMediaRequested(urls) { addAudioLoader.active = true; addAudioLoader.item.openForMedia(urls) }
        function onAddSubtitlesToMediaRequested(urls) { addSubtitlesLoader.active = true; addSubtitlesLoader.item.openForMedia(urls) }
        function onAddSubtitlesRequested(url) { addSubtitlesLoader.active = true; addSubtitlesLoader.item.openFor(url) }
    }

    // Restore explicit per-file subtitle associations when the same media is opened again.
    Timer {
        id: subtitleAssociation
        interval: 200
        repeat: true
        property int attempts: 0
        property bool subtitleApplied: false
        property bool audioApplied: false
        onTriggered: {
            const url = String(Player.url || "")
            const subtitle = String(MainCtx.settingValue("Redesign/subtitlePairs/" + encodeURIComponent(url), ""))
            const audio = String(MainCtx.settingValue("Redesign/audioPairs/" + encodeURIComponent(url), ""))
            if (Player.isStarted) {
                if (subtitle.length && !subtitleApplied) subtitleApplied = RedesignEffects.associateSubtitleFile(subtitle)
                if (audio.length && !audioApplied) audioApplied = RedesignEffects.associateAudioFile(audio)
            }
            if (++attempts > 5 || ((!subtitle.length || subtitleApplied) && (!audio.length || audioApplied))) stop()
        }
    }
    Connections {
        target: Player
        function onInputChanged(hasInput) {
            subtitleAssociation.stop()
            subtitleAssociation.attempts = 0
            subtitleAssociation.subtitleApplied = false
            subtitleAssociation.audioApplied = false
            if (hasInput) subtitleAssociation.start()
        }
    }

    // keep VLCStyle informed, some C++ helpers (tooltips, popups) rely on it
    Binding { target: VLCStyle; property: "appWidth"; value: root.width }
    Binding { target: VLCStyle; property: "appHeight"; value: root.height }

    Window.onWindowChanged: {
        if (Window.window && !Qt.colorEqual(Window.window.color, "transparent"))
            Window.window.color = Qt.binding(function() { return Theme.barBackground })
    }

    Widgets.ToolTipExt {
        id: attachedToolTip
        parent: null
        z: 99
        colorContext.palette: VLCStyle.palette
        Component.onCompleted: MainCtx.setAttachedToolTip(this)
    }

    Widgets.PointingTooltip {
        parent: null
        z: 99
        colorContext.palette: VLCStyle.palette
        Widgets.PointingToolTipAttached.instance: this
        Component.onDestruction: {
            if (Widgets.PointingToolTipAttached.instance === this)
                Widgets.PointingToolTipAttached.instance = null
        }
    }

    DropArea {
        anchors.fill: parent
        z: -1

        onEntered: (drag) => {
            drag.accepted = !drag.source && (drag.hasUrls || drag.hasText)
        }

        onDropped: (drop) => {
            let urls = []
            if (drop.hasUrls) {
                for (let i = 0; i < drop.urls.length; i++)
                    urls.push(drop.urls[i])
            } else if (drop.hasText) {
                urls.push(...drop.text.replace("\r\n", "\n").split("\n"))
            }
            if (urls.length === 0)
                return
            // a single subtitle file dropped while playing is attached to the media
            if (Player.isStarted && urls.length === 1 && RedesignEffects.associateSubtitleFile(urls[0])) {
                drop.accept()
                return
            }
            MainPlaylistController.append(urls, true)
            drop.accept()
        }
    }

    // ---- library / player
    property bool sidebarVisible: false
    property bool libraryMode: false
    property bool compactMode: false
    property bool compactQueue: false
    property var savedWindow: null
    readonly property rect compactVideo: Qt.rect(Theme.dp(8), compactQueue ? height * 0.45 : Theme.dp(8), width - Theme.dp(16), (compactQueue ? height * 0.55 : height) - Theme.dp(146))
    function enterMiniPlayer() {
        if (compactMode) return
        const w = root.Window.window
        savedWindow = { x: w.x, y: w.y, width: w.width, height: w.height, visibility: w.visibility,
                        minimal: MainCtx.minimalView, onTop: MainCtx.interfaceAlwaysOnTop }
        w.showNormal()
        MainCtx.minimalView = true
        MainCtx.interfaceAlwaysOnTop = true
        libraryMode = false
        sidebarVisible = false
        compactMode = true
        w.width = Theme.dp(400)
        w.height = Theme.dp(370)
    }
    function leaveMiniPlayer() {
        if (!compactMode) return
        compactMode = false
        compactQueue = false
        if (detachedLibraryLoader.item) detachedLibraryLoader.item.close()
        const w = root.Window.window, s = savedWindow
        MainCtx.minimalView = s.minimal
        MainCtx.interfaceAlwaysOnTop = s.onTop
        w.x = s.x; w.y = s.y; w.width = s.width; w.height = s.height
        if (s.visibility === Window.Maximized) w.showMaximized()
        else if (s.visibility === Window.FullScreen) w.showFullScreen()
    }

    RLibraryView {
        id: library
        z: root.sidebarVisible && !root.libraryMode ? 5 : 0
        x: 0
        y: compact ? Theme.topBarHeight : 0
        width: compact ? Math.min(root.width * 0.65, Theme.dp(720)) : root.width
        height: compact ? root.height - Theme.topBarHeight - Theme.controlBarHeight : root.height
        compact: root.sidebarVisible && !root.libraryMode
        visible: root.libraryMode || root.sidebarVisible
        onExpandLibrary: { root.sidebarVisible = false; root.libraryMode = true }
        onBackToPlayer: { root.libraryMode = false; root.sidebarVisible = false }
    }

    // card of the mini player, around the video shown by playerView
    RMiniPlayer {
        visible: (root.libraryMode || root.compactMode) && Player.isStarted
        videoRect: root.compactMode ? root.compactVideo : library.miniPlayerRect
        onLibraryRequested: RWindows.libraryRequested("home")
        onExpandRequested: { root.leaveMiniPlayer(); root.libraryMode = false }
        onQueueRequested: { if (root.compactMode) root.compactQueue = !root.compactQueue; else { root.libraryMode = false; playerView.togglePanel("queue", 0) } }
    }

    RPlayerView {
        id: playerView
        focus: !root.libraryMode
        mini: root.libraryMode || root.compactMode
        visible: (!root.libraryMode || Player.isStarted) && (!(root.compactMode || root.libraryMode) || MainCtx.hasEmbededVideo)
        x: root.compactMode ? root.compactVideo.x : root.libraryMode ? library.miniPlayerRect.x : 0
        y: root.compactMode ? root.compactVideo.y : root.libraryMode ? library.miniPlayerRect.y : 0
        width: root.compactMode ? root.compactVideo.width : root.libraryMode ? library.miniPlayerRect.width : root.width
        height: root.compactMode ? root.compactVideo.height : root.libraryMode ? library.miniPlayerRect.height : root.height
        onSidebarRequested: { root.sidebarVisible = !root.sidebarVisible; root.libraryMode = false }
        onLibraryRequested: (page) => {
            root.sidebarVisible = false
            root.libraryMode = true
            if (page.length > 0)
                library.openPage(page)
        }

    }

    RQueuePanel {
        visible: root.compactMode && root.compactQueue
        width: parent.width
        height: root.compactVideo.y - Theme.dp(8)
    }
    Row {
        visible: root.compactMode
        z: 10
        anchors.right: parent.right
        RIconButton { iconName: "fullscreen"; toolTip: qsTr("Restore player"); onClicked: root.leaveMiniPlayer() }
        RIconButton { iconName: "close"; toolTip: qsTr("Close mini player"); onClicked: { MainPlaylistController.stop(); root.leaveMiniPlayer() } }
    }
    DragHandler { enabled: root.compactMode; target: null; onActiveChanged: if (active) root.Window.window.startSystemMove() }
    Shortcut { sequence: "Esc"; enabled: root.compactMode; onActivated: root.leaveMiniPlayer() }

    // first start: welcome, theme and accent, basic shortcuts
    Loader {
        id: onboarding
        anchors.fill: parent
        z: 50
        active: String(MainCtx.settingValue("Redesign/onboardingDone", false)) !== "true"
        sourceComponent: ROnboarding {
            onFinished: onboarding.active = false
        }
    }

    // a click on the small video goes back to the player (above the video surface,
    // which takes the mouse for the video output)
    MouseArea {
        visible: root.libraryMode && Player.isStarted
        x: library.miniPlayerRect.x
        y: library.miniPlayerRect.y
        width: library.miniPlayerRect.width
        height: library.miniPlayerRect.height
        cursorShape: Qt.PointingHandCursor
        onClicked: root.libraryMode = false
    }

    Loader {
        asynchronous: true
        source: "qrc:///qt/qml/VLC/Menus/GlobalShortcuts.qml"
    }

    Component.onDestruction: if (compactMode) leaveMiniPlayer()

    // resize handles on the window border when using client side decorations
    Loader {
        active: {
            const v = MainCtx.intfMainWindow.visibility
            return MainCtx.clientSideDecoration && !MainCtx.platformHandlesResizeWithCSD()
                   && v !== Window.Maximized && v !== Window.FullScreen
        }
        Component.onCompleted: {
            setSource("qrc:///qt/qml/VLC/Widgets/CSDMouseStealer.qml",
                      { target: root, anchorInside: true })
        }
    }
}
