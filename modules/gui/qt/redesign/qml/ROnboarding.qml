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

// First start of the redesign (Figma "Onboarding", "Onboarding-1..10"):
// 1. welcome + media folder, 2. theme and accent color, 3. basic keyboard shortcuts.
Rectangle {
    id: root

    property int step: 0
    property string folder: ""

    signal finished()

    function finish() {
        MainCtx.setSettingValue("Redesign/onboardingDone", true)
        root.finished()
    }

    color: Theme.p.bgB2

    // swallow input below
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onWheel: (w) => w.accepted = true }

    Loader {
        id: folders
        active: MainCtx.mediaLibraryAvailable
        source: "RLibraryFolders.qml"
    }

    // ---------------------------------------------------------------- step 1
    Column {
        visible: root.step === 0
        anchors.centerIn: parent
        width: Math.min(Theme.dp(600), parent.width - Theme.dp(80))
        spacing: Theme.dp(20)

        RIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: "logo"
            size: Theme.dp(128)
            color: Theme.accent
            accentColor: Theme.accent
        }
        RText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Welcome to VLC!")
            font.pixelSize: Theme.dp(30)
            font.weight: Font.Light
            color: Theme.textStrong
        }
        RText {
            width: parent.width
            wrapMode: Text.Wrap
            lineHeight: 1.4
            text: qsTr("VLC is a free and open source cross-platform multimedia player and framework that plays most multimedia files as well as DVDs, Audio CDs, VCDs, and various streaming protocols.")
            color: Theme.textItem
        }
        Item { width: 1; height: Theme.dp(30) }
        RText {
            visible: MainCtx.mediaLibraryAvailable
            text: qsTr("Choose a Media Folder to get started with")
            font.pixelSize: Theme.fontSizeSmall + Theme.dp(1)
            color: Theme.textItem
        }
        Row {
            visible: MainCtx.mediaLibraryAvailable
            width: parent.width
            spacing: Theme.dp(10)
            RTextField {
                id: folderField
                width: parent.width - browse.width - parent.spacing
                height: Theme.dp(36)
                text: root.folder
                placeholderText: qsTr("Optional: your videos or music folder")
                onCommitted: (t) => root.folder = t
            }
            RButton {
                id: browse
                height: Theme.dp(36)
                text: qsTr("Browse")
                onClicked: {
                    const d = RedesignSettings.browseDirectory(root.folder)
                    if (d.length > 0)
                        root.folder = d
                }
            }
        }
    }

    // ---------------------------------------------------------------- step 2
    Item {
        visible: root.step === 1
        anchors.fill: parent

        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -Theme.dp(60)
            spacing: Theme.dp(40)

            RText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Select your preferred theme and color.")
                font.pixelSize: Theme.dp(22)
                font.weight: Font.Light
                color: Theme.textItem
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.dp(56)
                Repeater {
                    model: [{ value: "light", text: qsTr("Light") }, { value: "dark", text: qsTr("Dark") },
                            { value: "system", text: qsTr("System") }]
                    delegate: T.AbstractButton {
                        id: themeBtn
                        required property var modelData
                        readonly property bool selected: Theme.mode === modelData.value
                        width: Theme.dp(124)
                        height: Theme.dp(160)
                        hoverEnabled: true
                        onClicked: Theme.setMode(modelData.value)

                        contentItem: Column {
                            spacing: Theme.dp(18)
                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: Theme.dp(124)
                                height: Theme.dp(124)
                                radius: Theme.dp(20)
                                color: "transparent"
                                border.color: themeBtn.selected ? Theme.accent : themeBtn.hovered ? Theme.p.dividerBright : "transparent"
                                border.width: Theme.dp(4)
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: Theme.dp(12)
                                    radius: Theme.dp(12)
                                    clip: true
                                    color: themeBtn.modelData.value === "light" ? "#B1B1B1" : "#232323"
                                    // "System": light half
                                    Rectangle {
                                        visible: themeBtn.modelData.value === "system"
                                        x: parent.width * 0.35
                                        y: -parent.height * 0.2
                                        width: parent.width
                                        height: parent.height * 1.6
                                        rotation: -28
                                        color: "#B1B1B1"
                                    }
                                }
                            }
                            RText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: themeBtn.modelData.text
                                color: themeBtn.selected ? Theme.textStrong : Theme.textItem
                            }
                        }
                    }
                }
            }
        }

        // accent colors
        Row {
            x: Theme.dp(40)
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.dp(40)
            spacing: Theme.dp(24)
            Repeater {
                model: ["", "#B5432F", "#9C8424", "#2D8A34", "#1F8EA3", "#2050A6", "#7A3BC4", "#C2408C", "#8A8A8A"]
                delegate: T.AbstractButton {
                    id: dot
                    required property string modelData
                    readonly property bool selected: Theme.accentSetting === modelData
                    width: Theme.dp(56)
                    height: Theme.dp(56)
                    hoverEnabled: true
                    onClicked: Theme.setAccent(modelData)
                    contentItem: Item {
                        Rectangle {
                            anchors.centerIn: parent
                            width: Theme.dp(56)
                            height: width
                            radius: width / 2
                            color: "transparent"
                            border.color: dot.selected ? Qt.darker(dot.modelData.length ? dot.modelData : Theme.p.accent, 1.6) : "transparent"
                            border.width: Theme.dp(4)
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            width: Theme.dp(40)
                            height: width
                            radius: width / 2
                            color: dot.modelData.length > 0 ? dot.modelData : Theme.p.accent
                            opacity: dot.hovered || dot.selected ? 1 : 0.8
                        }
                    }
                }
            }
        }
    }

    // ---------------------------------------------------------------- step 3
    Item {
        visible: root.step === 2
        anchors.fill: parent

        readonly property var keys: RedesignSettings.hotkeys()
        function keyText(name) {
            for (const k of keys)
                if (k.name === name)
                    return k.keyText
            return ""
        }

        Column {
            id: shortcuts
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -Theme.dp(30)
            width: Math.min(Theme.dp(900), parent.width - Theme.dp(80))
            spacing: Theme.dp(30)

            RText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Learn the basic keyboard shortcuts.")
                font.pixelSize: Theme.dp(22)
                font.weight: Font.Light
                color: Theme.textItem
            }

            Grid {
                columns: 2
                columnSpacing: Theme.dp(60)
                rowSpacing: Theme.dp(18)
                Repeater {
                    model: [
                        { text: qsTr("Play / Pause"), keys: ["key-play-pause"] },
                        { text: qsTr("Toggle Fullscreen"), keys: ["key-toggle-fullscreen"] },
                        { text: qsTr("Seek Backward / Forward"), keys: ["key-jump-extrashort", "key-jump+extrashort"] },
                        { text: qsTr("Increase / Decrease Volume"), keys: ["key-vol-up", "key-vol-down"] },
                        { text: qsTr("Previous / Next Item"), keys: ["key-prev", "key-next"] },
                        { text: qsTr("Previous / Next Frame"), keys: ["key-frame-previous", "key-frame-next"] },
                        { text: qsTr("Cycle Subtitle Track"), keys: ["key-subtitle-track"] },
                        { text: qsTr("Cycle Audio Track"), keys: ["key-audio-track"] },
                        { text: qsTr("Take a Snapshot"), keys: ["key-snapshot"] },
                        { text: qsTr("Record"), keys: ["key-record"] }
                    ]
                    delegate: Item {
                        required property var modelData
                        width: (shortcuts.width - Theme.dp(60)) / 2
                        height: Theme.dp(34)
                        RText {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width * 0.5
                            text: modelData.text
                            color: Theme.textItem
                        }
                        Row {
                            x: parent.width * 0.55
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.dp(8)
                            Repeater {
                                model: modelData.keys
                                delegate: Row {
                                    required property string modelData
                                    required property int index
                                    spacing: Theme.dp(8)
                                    RText { visible: index > 0; text: "/"; color: Theme.textDim; anchors.verticalCenter: parent.verticalCenter }
                                    Rectangle {
                                        width: Math.max(Theme.dp(30), keyLabel.implicitWidth + Theme.dp(18))
                                        height: Theme.dp(30)
                                        radius: Theme.radius
                                        color: Theme.p.bgA3
                                        border.color: Theme.p.dividerBright
                                        RText {
                                            id: keyLabel
                                            anchors.centerIn: parent
                                            text: shortcuts.parent.keyText(modelData) || "-"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.textStrong
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        RText {
            x: Theme.dp(40)
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.dp(54)
            text: qsTr("Find the full list in the menu (Keyboard Shortcuts).")
            color: Theme.textDim
        }
    }

    // ---------------------------------------------------------------- buttons
    Row {
        anchors.right: parent.right
        anchors.rightMargin: Theme.dp(40)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.dp(48)
        spacing: Theme.dp(10)

        RButton {
            text: root.step === 0 ? qsTr("Skip") : qsTr("Back")
            onClicked: root.step === 0 ? root.finish() : root.step--
        }
        RButton {
            primary: true
            text: root.step === 2 ? qsTr("Finish") : qsTr("Next")
            onClicked: {
                if (root.step === 0 && root.folder.length > 0 && folders.item)
                    folders.item.add("file:///" + root.folder.replace(/\\/g, "/").replace(/^\/+/, ""))
                if (root.step === 2)
                    root.finish()
                else
                    root.step++
            }
        }
    }
}
