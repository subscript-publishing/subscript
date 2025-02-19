//
//  Toolbar.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/19/22.
//

import Foundation
import SwiftUI
import Combine

//
fileprivate let DARK_TOOLBAR_FOREGROUND_COLOR: UI.LL.Color = #colorLiteral(red: 0.1744112816, green: 0.197636486, blue: 0.2650109351, alpha: 1)
fileprivate let LIGHT_TOOLBAR_FOREGROUND_COLOR: UI.LL.Color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

fileprivate let iconColor: Color = Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
fileprivate let disabledIconColor: Color = Color(#colorLiteral(red: 0.5570612527, green: 0.633860792, blue: 0.6627638421, alpha: 1))
fileprivate let textColor: Color = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
fileprivate let borderColor: Color = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
fileprivate let buttonBgColor: Color = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))

fileprivate enum LayerViewToggle {
    case foreground
    case background
    case both
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

@ViewBuilder fileprivate func sliderControl(
    title: String,
    value: Binding<CGFloat>,
    range: ClosedRange<CGFloat>,
    onChange: @escaping (Bool) -> ()
) -> some View {
    Slider(
        value: value,
        in: range,
        label: {
            Text(title)
        },
        onEditingChanged: onChange
    )
    VStack(alignment: .center, spacing: 0) {
        Text("\(value.wrappedValue)")
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

struct EditToolSettingView: View {
    @Binding var settingsModel: SS1.ToolBarModel.EditToolSettings
    let onSync: () -> ()
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Form {
                enumPicker(title: "Active Layer", value: $settingsModel.selectionLayer)
            }
            .onChange(of: settingsModel.selectionLayer, perform: {_ in
                onSync()
            })
        }
        .frame(minWidth: 400, minHeight: 100)
    }
}


fileprivate struct EraserTool: View {
    @ObservedObject var toolbarModel: SS1.ToolBarModel
    
    @State private var showPopup: Bool = false
    
    private var isActive: Bool {
        self.toolbarModel.currentToolType.isEraser
    }
    
    private func activateEraserTool() {
        toolbarModel.currentToolType = SS1.ToolBarModel.CurrentToolType.eraser
        for (ix, _) in toolbarModel.pens.enumerated() {
            if toolbarModel.pens[ix].active {
                toolbarModel.pens[ix].active = false
            }
        }
        toolbar_set_current_tool_to_eraser(self.toolbarModel.eraserSettings.toCFFI)
//        ss1_toolbar_runtime_set_active_tool_to_eraser(
//            self.toolbarModel.eraserSettings.asCDataType
//        )
    }
    
    private func onClick() {
        if self.isActive {
            self.showPopup = true
        } else {
            self.activateEraserTool()
        }
    }
    
    @ViewBuilder private func popupView() -> some View  {
        EditToolSettingView(
            settingsModel: $toolbarModel.eraserSettings,
            onSync: {
                toolbar_set_current_tool_to_eraser(self.toolbarModel.eraserSettings.toCFFI)
            }
        )
    }
    @ViewBuilder private var label: some View {
        let fg = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        ZStack(alignment: Alignment.top) {
            BackgroundGraphic(active: isActive)
                .scale(1.0)
                .foregroundColor(Color(fg))
            TopGraphic(active: isActive)
                .scale(0.95)
                .fill(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)),
                                Color(#colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)),
                            ]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            BottomGraphic(active: isActive)
                .scale(0.95)
                .fill(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color(#colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)),
                                Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .offset(x: 0, y: self.isActive ? 10 : 0)
        .foregroundColor(Color.clear)
    }
    
    var body: some View {
        Button(
            action: self.onClick,
            label: {
                if toolbarModel.eraserSettings.selectionLayer == .background {
                    label.rotationEffect(Angle.degrees(180))
                } else {
                    label
                }
            }
        )
            .sheet(isPresented: $showPopup, content: popupView)
    }
    private struct BackgroundGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.62))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.62))
            path.closeSubpath()
            return path
        }
    }
    private struct TopGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.4))
            path.closeSubpath()
            return path
        }
    }
    private struct BottomGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.6))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.6))
            path.closeSubpath()
            return path
        }
    }
}
fileprivate struct SelectionTool: View {
    @ObservedObject var toolbarModel: SS1.ToolBarModel
    @State private var showPopup: Bool = false
    
    private var isActive: Bool {
        self.toolbarModel.currentToolType.isSelection
    }
    
    private func activateSelectionTool() {
        self.toolbarModel.currentToolType = SS1.ToolBarModel.CurrentToolType.selection
        for (ix, _) in self.toolbarModel.pens.enumerated() {
            if toolbarModel.pens[ix].active {
                toolbarModel.pens[ix].active = false
            }
        }
        toolbar_set_current_tool_to_transform(self.toolbarModel.lassoSettings.toCFFI)
    }
    
    private func onClick() {
        if self.isActive {
            self.showPopup = true
        } else {
            self.activateSelectionTool()
        }
    }
    
    @ViewBuilder private func popupView() -> some View {
        EditToolSettingView(
            settingsModel: $toolbarModel.lassoSettings,
            onSync: {
                toolbar_set_current_tool_to_transform(self.toolbarModel.lassoSettings.toCFFI)
            }
        )
    }
    
    @ViewBuilder private var label: some View {
        ZStack(alignment: Alignment.top) {
            BackgroundGraphic(active: isActive)
                .scale(1.0)
                .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
            TopGraphic(active: isActive)
                .scale(0.95)
                .fill(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)),
                                Color(#colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)),
                            ]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            BottomGraphic(active: isActive)
                .scale(0.95)
                .fill(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color(#colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)),
                                Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .offset(x: 0, y: self.isActive ? 8 : 0)
        .foregroundColor(Color.clear)
    }
    
    var body: some View {
        Button(
            action: self.onClick,
            label: {
                if toolbarModel.lassoSettings.selectionLayer == .background {
                    label.rotationEffect(Angle.degrees(180))
                } else {
                    label
                }
            }
        )
            .sheet(isPresented: $showPopup, content: popupView)
    }
    private struct BackgroundGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.42))
            path.addLine(to: CGPoint(x: rect.maxX / 2, y: rect.maxY * 0.752))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.42))
            path.closeSubpath()
            return path
        }
    }
    private struct TopGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.4))
            path.closeSubpath()
            return path
        }
    }
    private struct BottomGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: rect.maxX / 2, y: rect.maxY * 0.75))
