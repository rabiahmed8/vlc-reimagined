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

import VLC.MainInterface

// Keyboard shortcuts editor (Figma "Keyboard Shortcuts"): search, grouped actions,
// hotkey and global hotkey per action. Changes are kept until "Save".
Window {
    id: root

    // name -> config string, for the edited but not saved keys
    property var pending: ({})
    property var actions: []
    property string editing: ""      // option name being captured ("key-…" or "global-key-…")

    function open() {
        pending = {}
        editing = ""
        actions = RedesignSettings.hotkeys()
        searchField.text = ""
        show()
        raise()
        requestActivate()
    }

    function keyOf(name, fallback) {
        return pending[name] !== undefined ? pending[name] : fallback
    }

    function assign(name, key) {
        const p = Object.assign({}, pending)
        // a key belongs to one action: free it elsewhere (same scope)
        const global = name.startsWith("global-")
        for (const a of actions) {
            const other = global ? "global-" + a.name : a.name
            if (other !== name && key.length > 0 && keyOf(other, global ? a.globalKey : a.key) === key)
                p[other] = "Unset"
        }
        p[name] = key.length > 0 ? key : "Unset"
        pending = p
    }

    function save() {
        for (const n in pending)
            RedesignSettings.setValue(n, pending[n])
        RedesignSettings.save()
        pending = {}
        close()
    }

    // "Basic", "Playback"... from the action names
    function group(name) {
        const n = name.replace("key-", "")
        const rules = [
            [/^(toggle-fullscreen|leave-fullscreen|position|intf-|quit|wallpaper|toggle-autoscale|loop|random)/, qsTr("Basic")],
            [/^(play|pause|stop|next|prev|faster|slower|rate|frame|jump|record|program)/, qsTr("Playback")],
            [/^(vol|audio|audiodelay|audiodevice|mute)/, qsTr("Audio")],
            [/^(sub|spu)/, qsTr("Subtitles")],
            [/^(aspect|crop|deinterlace|zoom|unzoom|snapshot|viewpoint|projection|toggle-video|cycle|incr-scalefactor|decr-scalefactor)/, qsTr("Video")],
            [/^(nav|disc|title|chapter|menu)/, qsTr("Navigation")],
            [/^(set-bookmark|play-bookmark)/, qsTr("Bookmarks")]
        ]
        for (const r of rules)
            if (r[0].test(n))
                return r[1]
        return qsTr("Other")
    }

    readonly property var groups: [qsTr("Basic"), qsTr("Playback"), qsTr("Audio"), qsTr("Video"),
                                   qsTr("Subtitles"), qsTr("Navigation"), qsTr("Bookmarks"), qsTr("Other")]

    readonly property var rows: {
        const q = searchField.text.trim().toLowerCase()
        const field = fieldBox.currentValue
        const out = []
        for (const g of groups) {
            const items = actions.filter(a => {
                if (group(a.name) !== g)
                    return false
                if (q.length === 0)
                    return true
                const inAction = a.text.toLowerCase().indexOf(q) >= 0
                const inKey = (a.keyText + " " + a.globalKeyText).toLowerCase().indexOf(q) >= 0
                return field === "action" ? inAction : field === "key" ? inKey : (inAction || inKey)
            })
            if (items.length === 0)
                continue
            out.push({ header: g })
            for (const a of items)
                out.push(a)
        }
        return out
    }

    title: qsTr("Keyboard Shortcuts")
    width: Theme.dp(1048)
    height: Theme.dp(800)
    minimumWidth: Theme.dp(700)
    minimumHeight: Theme.dp(420)
    flags: Qt.Window | Qt.FramelessWindowHint
    color: Theme.p.bgA3

    Shortcut { sequence: "Esc"; enabled: root.editing.length === 0; onActivated: root.close() }

    MouseArea {
        z: 10
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: Theme.dp(12)
        height: Theme.dp(12)
        cursorShape: Qt.SizeFDiagCursor
        onPressed: root.startSystemResize(Qt.RightEdge | Qt.BottomEdge)
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.p.bgA3
        border.color: Theme.p.dividerDim

        // ---- title + search
        Rectangle {
            id: top
            width: parent.width
            height: Theme.dp(96)
            color: Theme.p.bgB1Transparent

            DragHandler {
                target: null
                onActiveChanged: if (active) root.startSystemMove()
            }

            RText {
                x: Theme.dp(20)
                y: Theme.dp(14)
                text: qsTr("Keyboard Shortcuts")
                color: Theme.textItem
            }
            RIconButton {
                anchors.right: parent.right
                anchors.rightMargin: Theme.dp(14)
                y: Theme.dp(10)
                iconName: "close"
                toolTip: qsTr("Close")
                onClicked: root.close()
            }

            RTextField {
                id: searchField
                x: Theme.dp(10)
                y: Theme.dp(52)
                width: parent.width - fieldBox.width - Theme.dp(30)
                height: Theme.dp(34)
                leftPadding: Theme.dp(40)
                placeholderText: qsTr("Search Keyboard Shortcuts...")
                background: Rectangle { radius: Theme.radius; color: Theme.p.bgA3 }
                RIcon {
                    x: Theme.dp(12)
                    anchors.verticalCenter: parent.verticalCenter
                    name: "search"
                    size: Theme.iconSizeSmall
                    color: Theme.textDim
                }
            }

            RDropdown {
                id: fieldBox
                anchors.right: parent.right
                anchors.rightMargin: Theme.dp(10)
                y: Theme.dp(52)
                width: Theme.dp(200)
                model: [{ value: "all", text: qsTr("All Fields") },
                        { value: "action", text: qsTr("Action") },
                        { value: "key", text: qsTr("Hotkey") }]
                Component.onCompleted: currentIndex = 0
            }
        }

        // ---- column titles
        Item {
            id: columns
            anchors.top: top.bottom
            width: parent.width
            height: Theme.dp(64)
            readonly property real keyX: width * 0.37
            readonly property real globalX: width * 0.70
            readonly property real keyWidth: width * 0.26

            RText { x: Theme.dp(20); anchors.verticalCenter: parent.verticalCenter; text: qsTr("Action"); color: Theme.textDim }
            RText { x: columns.keyX; width: columns.keyWidth; horizontalAlignment: Text.AlignHCenter; anchors.verticalCenter: parent.verticalCenter; text: qsTr("Hotkey"); color: Theme.textDim }
            RText { x: columns.globalX; width: columns.keyWidth; horizontalAlignment: Text.AlignHCenter; anchors.verticalCenter: parent.verticalCenter; text: qsTr("Global Hotkey"); color: Theme.textDim }
        }

        ListView {
            id: list
            anchors.top: columns.bottom
            anchors.bottom: bottomBar.top
            width: parent.width
            clip: true
            model: root.rows
            boundsBehavior: Flickable.StopAtBounds
            T.ScrollBar.vertical: RScrollBar { }

            delegate: Item {
                id: row
                required property var modelData
                readonly property bool isHeader: modelData.header !== undefined
                width: list.width
                height: isHeader ? Theme.dp(60) : Theme.dp(47)

                RText {
                    x: Theme.dp(20)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: row.isHeader ? Theme.dp(8) : 0
                    width: columns.keyX - Theme.dp(40)
                    text: row.isHeader ? row.modelData.header : row.modelData.text
                    font.pixelSize: row.isHeader ? Theme.fontSizeLarge : Theme.fontSize
                    color: row.isHeader ? Theme.textItem : Theme.textStrong
                }

                RKeyField {
                    visible: !row.isHeader
                    x: columns.keyX
                    width: columns.keyWidth
                    anchors.verticalCenter: parent.verticalCenter
                    optionName: row.isHeader ? "" : row.modelData.name
                    keyText: row.isHeader ? "" : RedesignSettings.keyDisplayText(root.keyOf(optionName, row.modelData.key))
                    capturing: root.editing === optionName
                    onCaptureRequested: root.editing = optionName
                    onCaptured: (key) => { root.assign(optionName, key); root.editing = "" }
                    onCancelled: root.editing = ""
                }
                RKeyField {
                    visible: !row.isHeader
                    x: columns.globalX
                    width: columns.keyWidth
                    anchors.verticalCenter: parent.verticalCenter
                    optionName: row.isHeader ? "" : "global-" + row.modelData.name
                    keyText: row.isHeader ? "" : RedesignSettings.keyDisplayText(root.keyOf(optionName, row.modelData.globalKey))
                    capturing: root.editing === optionName
                    onCaptureRequested: root.editing = optionName
                    onCaptured: (key) => { root.assign(optionName, key); root.editing = "" }
                    onCancelled: root.editing = ""
                }
            }
        }

        Item {
            id: bottomBar
            anchors.bottom: parent.bottom
            width: parent.width
            height: Theme.dp(64)

            RButton {
                x: Theme.dp(20)
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Cancel")
                onClicked: root.close()
            }
            RText {
                anchors.centerIn: parent
                text: qsTr("Changes apply the next time VLC starts")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textDim
                visible: Object.keys(root.pending).length > 0
            }
            RButton {
                anchors.right: parent.right
                anchors.rightMargin: Theme.dp(20)
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Save")
                primary: Object.keys(root.pending).length > 0
                enabled: Object.keys(root.pending).length > 0
                onClicked: root.save()
            }
        }
    }
}
