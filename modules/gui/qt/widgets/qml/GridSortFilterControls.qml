import QtQuick

import VLC.MainInterface
import VLC.Style
import VLC.Util
import VLC.Menus

NavigableRow {
    id: root

    spacing: VLCStyle.dp(8, VLCStyle.scale)
    enabled: viewModeSegment.visible || sortControl.visible || searchBox.visible

    property SortMenu sortMenu: null
    required property SortCtx sort
    required property SearchCtx search

    Rectangle {
        id: viewModeSegment

        visible: MainCtx.hasGridListMode
        enabled: visible

        implicitWidth: viewRow.implicitWidth + VLCStyle.dp(6, VLCStyle.scale)
        implicitHeight: VLCStyle.dp(28, VLCStyle.scale)
        radius: VLCStyle.dp(6, VLCStyle.scale)

        color: VLCStyle.palette.juxtBgA3
        border.width: 1
        border.color: VLCStyle.palette.juxtDividerDim

        Row {
            id: viewRow
            anchors.centerIn: parent
            spacing: VLCStyle.dp(2, VLCStyle.scale)

            Item {
                id: gridBtn
                implicitWidth: VLCStyle.dp(28, VLCStyle.scale)
                implicitHeight: VLCStyle.dp(24, VLCStyle.scale)

                Rectangle {
                    anchors.fill: parent
                    radius: VLCStyle.dp(4, VLCStyle.scale)
                    color: MainCtx.gridView ? VLCStyle.palette.juxtBgPill : (gridHover.hovered ? "#222222" : "transparent")
                    Behavior on color { ColorAnimation { duration: VLCStyle.duration_short } }

                    Text {
                        anchors.centerIn: parent
                        font.family: VLCIcons.fontFamily
                        font.pixelSize: VLCStyle.dp(15, VLCStyle.scale)
                        text: VLCIcons.grid
                        color: MainCtx.gridView ? VLCStyle.palette.orange500 : (gridHover.hovered ? VLCStyle.palette.juxtFg1 : VLCStyle.palette.juxtFgA2)
                        Behavior on color { ColorAnimation { duration: VLCStyle.duration_short } }
                    }
                }

                HoverHandler {
                    id: gridHover
                }

                TapHandler {
                    onTapped: MainCtx.gridView = true
                }

                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Grid view")
            }

            Rectangle {
                width: 1
                height: VLCStyle.dp(14, VLCStyle.scale)
                anchors.verticalCenter: parent.verticalCenter
                color: VLCStyle.palette.juxtDividerDim
            }

            Item {
                id: listBtn
                implicitWidth: VLCStyle.dp(28, VLCStyle.scale)
                implicitHeight: VLCStyle.dp(24, VLCStyle.scale)

                Rectangle {
                    anchors.fill: parent
                    radius: VLCStyle.dp(4, VLCStyle.scale)
                    color: !MainCtx.gridView ? VLCStyle.palette.juxtBgPill : (listHover.hovered ? "#222222" : "transparent")
                    Behavior on color { ColorAnimation { duration: VLCStyle.duration_short } }

                    Text {
                        anchors.centerIn: parent
                        font.family: VLCIcons.fontFamily
                        font.pixelSize: VLCStyle.dp(15, VLCStyle.scale)
                        text: VLCIcons.list
                        color: !MainCtx.gridView ? VLCStyle.palette.orange500 : (listHover.hovered ? VLCStyle.palette.juxtFg1 : VLCStyle.palette.juxtFgA2)
                        Behavior on color { ColorAnimation { duration: VLCStyle.duration_short } }
                    }
                }

                HoverHandler {
                    id: listHover
                }

                TapHandler {
                    onTapped: MainCtx.gridView = false
                }

                Accessible.role: Accessible.Button
                Accessible.name: qsTr("List view")
            }
        }
    }

    SortControl {
        id: sortControl

        visible: root.sort.available
        enabled: visible
        height: VLCStyle.dp(28, VLCStyle.scale)
        description: qsTr("Sort")

        model: root.sort.model

        menu: root.sortMenu

        sortKey:  root.sort.criteria
        sortOrder: root.sort.order

        onSortSelected: (key) => {
            root.sort.criteria = key
        }
        onSortOrderSelected: (type) => {
            root.sort.order = type
        }
    }

    SearchBox {
        id: searchBox

        //TODO: initialise visible value with MainCtx
        visible: root.search.available
        height: VLCStyle.dp(28, VLCStyle.scale)
        buttonWidth: VLCStyle.dp(28, VLCStyle.scale)

        Binding {
            target: root.search
            property: "pattern"
            value: searchBox.searchPattern
        }

        Connections {
            target: root.search
            function onAskShow() {
                searchBox.expandAndFocus()
            }
        }
    }
}