//            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.6))
            path.closeSubpath()
            return path
        }
    }
}

fileprivate struct PenView: View {
    let width: CGFloat
    @ObservedObject var toolbarModel: SS1.ToolBarModel
    @Binding var pen: SS1.PenModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showPopUp: Bool = false
    @State private var penStateCopy: SS1.PenModel = SS1.PenModel()
    
    private func activatePen() {
        self.toolbarModel.currentToolType = SS1.ToolBarModel.CurrentToolType.pen
        let newPenID = pen.id
        for (ix, _) in self.toolbarModel.pens.enumerated() {
            if self.toolbarModel.pens[ix].active && self.toolbarModel.pens[ix].id != newPenID {
                self.toolbarModel.pens[ix].active = false
            }
            if self.toolbarModel.pens[ix].id == newPenID {
                self.toolbarModel.pens[ix].active = true
                self.toolbarModel.pens[ix].setToCurrentPen()
            }
        }
    }
    @ViewBuilder private func penPopup() -> some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                Spacer()
                UI.Btn.Rounded(action: {
                    showPopUp = false
                }) {
                    Text("Close")
                }
            }
            .padding(10)
            .border(edges: .bottom)
            SS1.ToolBarView.PenSettingsFormInline(
                toolbarModel: toolbarModel,
                pen: $penStateCopy,
                onDismiss: {
                    self.pen = self.penStateCopy
                }
            )
        }
        .frame(minWidth: 400, minHeight: 600)
    }
