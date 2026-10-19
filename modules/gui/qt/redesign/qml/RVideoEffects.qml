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

// Video effects of the tracks popup (Figma "Video - Essential", "Video - Colors",
// "Video - Crop"): live filters on the playing video, kept for the next media.
Flickable {
    id: root

    function filterOn(m) { return RedesignEffects.videoFilterEnabled(m) }
    function setFilter(m, on) { RedesignEffects.setVideoFilterEnabled(m, on) }

    clip: true
    contentHeight: column.height + Theme.dp(20)
    boundsBehavior: Flickable.StopAtBounds
    T.ScrollBar.vertical: RScrollBar { }

    Column {
        id: column
        x: Theme.dp(16)
        y: Theme.dp(10)
        width: root.width - Theme.dp(32)
        spacing: Theme.dp(10)

        RCollapsible {
            title: qsTr("Picture")
            expanded: true
            checkable: true
            checked: root.filterOn("adjust")
            onToggled: (on) => { root.setFilter("adjust", on); checked = on }

            REffectSlider { label: qsTr("Hue"); option: "hue"; from: -180; to: 180; stepSize: 1; integer: true; unit: "°" }
            REffectSlider { label: qsTr("Brightness"); option: "brightness"; from: 0; to: 2; decimals: 2 }
            REffectSlider { label: qsTr("Contrast"); option: "contrast"; from: 0; to: 2; decimals: 2 }
            REffectSlider { label: qsTr("Saturation"); option: "saturation"; from: 0; to: 3; decimals: 2 }
            REffectSlider { label: qsTr("Gamma"); option: "gamma"; from: 0.01; to: 10; decimals: 2; tickCount: 10 }
            RButton {
                text: qsTr("Reset")
                onClicked: {
                    const d = { hue: 0, brightness: 1, contrast: 1, saturation: 1, gamma: 1 }
                    for (const k in d)
                        RedesignEffects.setVideoValue(k, d[k])
                    for (let i = 0; i < parent.children.length; ++i)
                        if (parent.children[i].reload) parent.children[i].reload()
                }
            }
        }

        RCollapsible {
            title: qsTr("Sharpen")
            checkable: true
            checked: root.filterOn("sharpen")
            onToggled: (on) => { root.setFilter("sharpen", on); checked = on }
            REffectSlider { label: qsTr("Sharpen sigma"); option: "sharpen-sigma"; from: 0; to: 2; decimals: 2; tickCount: 4 }
        }

        RCollapsible {
            title: qsTr("Banding removal")
            checkable: true
            checked: root.filterOn("gradfun")
            onToggled: (on) => { root.setFilter("gradfun", on); checked = on }
            REffectSlider { label: qsTr("Radius"); option: "gradfun-radius"; from: 4; to: 32; stepSize: 1; integer: true; tickCount: 7 }
        }

        RCollapsible {
            title: qsTr("Film grain")
            checkable: true
            checked: root.filterOn("grain")
            onToggled: (on) => { root.setFilter("grain", on); checked = on }
            REffectSlider { label: qsTr("Variance"); option: "grain-variance"; from: 0; to: 10; decimals: 1; tickCount: 10 }
        }

        RCollapsible {
            title: qsTr("Colors")

            RFilterSwitch { label: qsTr("Negate colors"); module: "invert" }
            RFilterSwitch { label: qsTr("Posterize"); module: "posterize" }
            RFilterSwitch { id: sepia; label: qsTr("Sepia"); module: "sepia" }
            REffectSlider { visible: sepia.checked; label: qsTr("Sepia intensity"); option: "sepia-intensity"; from: 0; to: 255; stepSize: 1; integer: true }
            RFilterSwitch { id: gradient; label: qsTr("Gradient"); module: "gradient" }
            RFilterSwitch { visible: gradient.checked; label: qsTr("Cartoon"); option: "gradient-cartoon" }
            RFilterSwitch { id: threshold; label: qsTr("Color threshold"); module: "colorthres" }
            REffectSlider { visible: threshold.checked; label: qsTr("Saturation"); option: "colorthres-saturationthres"; from: 0; to: 255; stepSize: 1; integer: true }
            REffectSlider { visible: threshold.checked; label: qsTr("Similarity"); option: "colorthres-similaritythres"; from: 0; to: 255; stepSize: 1; integer: true }
            RFilterSwitch { label: qsTr("Color extraction"); module: "extract" }
        }

        RCollapsible {
            title: qsTr("Geometry")

            RFilterSwitch { id: transform; label: qsTr("Rotate / flip"); module: "transform" }
            RDropdown {
                visible: transform.checked
                width: parent.width
                model: [{ value: "90", text: qsTr("Rotate 90°") }, { value: "180", text: qsTr("Rotate 180°") },
                        { value: "270", text: qsTr("Rotate 270°") }, { value: "hflip", text: qsTr("Flip horizontally") },
                        { value: "vflip", text: qsTr("Flip vertically") }, { value: "transpose", text: qsTr("Transpose") },
                        { value: "antitranspose", text: qsTr("Anti-transpose") }]
                Component.onCompleted: selectValue(RedesignEffects.videoValue("transform-type"))
                onPicked: (v) => RedesignEffects.setVideoValue("transform-type", v)
            }
            RFilterSwitch { label: qsTr("Mirror"); module: "mirror" }
            RFilterSwitch { label: qsTr("Wave"); module: "wave" }
            RFilterSwitch { label: qsTr("Motion blur"); module: "motionblur" }
        }

        RCollapsible {
            title: qsTr("Crop")
            RCropEditor { width: parent.width }
        }

        // Figma "HDR Options": VLC only has the Direct3D11 output mode (Windows),
        // it applies when the next video starts
        RCollapsible {
            id: hdr
            property var opt: RedesignSettings.option("d3d11-hdr-mode")
            visible: opt.exists === true
            title: qsTr("HDR")

            RDropdown {
                width: parent.width
                model: hdr.opt.choices || []
                Component.onCompleted: selectValue(hdr.opt.value)
                onPicked: (v) => RedesignSettings.setValue("d3d11-hdr-mode", v)
            }
            RText {
                width: parent.width
                wrapMode: Text.WordWrap
                text: qsTr("Applies to the next video.")
                color: Theme.textDim
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}
