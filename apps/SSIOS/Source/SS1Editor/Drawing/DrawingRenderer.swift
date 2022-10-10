//
//  DrawingRenderer.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/22/22.
//

import SwiftUI
import UIKit

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CONSTANTS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

fileprivate let CANAVS_PAPER_DARK_BG_COLOR: UIColor = #colorLiteral(red: 0.1447366774, green: 0.1447366774, blue: 0.1447366774, alpha: 1)
fileprivate let CANAVS_PAPER_LIGHT_BG_COLOR: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
fileprivate let DARK_LINE_COLOR: UIColor = #colorLiteral(red: 0.2846999907, green: 0.2846999907, blue: 0.2846999907, alpha: 1)
fileprivate let LIGHT_LINE_COLOR: UIColor = #colorLiteral(red: 0.7919328, green: 0.7919328, blue: 0.7919328, alpha: 1)



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DRAWING GESTURE RECOGNIZER
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

fileprivate class DrawingGestureRecognizer: UIGestureRecognizer {
    fileprivate var paperIndex: Int!
    fileprivate var drawingPaper: SS1.DrawingDataModel!
    fileprivate var runtimeModel: SS1.RuntimeDataModel!
    fileprivate var drawingRendererView: DrawingRendererView!
    fileprivate var onChange: (() -> ())!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if runtimeModel.currentToolType.isAnyEditToolType {
            clearActiveStroke()
            drawingPaper.clearHighlights()
        }
        if runtimeModel.currentToolType.isPen {
            finalizeActiveStroke()
        }
        
        for touch in touches {
            addSample(touch: touch, event: event)
        }
        onChange()
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        for touch in touches {
            addSample(touch: touch, event: event)
        }
        onChange()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        // REGISTER TOUCHES
        for touch in touches {
            addSample(touch: touch, event: event)
        }
        // SAVE AND CLEAR ACTIVE STROKE
        let oldActive = drawingPaper.active
        finalizeActiveStroke()
        // APPLY EDITOR CHANGES
        if runtimeModel.currentToolType.isAnyEditToolType {
            if let boundingBox = oldActive.boundingBox(maxWidth: 1000) {
                let _ = drawingPaper.updateHighlights(withinRegion: boundingBox)
                if runtimeModel.currentToolType.isEraser {
                    drawingPaper.removeHighlights()
                }
            }
        }
        onChange()
    }
    @inline(__always)
    func finalizeActiveStroke() {
        if runtimeModel.currentToolType.isPen && !drawingPaper.active.isEmpty {
            switch drawingPaper.activeLayer {
            case .foreground:
                drawingPaper.foregroundStrokes.append(drawingPaper.active.finalize(
                    runtimeMode: runtimeModel
                ))
            case .background:
                drawingPaper.backgroundStrokes.append(drawingPaper.active.finalize(
                    runtimeMode: runtimeModel
                ))
            }
        }
        clearActiveStroke()
    }
    @inline(__always)
    func clearActiveStroke() {
        drawingPaper.active.uid = UUID()
        drawingPaper.active.samples.removeAll(keepingCapacity: true)
    }
    @inline(__always)
    private func addSample(touch: UITouch, event: UIEvent) {
        for x in event.coalescedTouches(for: touch) ?? [touch] {
            addSample(touch: x)
        }
    }
    @inline(__always)
    private func addSample(touch: UITouch) {
        // ONLY RESPOND TO APPLE PENCIL INPUT (UNLESS YOURE ON A MAC)
        #if !targetEnvironment(macCatalyst)
        if touch.type != UITouch.TouchType.pencil {return}
        #endif
        // GET LOCATION OF STROKE
        let absoluteLocation = touch.location(in: drawingRendererView)
        let xScale = MathUtils.newLinearScale(domain: (0, drawingRendererView.frame.width), range: (0, 1000))
        let relativeLocation = CGPoint(x: xScale(absoluteLocation.x), y: absoluteLocation.y)
        // FILTER
//        if let lastSample = drawingPaper.active.samples.last {
//            let angle = lastSample.point.angle(other: relativeLocation)
//            let length = lastSample.point.lengthBetween(other: relativeLocation)
//            if angle < pow(10, -3) || length < 1.0 {
//                return ()
//            }
//        }
        // APPEND SAMPLE TO ACTIVE STROKE
        drawingPaper.active.samples.append(SS1.Stroke.Sample(point: relativeLocation))
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DRAWING UTILS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

fileprivate func renderPenStroke(
    displayMode: ColorScheme,
    size: CGSize,
    context: CGContext,
    stroke: SS1.Stroke,
    isHighlighted: Bool,
    invertColor: Bool = false
) {
    if stroke.count < 2 {
        return ()
    }
    let xScale = MathUtils.newLinearScale(domain: (0, 1000), range: (0, size.width))
    let points: Array<CGPoint> = stroke.complexOutlinePoints().map { point in
        return CGPoint(x: xScale(point.x), y: point.y)
    }
    if points.count <= 2 {
        return ()
    }
    context.saveGState()
    context.beginPath()
    context.setFillColor(stroke.options.color.getCGColorFor(
        invertToggle: invertColor,
        displayMode
    ))
    context.addLines(between: points)
    context.closePath()
    if isHighlighted {
        let overrideColor = stroke.options.color
            .getUIColorFor(invertToggle: invertColor, displayMode)
            .withAlphaComponent(0.3)
            .cgColor
        context.setFillColor(overrideColor)
        context.drawPath(using: CGPathDrawingMode.fill)
    } else {
        context.fillPath()
    }
    context.restoreGState()
}

fileprivate func renderSelectionStroke(
    displayMode: ColorScheme,
    size: CGSize,
    context: CGContext,
    stroke: inout SS1.Stroke
) {
    if let boundingBox = stroke.boundingBox(maxWidth: size.width) {
        context.saveGState()
        context.beginPath()
        context.setStrokeColor(stroke.options.color.getCGColorFor(
            invertToggle: false,
            displayMode
        ))
        context.addRect(boundingBox.cgRect)
        context.drawPath(using: CGPathDrawingMode.stroke)
        context.restoreGState()
    }
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DRAWING RENDERER VIEW
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class DrawingRendererView: UIView {
    // SETTINGS
    fileprivate var colorScheme: ColorScheme!
    fileprivate var previewMode: Bool = false
    fileprivate var drawingPaper: SS1.DrawingDataModel!
    fileprivate var runtimeModel: SS1.RuntimeDataModel!
    // INETRNAL
    fileprivate var drawingGestureRecognizer = DrawingGestureRecognizer()
    fileprivate var backgroundPattern = BackgroundPattern()
    fileprivate var drawingView = DrawingView()
//    fileprivate var fingerPinchRecognizer: UIPinchGestureRecognizer!
    fileprivate var fingerPanRecognizer: UIPanGestureRecognizer!
    fileprivate var fingerTapRecognizer: UITapGestureRecognizer!

    
    func setup() {
        assert(self.drawingPaper != nil)
        assert(self.runtimeModel != nil)
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // PENCIL GESTURE RECOGNIZERS
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        #if !targetEnvironment(macCatalyst)
        drawingGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.pencil.rawValue)]
        #endif
        drawingGestureRecognizer.drawingPaper = drawingPaper
        drawingGestureRecognizer.drawingRendererView = self
        drawingGestureRecognizer.runtimeModel = runtimeModel
        drawingGestureRecognizer.onChange = {
            self.setNeedsDisplay()
        }
        if !previewMode {
            self.addGestureRecognizer(drawingGestureRecognizer)
        }
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // FINGER PINCH GESTURE RECOGNIZER
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//        fingerPinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(fingerPinchGestureHandler(_:)))
//        fingerPinchRecognizer.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
//        self.addGestureRecognizer(fingerPinchRecognizer)
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // FINGER PAN GESTURE RECOGNIZER
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        fingerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(fingerPanGestureHandler(_:)))
        fingerPanRecognizer.maximumNumberOfTouches = 1
        fingerPanRecognizer.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        fingerPanRecognizer.delaysTouchesBegan = true
        self.addGestureRecognizer(fingerPanRecognizer)
//        fingerPanRecognizer.canBePrevented(by: self.panGestureRecognizer)
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // FINGER TAP GESTURE RECOGNIZER
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        fingerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(fingerTapGestureHandler(_:)))
        fingerTapRecognizer.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        self.addGestureRecognizer(fingerTapRecognizer)
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // BACKGROUND GRID VIEW
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        backgroundPattern.setup(colorScheme: colorScheme, previewMode: previewMode, parent: self)
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // DRAWING RENDERER VIEW
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        drawingView.colorScheme = colorScheme
        drawingView.previewMode = previewMode
        drawingView.drawingPaper = self.drawingPaper
        drawingView.runtimeModel = self.runtimeModel
        drawingView.setup(colorScheme: colorScheme, parent: self)
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        backgroundPattern.setNeedsDisplay()
        drawingView.setNeedsDisplay()
    }
    
    @objc private func fingerTapGestureHandler(_ gesture: UITapGestureRecognizer) {
        if runtimeModel.currentToolType.isAnyEditToolType {
            drawingGestureRecognizer.clearActiveStroke()
            drawingPaper.clearHighlights()
            self.setNeedsDisplay()
        }
        if runtimeModel.currentToolType.isPen {
            drawingGestureRecognizer.finalizeActiveStroke()
            self.setNeedsDisplay()
        }
    }
    @objc func fingerPinchGestureHandler(_ gesture: UIPinchGestureRecognizer) {
//        let xScale = MathUtils.newLinearScale(domain: (0, drawingView.frame.width), range: (0, 1000))
//        let rawLocation = gesture.location(in: self.drawingView)
//        let location = CGPoint(x: xScale(rawLocation.x), y: rawLocation.y)
//        for highlightedStroke in drawingPaper.strokes.filter({drawingPaper.highlights.contains($0.uid)}) {
//            let midpoint = highlightedStroke.boundingBox(maxWidth: 1000)
//
//        }
//        gesture.scale = 1.0
//        self.setNeedsDisplay()
    }
    @objc func fingerPanGestureHandler(_ gesture: UIPanGestureRecognizer) {
        let xScale = MathUtils.newLinearScale(domain: (0, drawingView.frame.width), range: (0, 1000))
        let rawLocation = gesture.location(in: self.drawingView)
        let location = CGPoint(x: xScale(rawLocation.x), y: rawLocation.y)
        if drawingPaper.highlights.isEmpty {
            return
        }
        
        if let box = drawingPaper.highlightBox(maxWidth: 1000) {
            let region = box.cgRect
            let perStroke: (SS1.Stroke) -> SS1.Stroke = { stroke in
                if self.drawingPaper.highlights.contains(stroke.uid) {
                    var newStroke = stroke
                    let xOffset = location.x - region.midX
                    let yOffset = location.y - region.midY
                    let transform = CGAffineTransform.init(translationX: (xOffset / 10), y: (yOffset / 10))
                    newStroke.samples = stroke.samples.map {sample -> SS1.Stroke.Sample in
                        var newSample = sample
                        newSample.point = sample.point.applying(transform)
                        return newSample
                    }
                    return newStroke
                }
                return stroke
            }
            drawingPaper.foregroundStrokes = drawingPaper.foregroundStrokes.map(perStroke)
            drawingPaper.backgroundStrokes = drawingPaper.backgroundStrokes.map(perStroke)
        }
        self.setNeedsDisplay()
    }
    
    fileprivate class BackgroundPattern: UIView {
        fileprivate var colorScheme: ColorScheme!
        fileprivate var previewMode: Bool = false
        
        fileprivate func setup(colorScheme: ColorScheme, previewMode: Bool, parent: UIView) {
            self.previewMode = previewMode
            self.translatesAutoresizingMaskIntoConstraints = false
            parent.addSubview(self)
            NSLayoutConstraint.activate([
                self.leftAnchor.constraint(equalTo: parent.leftAnchor),
                self.rightAnchor.constraint(equalTo: parent.rightAnchor),
                self.topAnchor.constraint(equalTo: parent.topAnchor),
                self.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            ])
            self.contentMode = .redraw
            self.backgroundColor = UIColor.clear
            self.colorScheme = colorScheme
        }
        
        override func draw(_ rect: CGRect) {
            let context = UIGraphicsGetCurrentContext()!
            let lineColor = self.colorScheme == .dark ? DARK_LINE_COLOR : LIGHT_LINE_COLOR
            let marginLineColor = #colorLiteral(red: 0.7126647534, green: 0.3747633605, blue: 0.5037802704, alpha: 1)
            // DRAW GRID LINES
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
            if !previewMode {
                context.setStrokeColor(marginLineColor.cgColor)
                context.move(to: CGPoint(x: 0, y: self.frame.height - 50))
                context.addLine(to: CGPoint(x: rect.maxX, y: self.frame.height - 50))
                context.strokePath()
            }
        }
    }
    
    fileprivate class DrawingView: UIView {
        fileprivate var colorScheme: ColorScheme!
        fileprivate var previewMode: Bool = false
        fileprivate var paperIndex: Int!
        fileprivate var drawingPaper: SS1.DrawingDataModel!
        fileprivate var runtimeModel: SS1.RuntimeDataModel!
        private var initialized: Bool = false
        
        fileprivate func setup(colorScheme: ColorScheme, parent: UIView) {
            initialized = true
            self.translatesAutoresizingMaskIntoConstraints = false
            parent.addSubview(self)
            NSLayoutConstraint.activate([
                self.leftAnchor.constraint(equalTo: parent.leftAnchor),
                self.rightAnchor.constraint(equalTo: parent.rightAnchor),
                self.topAnchor.constraint(equalTo: parent.topAnchor),
                self.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            ])
            self.contentMode = .redraw
            self.backgroundColor = UIColor.clear
        }
        
        override func draw(_ rect: CGRect) {
            assert(initialized)
            assert(self.drawingPaper != nil)
            let context = UIGraphicsGetCurrentContext()!
            DrawingView.renderToCGContext(
                displayMode: colorScheme,
                context: context,
                runtimeModel: runtimeModel,
                drawingPaper: drawingPaper,
                size: rect.size
            )
        }
        static func renderToCGContext(
            displayMode: ColorScheme,
            context: CGContext,
            runtimeModel: SS1.RuntimeDataModel,
            drawingPaper: SS1.DrawingDataModel,
            size: CGSize
        ) {
            let isDrawingPen = runtimeModel.currentToolType.isPen
            let isEditorTool = runtimeModel.currentToolType.isAnyEditToolType
            if !drawingPaper.active.isEmpty && drawingPaper.activeLayer == .background && isDrawingPen {
                renderPenStroke(
                    displayMode: displayMode,
                    size: size,
                    context: context,
                    stroke: drawingPaper.active,
                    isHighlighted: false,
                    invertColor: runtimeModel.invertPenColors
                )
            }
            for stroke in drawingPaper.backgroundStrokes {
                let isHighlighted = drawingPaper.highlights.contains(stroke.uid)
                renderPenStroke(
                    displayMode: displayMode,
                    size: size,
                    context: context,
                    stroke: stroke,
                    isHighlighted: isHighlighted
                )
            }
            for stroke in drawingPaper.foregroundStrokes {
                let isHighlighted = drawingPaper.highlights.contains(stroke.uid)
                renderPenStroke(
                    displayMode: displayMode,
                    size: size,
                    context: context,
                    stroke: stroke,
                    isHighlighted: isHighlighted
                )
            }
            if !drawingPaper.active.isEmpty && drawingPaper.activeLayer == .foreground && isDrawingPen {
                renderPenStroke(
                    displayMode: displayMode,
                    size: size,
                    context: context,
                    stroke: drawingPaper.active,
                    isHighlighted: false,
                    invertColor: runtimeModel.invertPenColors
                )
            }
            if !drawingPaper.active.isEmpty && isEditorTool {
                renderSelectionStroke(
                    displayMode: displayMode,
                    size: size,
                    context: context,
                    stroke: &drawingPaper.active
                )
                renderPenStroke(
                    displayMode: displayMode,
                    size: size,
                    context: context,
                    stroke: drawingPaper.active,
                    isHighlighted: true
                )
            }
            if let box = drawingPaper.highlightBox(maxWidth: size.width) {
                let color = #colorLiteral(red: 0.7126647534, green: 0.3747633605, blue: 0.5037802704, alpha: 1)
                context.saveGState()
                context.beginPath()
                context.setStrokeColor(color.cgColor)
                context.addRect(box.cgRect)
                context.drawPath(using: CGPathDrawingMode.stroke)
                context.restoreGState()
                
                context.saveGState()
                context.beginPath()
                context.setFillColor(color.cgColor)
                context.addEllipse(in: CGRect(x: box.cgRect.midX - 5, y: box.cgRect.midY - 5, width: 10, height: 10))
                context.drawPath(using: CGPathDrawingMode.fill)
                context.restoreGState()
            }
        }
        static func computeCGImage(
            displayMode: ColorScheme,
            size: CGSize,
            runtimeModel: SS1.RuntimeDataModel,
            drawingPaper: SS1.DrawingDataModel
        ) -> Optional<CGImage> {
            autoreleasepool {
                let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
                let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
                let context: Optional<CGContext> = CGContext(
                    data: nil,
                    width: Int(size.width),
                    height: Int(size.height),
                    bitsPerComponent: 8,
                    bytesPerRow: 0,
                    space: colorSpace,
                    bitmapInfo: bitmapInfo.rawValue
                )
                if case let .some(context) = context {
                    context.setAllowsAntialiasing(true)
                    DrawingView.renderToCGContext(
                        displayMode: displayMode,
                        context: context,
                        runtimeModel: runtimeModel,
                        drawingPaper: drawingPaper,
                        size: size
                    )
                    return context.makeImage()!
                }
                return .none
            }
        }
    }
}


