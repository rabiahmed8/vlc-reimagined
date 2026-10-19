/*****************************************************************************
 * Copyright (C) 2021 VLC authors and VideoLAN
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

import VLC.Style

Row {
    id: root

    required property var labels

    onLabelsChanged: {
        // try to reuse items, texts are assigned with Binding
        // extra items are hidden, Row should take care of them
        if (repeater.count < labels.length)
            repeater.model = labels.length
    }

    spacing: VLCStyle.margin_xxsmall

    readonly property ColorContext colorContext: ColorContext {
        id: theme
        colorSet: ColorContext.Badge
    }

    Repeater {
        id: repeater

        delegate: T.Label {
            id: label

            padding: VLCStyle.margin_xxsmall
            leftPadding: VLCStyle.margin_xsmall
            rightPadding: VLCStyle.margin_xsmall

            visible: index < root.labels.length
            text: index >= root.labels.length ? "" :  root.labels[index]

            font.pixelSize: VLCStyle.fontSize_small
            font.weight: Font.Medium

            horizontalAlignment: Text.AlignRight

            color: VLCStyle.palette.juxtFgA1

            background: Rectangle {
                anchors.fill: label
                color: Qt.rgba(0, 0, 0, 0.75)
                border.color: VLCStyle.palette.juxtDividerBright
                border.width: 1
                radius: VLCStyle.dp(4, VLCStyle.scale)
            }

            Accessible.ignored: true
        }
    }
}
