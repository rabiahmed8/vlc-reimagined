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

import VLC.MainInterface

// A settings row bound to a VLC option. The control is picked from the option type:
// bool -> switch, list of choices -> dropdown, number -> field or slider, file -> field + Browse...
// The row hides itself when the option does not exist in this build.
RSettingRow {
    id: root

    property string name                 // VLC option name
    property string kind: "auto"         // auto, switch, dropdown, segmented, slider, text
    property var choices                 // overrides the option choices: [{ value, text }]
    property var sliderLabels: []        // for kind: "slider"
    property int sliderTicks: 0
    property real sliderStep: 0
    property var minimum                 // override the option range for kind: "slider"
    property var maximum
    property string suffix               // shown after numbers in text fields ("s", "ms")
    property string title                // label, defaults to the option text

    property var opt: ({})
    readonly property var value: opt.value
    readonly property string type: opt.type || ""

    signal changed(var value)

    function reload() { opt = RedesignSettings.option(name) }
    // text of the value in a field: floats without binary noise (12.8, not 12.800000190734863)
    function displayValue() {
        if (value === undefined)
            return ""
        const v = type === "float" ? String(Math.round(Number(value) * 10000) / 10000) : String(value)
        return v + (suffix ? " " + suffix : "")
    }
    function set(v) {
        if (RedesignSettings.setValue(name, v))
            root.changed(v)
    }

    readonly property string resolvedKind: {
        if (kind !== "auto")
            return kind
        const t = type
        const hasChoices = (choices || opt.choices || []).length > 0
        if (t === "bool") return "switch"
        if (t === "color") return "color"
        if (t === "file" || t === "savefile" || t === "directory" || t === "font") return "path"
        if (hasChoices && t !== "modulelist") return "dropdown"
        return "text"
    }

    visible: opt.exists === true
    label: title.length > 0 ? title : (opt.text || name)
    info: opt.longtext && opt.longtext !== opt.text ? opt.longtext : ""

    Component.onCompleted: reload()
    onNameChanged: reload()

    Connections {
        target: RedesignSettings
        function onValueChanged(changedName) { if (changedName === root.name) root.reload() }
        function onAllValuesChanged() { root.reload() }
    }

    Loader {
        id: loader
        width: parent.width
        sourceComponent: {
            switch (root.resolvedKind) {
            case "switch": return switchComponent
            case "dropdown": return dropdownComponent
            case "segmented": return segmentedComponent
            case "slider": return sliderComponent
            case "color": return colorComponent
            case "path": return pathComponent
            default: return textComponent
            }
        }
    }

    Component {
        id: switchComponent
        Item {
            width: parent ? parent.width : 0
            height: sw.height
            RSwitch {
                id: sw
                anchors.right: parent.right
                checked: root.value === true
                onToggled: root.set(checked)
            }
        }
    }

    Component {
        id: dropdownComponent
        RDropdown {
            width: parent ? parent.width : 0
            model: root.choices || root.opt.choices || []
            onModelChanged: selectValue(root.value)
            Component.onCompleted: selectValue(root.value)
            Connections {
                target: root
                function onValueChanged() { selectValue(root.value) }
            }
            onPicked: (v) => root.set(v)
        }
    }

    Component {
        id: segmentedComponent
        RSegmented {
            width: parent ? parent.width : 0
            model: root.choices || root.opt.choices || []
            currentValue: root.value
            onPicked: (v) => root.set(v)
        }
    }

    Component {
        id: sliderComponent
        RTickSlider {
            width: parent ? parent.width : 0
            from: root.minimum !== undefined ? root.minimum : root.opt.min !== undefined ? root.opt.min : 0
            to: root.maximum !== undefined ? root.maximum : root.opt.max !== undefined ? root.opt.max : 100
            stepSize: root.sliderStep > 0 ? root.sliderStep : (root.type === "int" ? 1 : 0)
            labels: root.sliderLabels
            tickCount: root.sliderTicks
            value: Number(root.value)
            onCommitted: (v) => root.set(root.type === "int" ? Math.round(v) : v)
        }
    }

    Component {
        id: textComponent
        RTextField {
            width: parent ? parent.width : 0
            echoMode: root.type === "password" ? TextInput.Password : TextInput.Normal
            text: root.displayValue()
            onActiveFocusChanged: if (activeFocus && root.suffix) text = String(root.value)
            onCommitted: (t) => {
                let v = root.suffix ? t.replace(root.suffix, "").trim() : t
                if (root.type === "int") {
                    v = parseInt(v)
                    if (isNaN(v)) { root.reload(); return }
                } else if (root.type === "float") {
                    v = parseFloat(v.replace(",", "."))
                    if (isNaN(v)) { root.reload(); return }
                }
                root.set(v)
                text = Qt.binding(() => root.displayValue())
            }
        }
    }

    Component {
        id: pathComponent
        Item {
            width: parent ? parent.width : 0
            height: field.height
            RTextField {
                id: field
                anchors.left: parent.left
                anchors.right: browse.left
                anchors.rightMargin: Theme.dp(12)
                text: root.value || ""
                onCommitted: (t) => root.set(t)
            }
            RButton {
                id: browse
                anchors.right: parent.right
                text: qsTr("Browse")
                onClicked: {
                    let v = ""
                    if (root.type === "directory")
                        v = RedesignSettings.browseDirectory(root.value || "")
                    else if (root.type === "font")
                        v = RedesignSettings.pickFont(root.value || "")
                    else
                        v = RedesignSettings.browseFile(root.value || "", root.type === "savefile")
                    if (v.length > 0)
                        root.set(v)
                }
            }
        }
    }

    Component {
        id: colorComponent
        RColorField {
            width: parent ? parent.width : 0
            color: "#" + ("000000" + Number(root.value || 0).toString(16)).slice(-6)
            onPicked: (c) => root.set(parseInt(String(c).slice(1, 7), 16))
        }
    }
}
