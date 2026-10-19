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
import QtQuick.Templates as T

// Popup menu in the redesign style (dark panel, 10px radius, two-tone icons,
// shortcut on the right). Items are RMenuItem / RMenuSeparator.
T.Menu {
    id: root
    property string iconName: ""

    implicitWidth: Math.max(Theme.dp(260), contentItem ? contentItem.implicitWidth + leftPadding + rightPadding : 0)
    implicitHeight: Math.min(contentItem ? contentItem.implicitHeight + topPadding + bottomPadding : 0, Window.window ? Window.window.height - 2 * margins : 10000)

    padding: Theme.dp(8)
    margins: Theme.dp(8)
    overlap: Theme.dp(4)
    cascade: true

    delegate: RMenuItem { }

    enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.durationShort } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.durationShort } }

    contentItem: ListView {
        implicitHeight: contentHeight
        implicitWidth: {
            let w = 0
            for (let i = 0; i < count; ++i) {
                const it = itemAtIndex(i)
                if (it) w = Math.max(w, it.implicitWidth)
            }
            return w
        }
        model: root.contentModel
        interactive: Window.window ? contentHeight + root.topPadding + root.bottomPadding > Window.window.height : false
        clip: true
        currentIndex: root.currentIndex
    }

    background: Rectangle {
        implicitWidth: Theme.dp(260)
        radius: Theme.radiusLarge
        color: Theme.p.bgA3Transparent
        border.color: Theme.p.dividerDim
        border.width: 1
    }

}
