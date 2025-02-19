//
//  Canvas.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/19/22.
//

import Foundation
import SwiftUI
import Combine
import Metal
import MetalKit

fileprivate let CANAVS_PAPER = UI.LL.ColorMap(
    lightUI: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
    darkUI: #colorLiteral(red: 0.1447366774, green: 0.1447366774, blue: 0.1447366774, alpha: 1)
)
fileprivate let LINE_COLOR: UI.LL.ColorMap = UI.LL.ColorMap(
    lightUI: #colorLiteral(red: 0.7919328, green: 0.7919328, blue: 0.7919328, alpha: 1),
    darkUI: #colorLiteral(red: 0.2846999907, green: 0.2846999907, blue: 0.2846999907, alpha: 1)
)

#if os(iOS)
#elseif os(macOS)
#endif



fileprivate final class CanvasGestureRecognizer: UI.LL.GestureRecognizer {
    weak var canvasRuntime: SS1.FFI.CanvasRuntime!
    
#if os(iOS)
    @inline(__always) private func getSample(touch: UITouch) -> SS1.CanvasModel.SamplePoint {
        let point = touch.location(in: self.view)
        let force = touch.force
        let sample = SS1.CanvasModel.SamplePoint(
            point: point,
            force: force
        )
        return sample
    }
    @inline(__always) private func addSample(touch: UITouch) {
#if !targetEnvironment(macCatalyst)
        if touch.type != UITouch.TouchType.pencil {
            root_scene_clear_any_highlights(self.canvasRuntime.rootScenePointer)
            return
        }
#endif
        let point = touch.location(in: self.view)
        let width = self.view!.frame.width
        let height = self.view!.frame.height
        let force = touch.force
        let sample = SS1.CanvasModel.SamplePoint(
            point: point,
            force: force
        )
        self.canvasRuntime.recordStrokePoint(width: width, height: height, sample: sample)
    }
    @inline(__always) private func addSample(touch: UITouch, event: UIEvent) {
        for x in event.coalescedTouches(for: touch) ?? [touch] {
            addSample(touch: x)
        }
    }
    @inline(__always) private func addSample(_ touches: Set<UITouch>, with event: UIEvent) {
        for touch in touches {
            addSample(touch: touch, event: event)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if let first = touches.first {
            let startPoint = getSample(touch: first)
            self.canvasRuntime.beginStroke(startPoint: startPoint)
        }
        for (ix, touch) in touches.enumerated() {
            if ix == 0 {
                continue
            }
            self.addSample(touch: touch)
        }
        self.view!.setNeedsDisplay()
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        self.addSample(touches, with: event)
        self.view!.setNeedsDisplay()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        self.addSample(touches, with: event)
        self.canvasRuntime.endStroke()
        self.view!.setNeedsDisplay()
    }
#elseif os(macOS)
    private var dragging: Bool = false
    private func toSample(event: NSEvent) -> SS1.CanvasModel.SamplePoint {
        let point = self.view!.convert(event.locationInWindow, from: nil)
        let sample = SS1.CanvasModel.SamplePoint(
            point: CGPoint(x: point.x, y: point.y),
            force: nil
        )
        return sample
    }
    private func addSample(event: NSEvent) {
        if self.dragging {
            let sample = self.toSample(event: event)
            let width = self.view!.frame.width
            let height = self.view!.frame.height
            self.canvasRuntime.recordStrokePoint(width: width, height: height, sample: sample)
        }
    }
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.dragging = true
        let sample = self.toSample(event: event)
        self.canvasRuntime.beginStroke(startPoint: sample)
        self.view!.setNeedsDisplay(self.view!.frame)
    }
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        self.addSample(event: event)
        self.view!.setNeedsDisplay(self.view!.frame)
    }
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        self.addSample(event: event)
        self.dragging = false
        self.canvasRuntime.endStroke()
        self.view!.setNeedsDisplay(self.view!.frame)
    }
#endif
}



fileprivate final class RootMetalRenderer: UI.LL.View, MTKViewDelegate {
    weak var canvasModel: SS1.CanvasModel!
    private var canvasGestureRecognizer = CanvasGestureRecognizer()
    private var backgroundPattern: BackgroundPattern = BackgroundPattern()
    
    private var canvasRuntimeContext: SS1.FFI.CanvasRuntime!
    private var metalBackendContextPtr: SSMetalBackendContextPointer!
    
    private var metalDevice: MTLDevice!
    private var metalQueue: MTLCommandQueue!
    private var mtkView: MTKView = MTKView()
    
#if os(iOS)
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        self.backgroundPattern.setNeedsDisplay()
        self.mtkView.setNeedsDisplay()
    }