//    @Environment(\.presentationMode) private var presentationMode
    var body: some View {
        Button(action: onClick, label: self.label)
//            .popover(isPresented: $showPopUp, content: penPopup)
            .sheet(isPresented: $showPopUp, content: penPopup)
    }
    
    private func onClick() {
        if pen.active {
            self.penStateCopy = self.pen
            showPopUp = true
        } else {
            activatePen()
        }
    }
    
    @ViewBuilder private func label() -> some View {
        GeometryReader { geo in
            let graphic = ZStack(alignment: Alignment.top) {
                let backColor: UI.LL.Color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                let frontColor: UI.LL.Color = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                let invertToggle = toolbarModel.invertPenColors
                let penColor = pen.dynamicPenStyle.color.get(for: colorScheme, withInvert: invertToggle).asColor
                Top(active: pen.active)
                    .foregroundColor(Color(backColor))
                Top(active: pen.active)
                    .scale(0.95)
                    .foregroundColor(Color(frontColor))
                Top(active: pen.active)
                    .scale(0.90)
                    .offset(y: -2.0)
                    .foregroundColor(penColor)
                Bottom(active: pen.active)
                    .foregroundColor(Color(backColor))
                Bottom(active: pen.active)
                    .scale(0.95)
                    .foregroundColor(Color(frontColor))
                Bottom(active: pen.active)
                    .scale(0.9)
                    .offset(y: -1.0)
                    .foregroundColor(penColor)
            }
            if self.pen.active {
                graphic.offset(x: 0, y: 6.0)
            } else {
                graphic.offset(x: 0, y: -2.0)
            }
        }
    }
    
    private struct Top: Shape {
        let active: Bool
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -8.0))
            path.addLine(to: CGPoint(x: rect.maxX, y: -8.0))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.2))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.2))
            path.closeSubpath()
            return path
        }
    }
    
    private struct Bottom: Shape {
        let active: Bool
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: rect.maxY * 0.2))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.2))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX / 2, y: rect.maxY * 0.8),
                control: CGPoint(x: rect.maxX, y: rect.maxY / 2)
            )
            path.addQuadCurve(
                to: CGPoint(x: 0, y: rect.maxY * 0.2),
                control: CGPoint(x: 0, y: rect.maxY / 2)
            )
            path.closeSubpath()
            return path
        }
    }
    
    private struct Background: Shape {
        let active: Bool
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -8.0))
            path.addLine(to: CGPoint(x: rect.maxX, y: -8.0))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.21))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX / 2, y: rect.maxY * 0.8),
                control: CGPoint(x: rect.maxX, y: rect.maxY / 2)
            )
            path.addQuadCurve(
                to: CGPoint(x: 0, y: rect.maxY * 0.21),
                control: CGPoint(x: 0, y: rect.maxY / 2)
            )
            path.closeSubpath()
            return path
        }
    }
}

extension SS1 {
    struct ToolBarView: View {
        @ObservedObject var toolbarModel: ToolBarModel
        @Binding var showPenListEditor: Bool
        let toggleColorScheme: () -> ()
        let goBack: () -> ()
        let onSave: () -> ()
        
        
        @Environment(\.colorScheme) private var colorScheme
        @State private var layerViewToggle: LayerViewToggle = .both
        @State private var penSetViewToggle = SS1.PenModel.PenSet.set1
        
