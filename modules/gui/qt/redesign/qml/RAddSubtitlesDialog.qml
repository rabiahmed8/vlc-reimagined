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
import VLC.Player

// "Add Subtitles" (Figma "Add Subtitles to Playlist"): pairs every video of a folder
// with a subtitle file, then plays the folder with those subtitles.
RDialogWindow {
    id: root

    property bool audioMode: false
    readonly property var videoExtensions: ["mp4", "mkv", "avi", "mov", "wmv", "m4v", "webm", "ts", "m2ts", "mpg", "mpeg", "flv", "ogv", "3gp"]
    readonly property var subtitleExtensions: audioMode ? ["mp3", "wav", "flac", "aac", "m4a", "ogg", "opus", "ac3", "dts"] : ["srt", "ass", "ssa", "sub", "vtt", "idx", "smi"]

    property string videoDir: ""          // URL of the folder of the videos
    property string subtitleDir: ""       // URL of the folder of the subtitles
    property var sourceVideos: []
    property var videos: []
    property var subtitles: []
    property var pairs: []                // [{ video, videoName, subtitle, subtitleName }]

    function openForMedia(urls) {
        sourceVideos = urls.map(u => String(u))
        videoDir = sourceVideos.length ? RedesignSettings.directoryOf(sourceVideos[0]) : ""
        subtitleDir = videoDir
        sourceBox.currentIndex = 0
        reload()
        open()
    }

    function openFor(mediaUrl) {
        sourceVideos = []
        videoDir = RedesignSettings.directoryOf(String(mediaUrl || ""))
        subtitleDir = videoDir
        sourceBox.currentIndex = 0
        reload()
        open()
    }

    // "S01E05", "1x05" or the last number of the name: the episode key used for matching
    function episodeKey(name) {
        const n = name.toLowerCase()
        let m = n.match(/s(\d{1,2})[ ._-]*e(\d{1,3})/)
        if (m) return Number(m[1]) + "x" + Number(m[2])
        m = n.match(/(\d{1,2})x(\d{1,3})/)
        if (m) return Number(m[1]) + "x" + Number(m[2])
        m = n.replace(/\.[^.]+$/, "").match(/(\d{1,3})(?!.*\d)/)
        return m ? "e" + Number(m[1]) : ""
    }
    function stem(name) { return name.replace(/\.[^.]+$/, "").toLowerCase() }

    function reload() {
        videos = sourceVideos.length ? sourceVideos.map(url => ({ url: url, name: decodeURIComponent(url.split("/").pop()) }))
                                    : videoDir ? RedesignSettings.listFiles(videoDir, videoExtensions) : []
        subtitles = subtitleDir ? RedesignSettings.listFiles(subtitleDir, subtitleExtensions) : []
        const used = {}
        const out = []
        for (const v of videos) {
            let best = subtitles.find(s => !used[s.url] && stem(s.name).startsWith(stem(v.name)))
            if (!best) {
                const k = episodeKey(v.name)
                if (k)
                    best = subtitles.find(s => !used[s.url] && episodeKey(s.name) === k)
            }
            if (best)
                used[best.url] = true
            out.push({ video: v.url, videoName: v.name, subtitle: best ? best.url : "", subtitleName: best ? best.name : "" })
        }
        pairs = out
    }

    function chooseSubtitle(index) {
        const files = RedesignSettings.browseFiles(root.audioMode ? qsTr("Select an audio file") : qsTr("Select a subtitle file"))
        if (files.length === 0)
            return
        const p = pairs.slice()
        p[index] = Object.assign({}, p[index], { subtitle: files[0], subtitleName: decodeURIComponent(files[0].split("/").pop()) })
        pairs = p
    }

    heading: audioMode ? qsTr("Add Audio Tracks") : qsTr("Add Subtitles")
    acceptText: audioMode ? qsTr("Play with audio tracks") : qsTr("Play with subtitles")
    acceptEnabled: pairs.some(p => p.subtitle.length > 0)
    width: Theme.dp(1048)
    height: Theme.dp(800)
    minimumWidth: Theme.dp(700)
    minimumHeight: Theme.dp(420)
    headerExtraHeight: Theme.dp(50)

    onAccepted: {
        for (const pair of pairs) {
            if (pair.subtitle.length)
                MainCtx.setSettingValue((root.audioMode ? "Redesign/audioPairs/" : "Redesign/subtitlePairs/") + encodeURIComponent(pair.video), pair.subtitle)
        }
        RedesignEffects.enqueueWithSubtitles(root.audioMode ? pairs.map(p => ({ video: p.video, audio: p.subtitle })) : pairs, true)
    }

    headerExtra: [
        Row {
            spacing: Theme.dp(10)
            height: parent ? parent.height : 0

            RDropdown {
                id: sourceBox
                width: Theme.dp(200)
                model: [{ value: "same", text: qsTr("From The Same Folder") },
                        { value: "computer", text: qsTr("From Computer") }]
                Component.onCompleted: currentIndex = 0
                onPicked: (v) => {
                    if (v === "computer") {
                        const d = RedesignSettings.browseDirectory("")
                        if (d.length > 0)
                            root.subtitleDir = "file:///" + d.replace(/\\/g, "/").replace(/^\/+/, "")
                    } else {
                        root.subtitleDir = root.videoDir
                    }
                    root.reload()
                }
            }

            T.AbstractButton {
                id: folderButton
                width: (parent.parent ? parent.parent.width : 600) - sourceBox.width - Theme.dp(10)
                height: Theme.dp(34)
                hoverEnabled: true
                onClicked: {
                    const d = RedesignSettings.browseDirectory("")
                    if (d.length > 0) {
                        root.sourceVideos = []
                        root.videoDir = "file:///" + d.replace(/\\/g, "/").replace(/^\/+/, "")
                        if (sourceBox.currentValue === "same")
                            root.subtitleDir = root.videoDir
                        root.reload()
                    }
                }
                background: Rectangle {
                    radius: Theme.radius
                    color: folderButton.hovered ? Theme.p.bgA1 : Theme.p.bgA3
                }
                contentItem: Item {
                    RIcon { id: folderIcon; x: Theme.dp(8); anchors.verticalCenter: parent.verticalCenter; name: "folder"; size: Theme.iconSizeSmall; color: Theme.textItem }
                    RText {
                        anchors.left: folderIcon.right
                        anchors.leftMargin: Theme.dp(10)
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.videoDir ? decodeURIComponent(root.videoDir.replace("file:///", "")).split("/").join(" / ")
                                            : qsTr("Choose the folder of the videos")
                        color: Theme.textItem
                        elide: Text.ElideLeft
                    }
                }
            }
        }
    ]

    RText {
        anchors.centerIn: parent
        visible: root.pairs.length === 0
        text: root.videoDir ? qsTr("No video in this folder") : qsTr("Choose the folder of the videos above")
        color: Theme.textDim
    }

    ListView {
        anchors.fill: parent
        clip: true
        model: root.pairs
        T.ScrollBar.vertical: RScrollBar { }

        delegate: Item {
            id: row
            required property var modelData
            required property int index
            width: ListView.view.width
            height: Theme.dp(40)

            RIcon { id: vIcon; x: Theme.dp(8); anchors.verticalCenter: parent.verticalCenter; name: "video"; size: Theme.iconSizeSmall; color: Theme.textDim }
            RText {
                id: vName
                anchors.left: vIcon.right
                anchors.leftMargin: Theme.dp(12)
                width: Math.min(implicitWidth, row.width * 0.45 - Theme.dp(40))
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.videoName
                color: Theme.textItem
            }
            // dashed link between the video and its subtitle
            RDashedLine {
                anchors.left: vName.right
                anchors.leftMargin: Theme.dp(12)
                anchors.right: subButton.left
                anchors.rightMargin: Theme.dp(12)
                anchors.verticalCenter: parent.verticalCenter
                height: 1
            }
            T.AbstractButton {
                id: subButton
                x: row.width * 0.5
                width: row.width * 0.5 - Theme.dp(8)
                height: parent.height
                hoverEnabled: true
                onClicked: root.chooseSubtitle(row.index)
                background: Rectangle { radius: Theme.radiusSmall; color: subButton.hovered ? Theme.hover : "transparent" }
                contentItem: Item {
                    RIcon { id: sIcon; x: Theme.dp(6); anchors.verticalCenter: parent.verticalCenter; name: root.audioMode ? "audio" : "subtitle"; size: Theme.iconSizeSmall; color: Theme.textDim }
                    RText {
                        anchors.left: sIcon.right
                        anchors.leftMargin: Theme.dp(12)
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.modelData.subtitleName || (root.audioMode ? qsTr("No audio track, click to choose one") : qsTr("No subtitle, click to choose one"))
                        color: row.modelData.subtitleName ? Theme.textItem : Theme.textDim
                    }
                }
            }
        }
    }
}