#elseif os(macOS)
    override var isFlipped: Bool {true}
    override func setNeedsDisplay(_ rect: NSRect) {
        super.setNeedsDisplay(rect)
        self.backgroundPattern.setNeedsDisplay(rect)
        self.mtkView.setNeedsDisplay(rect)
    }
#endif
    
    func setup(canvasModel: SS1.CanvasModel) {
        self.canvasModel = canvasModel
        self.canvasRuntimeContext = SS1.FFI.CanvasRuntime(rootScenePointer: canvasModel.pointer)
        self.canvasGestureRecognizer.canvasRuntime = self.canvasRuntimeContext
#if os(macOS)
        self.autoresizesSubviews = true
        self.autoresizingMask = [.width, .height]
        self.layerContentsRedrawPolicy = NSView.LayerContentsRedrawPolicy.beforeViewResize
#endif
        self.addGestureRecognizer(canvasGestureRecognizer)
        self.backgroundPattern.setup(parent: self)
        self.metalDevice = MTLCreateSystemDefaultDevice()
        self.metalQueue = self.metalDevice.makeCommandQueue()
        self.metalBackendContextPtr = metalBackendContextInit(self.metalDevice, self.metalQueue)
#if os(iOS)
        mtkView.backgroundColor = UIColor.clear
        mtkView.contentMode = .redraw
#elseif os(macOS)
        mtkView.layer?.isOpaque = false
        mtkView.autoResizeDrawable = true
        mtkView.autoresizingMask = [.width, .height]
        mtkView.autoresizesSubviews = true
#endif
        mtkView.clearColor = MTLClearColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.device = self.metalDevice
        mtkView.enableSetNeedsDisplay = true
        self.addSubview(mtkView)
        NSLayoutConstraint.activate([
            mtkView.topAnchor.constraint(equalTo: self.topAnchor),
            mtkView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            mtkView.leftAnchor.constraint(equalTo: self.leftAnchor),
            mtkView.rightAnchor.constraint(equalTo: self.rightAnchor),
        ])
        mtkView.depthStencilPixelFormat = .depth32Float_stencil8 // MTLPixelFormatDepth32Float_Stencil8
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.sampleCount = 1
        mtkView.delegate = self
    }
    
    func mtkView(_ _: MTKView, drawableSizeWillChange size: CGSize) {
        metalBackendContextReloadViewSurface(metalBackendContextPtr, mtkView)
    }
    func draw(in _: MTKView) {
        metalBackendContextReloadViewSurface(metalBackendContextPtr, mtkView)
        let viewInfo = SSViewInfo(
            size: SSFrameSize(
                width: Float(mtkView.frame.width),
                height: Float(mtkView.frame.height)
            ),
            preferred_color_scheme: self.colorScheme.toCFFI
        )
        let _ = ss1MetalViewDrawFlushAndSubmit(
            metalBackendContextPtr,
            canvasRuntimeContext.rootScenePointer,
            mtkView,
            viewInfo
        )
        let commandBuffer: MTLCommandBuffer = metalQueue.makeCommandBuffer()!
        let drawable = mtkView.currentDrawable!
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    
    fileprivate class BackgroundPattern: UI.LL.View {
#if os(macOS)
        override var isFlipped: Bool {true}
#endif
        fileprivate func setup(parent: RootMetalRenderer) {
            self.translatesAutoresizingMaskIntoConstraints = false
            parent.addSubview(self)
            NSLayoutConstraint.activate([
                self.leftAnchor.constraint(equalTo: parent.leftAnchor),
                self.rightAnchor.constraint(equalTo: parent.rightAnchor),
                self.topAnchor.constraint(equalTo: parent.topAnchor),
                self.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            ])
#if os(iOS)
            self.contentMode = .redraw
            self.backgroundColor = UI.LL.Color.clear
#elseif os(macOS)
#endif
        }
        
        override func draw(_ rect: CGRect) {
            let context = self.getCGContext()!
            // BACKGROUND
            context.saveGState()
            let backgroundColor = CANAVS_PAPER.get(for: self.colorScheme)
            context.setFillColor(backgroundColor.cgColor)
            context.fill(rect)
            // DRAW GRID LINES
            let lineColor = LINE_COLOR.get(for: self.colorScheme)
            let marginLineColor = #colorLiteral(red: 0.7126647534, green: 0.3747633605, blue: 0.5037802704, alpha: 1)
            context.setStrokeColor(lineColor.cgColor)
            var row: CGFloat = 0.0
            var column: CGFloat = 50.0
            while row < self.frame.height {
                context.move(to: CGPoint(x: 0, y: row))
                context.addLine(to: CGPoint(x: rect.maxX, y: row))
                row += 50.0
            }
            while column < self.frame.width {
                context.move(to: CGPoint(x: column, y: 0))
                context.addLine(to: CGPoint(x: column, y: rect.maxY))
                column += 50.0
            }
            context.strokePath()
            // DRAW BOTTOM MARGIN LINE
            context.setStrokeColor(marginLineColor.cgColor)
            context.move(to: CGPoint(x: 0, y: self.frame.height - 50))
            context.addLine(to: CGPoint(x: rect.maxX, y: self.frame.height - 50))
            context.strokePath()
            context.restoreGState()
        }
    }
}