        var body: some View {
            HStack(alignment: .center, spacing: 10) {
                Group {
                    Button(action: goBack, label: {Image(systemName: "chevron.left")})
                        .buttonStyle(RoundedButtonStyle())
                    SelectionTool(toolbarModel: self.toolbarModel)
                        .frame(width: 30, alignment: .center)
                    EraserTool(toolbarModel: self.toolbarModel)
                        .frame(width: 30, alignment: .center)
                    Button(
                        action: {
                            switch self.layerViewToggle {
                            case .both: self.layerViewToggle = .foreground
                            case .foreground: self.layerViewToggle = .background
                            case .background: self.layerViewToggle = .both
                            }
                        },
                        label: {
    #if os(iOS) && !targetEnvironment(macCatalyst)
                            let foreground = "square.2.stack.3d.top.filled"
                            let background = "square.2.stack.3d.bottom.filled"
                            let both = "square.3.layers.3d.down.right"
    #else
                            let foreground = "arrowtriangle.up"
                            let background = "arrowtriangle.down"
                            let both = "chevron.up.chevron.down"
    #endif
                            switch self.layerViewToggle {
                            case .foreground: Image(systemName: foreground)
                            case .background: Image(systemName: background)
                            case .both: Image(systemName: both)
                            }
                        }
                    )
                        .buttonStyle(RoundedButtonStyle())
                    Button(
                        action: {
                            switch self.penSetViewToggle {
                            case .set1: self.penSetViewToggle = SS1.PenModel.PenSet.set2
                            case .set2: self.penSetViewToggle = SS1.PenModel.PenSet.set3
                            case .set3: self.penSetViewToggle = SS1.PenModel.PenSet.set4
                            case .set4: self.penSetViewToggle = SS1.PenModel.PenSet.set1
                            }
                        },
                        label: {
                            switch self.penSetViewToggle {
                            case .set1: Text("{1}")
                            case .set2: Text("{2}")
                            case .set3: Text("{3}")
                            case .set4: Text("{4}")
                            }
                        }
                    )
                        .buttonStyle(RoundedButtonStyle(useMonospacedFont: true))
                }
                pensListMenu.border(edges: [.leading, .trailing])
                Group {
                    Button(action: {showPenListEditor = true}, label: {Image(systemName: "scribble.variable")})
                        .buttonStyle(RoundedButtonStyle())
                    Button(
                        action: {
                            toolbarModel.invertPenColors.toggle()
                        },
                        label: {
                            Text("𝑓⁻¹")
                        }
                    )
                        .buttonStyle(RoundedButtonStyle(
                            useMonospacedFont: false,
                            useDangerousColor: toolbarModel.invertPenColors
                        ))
                    Button(
                        action: toggleColorScheme,
                        label: {
                            let darkIcon = Image(systemName: "moon")
                            let lightIcon = Image(systemName: "sun.min")
                            colorScheme == .dark ? darkIcon : lightIcon
                        }
                    )
                        .buttonStyle(RoundedButtonStyle())
                    Button(
                        action: onSave,
                        label: {
                            Text("Save")
                        }
                    )
                        
                }
            }
            .padding([.leading, .trailing], 10)
            .background(Color(colorScheme == .dark ? DARK_TOOLBAR_FOREGROUND_COLOR : LIGHT_TOOLBAR_FOREGROUND_COLOR))
//            .border(width: 0.5, edges: [.bottom, .top])
            .clipped()
            .buttonStyle(PlainButtonStyle())
        }
        private func getPenSize(_ pen: SS1.PenModel) -> CGFloat {
            var sizes: Array<CGFloat> = []
            for pen in toolbarModel.pens {
                if pen.penSet == penSetViewToggle {
                    sizes.append(pen.dynamicPenStyle.size)
                }
            }
            let min: CGFloat = sizes.min()!
            let max: CGFloat = sizes.max()!
            let delta = max - min
            let outputMin: CGFloat = 25
            let outputMax: CGFloat = delta >= 10 ? 60 : 45
            let xScale: (CGFloat) -> CGFloat = MathUtils.newLinearScale(
                domain: (min, max),
                range: (outputMin, outputMax)
            )
            let penWidthX: CGFloat = xScale(pen.dynamicPenStyle.size)
            if penWidthX.isNaN {
                return outputMin
            }
            if penWidthX.isZero {
                return outputMin
            }
            if penWidthX.isInfinite {
                return outputMax
            }
            if penWidthX.isSignalingNaN {
                return outputMin
            }
            if penWidthX <= outputMin {
                return outputMin
            } else {
                if penWidthX >= outputMax {
                    return outputMax
                }
                return penWidthX
            }
        }
        @ViewBuilder private func penItemHelper(ix: Int, pen: SS1.PenModel) -> some View {
            let width = getPenSize(pen)
            let penView = PenView(
                width: width,
                toolbarModel: toolbarModel,
                pen: Binding.proxy($toolbarModel.pens[ix])
            )
            if pen.dynamicPenStyle.layer == .foreground {
                penView
                    .frame(width: width, alignment: .center)
            } else {
                penView
                    .rotationEffect(Angle.degrees(180))
                    .frame(width: width, alignment: .center)
            }
        }
        @ViewBuilder private func penItem(ix: Int, pen: PenModel) -> some View {
            let view = {
                Group {
                    switch (self.layerViewToggle, pen.dynamicPenStyle.layer) {
                    case (.both, _): penItemHelper(ix: ix, pen: pen)
                    case (.foreground, .foreground): penItemHelper(ix: ix, pen: pen)
                    case (.background, .background): penItemHelper(ix: ix, pen: pen)
                    default: EmptyView()
                    }
                }
            }
            if pen.penSet == self.penSetViewToggle {
                if toolbarModel.invertPenColors {
                    view()
                } else {
                    view()
                }
            } else {
                EmptyView()
            }
        }
        @ViewBuilder private var pensListMenu: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: -5) {
                    ForEach(Array(toolbarModel.pens.enumerated()), id: \.1.id) { (ix, pen) in
                        penItem(ix: ix, pen: pen)
                    }
                    Spacer()
                }
                .padding([.leading, .trailing], 10)
            }
        }
    }
}
