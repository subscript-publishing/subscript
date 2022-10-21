//
//  Canvas.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/19/22.
//

import Foundation

import SwiftUI
import Combine

fileprivate let CANAVS_PAPER_DARK_BG_COLOR: UI.Color = #colorLiteral(red: 0.1447366774, green: 0.1447366774, blue: 0.1447366774, alpha: 1)
fileprivate let CANAVS_PAPER_LIGHT_BG_COLOR: UI.Color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
fileprivate let DARK_LINE_COLOR: UI.Color = #colorLiteral(red: 0.2846999907, green: 0.2846999907, blue: 0.2846999907, alpha: 1)
fileprivate let LIGHT_LINE_COLOR: UI.Color = #colorLiteral(red: 0.7919328, green: 0.7919328, blue: 0.7919328, alpha: 1)

#if os(iOS)
#elseif os(macOS)
#endif


fileprivate class CanvasGestureRecognizer: UI.GestureRecognizer {
    weak var canvasRuntime: SS1.CanvasRuntime!
#if os(iOS)
    @inline(__always) private func addSample(touch: UITouch) {
        #if !targetEnvironment(macCatalyst)
        if touch.type != UITouch.TouchType.pencil {return}
        #endif
        let point = touch.location(in: self.view)
        let width = self.view!.frame.width
        let height = self.view!.frame.height
        self.canvasRuntime.recordStrokePoint(width: width, height: height, x: point.x, y: point.y)
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
        self.canvasRuntime.beginStroke()
        self.addSample(touches, with: event)
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
    private func addSample(event: NSEvent) {
        if self.dragging {
            let point = self.view!.convert(event.locationInWindow, from: nil)
            let width = self.view!.frame.width
            let height = self.view!.frame.height
            self.canvasRuntime.recordStrokePoint(width: width, height: height, x: point.x, y: point.y)
        }
    }
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.dragging = true
        self.canvasRuntime.beginStroke()
        self.addSample(event: event)
        self.view!.setNeedsDisplay(self.view!.frame)
    }
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        self.addSample(event: event)
        self.view!.setNeedsDisplay(self.view!.frame)
    }
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        self.dragging = false
        self.canvasRuntime.endStroke()
        self.view!.setNeedsDisplay(self.view!.frame)
    }
#endif
}

fileprivate class CanvasRendererView: UI.View {
    private var canvasRuntime = SS1.CanvasRuntime()
    private var canvasGestureRecognizer = CanvasGestureRecognizer()
    private var backgroundPattern: BackgroundPattern = BackgroundPattern()
    private var drawingRenderer: DrawingRenderer = DrawingRenderer()
#if os(macOS)
    override var isFlipped: Bool {true}
#endif
    func setupIOS() {
#if os(iOS)
        self.backgroundColor = UIColor.clear
#endif
    }
    func setup() {
        self.setupIOS()
        self.canvasGestureRecognizer.canvasRuntime = self.canvasRuntime
#if os(iOS)
        self.canvasGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.pencil.rawValue)]
#endif
        self.addGestureRecognizer(canvasGestureRecognizer)
        let newPen = SS1.Pen(
            color: SS1.ColorMode(
                lightUIColorMode: CodableColor(withColor: UI.Color.red),
                darkUIColorMode: CodableColor(withColor: UI.Color.red)
            )
        )
        newPen.setToCurrentPen()
        self.backgroundPattern.setup(parent: self)
        self.drawingRenderer.setup(parent: self)
    }
#if os(iOS)
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        self.backgroundPattern.setNeedsDisplay()
        self.drawingRenderer.setNeedsDisplay()
    }
#elseif os(macOS)
    override func setNeedsDisplay(_ rect: NSRect) {
        super.setNeedsDisplay(rect)
        self.backgroundPattern.setNeedsDisplay(rect)
        self.drawingRenderer.setNeedsDisplay(rect)
    }
