//
//  PenSettingsUI.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/24/22.
//

import SwiftUI

fileprivate let sunIcon = "sun.min"
fileprivate let moonIcon = "moon"
fileprivate let templateColorIcon = "paintpalette"

@ViewBuilder fileprivate func topLevelSection<V: View>(title: String, @ViewBuilder _ content: @escaping () -> V) -> some View {
    Section(
        header: Text(title).font(.headline),
        content: content
    )
}
@ViewBuilder fileprivate func section<V: View>(title: String, @ViewBuilder _ content: @escaping () -> V) -> some View {
    Section(
        header: Text(title).font(.subheadline),
        content: content
    )
}
@ViewBuilder fileprivate func resettable<T, V: View>(
    _ value: Binding<T>,
    defaultValue: Binding<T>,
    @ViewBuilder _ view: @escaping () -> V
) -> some View {
    HStack(alignment: .center, spacing: 10) {
        view()
        Spacer()
        UI.Btn.Rounded(action: {value.wrappedValue = defaultValue.wrappedValue}) {
            Text("Reset")
        }
    }
}
@ViewBuilder fileprivate func resettable<V: View>(
    onReset: @escaping () -> (),
    @ViewBuilder _ view: @escaping () -> V
) -> some View {
    HStack(alignment: .center, spacing: 10) {
        view()
        Spacer()
        UI.Btn.Rounded(action: onReset) {
            Text("Reset")
        }
    }
}
/// Simple hack so non-resettable controls with align with resettable controls.
@ViewBuilder fileprivate func notResettable<V: View>(
    @ViewBuilder _ view: @escaping () -> V
) -> some View {
    HStack(alignment: .center, spacing: 10) {
        view()
        Spacer()
        UI.Btn.Rounded(action: {}) {
            Text("Reset")
        }.hidden()
    }
}
@ViewBuilder fileprivate func sliderControl(
    title: String,
    value: Binding<CGFloat>,
    range: ClosedRange<CGFloat>
) -> some View {
    Slider(
        value: value,
        in: range,
        label: {
            Text(title)
        }
    )
    Text("\(value.wrappedValue)")
}
@ViewBuilder fileprivate func resettableSliderControl(
    title: String,
    value: Binding<CGFloat>,
    defaultValue: Binding<CGFloat>,
    range: ClosedRange<CGFloat>
) -> some View {
    VStack(alignment: .center, spacing: 10) {
        ZStack {
            HStack(alignment: .center, spacing: 0) {
                Text(title)
                Spacer()
            }
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                Text("\(value.wrappedValue)")
                Spacer()
            }
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                UI.Btn.Rounded(action: {value.wrappedValue = defaultValue.wrappedValue}) {
                    Text("Reset")
                }
            }
        }
        Slider(
            value: value,
            in: range
        )
    }
}
@ViewBuilder fileprivate func toggleControl(
    title: String,
    value: Binding<Bool>
) -> some View {
    HStack(alignment: .center, spacing: 10) {
        Toggle(title, isOn: value)
    }
}
@ViewBuilder fileprivate func colorPickerControl(
    icon: String,
    title: String,
    color: Binding<CGColor>
) -> some View {
    HStack(alignment: .center, spacing: 10) {
        Image(systemName: icon)
        Text(title)
        Spacer()
        ColorPicker(
            "Color Picker",
            selection: color,
            supportsOpacity: true
        )
            .labelsHidden()
    }
}
@ViewBuilder fileprivate func enumPicker<T>(
    title: String,
    value: Binding<T>
) -> some View where T: CaseIterable, T: Hashable {
    let allCases = Array(T.allCases)
    let pickerView = Picker(
        selection: value,
        content: {
            ForEach(Array(allCases.enumerated()), id: \.1.hashValue, content: { (ix, t) in
                let typeName = String(reflecting: t)
                    .stripPrefix(String(reflecting: T.self))
                    .stripPrefix(".")
                    .capitalized
                Text(typeName).tag(t)
            })
        },
        label: {
            Text(title)
        }
    )
    if allCases.count < 5 {
        pickerView.pickerStyle(SegmentedPickerStyle())
    } else {
        pickerView
    }
}
@ViewBuilder fileprivate func strokeCapSection(
    title: String,
    cap: Binding<Bool>,
    taper: Binding<CGFloat>,
    easing: Binding<SS1.PenModel.DynamicPenStyle.Easing>
) -> some View {
    section(title: title) {
        resettable(cap, defaultValue: Binding.constant(true)) {
            toggleControl(title: "Show Cap", value: cap)
        }
        resettable(easing, defaultValue: Binding.constant(SS1.PenModel.DynamicPenStyle.Easing.linear)) {
            enumPicker(title: "Cap Easing", value: easing)
        }
    }
}

