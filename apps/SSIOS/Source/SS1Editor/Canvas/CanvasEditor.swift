//
//  CanvasHome.swift
//  Subscript
//
//  Created by Colbyn Wadman on 3/30/22.
//

import UIKit
import SwiftUI


fileprivate struct SegmentedViewWrapper<L: View, C: View, R: View>: View {
    var viewport: CGSize? = nil
    var height: CGFloat? = nil
    @ViewBuilder var left: L
    @ViewBuilder var center: C
    @ViewBuilder var right: R
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            left.frame(width: 50, height: height, alignment: .center)
            center
                .frame(height: height, alignment: .leading)
                .border(edges: [.leading, .trailing])
            right.frame(width: 50, height: height)
        }
        .frame(width: viewport?.width, height: height)
    }
}

fileprivate struct DrawingRootView: View {
    @ObservedObject var runtimeModel: SS1.RuntimeDataModel
    @ObservedObject var drawingModel: SS1.DrawingDataModel
    @Environment(\.colorScheme) private var colorScheme
    
    let isFirstChild: Bool
    let isLastChild: Bool
    let deleteMe: () -> ()
    let insertNewPaper: () -> ()
    let toggleVisibility: () -> ()
    let updateLayouts: () -> ()
    
    @ViewBuilder private var header: some View {
        HStack(alignment: .center, spacing: 0) {Spacer()}
            .background(Rectangle().foregroundColor(
                colorScheme == .dark
                    ? SS1.StaticSettings.DarkMode.Canvas.BG2
                    : SS1.StaticSettings.LightMode.Canvas.BG2
            ))
            .padding([.top, .bottom], 4)
            .border(edges: [.top, .bottom])
    }
    
    @ViewBuilder private var canvas: some View {
        let mask = MaskView().fill()
        
        let darkMainShadowColor = Color(#colorLiteral(red: 0.0795307681, green: 0.0795307681, blue: 0.0795307681, alpha: 1))
        let darkLastShadowColor = Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        
        let lightMainShadowColor = Color(#colorLiteral(red: 0.0795307681, green: 0.0795307681, blue: 0.0795307681, alpha: 0.3999450262))
        let lightLastShadowColor = Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5857864591))
        
        let lastShadowColor = colorScheme == .dark ? darkLastShadowColor : lightLastShadowColor
        let mainShadowColor = colorScheme == .dark ? darkMainShadowColor : lightMainShadowColor
        
        SS1.Drawing.DisplayDrawingEntry(
            runtimeModel: runtimeModel,
            drawingModel: drawingModel,
            updateLayouts: updateLayouts,
            deleteMe: deleteMe,
            insertNewPaper: insertNewPaper
        )
            .frame(height: max(200, drawingModel.height))
            .mask(mask)
            .shadow(
                color: isLastChild ? lastShadowColor : mainShadowColor,
                radius: isLastChild ? 4 : 2,
                x: 0,
                y: isLastChild ? 8 : 5
            )
    }
    
    private func incDrawingHeight() {
        drawingModel.height = max(0, drawingModel.height + 50)
        updateLayouts()
    }
    private func bigIncDrawingHeight() {
        drawingModel.height = max(0, drawingModel.height + 250)
        updateLayouts()
    }
    private func decDrawingHeight() {
        drawingModel.height = max(0, drawingModel.height - 50)
        updateLayouts()
    }
    private func bigDecDrawingHeight() {
        drawingModel.height = max(0, drawingModel.height - 250)
        updateLayouts()
    }
    
    @ViewBuilder
    private var bottomMenu: some View {
        HStack(alignment: .center, spacing: 0) {
            let spacing: CGFloat = 12
            let width: CGFloat = drawingModel.visible ? 40 : 25
            let height: CGFloat = drawingModel.visible ? 40 : 25
            let fontSizeScale: CGFloat = drawingModel.visible ? 0.75 : 0.5
            
            HStack(alignment: .center, spacing: spacing) {
                Button(action: self.decDrawingHeight, label: {
                    let color = #colorLiteral(red: 0.8545565443, green: 0.8545565443, blue: 0.8545565443, alpha: 1)
                    let background = Circle()
                        .foregroundColor(Color(color))
                    Image(systemName: "minus")
                        .font(.system(size: 30 * fontSizeScale))
                        .frame(width: width, height: height, alignment: .center)
                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                        .background(background)
                })
                .hidden(!drawingModel.visible)
                Button(action: self.bigDecDrawingHeight, label: {
                    let color = #colorLiteral(red: 0.8545565443, green: 0.8545565443, blue: 0.8545565443, alpha: 1)
                    let background = Circle()
                        .foregroundColor(Color(color))
                    Image(systemName: "minus")
                        .font(.system(size: 30 * fontSizeScale))
                        .frame(width: width + 15, height: height + 15, alignment: .center)
                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                        .background(background)
                })
                .hidden(!drawingModel.visible)
                Button(action: self.bigIncDrawingHeight, label: {
                    let bgColor = #colorLiteral(red: 0.8545565443, green: 0.8545565443, blue: 0.8545565443, alpha: 1)
                    let background = Circle()
                        .foregroundColor(Color(bgColor))
                    Image(systemName: "plus")
                        .font(.system(size: 24 * fontSizeScale))
                        .frame(width: width + 15, height: height + 15, alignment: .center)
                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                        .background(background)
                })
                .hidden(!drawingModel.visible)
                Button(action: self.incDrawingHeight, label: {
                    let bgColor = #colorLiteral(red: 0.8545565443, green: 0.8545565443, blue: 0.8545565443, alpha: 1)
                    let background = Circle()
                        .foregroundColor(Color(bgColor))
                    Image(systemName: "plus")
                        .font(.system(size: 24 * fontSizeScale))
                        .frame(width: width, height: height, alignment: .center)
                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                        .background(background)
                })
                .hidden(!drawingModel.visible)
                Spacer()
            }
            .frame(width: 100, alignment: .leading)
            Spacer()
            HStack(alignment: .center, spacing: spacing) {
                Button(action: toggleVisibility, label: {
                    let bgColor = #colorLiteral(red: 0.8545565443, green: 0.8545565443, blue: 0.8545565443, alpha: 1)
                    let background = Circle()
                        .foregroundColor(Color(bgColor))
                    Image(systemName: "eye")
                        .font(.system(size: 18 * fontSizeScale))
                        .frame(width: width, height: height, alignment: .center)
                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                        .background(background)
                })
            }
            .frame(width: 100, alignment: .trailing)
            .hidden()
            Spacer()
            HStack(alignment: .center, spacing: spacing) {
                Button(action: deleteMe, label: {
                    let bgColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
                    let background = Circle()
                        .foregroundColor(Color(bgColor))
                    Image(systemName: "trash")
                        .font(.system(size: 20 * fontSizeScale))
                        .frame(width: width, height: height, alignment: .center)
                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                        .background(background)
                })
                .hidden(!drawingModel.visible)
                Button(action: insertNewPaper, label: {
                    let bgColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
                    let background = Circle()
                        .foregroundColor(Color(bgColor))
                    Image(systemName: "plus.square")
                        .font(.system(size: 24 * fontSizeScale))
                        .frame(width: width, height: height, alignment: .center)
                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                        .background(background)
                })
                .hidden(!drawingModel.visible)
            }
            .frame(width: 100, alignment: .center)
            
        }
        .padding([.leading, .trailing], 50)
        .padding(.top, 12)
        .padding(.bottom, drawingModel.visible ? 24 : 12)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            header
            if drawingModel.visible {
                canvas
            }
            bottomMenu
        }
        .background(Color.clear)
    }
    
    fileprivate struct GridLinesBackground: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            var row: CGFloat = 0.0
            var column: CGFloat = 0.0
            while row < rect.height {
                path.move(to: CGPoint(x: 0, y: row))
                path.addLine(to: CGPoint(x: rect.maxX, y: row))
                row += 50.0
            }
            while column < rect.width {
                path.move(to: CGPoint(x: column, y: 0))
                path.addLine(to: CGPoint(x: column, y: rect.maxY))
                column += 50.0
            }
            return path
        }
    }
    
    fileprivate struct MaskView: Shape {
        func path(in rect: CGRect) -> Path {
            let centerY = rect.height - 25
            let steps = 545
            let stepX = rect.width / CGFloat(steps)
            var path = Path()
            path.move(to: CGPoint(x: 0, y: 0))
            for i in 0...steps {
                let x = CGFloat(i) * stepX
                let y = abs((cos(Double(i) * 0.15) * 10) + Double(centerY))
                path.addLine(to: CGPoint(x: x, y: CGFloat(y)))
            }
            path.addLine(to: CGPoint(x: rect.width, y: 0.0))
            path.closeSubpath()
            return path
        }
    }
}


