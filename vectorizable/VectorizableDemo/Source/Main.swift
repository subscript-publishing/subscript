//
//  Main.swift
//  VectorizableDemo
//
//  Created by Colbyn Wadman on 10/28/22.
//

import Foundation
import SwiftUI
import Combine
import Metal
import MetalKit


struct UI {
    struct LL {
        
    }
}

#if os(iOS)
import UIKit
extension UI.LL {
    typealias GestureRecognizer = UIGestureRecognizer
    typealias View = UIView
    typealias ViewRepresentable = UIViewRepresentable
}
#elseif os(macOS)
import AppKit
extension UI.LL {
    typealias GestureRecognizer = NSGestureRecognizer
    typealias View = NSView
    typealias ViewRepresentable = NSViewRepresentable
}
#endif


struct WrapView<UIViewType: UI.LL.View>: UI.LL.ViewRepresentable {
#if os(iOS)
    typealias UIViewType = UIViewType
#elseif os(macOS)
    typealias NSViewType = UIViewType
#endif
    typealias Updater = (UIViewType, Context) -> Void
    
    fileprivate var makeView: (Context) -> UIViewType
    fileprivate var update: (UIViewType, Context) -> ()

    init(_ setup: @escaping (Context) -> UIViewType) {
        self.makeView = setup
        self.update = {(_, _) in ()}
    }

    init(setup: @escaping (Context) -> UIViewType, update: @escaping (UIViewType) -> ()) {
        self.makeView = setup
        self.update = {(wrapper, _) in update(wrapper)}
    }
    
#if os(iOS)
    func makeUIView(context: Context) -> UIViewType {
        return makeView(context)
    }
    func updateUIView(_ view: UIViewType, context: Context) {
        update(view, context)
    }
#elseif os(macOS)
    func makeNSView(context: Context) -> UIViewType {
        return makeView(context)
    }
    func updateNSView(_ view: UIViewType, context: Context) {
        update(view, context)
    }
#endif
}



class AppModel {
    var appModelPtr: RS_AppModelPtr
    
    init() {
        self.appModelPtr = app_model_new()
    }
    
    func beginStroke() {
        app_model_begin_stroke(self.appModelPtr)
    }
    func recordStrokePoint(point: CGPoint) {
        app_model_record_stroke_sample(self.appModelPtr, RS_Point(x: Float(point.x), y: Float(point.y)))
    }
    func endStroke() {
        app_model_end_stroke(self.appModelPtr)
    }
}



fileprivate final class CanvasGestureRecognizer: UI.LL.GestureRecognizer {
    private weak var appModel: AppModel!
    private var flush: (() -> ())!
    
    func setup(
        appModel: AppModel,
        view: UI.LL.View,
        flush: @escaping () -> ()
    ) {
        self.appModel = appModel
        self.flush = flush
        view.addGestureRecognizer(self)
    }
    
#if os(iOS)
    @inline(__always) private func addSample(touch: UITouch) {
//        let point = touch.location(in: self.view)
//        let width = self.view!.frame.width
//        let height = self.view!.frame.height
//        let force = touch.force
//        let sample = SS1.CanvasModel.SamplePoint(
//            point: point,
//            force: force
//        )
//        self.canvasRuntime.recordStrokePoint(width: width, height: height, sample: sample)
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
//        super.touchesBegan(touches, with: event)
//        self.canvasRuntime.beginStroke()
//        self.addSample(touches, with: event)
//        self.view!.setNeedsDisplay()
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
//        super.touchesMoved(touches, with: event)
//        self.addSample(touches, with: event)
//        self.view!.setNeedsDisplay()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
//        super.touchesEnded(touches, with: event)
//        self.addSample(touches, with: event)
//        self.canvasRuntime.endStroke()
//        self.view!.setNeedsDisplay()
    }
#elseif os(macOS)
    private var dragging: Bool = false
    private func addSample(event: NSEvent) {
        if self.dragging {
            let point = self.view!.convert(event.locationInWindow, from: nil)
//            let width = self.view!.frame.width
//            let height = self.view!.frame.height
            let cgPoint = CGPoint(x: point.x, y: point.y)
            self.appModel.recordStrokePoint(point: cgPoint)
        }
    }
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.dragging = true
        self.appModel.beginStroke()
//        self.addSample(event: event)
        self.view!.setNeedsDisplay(self.view!.frame)
    }
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        self.addSample(event: event)
        self.view!.setNeedsDisplay(self.view!.frame)
    }
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
//        self.addSample(event: event)
        self.dragging = false
        self.appModel.endStroke()
        self.flush!()
        self.view!.setNeedsDisplay(self.view!.frame)
    }
#endif
}




