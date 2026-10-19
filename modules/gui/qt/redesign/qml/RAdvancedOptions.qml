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

// "Advanced Options >" at the bottom of a settings page. Expanded, it lists every
// other VLC option of the page's area (the given subcategories), grouped by module,
// so that nothing of the classic "All" preferences is lost.
Column {
    id: root

    readonly property bool advancedOptionGroup: true

    property var subcats: []          // vlc_config_subcat values
    property var exclude: []          // option names already shown on the page (default: the
                                      // ROption rows of the enclosing RSettingsPage)
    // --qt-redesign-open=settings:<category>:advanced opens it expanded (testing)
    property bool expanded: RedesignSettings.inheritedString("qt-redesign-open").endsWith(":advanced")

    function excludedNames() {
        if (exclude.length > 0)
            return exclude
        for (let p = parent; p; p = p.parent) {
            if (p.optionNames !== undefined)
                return p.optionNames()
        }
        return []
    }

    width: parent ? parent.width : implicitWidth
    spacing: 0

    Item { width: 1; height: Theme.dp(14) }

    T.AbstractButton {
        id: toggle
        width: parent.width
        height: Theme.dp(38)
        hoverEnabled: true
        onClicked: root.expanded = !root.expanded

        background: Rectangle {
            radius: Theme.radius
            color: toggle.hovered ? Qt.lighter(Theme.p.bgA1, 1.25) : Theme.p.bgA1
        }
        contentItem: Item {
            Row {
                anchors.centerIn: parent
                spacing: Theme.dp(10)
                RText {
                    text: qsTr("Advanced Options")
                    color: Theme.textItem
                    anchors.verticalCenter: parent.verticalCenter
                }
                RIcon {
                    name: root.expanded ? "chevron_down" : "chevron_right"
                    size: Theme.iconSizeSmall
                    color: Theme.textItem
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    Repeater {
        model: root.expanded ? RedesignSettings.advancedOptions(root.subcats, root.excludedNames()) : []

        delegate: Column {
            required property var modelData
            width: root.width

            RSettingsSection {
                text: modelData.title
                font.pixelSize: Theme.fontSize
            }

            Repeater {
                model: modelData.options
                delegate: ROption {
                    required property string modelData
                    width: root.width
                    name: modelData
                }
            }
        }
    }

    RText {
        visible: root.expanded
        topPadding: Theme.dp(16)
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Changes are saved when the settings window is closed. Some options apply to the next playback or to the next start of VLC.")
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.textDim
    }
}
