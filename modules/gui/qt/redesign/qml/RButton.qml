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
import QtQuick.Templates as T

// Flat text button ("Browse", "Reset", "Edit Keyboard Shortcuts"...).
// primary: accent background, for the main action of a dialog.
T.Button {
    id: root

    property bool primary: false

    implicitWidth: Math.max(Theme.dp(100), contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Theme.dp(32)
    leftPadding: Theme.dp(16)
    rightPadding: Theme.dp(16)
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    background: Rectangle {
        radius: Theme.radius
        color: root.primary
               ? (root.pressed ? Theme.p.accentDim : root.hovered ? Qt.lighter(Theme.accent, 1.1) : Theme.accent)
               : (root.pressed ? Theme.p.bgB2 : root.hovered ? Qt.lighter(Theme.p.bgA1, 1.25) : Theme.p.bgA1)
        border.color: root.visualFocus ? Theme.p.dividerBright : "transparent"
        border.width: 1
        opacity: root.enabled ? 1 : 0.4
    }

    contentItem: RText {
        text: root.text
        horizontalAlignment: Text.AlignHCenter
        font.weight: Font.DemiBold
        color: root.primary ? Theme.iconOnAccent : (root.enabled ? Theme.textItem : Theme.iconDisabled)
    }
}