extension SS1 {
    struct CanvasView: View {
        let index: Int?
        @ObservedObject var canvasModel: CanvasModel
        let isFirstChild: Bool
        let isLastChild: Bool
        let deleteMe: () -> ()
        let insertNewEntry: () -> ()
        let toggleVisibility: () -> ()
        let onUpdate: () -> ()
        
        @Environment(\.colorScheme) private var colorScheme
        @State private var showBottomMenu: Bool = false
        private var canvasHeight: CGFloat {
            return max(200, self.canvasModel.height)
        }
        private func incDrawingHeight() {
            canvasModel.height = max(0, canvasModel.height + 50)
            self.onUpdate()
        }
        private func bigIncDrawingHeight() {
            canvasModel.height = max(0, canvasModel.height + 250)
            self.onUpdate()
        }
        private func decDrawingHeight() {
            canvasModel.height = max(0, canvasModel.height - 50)
            self.onUpdate()
        }
        private func bigDecDrawingHeight() {
            canvasModel.height = max(0, canvasModel.height - 250)
            self.onUpdate()
        }
        @ViewBuilder private var topGutter: some View {
            HStack(alignment: .center, spacing: 0) {Spacer()}
                .background(Rectangle().foregroundColor(
                    colorScheme == .dark
                        ? SS1.StaticSettings.DarkMode.Canvas.BG2
                        : SS1.StaticSettings.LightMode.Canvas.BG2
                ))
                .padding([.top, .bottom], 4)
                .border(edges: [.bottom, .top])
        }
        @ViewBuilder private var header: some View {
            topGutter
        }
        @ViewBuilder private var bottomMenu: some View {
            HStack(alignment: .center, spacing: 0) {
                let spacing: CGFloat = 12
                let width: CGFloat = canvasModel.visible ? 35 : 35
                let height: CGFloat = canvasModel.visible ? 35 : 35
                let fontSizeScale: CGFloat = canvasModel.visible ? 0.65 : 0.5
                let bigWidth: CGFloat = 50
                let bigHeight: CGFloat = 50
                HStack(alignment: .center, spacing: spacing) {
                    Button(action: self.decDrawingHeight, label: {
                        Image(systemName: "minus")
                            .font(.system(size: 30 * fontSizeScale))
                    })
                        .buttonStyle(CircleButton(width: width, height: height))
                        .hidden(!canvasModel.visible)
                    Button(action: self.bigDecDrawingHeight, label: {
                        Image(systemName: "minus")
                            .font(.system(size: 30 * fontSizeScale))
                    })
                        .hidden(!canvasModel.visible)
                        .buttonStyle(CircleButton(width: bigWidth, height: bigHeight))
                    Button(action: self.bigIncDrawingHeight, label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24 * fontSizeScale))
                    })
                        .buttonStyle(CircleButton(width: bigWidth, height: bigHeight))
                        .hidden(!canvasModel.visible)
                    Button(action: self.incDrawingHeight, label: {
                        Image(systemName: "plus").font(.system(size: 24 * fontSizeScale))
                    })
                        .buttonStyle(CircleButton(width: width, height: height))
                        .hidden(!canvasModel.visible)
                    Spacer()
                }
                .frame(width: 100, alignment: .leading)
                Spacer()
                HStack(alignment: .center, spacing: spacing) {
                    Group {
                        Button(
                            action: {
//                                withAnimation {
//                                    canvasModel.visible.toggle()
//                                }
                                canvasModel.visible.toggle()
                                onUpdate()
                            },
                            label: {
                                let showIcon = "eye"
                                let hiddenIcon = "eye.slash"
                                Image(systemName: canvasModel.visible ? showIcon : hiddenIcon)
                                    .font(.system(size: 20 * fontSizeScale))
                            }
                        )
                            .buttonStyle(CircleButton(width: width, height: height))
                    }
                    Group {
                        let bgColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
                        Button(action: insertNewEntry, label: {
                            Image(systemName: "plus.square")
                                .font(.system(size: 24 * fontSizeScale))
                        })
                            .buttonStyle(CircleButton(
                                width: width,
                                height: height,
                                bgColor: UI.ColorMode(
                                    lightUI: bgColor,
                                    darkUI: bgColor
                                ),
                                fgColor: UI.ColorMode(
                                    lightUI: nil,
                                    darkUI: UI.LL.Color.black
                                )
                            ))
                    }
                    Group {
                        let bgColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
                        Button(action: deleteMe, label: {
                            Image(systemName: "trash")
                                .font(.system(size: 20 * fontSizeScale))
                        })
                            .buttonStyle(CircleButton(
                                width: width,
                                height: height,
                                bgColor: UI.ColorMode(
                                    lightUI: bgColor,
                                    darkUI: bgColor
                                ),
                                fgColor: UI.ColorMode(
                                    lightUI: nil,
                                    darkUI: UI.LL.Color.black
                                )
                            ))
                    }
                }
                .frame(width: 100, alignment: .center)
                
            }
            .padding([.leading, .trailing], 50)
            .padding(.top, 12)
            .padding(.bottom, canvasModel.visible ? 24 : 12)
        }
        @ViewBuilder private var canvas: some View {
            let mask = MaskView()
                .fill()
                .foregroundColor(Color.black)
            let darkMainShadowColor = Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
            let darkLastShadowColor = Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
            
            let lightMainShadowColor = Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5857864591))
            let lightLastShadowColor = Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5857864591))
            
            let lastShadowColor = colorScheme == .dark ? darkLastShadowColor : lightLastShadowColor
            let mainShadowColor = colorScheme == .dark ? darkMainShadowColor : lightMainShadowColor
            
            WrapView { ctx in
                let view: RootMetalRenderer = RootMetalRenderer()
                view.setup(canvasModel: self.canvasModel)
                return view
            }
