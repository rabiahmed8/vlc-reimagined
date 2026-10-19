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

// Section title row in popups: 60px tall, 28px side padding, optional actions
Item {
    id: root

    property string text
    default property alias actions: actionsRow.data

    implicitHeight: Theme.dp(60)

    RText {
        anchors.left: parent.left
        anchors.leftMargin: Theme.dp(28)
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        color: Theme.textDim
    }

    Row {
        id: actionsRow
        anchors.right: parent.right
        anchors.rightMargin: Theme.dp(28)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.dp(14)
    }
}
