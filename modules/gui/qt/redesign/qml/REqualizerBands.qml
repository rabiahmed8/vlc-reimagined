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

// Preamp + 10 band equalizer with vertical sliders and dB values (Figma "Audio Defaults",
// "Audio - Equalizer"). Works on plain numbers; the owner reads/writes the VLC options.
Item {
    id: root

    property real preamp: 0
    property var bands: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    readonly property var labels: ["60 Hz", "170 Hz", "310 Hz", "600 Hz", "1 KHz",
                                   "3 KHz", "6 KHz", "12 KHz", "14 KHz", "16 KHz"]
    readonly property var shortLabels: ["60", "170", "310", "600", "1K", "3K", "6K", "12K", "14K", "16K"]
    // column width: 60 px when there is room (settings), narrower in the 400 px popup
    readonly property real columnWidth: Math.min(Theme.dp(60), width / 11)
    readonly property bool compact: columnWidth < Theme.dp(54)
    property int sliderHeight: Theme.dp(320)

    signal preampEdited(real value)
    signal bandsEdited(var values)

    implicitWidth: Theme.dp(760)
    implicitHeight: row.implicitHeight

    Row {
        id: row
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Math.max(0, (root.width - 11 * root.columnWidth) / 10)

        Repeater {
            model: 11
            delegate: Column {
                id: band
                required property int index
                readonly property bool isPreamp: index === 0
                readonly property real value: isPreamp ? root.preamp : Number(root.bands[index - 1] || 0)
                spacing: Theme.dp(8)
                width: root.columnWidth

                T.Slider {
                    id: slider
                    anchors.horizontalCenter: parent.horizontalCenter
                    orientation: Qt.Vertical
                    from: -20
                    to: 20
                    stepSize: 0.1
                    value: band.value
                    width: Theme.dp(20)
                    height: root.sliderHeight
                    hoverEnabled: true

                    onMoved: {
                        if (band.isPreamp) {
                            root.preampEdited(value)
                        } else {
                            const b = root.bands.slice()
                            b[band.index - 1] = Math.round(value * 10) / 10
                            root.bandsEdited(b)
                        }
                    }

                    background: Rectangle {
                        x: (slider.width - width) / 2
                        width: Theme.dp(16)
                        height: slider.height
                        radius: Theme.radiusSmall
                        color: Theme.trackBackground
                        border.color: Theme.p.bgB2
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: (1 - slider.visualPosition) * parent.height
                            radius: parent.radius
                            color: Theme.trackFill
                        }
                    }
                    handle: Rectangle {
                        x: (slider.width - width) / 2
                        y: slider.visualPosition * (slider.height - height)
                        width: Theme.dp(24)
                        height: Theme.dp(8)
                        radius: Theme.dp(2)
                        color: Theme.accent
                    }
                }

                RText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: band.isPreamp ? (root.compact ? qsTr("Pre") : qsTr("Preamp"))
                                        : (root.compact ? root.shortLabels[band.index - 1] : root.labels[band.index - 1])
                    font.pixelSize: root.compact ? Theme.fontSizeSmall : Theme.fontSize
                    color: Theme.textDim
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: root.columnWidth - Theme.dp(2)
                    height: Theme.dp(30)
                    radius: Theme.radiusSmall
                    color: Theme.p.bgB1Transparent
                    RText {
                        anchors.centerIn: parent
                        text: band.value.toFixed(1) + (root.compact ? "" : " dB")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textItem
                    }
                }
            }
        }
    }
}