#endif
    
    fileprivate class DrawingRenderer: UI.View {
        weak var canvasRuntime: SS1.CanvasRuntime!
#if os(macOS)
        override var isFlipped: Bool {true}
#endif
        fileprivate func setup(parent: CanvasRendererView) {
            self.canvasRuntime = parent.canvasRuntime
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
            self.backgroundColor = UI.Color.clear
#elseif os(macOS)
#endif
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            let context = self.getCGContext()!
            let width = self.frame.width;
            let height = self.frame.height;
            canvasRuntime.setColorScheme(colorScheme: self.colorScheme)
            canvasRuntime.draw(width: width, height: height, context: context)
        }
    }
    fileprivate class BackgroundPattern: UI.View {
#if os(macOS)
        override var isFlipped: Bool {true}
#endif
        fileprivate func setup(parent: CanvasRendererView) {
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
            self.backgroundColor = UI.Color.clear
#elseif os(macOS)
#endif
        }
        
        override func draw(_ rect: CGRect) {
            let context = self.getCGContext()!
            // BACKGROUND
            context.saveGState()
            let backgroundColor = self.colorScheme == .dark ? CANAVS_PAPER_DARK_BG_COLOR : CANAVS_PAPER_LIGHT_BG_COLOR
            context.setFillColor(backgroundColor.cgColor)
            context.fill(rect)
            // DRAW GRID LINES
            let lineColor = self.colorScheme == .dark ? DARK_LINE_COLOR : LIGHT_LINE_COLOR
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
    class CanvasModel: ObservableObject, Codable {
        var id = UUID.init()
        /// Drawn strokes
//        var foregroundStrokes: Array<Stroke> = []
//        var backgroundStrokes: Array<Stroke> = []
        /// Active stroke
//        var active: Stroke = Stroke()
//        var activeLayer: SS1.Stroke.Layer = SS1.Stroke.Layer.foreground
        @Published
        var height: CGFloat = 200
        @Published
        var visible: Bool = true
        
        enum CodingKeys: CodingKey {
            case foregroundStrokes, backgroundStrokes, height, visible
        }
        func encode(to encoder: Encoder) throws {
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try! container.encode(foregroundStrokes, forKey: .foregroundStrokes)
//            try! container.encode(backgroundStrokes, forKey: .backgroundStrokes)
//            try! container.encode(height, forKey: .height)
//            try! container.encode(visible, forKey: .visible)
        }
        init() {}
        required init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            foregroundStrokes = try container.decode(Array.self, forKey: .foregroundStrokes)
//            backgroundStrokes = try container.decode(Array.self, forKey: .backgroundStrokes)
//            height = try container.decode(CGFloat.self, forKey: .height)
//            visible = (try? container.decode(Bool.self, forKey: .visible)) ?? true
        }
    }
    struct CanvasView: View {
        @ObservedObject var canvasModel: CanvasModel
        let updateLayouts: () -> ()
        let isFirstChild: Bool
        let isLastChild: Bool
        let deleteMe: () -> ()
        let insertNewEntry: () -> ()
        let toggleVisibility: () -> ()
        
        @Environment(\.colorScheme) private var colorScheme
        @State private var showBottomMenu: Bool = false
        private var canvasHeight: CGFloat {
            return max(200, self.canvasModel.height)
        }
        private func incDrawingHeight() {
            canvasModel.height = max(0, canvasModel.height + 50)
            updateLayouts()
        }
        private func bigIncDrawingHeight() {
            canvasModel.height = max(0, canvasModel.height + 250)
            updateLayouts()
        }
        private func decDrawingHeight() {
            canvasModel.height = max(0, canvasModel.height - 50)
            updateLayouts()
        }
        private func bigDecDrawingHeight() {
            canvasModel.height = max(0, canvasModel.height - 250)
            updateLayouts()
        }
        @ViewBuilder private var topGutter: some View {
            HStack(alignment: .center, spacing: 0) {Spacer()}
                .background(Rectangle().foregroundColor(
                    colorScheme == .dark
                        ? SS1.StaticSettings.DarkMode.Canvas.BG2
                        : SS1.StaticSettings.LightMode.Canvas.BG2
                ))
                .padding([.top, .bottom], 4)
                .border(edges: [.top, .bottom])
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
                                withAnimation {
                                    canvasModel.visible.toggle()
                                }
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
                                    lightUIMode: bgColor,
                                    darkUIMode: bgColor
                                ),
                                fgColor: UI.ColorMode(
                                    lightUIMode: nil,
                                    darkUIMode: UI.Color.black
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
                                    lightUIMode: bgColor,
                                    darkUIMode: bgColor
                                ),
                                fgColor: UI.ColorMode(
                                    lightUIMode: nil,
                                    darkUIMode: UI.Color.black
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
            let darkMainShadowColor = Color(#colorLiteral(red: 0.0795307681, green: 0.0795307681, blue: 0.0795307681, alpha: 1))
            let darkLastShadowColor = Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
            
            let lightMainShadowColor = Color(#colorLiteral(red: 0.0795307681, green: 0.0795307681, blue: 0.0795307681, alpha: 0.3999450262))
            let lightLastShadowColor = Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5857864591))
            
            let lastShadowColor = colorScheme == .dark ? darkLastShadowColor : lightLastShadowColor
            let mainShadowColor = colorScheme == .dark ? darkMainShadowColor : lightMainShadowColor
            
            WrapView { ctx in
                let view: CanvasRendererView = CanvasRendererView()
                view.setup()
                return view
            }
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
            VStack(alignment: .center, spacing: 0) {
                header
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
        
        
        fileprivate struct MaskView2: Shape {
            static let offsetY: CGFloat = 20
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
        }
    }
}