fileprivate struct CanvasArtBoards: View {
    @ObservedObject var runtimeModel: SS1.RuntimeDataModel
    @ObservedObject var canvasModel: SS1.CanvasDataModel
    let updateLayouts: () -> ()
    
    @Environment(\.colorScheme) private var colorScheme
    
//    @ViewBuilder
//    private var verticalHeader: some View {
//        VStack(alignment: .center, spacing: 0) {Spacer()}
//            .padding([.top, .bottom], 4)
//            .background(Color(HEADER_BACKGROUND_COLOR))
//            .border(width: 0.5, edges: [.leading, .trailing], color: Color(HEADER_BORDER_COLOR))
//    }
    
    @ViewBuilder private func child(ix: Int) -> some View {
        let isFirstChild = ix == 0
        let isLastChild = ix + 1 == canvasModel.entries.count
        let toggleVisibility: () -> () = {
            canvasModel.entries[ix].visible = !canvasModel.entries[ix].visible
            updateLayouts()
        }
        DrawingRootView(
            runtimeModel: runtimeModel,
            drawingModel: canvasModel.entries[ix],
            isFirstChild: isFirstChild,
            isLastChild: isLastChild,
            deleteMe: {
                if canvasModel.entries.count > 1 {
                    canvasModel.entries.remove(at: ix)
                }
                updateLayouts()
            },
            insertNewPaper: {
                let newPaper = SS1.DrawingDataModel()
                canvasModel.entries.insert(newPaper, at: ix + 1)
                updateLayouts()
            },
            toggleVisibility: toggleVisibility,
            updateLayouts: updateLayouts
        )
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
//            let entries =
            ForEach(Array(canvasModel.entries.enumerated()), id: \.1.id) {(ix, _) in
                let isLastChild = ix + 1 == canvasModel.entries.count
                let view = self.child(ix: ix)
                if !isLastChild {
                    view.background(colorScheme == .dark ? SS1.StaticSettings.DarkMode.Canvas.BG2 : SS1.StaticSettings.LightMode.Canvas.BG2)
                } else {
                    view
                }
                
            }
            VStack(alignment: .center, spacing: 0) {
                Text("Scroll VIA two fingers and draw with an Apple Pencil.")
                Text("Increase battery life and improve performance by splitting big drawings into multiple panels.")
            }
            .padding(12)
            .padding(.top, 100)
        }
        .environmentObject(self.canvasModel)
        .environmentObject(self.runtimeModel)
    }
}

