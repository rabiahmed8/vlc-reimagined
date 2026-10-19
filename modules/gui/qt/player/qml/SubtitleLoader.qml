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
import QtQuick.Templates as T

import VLC.MainInterface
import VLC.Style
import VLC.Widgets as Widgets
import VLC.Player
import VLC.Dialogs
import VLC.Util

// Juxtopposed Phase 4: "Add Subtitles" modal dialog
T.Popup {
    id: root

    modal: true
    focus: true
    dim: true

    anchors.centerIn: parent

    width: Math.min(parent.width - VLCStyle.margin_large * 2, VLCStyle.dp(620, VLCStyle.scale))
    height: Math.min(parent.height - VLCStyle.margin_large * 2, VLCStyle.dp(480, VLCStyle.scale))

    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutside

    readonly property ColorContext colorContext: ColorContext {
        id: theme
        colorSet: ColorContext.Window
    }

    property string currentFolderPath: {
        if (Player.url && Player.url.toString() !== "") {
            var s = decodeURIComponent(Player.url.toString())
            if (s.startsWith("file:///"))
                s = s.substring(8)
            var lastSlash = Math.max(s.lastIndexOf('/'), s.lastIndexOf('\\'))
            if (lastSlash > 0)
                return s.substring(0, lastSlash)
        }
        return qsTr("Videos / Subtitles")
    }

    ListModel {
        id: subtitleFilesModel

        Component.onCompleted: {
            populateDefaults()
        }

        function populateDefaults() {
            subtitleFilesModel.clear()
            // Detect subtitle file candidate names based on playing media
            var baseName = ""
            if (Player.title && Player.title !== "")
                baseName = Player.title
            else if (Player.url && Player.url.toString() !== "") {
                var s = decodeURIComponent(Player.url.toString())
                var lastSlash = Math.max(s.lastIndexOf('/'), s.lastIndexOf('\\'))
                var f = lastSlash >= 0 ? s.substring(lastSlash + 1) : s
                var dot = f.lastIndexOf('.')
                baseName = dot > 0 ? f.substring(0, dot) : f
            }

            if (baseName !== "") {
                subtitleFilesModel.append({
                    "fileName": baseName + "_English.srt",
                    "filePath": "",
                    "isSelected": true
                })
                subtitleFilesModel.append({
                    "fileName": baseName + "_Spanish.srt",
                    "filePath": "",
                    "isSelected": false
                })
                subtitleFilesModel.append({
                    "fileName": baseName + "_Japanese.srt",
                    "filePath": "",
                    "isSelected": false
                })
                subtitleFilesModel.append({
                    "fileName": baseName + "_German.srt",
                    "filePath": "",
                    "isSelected": false
                })
                subtitleFilesModel.append({
                    "fileName": baseName + "_French.srt",
                    "filePath": "",
                    "isSelected": false
                })
            } else {
                subtitleFilesModel.append({
                    "fileName": "Subtitles_English.srt",
                    "filePath": "",
                    "isSelected": true
                })
                subtitleFilesModel.append({
                    "fileName": "Subtitles_Spanish.srt",
                    "filePath": "",
                    "isSelected": false
                })
            }
        }

        function addCustomFile(name, path) {
            subtitleFilesModel.insert(0, {
                "fileName": name,
                "filePath": path,
                "isSelected": true
            })
        }
    }

    background: Rectangle {
        color: "#141414"
        radius: VLCStyle.dp(10, VLCStyle.scale)
        border.color: "#232323"
        border.width: 1

        Widgets.DefaultShadow {}
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VLCStyle.margin_normal
        spacing: VLCStyle.margin_normal

        // 1. Header: Title and Close button
        RowLayout {
            Layout.fillWidth: true

            T.Label {
                text: qsTr("Add Subtitles")
                color: theme.fg.primary
                font.pixelSize: VLCStyle.fontSize_large
                font.weight: Font.DemiBold
                Layout.fillWidth: true
            }

            Widgets.IconToolButton {
                text: VLCIcons.close
                description: qsTr("Close")
                font.pixelSize: VLCStyle.icon_normal
                onClicked: root.close()
            }
        }

        // 2. Filter & Path Row (Matches Figma Phase 4)
        RowLayout {
            Layout.fillWidth: true
            spacing: VLCStyle.margin_small

            // "To This File" dropdown pill
            Rectangle {
                Layout.preferredHeight: VLCStyle.dp(32, VLCStyle.scale)
                Layout.preferredWidth: VLCStyle.dp(110, VLCStyle.scale)
                color: "#1B1B1B"
                radius: VLCStyle.dp(6, VLCStyle.scale)
                border.color: "#2A2A2A"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: VLCStyle.dp(6, VLCStyle.scale)
                    spacing: 4

                    T.Label {
                        text: qsTr("To This File")
                        color: theme.fg.primary
                        font.pixelSize: VLCStyle.fontSize_small
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    Widgets.IconLabel {
                        text: VLCIcons.chevron_down
                        font.pixelSize: VLCStyle.dp(10, VLCStyle.scale)
                        color: theme.fg.secondary
                    }
                }
            }

            // "From Computer" dropdown pill
            Rectangle {
                Layout.preferredHeight: VLCStyle.dp(32, VLCStyle.scale)
                Layout.preferredWidth: VLCStyle.dp(120, VLCStyle.scale)
                color: "#1B1B1B"
                radius: VLCStyle.dp(6, VLCStyle.scale)
                border.color: "#2A2A2A"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: VLCStyle.dp(6, VLCStyle.scale)
                    spacing: 4

                    T.Label {
                        text: qsTr("From Computer")
                        color: theme.fg.primary
                        font.pixelSize: VLCStyle.fontSize_small
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    Widgets.IconLabel {
                        text: VLCIcons.chevron_down
                        font.pixelSize: VLCStyle.dp(10, VLCStyle.scale)
                        color: theme.fg.secondary
                    }
                }
            }

            // Path pill / button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VLCStyle.dp(32, VLCStyle.scale)
                color: "#1B1B1B"
                radius: VLCStyle.dp(6, VLCStyle.scale)
                border.color: pathMouse.containsMouse ? theme.accent : "#2A2A2A"
                border.width: 1

                MouseArea {
                    id: pathMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        DialogsProvider.loadSubtitlesFile()
                        root.close()
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: VLCStyle.dp(10, VLCStyle.scale)
                    anchors.rightMargin: VLCStyle.dp(10, VLCStyle.scale)
                    spacing: VLCStyle.margin_xsmall

                    Widgets.IconLabel {
                        text: VLCIcons.folder
                        color: theme.fg.secondary
                        font.pixelSize: VLCStyle.icon_small
                    }

                    T.Label {
                        text: root.currentFolderPath
                        color: theme.fg.secondary
                        font.pixelSize: VLCStyle.fontSize_small
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // 3. Subtitle file list
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#111111"
            radius: VLCStyle.dp(8, VLCStyle.scale)
            border.color: "#1F1F1F"
            border.width: 1
            clip: true

            ListView {
                id: subListView
                anchors.fill: parent
                anchors.margins: VLCStyle.dp(6, VLCStyle.scale)
                spacing: VLCStyle.dp(2, VLCStyle.scale)
                model: subtitleFilesModel

                delegate: Rectangle {
                    id: fileRow
                    width: subListView.width
                    height: VLCStyle.dp(38, VLCStyle.scale)
                    radius: VLCStyle.dp(6, VLCStyle.scale)
                    color: rowMouse.containsMouse ? "#202020" : (model.isSelected ? "#191919" : "transparent")
                    border.color: model.isSelected ? "#2E2E2E" : "transparent"
                    border.width: 1

                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            model.isSelected = !model.isSelected
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: VLCStyle.dp(12, VLCStyle.scale)
                        anchors.rightMargin: VLCStyle.dp(12, VLCStyle.scale)
                        spacing: VLCStyle.margin_normal

                        Widgets.IconLabel {
                            text: VLCIcons.ic_fluent_document_add_24_regular
                            color: model.isSelected ? theme.accent : theme.fg.secondary
                            font.pixelSize: VLCStyle.icon_small
                        }

                        T.Label {
                            text: model.fileName
                            color: model.isSelected ? theme.fg.primary : theme.fg.secondary
                            font.pixelSize: VLCStyle.fontSize_normal
                            font.weight: model.isSelected ? Font.Medium : Font.Normal
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }

                        Widgets.IconLabel {
                            visible: model.isSelected
                            text: VLCIcons.check
                            color: theme.accent
                            font.pixelSize: VLCStyle.icon_small
                        }
                    }
                }
            }
        }

        // 4. Footer actions: Cancel and Save
        RowLayout {
            Layout.fillWidth: true
            spacing: VLCStyle.margin_normal

            // Left: browse custom button
            Widgets.TextToolButton {
                text: qsTr("Browse from disk...")
                onClicked: {
                    DialogsProvider.loadSubtitlesFile()
                    root.close()
                }
            }

            Item { Layout.fillWidth: true }

            // Cancel button
            Widgets.ButtonExt {
                text: qsTr("Cancel")
                onClicked: root.close()
            }

            // Save button (orange accent)
            Rectangle {
                id: saveBtn
                Layout.preferredHeight: VLCStyle.dp(34, VLCStyle.scale)
                Layout.preferredWidth: VLCStyle.dp(90, VLCStyle.scale)
                radius: VLCStyle.dp(6, VLCStyle.scale)
                color: saveMouse.pressed ? VLCStyle.colors.orange800 : (saveMouse.containsMouse ? "#E08A2E" : theme.accent)

                MouseArea {
                    id: saveMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // Apply selected subtitles
                        for (var i = 0; i < subtitleFilesModel.count; ++i) {
                            var item = subtitleFilesModel.get(i)
                            if (item.isSelected && item.filePath !== "") {
                                Player.associateSubtitleFile(item.filePath)
                            }
                        }
                        root.close()
                    }
                }

                T.Label {
                    anchors.centerIn: parent
                    text: qsTr("Save")
                    color: "#161616"
                    font.pixelSize: VLCStyle.fontSize_normal
                    font.weight: Font.Bold
                }
            }
        }
    }
}
