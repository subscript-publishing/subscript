//
//  CanvasHome.swift
//  Subscript
//
//  Created by Colbyn Wadman on 3/30/22.
//

import UIKit
import SwiftUI

fileprivate let HEADER_BACKGROUND_COLOR: UIColor = #colorLiteral(red: 0.210621506, green: 0.210621506, blue: 0.210621506, alpha: 1)
fileprivate let HEADER_BORDER_COLOR: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
fileprivate let PANEL_GUTTER_COLOR: UIColor = #colorLiteral(red: 0.1331654787, green: 0.1331654787, blue: 0.1331654787, alpha: 1)

fileprivate struct SegmentedViewWrapper<L: View, C: View, R: View>: View {
    let viewport: CGSize
    var height: CGFloat? = nil
    @ViewBuilder var left: L
    @ViewBuilder var center: C
    @ViewBuilder var right: R
    var body: some View {
        let foregroundColor = Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        HStack(alignment: .center, spacing: 0) {
            left.frame(width: 50, height: height, alignment: .center)
            center
                .frame(height: height, alignment: .leading)
                .border(edges: [.leading, .trailing])
            right.frame(width: 50, height: height)
        }
        .frame(width: viewport.width, height: height)
        .foregroundColor(foregroundColor)
    }
}

fileprivate struct DrawingRootView: View {
    @ObservedObject var runtimeModel: SS.RuntimeDataModel
    @ObservedObject var drawingModel: SS.DrawingDataModel
    
    let isFirstChild: Bool
    let isLastChild: Bool
    let deleteMe: () -> ()
    let insertNewPaper: () -> ()
    let toggleVisibility: () -> ()
    let updateLayouts: () -> ()
    
    @ViewBuilder
    private var header: some View {
        HStack(alignment: .center, spacing: 0) {Spacer()}
            .padding([.top, .bottom], 4)
            .background(Color(HEADER_BACKGROUND_COLOR))
            .border(width: 0.5, edges: isFirstChild ? [] : [.top], color: Color(HEADER_BORDER_COLOR))
            .padding(.top, isFirstChild ? 0 : 0)
            .border(width: 0.5, edges: [.bottom], color: Color(HEADER_BORDER_COLOR))
    }
    
    @ViewBuilder private var canvas: some View {
        let mask = MaskView().fill()
        
        let mainShadowColor = Color(#colorLiteral(red: 0.0795307681, green: 0.0795307681, blue: 0.0795307681, alpha: 1))
        let lastShadowColor = Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        
        SS.Freehand.DisplayDrawingEntry(
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
    
    fileprivate struct Background: Shape {
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
    @ObservedObject var runtimeModel: SS.RuntimeDataModel
    @ObservedObject var canvasModel: SS.CanvasDataModel
    let updateLayouts: () -> ()
    
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
                let newPaper = SS.DrawingDataModel()
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
                self.child(ix: ix)
            }
            let textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            VStack(alignment: .center, spacing: 0) {
                Text("Scroll VIA two fingers and draw with an Apple Pencil.")
                Text("Increase battery life and improve performance by splitting big drawings into multiple panels.")
            }
            .foregroundColor(Color(textColor))
            .padding(12)
            .padding(.top, 100)
        }
        .environmentObject(self.canvasModel)
        .environmentObject(self.runtimeModel)
    }
}

extension SS {
    struct Canvas: View {
        @ObservedObject var canvasModel: CanvasDataModel
        @ObservedObject var runtimeModel: SS.RuntimeDataModel
        
        let goBack: () -> ()
        let onSave: () -> ()
        let onCompile: () -> ()
        @State private var showPenEditor: Bool = false
        
        @ViewBuilder
        private var header: some View {
            HStack(alignment: .center, spacing: 0) {Spacer()}
                .padding([.top, .bottom], 4)
                .background(Color(HEADER_BACKGROUND_COLOR))
                .border(width: 0.5, edges: [.top], color: Color(HEADER_BORDER_COLOR))
                .border(width: 0.5, edges: [.bottom], color: Color(HEADER_BORDER_COLOR))
        }
        
        var body: some View {
            GeometryReader { geo in
                VStack(alignment: .center, spacing: 0) {
                    SS.Freehand.FreehandToolBar(
                        runtimeModel: runtimeModel,
                        canvasModel: canvasModel,
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
                                    self.canvasModel.entries[ix].finalizeActiveStroke()
                                }
                                self.canvasModel.entries[ix].active.options = pen.options
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
                                    canvasModel.entries[ix].finalizeActiveStroke()
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
                                    canvasModel.entries[ix].finalizeActiveStroke()
                                }
                                if runtimeModel.currentToolType.isAnyEditToolType {
                                    canvasModel.entries[ix].clearActiveStroke()
                                }
                            }
                            self.runtimeModel.currentToolType = .selection
                        },
                        goBack: goBack,
                        onSave: onSave,
                        onCompile: onCompile
                    )
                    .frame(height: 50)
                    .border(width: 0.5, edges: [.top])
                    
                    CustomScroller { customScrollerCoordinator in
                        VStack(alignment: .center, spacing: 0) {
                            CanvasArtBoards(
                                runtimeModel: runtimeModel,
                                canvasModel: canvasModel,
                                updateLayouts: {
                                    customScrollerCoordinator.customScrollerViewController.embeddedViewCtl.view.setNeedsUpdateConstraints()
                                }
                            )
                            .navigationBarTitle("")
                            .navigationBarHidden(true)
                            .edgesIgnoringSafeArea(.all)
                        }
                    }
                }
//                .background()
                .sheet(isPresented: $showPenEditor, content: {
                    SS.Freehand.PenSettingsView(runtimeModel: runtimeModel, drawingModel: canvasModel)
                })
            }
        }
    }
}