extension SS1 {
//    struct DrawingPreview: View {
//        @StateObject private var runtimeModel = SS.RuntimeDataModel()
//        @ObservedObject var drawingModel: SS.DrawingDataModel
//        var body: some View {
//            
//        }
//    }
    struct CanvasEditor: View {
        @Binding var title: SS1.Title
        let displayTitle: Bool
        @ObservedObject var canvasModel: CanvasDataModel
        @ObservedObject var runtimeModel: SS1.RuntimeDataModel
        let toggleColorScheme: () -> ()
        let goBack: () -> ()
        let onSave: () -> ()
        
        @State private var showPenEditor: Bool = false
        @Environment(\.colorScheme) private var colorScheme
        
        @ViewBuilder private var header: some View {
            HStack(alignment: .center, spacing: 0) {Spacer()}
                .padding([.top, .bottom], 4)
                .border(edges: [.top, .bottom])
        }
        
        @ViewBuilder private var titleView: some View {
            if displayTitle {
                VStack(alignment: .center, spacing: 0) {
                    header
                    SegmentedViewWrapper(
                        left: {
                            Spacer()
                        },
                        center: {
                            HStack(alignment: .center, spacing: 0) {
                                TextField("Canvas Title", text: $title.text)
                                    .textTheme()
                                    .autocapitalization(UITextAutocapitalizationType.words)
                                    .font(.system(size: 25, weight: Font.Weight.medium, design: Font.Design.monospaced))
                                    .padding(12)
                                Spacer()
                            }
                        },
                        right: {
                            Spacer()
                        }
                    )
                        .border(edges: .bottom)
                }
            }
        }
        