extension SS1.ToolBarView {
    struct PenSettingsFormInline: View {
        @ObservedObject var toolbarModel: SS1.ToolBarModel
        @Binding var pen: SS1.PenModel
        let onDismiss: () -> ()
        fileprivate typealias HSBA = SS1.PenModel.HSBA
        @ViewBuilder private var colorSection: some View {
            let baseColor = $pen.templateColor.asCGColor
            let lightUIColor = $pen.dynamicPenStyle.color.lightUI.asCGColor
            let darkUIColor = $pen.dynamicPenStyle.color.darkUI.asCGColor
            toggleControl(title: "Use Template Color", value: $pen.useTemplateColor)
            toggleControl(title: "Show HSLA Controls (Under Development)", value: $toolbarModel.showHSLAColorPicker)
            if pen.useTemplateColor {
                notResettable {
                    colorPickerControl(icon: templateColorIcon, title: "Base Color", color: baseColor)
                }
                if toolbarModel.showHSLAColorPicker {
                    SS1.HSBAColorSlider.ColorPreview(color: $pen.templateColor)
                    Text("Hue")
                    SS1.HSBAColorSlider.HueColorSlider(color: $pen.templateColor)
                    Text("Saturation")
                    SS1.HSBAColorSlider.SaturationColorSlider(color: $pen.templateColor)
                    Text("Brightness")
                    SS1.HSBAColorSlider.BrightnessColorSlider(color: $pen.templateColor)
                    Text("Alpha")
                    SS1.HSBAColorSlider.AlphaColorSlider(color: $pen.templateColor)
                }
            }
            section(title: pen.useTemplateColor ? "Derived Light & Dark UI Colors" : "Light & Dark UI Colors") {
                let resetLightUIColor = {
                    pen.dynamicPenStyle.color.lightUI = pen.useTemplateColor ? pen.templateColor : HSBA.black
                }
                let resetDarkUIColor = {
                    pen.dynamicPenStyle.color.darkUI = pen.useTemplateColor ? pen.templateColor : HSBA.white
                }
                resettable(onReset: resetLightUIColor) {
                    colorPickerControl(icon: sunIcon, title: "Light UI Mode", color: lightUIColor)
                }
                if toolbarModel.showHSLAColorPicker {
                    SS1.HSBAColorSlider.ColorPreview(color: $pen.dynamicPenStyle.color.lightUI)
                    Text("Hue")
                    SS1.HSBAColorSlider.HueColorSlider(color: $pen.dynamicPenStyle.color.lightUI)
                    Text("Saturation")
                    SS1.HSBAColorSlider.SaturationColorSlider(color: $pen.dynamicPenStyle.color.lightUI)
                    Text("Brightness")
                    SS1.HSBAColorSlider.BrightnessColorSlider(color: $pen.dynamicPenStyle.color.lightUI)
                    Text("Alpha")
                    SS1.HSBAColorSlider.AlphaColorSlider(color: $pen.dynamicPenStyle.color.lightUI)
                }
                resettable(onReset: resetDarkUIColor) {
                    colorPickerControl(icon: moonIcon, title: "Dark UI Mode", color: darkUIColor)
                }
                if toolbarModel.showHSLAColorPicker {
                    SS1.HSBAColorSlider.ColorPreview(color: $pen.dynamicPenStyle.color.darkUI)
                    Text("Hue")
                    SS1.HSBAColorSlider.HueColorSlider(color: $pen.dynamicPenStyle.color.darkUI)
                    Text("Saturation")
                    SS1.HSBAColorSlider.SaturationColorSlider(color: $pen.dynamicPenStyle.color.darkUI)
                    Text("Brightness")
                    SS1.HSBAColorSlider.BrightnessColorSlider(color: $pen.dynamicPenStyle.color.darkUI)
                    Text("Alpha")
                    SS1.HSBAColorSlider.AlphaColorSlider(color: $pen.dynamicPenStyle.color.darkUI)
                }
            }
        }
        @ViewBuilder private var penSetSection: some View {
            let title = "Pen Set"
            let value = $pen.penSet
            resettable(value, defaultValue: Binding.constant(SS1.PenModel.PenSet.set1)) {
                enumPicker(title: title, value: value)
            }
        }
        @ViewBuilder private var layerSection: some View {
            let title = "Layer"
            let value = $pen.dynamicPenStyle.layer
            resettable(value, defaultValue: Binding.constant(SS1.PenModel.DynamicPenStyle.Layer.foreground)) {
                enumPicker(title: title, value: value)
            }
        }
        @ViewBuilder private var sizeSection: some View {
            let title = "Stroke Diameter"
            let value = $pen.dynamicPenStyle.size
            let defaultValue = Binding.constant(SS1.PenModel.DynamicPenStyle.defaultSize)
            let range = SS1.PenModel.DynamicPenStyle.sizeRange
            resettableSliderControl(
                title: title,
                value: value,
                defaultValue: defaultValue,
                range: range
            )
        }
        @ViewBuilder private var thinningSection: some View {
            let title = "Thinning"
            let value = $pen.dynamicPenStyle.thinning
            let defaultValue = Binding.constant(SS1.PenModel.DynamicPenStyle.defaultThinning)
            let range = SS1.PenModel.DynamicPenStyle.thinningRange
            resettableSliderControl(
                title: title,
                value: value,
                defaultValue: defaultValue,
                range: range
            )
        }
        @ViewBuilder private var smoothingSection: some View {
            let title = "Smoothing"
            let value = $pen.dynamicPenStyle.smoothing
            let defaultValue = Binding.constant(SS1.PenModel.DynamicPenStyle.defaultSmoothing)
            let range = SS1.PenModel.DynamicPenStyle.smoothingRange
            resettableSliderControl(
                title: title,
                value: value,
                defaultValue: defaultValue,
                range: range
            )
        }
        @ViewBuilder private var streamlineSection: some View {
            let title = "Streamline"
            let value = $pen.dynamicPenStyle.streamline
            let defaultValue = Binding.constant(SS1.PenModel.DynamicPenStyle.defaultStreamline)
            let range = SS1.PenModel.DynamicPenStyle.streamlineRange
            resettableSliderControl(
                title: title,
                value: value,
                defaultValue: defaultValue,
                range: range
            )
        }
        @ViewBuilder private var easingSection: some View {
            let title = "Easing"
            let value = $pen.dynamicPenStyle.easing
            resettable(value, defaultValue: Binding.constant(SS1.PenModel.DynamicPenStyle.defaultEasing)) {
                enumPicker(title: title, value: value)
            }
        }
        @ViewBuilder private var simulatePressureSection: some View {
            let title = "Simulate Pressure"
            let value = $pen.dynamicPenStyle.simulatePressure
            resettable(value, defaultValue: Binding.constant(true)) {
                toggleControl(title: title, value: value)
            }
        }
        @ViewBuilder private var startSection: some View {
            strokeCapSection(
                title: "Stroke Start Cap",
                cap: $pen.dynamicPenStyle.start.cap,
                taper: $pen.dynamicPenStyle.start.taper,
                easing: $pen.dynamicPenStyle.start.easing
            )
        }
        @ViewBuilder private var endSection: some View {
            strokeCapSection(
                title: "Stroke End Cap",
                cap: $pen.dynamicPenStyle.end.cap,
                taper: $pen.dynamicPenStyle.end.taper,
                easing: $pen.dynamicPenStyle.end.easing
            )
        }
        @ViewBuilder private var platformSpecificDivider: some View {
#if os(iOS)
            EmptyView()
#elseif os(macOS)
            Divider()
#endif
        }
        @Environment(\.presentationMode) private var presentationMode
        var body: some View {
            Form {
                topLevelSection(title: "Toolbar UI") {
                    penSetSection
                }
                topLevelSection(title: "Canvas Placement") {
                    layerSection
                }
                platformSpecificDivider
                topLevelSection(title: "Stroke Coloring") {
                    colorSection
                }
                platformSpecificDivider
                topLevelSection(title: "Shaping Paramaters") {
                    Group {
                        sizeSection
                        thinningSection
                        smoothingSection
                        streamlineSection
                        easingSection
                        simulatePressureSection
                    }
                    platformSpecificDivider
                    startSection
                    platformSpecificDivider
                    endSection
                }
            }
            .onDisappear(perform: {
                self.onDismiss()
            })
        }
    }
    struct PenSettingsForm: View {
        @ObservedObject var toolbarModel: SS1.ToolBarModel
        @Binding var pen: SS1.PenModel
        
        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                PenSettingsFormInline(toolbarModel: toolbarModel, pen: $pen, onDismiss: {})
            }
        }
    }
}

