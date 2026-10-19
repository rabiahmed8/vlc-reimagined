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
import VLC.Dialogs
import VLC.Player

// The "..." menu of the top bar. Replaces the classic menubar: media
// related actions first, then app level settings.
RMenu {
    id: root

    // "Open Recent" needs the media library: inserted after "Convert" when it is there
    property Loader recentLoader: Loader {
        active: MainCtx.mediaLibraryAvailable
        source: "RRecentMenu.qml"
        onLoaded: root.insertMenu(6, item)
    }

    RAction { iconName: "file_2t";     text: qsTr("Open File(s)");          shortcutText: "Ctrl + O"; onTriggered: DialogsProvider.simpleOpenDialog() }
    RAction { iconName: "folder_2t";   text: qsTr("Open Folder");           shortcutText: "Ctrl + F"; onTriggered: DialogsProvider.PLOpenDir() }
    RAction { iconName: "streaming_2t";  text: qsTr("Open Network Stream");   shortcutText: "Ctrl + N"; onTriggered: RWindows.networkStreamRequested() }
    RAction { iconName: "disc_2t";     text: qsTr("Open Disc");             shortcutText: "Ctrl + D"; onTriggered: DialogsProvider.openDiscDialog() }
    RAction { iconName: "capture-device_2t";  text: qsTr("Open Capture Device");   shortcutText: "Ctrl + C"; onTriggered: DialogsProvider.openCaptureDialog() }
    RAction { iconName: "swap_2t";  text: qsTr("Convert");               shortcutText: "Ctrl + R"; onTriggered: DialogsProvider.openAndTranscodingDialogs() }

    RProfileMenu { }

    RAction { iconName: "playlist_2t"; text: qsTr("New Playlist");          onTriggered: RWindows.newPlaylistRequested(); enabled: MainCtx.mediaLibraryAvailable }
    RAction { iconName: "subtitles_2t"; text: qsTr("Add Subtitles to a Folder"); onTriggered: RWindows.addSubtitlesRequested(Player.isStarted ? String(Player.url) : "") }

    RMenuSeparator { }

    RAction { iconName: "fullscreen"; text: qsTr("Mini player"); enabled: Player.isStarted; onTriggered: RWindows.miniPlayerRequested() }
    RAction { iconName: "hotkeys_2t";  text: qsTr("Keyboard Shortcuts");    onTriggered: RWindows.shortcutsRequested() }
    RAction { iconName: "paint_2t";    text: qsTr("Customize Player");      onTriggered: RWindows.customizeRequested() }
    RAction { iconName: "settings_2t"; text: qsTr("Settings");              shortcutText: "Ctrl + P"; onTriggered: DialogsProvider.prefsDialog() }
    RAction { iconName: "info_2t";     text: qsTr("About VLC");             shortcutText: "Shift + F1"; onTriggered: DialogsProvider.aboutDialog() }
}