        @ViewBuilder
        private var ui: some View {
            GeometryReader { geo in
                VStack(alignment: .center, spacing: 0) {
                    header.background(
                        colorScheme == .dark
                            ? SS1.StaticSettings.DarkMode.Canvas.BG2
                            : SS1.StaticSettings.LightMode.Canvas.BG2
                    )
                    SS1.Drawing.ToolBar(
                        runtimeModel: runtimeModel,
                        canvasModel: canvasModel,
//                        displayStyle: $displayStyle,
                        toggleColorScheme: toggleColorScheme,
                        openSettings: {
                            showPenEditor = true
                        },
                        setToPen: {pen in
                            for ix in self.runtimeModel.pens.enumerated().map({$0.0}) {
                                if self.runtimeModel.pens[ix].id == pen.id {
                                    self.runtimeModel.pens[ix].active = true
                                } else {
                                    self.runtimeModel.pens[ix].active = false
                                }
                            }
                            for ix in self.canvasModel.entries.enumerated().map({$0.0}) {
                                if self.runtimeModel.currentToolType.isAnyEditToolType {
                                    self.canvasModel.entries[ix].clearActiveStroke()
                                }
                                if self.runtimeModel.currentToolType.isPen {
                                    self.canvasModel.entries[ix].finalizeActiveStroke(
                                        runtimeModel: runtimeModel
                                    )
                                }
                                self.canvasModel.entries[ix].active.options = pen.options
                                self.canvasModel.entries[ix].activeLayer = pen.layer
                            }
                            self.runtimeModel.currentToolType = .pen
                        },
                        setToEraser: {
                            for ix in self.runtimeModel.pens.enumerated().map({$0.0}) {
                                self.runtimeModel.pens[ix].active = false
                            }
                            for ix in runtimeModel.pens.enumerated().map({$0.0}) {
                                runtimeModel.pens[ix].active = false
                            }
                            for ix in canvasModel.entries.enumerated().map({$0.0}) {
                                if runtimeModel.currentToolType.isPen {
                                    canvasModel.entries[ix].finalizeActiveStroke(
                                        runtimeModel: runtimeModel
                                    )
                                }
                                if runtimeModel.currentToolType.isAnyEditToolType {
                                    canvasModel.entries[ix].clearActiveStroke()
                                }
                            }
                            self.runtimeModel.currentToolType = .eraser
                        },
                        setToSelection: {
                            for ix in self.runtimeModel.pens.enumerated().map({$0.0}) {
                                self.runtimeModel.pens[ix].active = false
                            }
                            for ix in runtimeModel.pens.enumerated().map({$0.0}) {
                                runtimeModel.pens[ix].active = false
                            }
                            for ix in canvasModel.entries.enumerated().map({$0.0}) {
                                if runtimeModel.currentToolType.isPen {
                                    canvasModel.entries[ix].finalizeActiveStroke(
                                        runtimeModel: runtimeModel
                                    )
                                }
                                if runtimeModel.currentToolType.isAnyEditToolType {
                                    canvasModel.entries[ix].clearActiveStroke()
                                }
                            }
                            self.runtimeModel.currentToolType = .selection
                        },
                        goBack: goBack,
                        onSave: onSave
                    )
                    .frame(height: 50)
                    CustomScroller { customScrollerCoordinator in
                        InnerView(
                            title: $title,
                            displayTitle: displayTitle,
                            canvasModel: canvasModel,
                            runtimeModel: runtimeModel,
                            toggleColorScheme: {
                                self.toggleColorScheme()
                                customScrollerCoordinator.customScrollerViewController.embeddedViewCtl.view.setNeedsUpdateConstraints()
                            },
                            goBack: goBack,
                            onSave: onSave,
                            updateLayouts: {
                                customScrollerCoordinator.customScrollerViewController.embeddedViewCtl.view.setNeedsUpdateConstraints()
                            }
                        )
                            .navigationViewStyle(StackNavigationViewStyle())
                            .navigationBarTitle("")
                            .navigationBarHidden(true)
                            .navigationBarBackButtonHidden(true)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarTitleDisplayMode(.inline)
                }
                .sheet(isPresented: $showPenEditor, content: {
                    SS1.Drawing.PenSettingsView(runtimeModel: runtimeModel, drawingModel: canvasModel)
                        .navigationViewStyle(StackNavigationViewStyle())
                        .navigationBarTitle("Pen List Editor")
                        .navigationBarHidden(false)
                        .navigationBarBackButtonHidden(false)
                        .navigationBarTitleDisplayMode(.inline)
                })
                .background(colorScheme == .dark ? SS1.StaticSettings.DarkMode.Canvas.BG : SS1.StaticSettings.LightMode.Canvas.BG)
            }
        }
        
        var body: some View {
            if SS1.StaticSettings.Canvas.ignoreSafeAreas {
                ui  .ignoresSafeArea()
                    .padding(.top, 1)
            } else {
                ui
            }
        }
        
        fileprivate struct InnerView: View {
            @Binding var title: SS1.Title
            let displayTitle: Bool
            @ObservedObject var canvasModel: CanvasDataModel
            @ObservedObject var runtimeModel: SS1.RuntimeDataModel
            let toggleColorScheme: () -> ()
            let goBack: () -> ()
            let onSave: () -> ()
            var updateLayouts: () -> ()
            @State private var showPenEditor: Bool = false
            @Environment(\.colorScheme) private var colorScheme
            @ViewBuilder private var header: some View {
                HStack(alignment: .center, spacing: 0) {Spacer()}
                    .padding([.top, .bottom], 4)
                    .border(width: 0.5, edges: [.top, .bottom])
            }
            @ViewBuilder private var titleView: some View {
                if displayTitle {
                    VStack(alignment: .center, spacing: 0) {
                        header
                        SegmentedViewWrapper(
                            left: {
                                Spacer()
                            },
                            center: {
                                HStack(alignment: .center, spacing: 0) {
                                    TextField("Canvas Title", text: $title.text)
                                        .textTheme()
                                        .autocapitalization(UITextAutocapitalizationType.words)
                                        .font(.system(size: 25, weight: Font.Weight.medium, design: Font.Design.monospaced))
                                        .padding(12)
                                    Spacer()
                                }
                            },
                            right: {
                                Spacer()
                            }
                        )
                            .border(width: 0.5, edges: .bottom)
                    }
                    .background(colorScheme == .dark ? SS1.StaticSettings.DarkMode.Canvas.BG2 : SS1.StaticSettings.LightMode.Canvas.BG2)
                }
            }
            var body: some View {
                VStack(alignment: .center, spacing: 0) {
                    titleView
                    CanvasArtBoards(
                        runtimeModel: runtimeModel,
                        canvasModel: canvasModel,
                        updateLayouts: updateLayouts
//                        updateLayouts: {
//                            customScrollerCoordinator.customScrollerViewController.embeddedViewCtl.view.setNeedsUpdateConstraints()
//                        }
                    )
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .edgesIgnoringSafeArea(.all)
                    Spacer()
                }
            }
        }
    }
}