extension SS1.Drawing {
    /// Used in the drawing editor
    struct DisplayDrawingEntry: View {
        @ObservedObject
        var runtimeModel: SS1.RuntimeDataModel
        @ObservedObject
        var drawingModel: SS1.DrawingDataModel
        var previewMode: Bool = false
        let updateLayouts: () -> ()
        let deleteMe: () -> ()
        let insertNewPaper: () -> ()
        @Environment(\.colorScheme) private var colorScheme
        
        struct LeftSettingsView: View {
            @ObservedObject var runtimeModel: SS1.RuntimeDataModel
            @ObservedObject var drawingModel: SS1.DrawingDataModel
            @State private var expanded: Bool = false
            let updateLayouts: () -> ()
            @Environment(\.colorScheme) private var colorScheme
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
            var body: some View {
                let bottomPadding: CGFloat = 60
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .foregroundColor(Color(
                            colorScheme == .dark ? CANAVS_PAPER_DARK_BG_COLOR : CANAVS_PAPER_LIGHT_BG_COLOR
                        ))
                    if expanded {
                        let btnBgColor = #colorLiteral(red: 0.8545565443, green: 0.8545565443, blue: 0.8545565443, alpha: 1)
                        let textColor = Color.black
                        VStack(alignment: .center, spacing: 10) {
                            if drawingModel.height > 300 {
                                Button(
                                    action: bigDecDrawingHeight,
                                    label: {
                                        Image(systemName: "minus")
                                            .padding(25)
                                            .foregroundColor(textColor)
                                            .background(Circle().foregroundColor(Color(btnBgColor)))
                                            .font(
                                                .system(
                                                    size: 30,
                                                    weight: Font.Weight.light,
                                                    design: Font.Design.monospaced
                                                )
                                            )
                                    }
                                )
                            }
                            Button(
                                action: decDrawingHeight,
                                label: {
                                    Image(systemName: "minus")
                                        .padding(15)
                                        .foregroundColor(textColor)
                                        .background(Circle().foregroundColor(Color(btnBgColor)))
                                        .font(
                                            .system(
                                                size: 20,
                                                weight: Font.Weight.light,
                                                design: Font.Design.monospaced
                                            )
                                        )
                                }
                            )
                            Button(
                                action: {
                                    expanded = false
                                },
                                label: {
                                    Image(systemName: "chevron.left.2")
                                        .padding(10)
                                        .font(
                                            .system(
                                                size: 15,
                                                weight: Font.Weight.light,
                                                design: Font.Design.monospaced
                                            )
                                        )
                                }
                            )
                            Button(
                                action: incDrawingHeight,
                                label: {
                                    Image(systemName: "plus")
                                        .padding(10)
                                        .foregroundColor(textColor)
                                        .background(Circle().foregroundColor(Color(btnBgColor)))
                                        .font(
                                            .system(
                                                size: 15,
                                                weight: Font.Weight.light,
                                                design: Font.Design.monospaced
                                            )
                                        )
                                }
                            )
                            if drawingModel.height > 300 {
                                Button(
                                    action: bigIncDrawingHeight,
                                    label: {
                                        Image(systemName: "plus")
                                            .padding(15)
                                            .foregroundColor(textColor)
                                            .background(Circle().foregroundColor(Color(btnBgColor)))
                                            .font(
                                                .system(
                                                    size: 30,
                                                    weight: Font.Weight.light,
                                                    design: Font.Design.monospaced
                                                )
                                            )
                                    }
                                )
                            }
                        }
                        .padding(.bottom, bottomPadding)
                    } else {
                        VStack(alignment: .center, spacing: 0) {
                            Button(
                                action: {
                                    expanded = true
                                },
                                label: {
                                    Image(systemName: "chevron.right.2")
                                }
                            )
                        }
                        .padding(.bottom, bottomPadding)
                    }
                }
                .frame(maxWidth: expanded ? 70 : 40)
            }
        }
        struct RightSettingsView: View {
            @ObservedObject var runtimeModel: SS1.RuntimeDataModel
            @ObservedObject var drawingModel: SS1.DrawingDataModel
            let updateLayouts: () -> ()
            let deleteMe: () -> ()
            let insertNewPaper: () -> ()
            @State private var expanded: Bool = false
            @Environment(\.colorScheme) private var colorScheme
            var body: some View {
                let bottomPadding: CGFloat = 60
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .foregroundColor(Color(CANAVS_PAPER_DARK_BG_COLOR))
                    if expanded {
//                        let btnBgColor = #colorLiteral(red: 0.8545565443, green: 0.8545565443, blue: 0.8545565443, alpha: 1)
                        let textColor = Color.black
                        VStack(alignment: .center, spacing: 10) {
                            Button(
                                action: deleteMe,
                                label: {
                                    let bgColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
                                    Image(systemName: "trash")
                                        .padding(10)
                                        .foregroundColor(textColor)
                                        .background(Circle().foregroundColor(Color(bgColor)))
                                        .font(
                                            .system(
                                                size: 20,
                                                weight: Font.Weight.light,
                                                design: Font.Design.monospaced
                                            )
                                        )
                                }
                            )
                            Button(
                                action: {
                                    expanded = false
                                },
                                label: {
                                    Image(systemName: "chevron.right.2")
                                        .padding(10)
                                        .font(
                                            .system(
                                                size: 20,
                                                weight: Font.Weight.light,
                                                design: Font.Design.monospaced
                                            )
                                        )
                                }
                            )
                            Button(
                                action: insertNewPaper,
                                label: {
                                    let bgColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
                                    Image(systemName: "plus.square")
                                        .padding(10)
                                        .foregroundColor(textColor)
                                        .background(Circle().foregroundColor(Color(bgColor)))
                                        .font(
                                            .system(
                                                size: 20,
                                                weight: Font.Weight.light,
                                                design: Font.Design.monospaced
                                            )
                                        )
                                }
                            )
                        }
                        .padding(.bottom, bottomPadding)
                    } else {
                        VStack(alignment: .center, spacing: 0) {
                            Button(
                                action: {
                                    expanded = true
                                },
                                label: {
                                    Image(systemName: "chevron.left.2")
                                }
                            )
                        }
                        .padding(.bottom, bottomPadding)
                    }
                }
                .frame(maxWidth: expanded ? 70 : 40)
            }
        }
        
        @ViewBuilder private func leftSettingsView() -> some View {
            LeftSettingsView(
                runtimeModel: runtimeModel,
                drawingModel: drawingModel,
                updateLayouts: updateLayouts
            )
                .border(width: 1, edges: [.trailing])
        }
        
        @ViewBuilder private func rightSettingsView() -> some View {
            RightSettingsView(
                runtimeModel: runtimeModel,
                drawingModel: drawingModel,
                updateLayouts: updateLayouts,
                deleteMe: deleteMe,
                insertNewPaper: insertNewPaper
            )
                .border(width: 1, edges: [.leading])
        }
        
        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                if colorScheme == .light {
                    WrapView {
                        let drawingRendererView = DrawingRendererView()
                        drawingRendererView.colorScheme = .light
                        drawingRendererView.previewMode = previewMode
                        drawingRendererView.drawingPaper = drawingModel
                        drawingRendererView.runtimeModel = runtimeModel
                        drawingRendererView.backgroundColor = CANAVS_PAPER_LIGHT_BG_COLOR
                        drawingRendererView.setup()
                        return drawingRendererView
                    }
                } else {
                    WrapView {
                        let drawingRendererView = DrawingRendererView()
                        drawingRendererView.colorScheme = .dark
                        drawingRendererView.previewMode = previewMode
                        drawingRendererView.drawingPaper = drawingModel
                        drawingRendererView.runtimeModel = runtimeModel
                        drawingRendererView.backgroundColor = CANAVS_PAPER_DARK_BG_COLOR
                        drawingRendererView.setup()
                        return drawingRendererView
                    }
                }
            }
        }
    }
    /// Used in image previews
    struct DisplayEntireDrawing: View {
        @StateObject private var runtimeModel = SS1.RuntimeDataModel()
        @ObservedObject var canvasModel: SS1.CanvasDataModel
        @Environment(\.colorScheme) private var colorScheme
        private func renderDrawings(size: CGSize, ix: Int) -> Optional<(CGImage, CGImage)> {
            let height = (canvasModel.entries[ix].height - 50) * 1.5
            let width = size.width * 1.5
            let rect = CGRect(x: 0, y: 0, width: width, height: height)
            let darkCgImage: CGImage? = DrawingRendererView.DrawingView.computeCGImage(
                displayMode: .dark,
                size: rect.size,
                runtimeModel: runtimeModel,
                drawingPaper: canvasModel.entries[ix]
            )
            let lightCgImage: CGImage? = DrawingRendererView.DrawingView.computeCGImage(
                displayMode: .light,
                size: rect.size,
                runtimeModel: runtimeModel,
                drawingPaper: canvasModel.entries[ix]
            )
            if case let .some(darkCgImage) = darkCgImage {
                if case let .some(lightCgImage) = lightCgImage {
                    return .some((darkCgImage, lightCgImage))
                }
            }
            return .none
        }
        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                ForEach(Array(canvasModel.entries.enumerated()), id: \.1.id) {(ix, _) in
                    GeometryReader { geo in
                        if case let .some((darkCgImage, lightCgImage)) = self.renderDrawings(size: geo.size, ix: ix) {
                            if colorScheme == .dark {
                                Image(decorative: darkCgImage, scale: 1.5, orientation: Image.Orientation.downMirrored).resizable()
                                    .foregroundColor(Color.clear)
                            } else {
                                Image(decorative: lightCgImage, scale: 1.5, orientation: Image.Orientation.downMirrored).resizable()
                                    .foregroundColor(Color.clear)
                            }
                        } else {
                            Text("Failed to Render Drawing")
                        }
                    }
                    .frame(height: max(canvasModel.entries[ix].height - 50, 100))
                }
            }
        }
    }
}