fileprivate final class MetalLayer: UI.LL.View, MTKViewDelegate {
    var onDraw: ((RS_MetalBackendContextPtr, MTKView) -> ())!
    private var metalBackendContextPtr: RS_MetalBackendContextPtr!
    private var metalDevice: MTLDevice!
    private var metalQueue: MTLCommandQueue!
    private var mtkView: MTKView = MTKView()
        
    #if os(iOS)
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        self.mtkView.setNeedsDisplay()
        self.updateSurface()
        self.updateSurface()
    }
    #elseif os(macOS)
    override var isFlipped: Bool {true}
    override func setNeedsDisplay(_ rect: NSRect) {
        super.setNeedsDisplay(rect)
        self.mtkView.setNeedsDisplay(rect)
        self.updateSurface()
    }
    #endif
        
    func setup(
        parent: RootMetalRenderer,
        onDraw: @escaping (RS_MetalBackendContextPtr, MTKView) -> ()
    ) {
        self.onDraw = onDraw
        self.metalDevice = MTLCreateSystemDefaultDevice()
        self.metalQueue = self.metalDevice.makeCommandQueue()
        self.metalBackendContextPtr = vectorizableMetalBackendContextInit(self.metalDevice, self.metalQueue)
        self.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: parent.topAnchor),
            self.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            self.leftAnchor.constraint(equalTo: parent.leftAnchor),
            self.rightAnchor.constraint(equalTo: parent.rightAnchor),
        ])
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
        vectorizableMetalBackendContextReloadViewSurface(metalBackendContextPtr, mtkView)
    }
    func updateSurface() {
        vectorizableMetalBackendContextReloadViewSurface(metalBackendContextPtr, mtkView)
    }
    func mtkView(_ _: MTKView, drawableSizeWillChange size: CGSize) {
        print(size, " <-> ", self.frame, " <-> ", mtkView.frame)
        self.updateSurface()
    }
    func draw(in _: MTKView) {
        self.onDraw(metalBackendContextPtr, mtkView)
        let commandBuffer: MTLCommandBuffer = metalQueue.makeCommandBuffer()!
        let drawable = mtkView.currentDrawable!
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

fileprivate final class RootMetalRenderer: UI.LL.View {
    private var appModel = AppModel()
    private var backgroundLayer: MetalLayer = MetalLayer()
    private var backgroundActiveLayer: MetalLayer = MetalLayer()
    private var foregroundLayer: MetalLayer = MetalLayer()
    private var foregroundActiveLayer: MetalLayer = MetalLayer()
    private var canvasGestureRecognizer: CanvasGestureRecognizer = CanvasGestureRecognizer()
    
#if os(iOS)
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        backgroundLayer.setNeedsDisplay()
        backgroundActiveLayer.setNeedsDisplay()
        foregroundLayer.setNeedsDisplay()
        foregroundActiveLayer.setNeedsDisplay()
    }
#elseif os(macOS)
    override var isFlipped: Bool {true}
    override func setNeedsDisplay(_ rect: NSRect) {
        super.setNeedsDisplay(rect)
        backgroundLayer.setNeedsDisplay(rect)
        backgroundActiveLayer.setNeedsDisplay(rect)
        foregroundLayer.setNeedsDisplay(rect)
        foregroundActiveLayer.setNeedsDisplay(rect)
    }
#endif
    
    func setup() {
        self.canvasGestureRecognizer.setup(
            appModel: self.appModel,
            view: self,
            flush: {
                app_model_force_flush(self.appModel.appModelPtr)
            }
        )
        backgroundActiveLayer.setup(
            parent: self,
            onDraw: { metalContextPtr, mtkView in
                print("DRAW > backgroundActiveLayer")
                vectorizableDrawFlushAndSubmitBackgroundActive(metalContextPtr, self.appModel.appModelPtr, mtkView)
            }
        )
        backgroundLayer.setup(
            parent: self,
            onDraw: { metalContextPtr, mtkView in
                print("DRAW > backgroundLayer")
                vectorizableDrawFlushAndSubmitBackground(metalContextPtr, self.appModel.appModelPtr, mtkView)
            }
        )
        foregroundActiveLayer.setup(
            parent: self,
            onDraw: { metalContextPtr, mtkView in
                print("DRAW > foregroundActiveLayer")
                vectorizableDrawFlushAndSubmitForegroundActive(metalContextPtr, self.appModel.appModelPtr, mtkView)
            }
        )
        foregroundLayer.setup(
            parent: self,
            onDraw: { metalContextPtr, mtkView in
                print("DRAW > foregroundLayer")
                vectorizableDrawFlushAndSubmitForeground(metalContextPtr, self.appModel.appModelPtr, mtkView)
            }
        )
    }
}


struct CanvasView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                Button(
                    action: {
                        toolbar_set_current_layer_to_foreground()
                    },
                    label: {
                        Text("Foreground")
                    }
                )
                Button(
                    action: {
                        toolbar_set_current_layer_to_background()
                    },
                    label: {
                        Text("Background")
                    }
                )
            }
            WrapView { _ in
                let view = RootMetalRenderer()
                view.setup()
                return view
            }
        }
    }
}


@main
struct VectorizableDemoApp: App {
    var body: some Scene {
        WindowGroup {
            CanvasView()
        }
    }
}


