//
//  ToolBar.swift
//  Superscript
//
//  Created by Colbyn Wadman on 12/29/21.
//

import SwiftUI
import UIKit


fileprivate let TOOLBAR_FOREGROUND_COLOR: UIColor = #colorLiteral(red: 0.2541313469, green: 0.2541313469, blue: 0.2541313469, alpha: 1)
fileprivate let iconColor: Color = Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
fileprivate let disabledIconColor: Color = Color(#colorLiteral(red: 0.5570612527, green: 0.633860792, blue: 0.6627638421, alpha: 1))
fileprivate let textColor: Color = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
fileprivate let borderColor: Color = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
fileprivate let buttonBgColor: Color = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))

fileprivate struct PenSettingsPanel: View {
    var onDelete: (() -> ())? = nil
    var onSave: (() -> ()) = {}
    @Binding var pen: SS.RuntimeDataModel.Pen
    @Environment(\.presentationMode) private var presentationMode
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            VStack(alignment: .center, spacing: 8) {
                Text("Layer")
                Picker("Layer", selection: $pen.layer) {
                    Text("Foreground").tag(SS.Stroke.Layer.foreground)
                    Text("Background").tag(SS.Stroke.Layer.background)
                }
                .pickerStyle(SegmentedPickerStyle())
                HStack(alignment: .center, spacing: 0) {
                    Text("Size")
                    Spacer()
                    Text(String(format: "%.2f", pen.options.size))
                }
                Slider(
                    value: $pen.options.size,
                    in: SS.Stroke.Options.minSize...SS.Stroke.Options.maxSize,
                    step: 0.5
                )
                HStack(alignment: .center, spacing: 0) {
                    ColorPicker(
                        selection: $pen.options.color.cgColor,
                        supportsOpacity: true
                    ) {
                        Text("Color Picker")
                    }
                }
            }
            .padding(12)
            Divider()
            VStack(alignment: .center, spacing: 8) {
                HStack(alignment: .center, spacing: 0) {
                    Text("Thinning")
                    Spacer()
                    Text(String(format: "%.2f", pen.options.thinning))
                }
                Slider(
                    value: $pen.options.thinning,
                    in: SS.Stroke.Options.minThinning...SS.Stroke.Options.maxThinning
                )
                HStack(alignment: .center, spacing: 0) {
                    Text("Smoothing")
                    Spacer()
                    Text(String(format: "%.2f", pen.options.smoothing))
                }
                Slider(
                    value: $pen.options.smoothing,
                    in: SS.Stroke.Options.minSmoothing...SS.Stroke.Options.maxSmoothing
                )
                HStack(alignment: .center, spacing: 0) {
                    Text("Streamline")
                    Spacer()
                    Text(String(format: "%.2f", pen.options.streamline))
                }
                Slider(
                    value: $pen.options.streamline,
                    in: SS.Stroke.Options.minStreamline...SS.Stroke.Options.maxStreamline
                )
            }
            .padding(12)
            Spacer()
        }
        .frame(minWidth: 500)
    }
}


fileprivate struct StrokeTextLabel: UIViewRepresentable {
    let color: UIColor
    let size: CGFloat
    
    private let scale = MathUtils.newLinearScale(domain: (0, SS.Stroke.Options.maxSize), range: (20, 40))
    
    func makeUIView(context: Context) -> UILabel {
        let attributedStringParagraphStyle = NSMutableParagraphStyle()
        attributedStringParagraphStyle.alignment = NSTextAlignment.center
        let attributedString = NSAttributedString(
            string: "Color",
            attributes:[
                NSAttributedString.Key.paragraphStyle: attributedStringParagraphStyle,
                NSAttributedString.Key.strokeWidth: -4.0,
                NSAttributedString.Key.foregroundColor: self.color,
                NSAttributedString.Key.strokeColor: UIColor.white,
                NSAttributedString.Key.font: UIFont(name:"Helvetica", size: scale(self.size))!
            ]
        )

        let strokeLabel = UILabel()
        strokeLabel.attributedText = attributedString
        strokeLabel.backgroundColor = UIColor.clear
        strokeLabel.sizeToFit()
        return strokeLabel
    }

    func updateUIView(_ uiView: UILabel, context: Context) {}
}