//            Spacer()
            .frame(height: canvasHeight)
            .mask(mask)
            .shadow(
                color: isLastChild ? lastShadowColor : mainShadowColor,
                radius: isLastChild ? 4 : 2,
                x: 0,
                y: isLastChild ? 8 : 5
            )
        }
        var body: some View {
            let view = VStack(alignment: .center, spacing: 0) {
                if colorScheme == .light {
                    header
                } else {
                    header.background(Color(UI.DefaultColors.DARK_BG_COLOR_LIGHTER))
                }
                if canvasModel.visible {
                    ZStack(alignment: .top) {
                        canvas.hidden(!canvasModel.visible)
                        VStack(alignment: .center, spacing: 0) {
                            Spacer()
                            bottomMenu
                        }
                        .frame(height: canvasHeight + 80)
                    }
                } else {
                    bottomMenu
                }
            }
            if isLastChild || colorScheme == .light {
                view
            } else {
                view.background(Color(UI.DefaultColors.DARK_BG_COLOR_LIGHTER))
            }
        }
        fileprivate struct MaskView: Shape {
            static let offsetY: CGFloat = 20
#if os(iOS)
            func path(in rect: CGRect) -> Path {
                let centerY = rect.height - MaskView.offsetY
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
#elseif os(macOS)
            func path(in rect: CGRect) -> Path {
                let transform = CGAffineTransform
                        .init(scaleX: 1.0, y: -1.0)
                        .translatedBy(x: 0.0, y: -rect.height)
                let centerY = rect.height - MaskView.offsetY
                let steps = 545
                let stepX = rect.width / CGFloat(steps)
                var path = Path()
                path.move(to: CGPoint(x: 0, y: 0).applying(transform))
                for i in 0...steps {
                    let x = CGFloat(i) * stepX
                    let y = abs((cos(Double(i) * 0.15) * 10) + Double(centerY))
                    path.addLine(to: CGPoint(x: x, y: CGFloat(y)).applying(transform))
                }
                path.addLine(to: CGPoint(x: rect.width, y: 0.0).applying(transform))
                path.closeSubpath()
                return path
            }
#endif
        }
    }
}



