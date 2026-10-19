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

import VLC.MainInterface

// Hotkey cell of the shortcuts window: shows the key, click (or the pencil) to record
// a new one, Esc cancels, Backspace/Delete clears.
T.AbstractButton {
    id: root

    property string optionName
    property string keyText
    property bool capturing: false

    signal captureRequested()
    signal captured(string key)
    signal cancelled()

    implicitHeight: Theme.dp(33)
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    onClicked: { root.captureRequested(); forceActiveFocus() }
    onCapturingChanged: if (capturing) forceActiveFocus()

    Keys.onPressed: (event) => {
        if (!root.capturing)
            return
        event.accepted = true
        switch (event.key) {
        case Qt.Key_Escape:
            root.cancelled()
            return
        case Qt.Key_Backspace:
        case Qt.Key_Delete:
            if (event.modifiers === Qt.NoModifier) {
                root.captured("")
                return
            }
            break
        case Qt.Key_Control: case Qt.Key_Shift: case Qt.Key_Alt: case Qt.Key_Meta:
            return // wait for the real key
        }
        const k = RedesignSettings.keyFromEvent(event.key, event.modifiers, event.text)
        if (k.length > 0)
            root.captured(k)
    }

    background: Rectangle {
        radius: Theme.radiusSmall
        color: Theme.p.bgB1Transparent
        border.color: root.capturing ? Theme.accent : root.hovered ? Theme.p.dividerDim : "transparent"
        border.width: 1
    }

    contentItem: Item {
        RText {
            anchors.centerIn: parent
            text: root.capturing ? qsTr("Press a key…") : root.keyText
            font.family: root.capturing ? Theme.fontFamily : "Consolas"
            color: root.capturing ? Theme.accent : Theme.textStrong
        }
        RIcon {
            anchors.right: parent.right
            anchors.rightMargin: Theme.dp(8)
            anchors.verticalCenter: parent.verticalCenter
            name: "edit"
            size: Theme.iconSizeSmall
            color: root.hovered ? Theme.textItem : Theme.textDim
        }
    }
}