fileprivate struct EraserTool: View {
    let active: Bool
    let onClick: () -> ()
    
    var body: some View {
        Button(
            action: onClick,
            label: {
                let fg = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                ZStack(alignment: Alignment.top) {
                    BackgroundGraphic(active: active)
                        .scale(1.0)
                        .foregroundColor(Color(fg))
                    TopGraphic(active: active)
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
                    BottomGraphic(active: active)
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
                .offset(x: 0, y: self.active ? 10 : 0)
                .foregroundColor(Color.clear)
            }
        )
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
    let active: Bool
    let onClick: () -> ()
    
    var body: some View {
        Button(
            action: onClick,
            label: {
                ZStack(alignment: Alignment.top) {
                    BackgroundGraphic(active: active)
                        .scale(1.0)
                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                    TopGraphic(active: active)
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
                    BottomGraphic(active: active)
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
                .offset(x: 0, y: self.active ? 8 : 0)
                .foregroundColor(Color.clear)
            }
        )
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
    let setToPen: (SS.RuntimeDataModel.Pen) -> ()
    @ObservedObject var runtimeModel: SS.RuntimeDataModel
    @Binding var pen: SS.RuntimeDataModel.Pen
    
    var body: some View {
        Button(action: onClick, label: self.label)
    }
    
    private func onClick() {
        for (ix, _) in runtimeModel.pens.enumerated() {
            runtimeModel.pens[ix].active = false
        }
        pen.active = true
        setToPen(pen)
    }
    
    @ViewBuilder private func label() -> some View {
        GeometryReader { geo in
            let graphic = ZStack(alignment: Alignment.top) {
                let backColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                let frontColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                let penColor = pen.options.color.color.withAlphaComponent(0.8)
                Top(active: pen.active)
                    .foregroundColor(Color(backColor))
                Top(active: pen.active)
                    .scale(0.95)
                    .foregroundColor(Color(frontColor))
                Top(active: pen.active)
                    .scale(0.90)
                    .offset(y: -2.0)
                    .foregroundColor(Color(penColor.cgColor))
                Bottom(active: pen.active)
                    .foregroundColor(Color(backColor))
                Bottom(active: pen.active)
                    .scale(0.95)
                    .foregroundColor(Color(frontColor))
                Bottom(active: pen.active)
                    .scale(0.9)
                    .offset(y: -1.0)
                    .foregroundColor(Color(penColor.cgColor))
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

extension SS.Freehand {
    struct FreehandToolBar: View {
        @ObservedObject var runtimeModel: SS.RuntimeDataModel
//        @ObservedObject var notebookModel: SS.NotebookDataModel
        @ObservedObject var canvasModel: SS.CanvasDataModel
//        let foregroundColor: Color
        let openSettings: () -> ()
        let setToPen: (SS.RuntimeDataModel.Pen) -> ()
        let setToEraser: () -> ()
        let setToSelection: () -> ()
        let goBack: () -> ()
        let onSave: () -> ()
        let onCompile: () -> ()
        @State private var usingEraserTool: Bool = false
        @State private var usingSelectionTool: Bool = false
        @Environment(\.colorScheme) private var colorScheme
        var body: some View {
            HStack(alignment: .center, spacing: 12) {
                Button(
                    action: goBack,
                    label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.purple)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5).stroke(Color.purple, lineWidth: 1)
                            )
                    }
                )
                Button(
                    action: onSave,
                    label: {
                        Text("Save")
                            .foregroundColor(.purple)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5).stroke(Color.purple, lineWidth: 1)
                            )
                    }
                )
                SelectionTool(active: usingSelectionTool, onClick: {
                    usingSelectionTool = !usingSelectionTool
                    usingEraserTool = false
                    setToSelection()
                })
                    .frame(width: 35, alignment: .center)
                EraserTool(active: usingEraserTool, onClick: {
                    usingEraserTool = !usingEraserTool
                    usingSelectionTool = false
                    setToEraser()
                })
                    .frame(width: 35, alignment: .center)
                pens
                Button(
                    action: openSettings,
                    label: {
                        Text("Options")
                            .foregroundColor(.purple)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5).stroke(Color.purple, lineWidth: 1)
                            )
                    }
                )
                Button(
                    action: onCompile,
                    label: {
                        Text("Compile")
                            .foregroundColor(.purple)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5).stroke(Color.purple, lineWidth: 1)
                            )
                    }
                )
            }
            .padding([.leading, .trailing], 20)
            .background(Color(TOOLBAR_FOREGROUND_COLOR))
            .border(width: 0.5, edges: .bottom, color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
            .clipped()
        }
        
        @ViewBuilder private var pens: some View {
            let DEFAULT_PEN_MIN: CGFloat = 1
            let DEFAULT_PEN_MAX: CGFloat = 60
            let (min, max) = runtimeModel.penMinMaxValues(
                defPenMin: DEFAULT_PEN_MIN,
                defPenMax: DEFAULT_PEN_MAX
            )
            let size: CGFloat = max - min
            let outputMin: CGFloat = 30
            let outputMax: CGFloat = size > 10 ? 50 : 40
            let xScale = MathUtils.newLinearScale(domain: (min, max), range: (outputMin, outputMax))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: -5) {
                    ForEach(Array(runtimeModel.pens.enumerated()), id: \.1.id) { (ix, pen) in
                        let width = pen.options.size
                        let penView = PenView(
                            setToPen: { pen in
                                self.usingSelectionTool = false
                                self.usingEraserTool = false
                                self.setToPen(pen)
                            },
                            runtimeModel: runtimeModel,
                            pen: Binding.proxy($runtimeModel.pens[ix])
                        )
                        if pen.layer == .foreground {
                            penView
                                .frame(width: xScale(width), alignment: .center)
                        } else {
                            penView
                                .rotationEffect(Angle.degrees(180))
                                .frame(width: xScale(width), alignment: .center)
                        }
                    }
                }
            }
        }
    }
    struct PenSettingsView: View {
        @ObservedObject var runtimeModel: SS.RuntimeDataModel
        @ObservedObject var drawingModel: SS.CanvasDataModel
        @State var editMode: Bool = false
        @Environment(\.presentationMode) private var presentationMode
        var body: some View {
            NavigationView {
                VStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .center, spacing: 12) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("Close")
                        })
                        Button(action: {editMode = !editMode}, label: {
                            Text("Toggle Edit Mode")
                        })
                        Button(action: {
                            runtimeModel.pens.append(SS.RuntimeDataModel.Pen())
                        }, label: {
                            Text("Add Pen")
                        })
                        Spacer()
                    }
                    .padding(12)
                    .border(edges: .bottom, color: borderColor)
                    Text("Notebook Pens")
                        .foregroundColor(/*@START_MENU_TOKEN@*/Color(hue: 0.587, saturation: 0.818, brightness: 0.231)/*@END_MENU_TOKEN@*/)
                        .padding(12)
                    let list = List {
                        ForEach(Array(runtimeModel.pens.enumerated()), id: \.1.id) {(ix, pen) in
                            HStack(alignment: .center, spacing: 8) {
                                let dest = PenSettingsPanel(pen: Binding.proxy($runtimeModel.pens[ix]))
                                NavigationLink(
                                    destination: dest,
                                    label: {
                                        HStack(alignment: .center, spacing: 12) {
                                            RoundedRectangle(cornerRadius: 3.0)
                                                .stroke(Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)), lineWidth: 1.0)
                                                .background(Color(runtimeModel.pens[ix].options.color.color))
                                                .frame(width: 50, alignment: .center)
                                            Text(String(format: "%.1fpx", runtimeModel.pens[ix].options.size))
                                        }
                                    }
                                )
                            }
                        }
                        .onMove(perform: onMove)
                        .onDelete(perform: onDelete)
                    }
                    if editMode {
                        list.environment(\.editMode, Binding.constant(EditMode.active))
                    } else {
                        list
                    }
                    Spacer()
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .edgesIgnoringSafeArea(.all)
            }
        }
        private func edit(id: UUID) -> some View {
            let index: Int = runtimeModel.getIndexForPen(id: id)
            return VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Text("Size")
                    Spacer()
                    Text(String(format: "%.2f", runtimeModel.pens[index].options.size))
                }
                Slider(
                    value: Binding.proxy($runtimeModel.pens[index].options.size),
                    in: 1...SS.Stroke.Options.maxSize,
                    step: 1
                )
                Spacer()
            }
            .padding(12)
        }
        private func onDelete(offsets: IndexSet) {
            runtimeModel.pens.remove(atOffsets: offsets)
        }
        private func onMove(source: IndexSet, destination: Int) {
            runtimeModel.pens.move(fromOffsets: source, toOffset: destination)
        }
    }
}

