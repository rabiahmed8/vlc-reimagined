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

import VLC.MediaLibrary

// Creates media library playlists for the dialogs. Separate file: VLC.MediaLibrary
// only exists when VLC runs with the media library, dialogs load it through a Loader.
QtObject {
    property MLPlaylistListModel model: MLPlaylistListModel { ml: MediaLib }

    // name: playlist title, urls: media URLs or paths
    function save(name, urls) {
        model.create(name, urls)
    }
}
