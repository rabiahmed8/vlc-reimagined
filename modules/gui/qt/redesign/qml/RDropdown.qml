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

// Dropdown of the settings ("Dropdown" component in Figma).
// model: [{ value, text }, ...]; currentValue follows "value".
T.ComboBox {
    id: root

    // emitted when the user picks an entry (not when the value is set from outside)
    signal picked(var value)

    // selects the entry holding value, if any
    function selectValue(value) {
        for (let i = 0; i < count; ++i) {
            if (valueAt(i) == value) { // loose comparison: ints come back as numbers or strings
                currentIndex = i
                return
            }
        }
        currentIndex = -1
    }

    textRole: "text"
    valueRole: "value"

    implicitWidth: Theme.dp(318)
    implicitHeight: Theme.dp(34)
    leftPadding: Theme.dp(14)
    rightPadding: Theme.dp(40)
    hoverEnabled: true
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize

    onActivated: (index) => root.picked(valueAt(index))

    background: Rectangle {
        radius: Theme.radius
        color: root.hovered ? Theme.p.bgA1 : Theme.p.bgA3
        border.color: root.visualFocus || root.popup.visible ? Theme.p.dividerBright : Theme.p.bgB2
        border.width: Theme.dp(2)
        opacity: root.enabled ? 1 : 0.4
    }

    contentItem: RText {
        text: root.currentIndex >= 0 ? root.displayText : ""
        color: root.enabled ? Theme.textItem : Theme.iconDisabled
    }

    indicator: RIcon {
        x: root.width - width - Theme.dp(12)
        anchors.verticalCenter: parent.verticalCenter
        name: "chevron_down"
        size: Theme.iconSizeSmall
        color: root.enabled ? Theme.textItem : Theme.iconDisabled
        rotation: root.popup.visible ? 180 : 0
    }

    delegate: T.ItemDelegate {
        id: entry
        required property int index
        required property var modelData
        width: ListView.view ? ListView.view.width : implicitWidth
        implicitHeight: Theme.dp(46)
        hoverEnabled: true
        highlighted: root.highlightedIndex === index

        background: Rectangle {
            color: entry.highlighted || entry.hovered ? Theme.p.bgA1 : "transparent"
        }
        contentItem: Item {
            // optional icon of the entry (equalizer presets)
            RIcon {
                id: entryIcon
                x: Theme.dp(14)
                anchors.verticalCenter: parent.verticalCenter
                visible: typeof entry.modelData === "object" && !!entry.modelData.icon
                name: visible ? entry.modelData.icon : ""
                size: Theme.iconSizeSmall
                color: Theme.textItem
            }
            RText {
                anchors.left: entryIcon.visible ? entryIcon.right : parent.left
                anchors.leftMargin: entryIcon.visible ? Theme.dp(10) : Theme.dp(16)
                anchors.right: check.left
                anchors.rightMargin: Theme.dp(8)
                anchors.verticalCenter: parent.verticalCenter
                text: entry.modelData[root.textRole] !== undefined ? entry.modelData[root.textRole] : entry.modelData
                color: entry.index === root.currentIndex ? Theme.textStrong : Theme.textItem
            }
            RIcon {
                id: check
                anchors.right: parent.right
                anchors.rightMargin: Theme.dp(14)
                anchors.verticalCenter: parent.verticalCenter
                name: "check"
                size: Theme.iconSizeSmall
                color: Theme.accent
                visible: entry.index === root.currentIndex
            }
        }
    }

    popup: T.Popup {
        y: root.height + Theme.dp(4)
        width: root.width
        implicitHeight: Math.min(list.contentHeight, Theme.dp(46) * 8)
        padding: 0

        contentItem: ListView {
            id: list
            clip: true
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex
            boundsBehavior: Flickable.StopAtBounds
        }

        background: Rectangle {
            radius: Theme.radius
            color: Theme.p.bgA3
            border.color: Theme.p.dividerDim
            border.width: 1
        }
    }
}
