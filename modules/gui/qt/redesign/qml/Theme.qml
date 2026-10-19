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
pragma Singleton

import QtQuick

import VLC.MainInterface

// Design tokens of the redesigned interface.
// Names follow the Figma variables ("Dark/BG/A3", "Dark/FG/A2", ...).
QtObject {
    id: theme

    // "dark", "light" or "system" (Settings > General > Theme), kept in the Qt settings
    property string mode: MainCtx.settingValue("Redesign/theme", "dark")
    property bool dark: mode === "system" ? Qt.styleHints.colorScheme !== Qt.Light : mode !== "light"

    // User configurable accent (Settings > General > Accent color), "" = default orange
    property string accentSetting: MainCtx.settingValue("Redesign/accent", "")
    property color accentOverride: accentSetting.length > 0 ? accentSetting : "transparent"

    function setMode(m) {
        mode = m
        MainCtx.setSettingValue("Redesign/theme", m)
    }
    function setAccent(c) {
        accentSetting = c
        MainCtx.setSettingValue("Redesign/accent", c)
    }

    // accent tints derived from the user accent (the palette ones match the default orange)
    readonly property color accentTrack: accentOverride.a > 0
        ? Qt.rgba(accentOverride.r, accentOverride.g, accentOverride.b, dark ? 0.25 : 0.35)
        : p.bgAccentBright

    readonly property QtObject darkPalette: QtObject {
        readonly property color bgA1: "#222222"
        readonly property color bgA3: "#1B1B1B"
        readonly property color bgA3Transparent: "#191919"
        readonly property color bgA4: "#191919"
        readonly property color bgA5: "#151515"
        readonly property color bgB1Transparent: "#0E0E0E"
        readonly property color bgB2: "#090909"
        readonly property color bgAccentBright: "#371F06"
        readonly property color fg1: "#EAEAEA"
        readonly property color fg2: "#C6C6C6"
        readonly property color fgA1: "#969696"
        readonly property color fgA2: "#8F8F8F"
        readonly property color fgA3: "#6B6B6B"
        readonly property color fgA4: "#404040"
        readonly property color fgB1: "#161616"
        readonly property color accent: "#D37918"
        readonly property color accentDim: "#AB6314"
        readonly property color logo: "#D37918"
        readonly property color dividerBright: "#373737"
        readonly property color dividerDim: "#222222"
        readonly property color videoBackground: "#2B2A28"
    }

    readonly property QtObject lightPalette: QtObject {
        readonly property color bgA1: "#C9C9C9"
        readonly property color bgA3: "#D5D5D5"
        readonly property color bgA3Transparent: "#D5D5D5"
        readonly property color bgA4: "#D9D9D9"
        readonly property color bgA5: "#888888"
        readonly property color bgB1Transparent: "#E7E7E7"
        readonly property color bgB2: "#DEDEDE"
        readonly property color bgAccentBright: "#D8BA9A"
        readonly property color fg1: "#111111"
        readonly property color fg2: "#1F1F1F"
        readonly property color fgA1: "#2B2B2B"
        readonly property color fgA2: "#2E2E2E"
        readonly property color fgA3: "#6B6B6B"
        readonly property color fgA4: "#9B9B9B"
        readonly property color fgB1: "#F2F2F2"
        readonly property color accent: "#E8851A"
        readonly property color accentDim: "#C2711A"
        readonly property color logo: "#C2711A"
        readonly property color dividerBright: "#9B9B9B"
        readonly property color dividerDim: "#ACACAC"
        readonly property color videoBackground: "#BDBDBD"
    }

    readonly property QtObject p: dark ? darkPalette : lightPalette

    // Semantic aliases used throughout the UI
    readonly property color accent: accentOverride.a > 0 ? accentOverride : p.accent
    readonly property color barBackground: p.bgA3
    readonly property color panelBackground: Qt.rgba(p.bgB1Transparent.r, p.bgB1Transparent.g, p.bgB1Transparent.b, 0.95)
    readonly property color railBackground: p.bgA4
    readonly property color trackBackground: p.bgB2
    readonly property color trackFill: accentTrack
    readonly property color text: p.fgA2
    readonly property color textStrong: p.fg1
    readonly property color textItem: p.fgA1
    readonly property color textDim: p.fgA3
    readonly property color iconDisabled: p.fgA4
    readonly property color iconOnAccent: p.fgB1
    readonly property color hover: Qt.rgba(1, 1, 1, dark ? 0.06 : 0.10)
    readonly property color pressed: Qt.rgba(1, 1, 1, dark ? 0.10 : 0.16)

    // Metrics (in px at 1x, multiplied by the interface scale factor)
    property real scale: 1.0
    function dp(v) { return Math.round(v * scale) }

    readonly property int topBarHeight: dp(40)
    readonly property int controlBarHeight: dp(54)
    readonly property int controlHeight: dp(28)
    readonly property int iconSize: dp(24)
    readonly property int iconSizeSmall: dp(20)
    readonly property int railWidth: dp(50)
    readonly property int sidePanelWidth: dp(377)
    readonly property int popupWidth: dp(400)
    readonly property int radiusSmall: dp(4)
    readonly property int radius: dp(6)
    readonly property int radiusLarge: dp(10)
    readonly property int videoFrameRadius: dp(19)
    readonly property int margin: dp(20)
    readonly property int spacing: dp(8)

    readonly property string fontFamily: "Inter"
    readonly property int fontSizeSmall: dp(12)
    readonly property int fontSize: dp(14)
    readonly property int fontSizeTime: dp(15)
    readonly property int fontSizeLarge: dp(16)

    readonly property int durationShort: 100
    readonly property int durationNormal: 200

    function icon(name) {
        return "qrc:///redesign/icons/" + name + ".svg"
    }
}
