//
//  SwiftDev.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/23/22.
//

import Foundation
import Metal
import MetalKit

//class DevMetalView: UI.LL.ViewController, MTKViewDelegate {
//    var metalQueue: MTLCommandQueue!
//    var canvasContext: OpaquePointer!
//    var canvasSurface: OpaquePointer!
//    var mtkView: MTKView!
//    var metalDevice: MTLDevice!
//
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
//    func draw(in view: MTKView) {
//        // RUST SKIA
//        let _canvasSurface = mtkViewToCanvasSurface(view, self.canvasContext);
//        app_logic_flush_canvas_surface(_canvasSurface);
//        // METAL - PRESENT & COMMIT
//        let commandBuffer: MTLCommandBuffer = self.metalQueue.makeCommandBuffer()!
//        commandBuffer.present(view.currentDrawable!)
//        commandBuffer.commit()
//    }
//#if os(macOS)
//    override func loadView() {
//        self.view = NSView()
//        self.view.autoresizingMask = [.width, .height]
//        self.view.autoresizesSubviews = true
//    }
//#endif
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.metalDevice = MTLCreateSystemDefaultDevice()
//        self.metalQueue = self.metalDevice.makeCommandQueue()
//        self.mtkView = MTKView()
//        self.mtkView.translatesAutoresizingMaskIntoConstraints = false
//        self.mtkView.device = self.metalDevice
//        self.mtkView.enableSetNeedsDisplay = true
//        self.view.addSubview(self.mtkView)
//        NSLayoutConstraint.activate([
//            self.mtkView.topAnchor.constraint(equalTo: self.view.topAnchor),
//            self.mtkView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//            self.mtkView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
//            self.mtkView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
//        ])
//        self.mtkView.depthStencilPixelFormat = .depth32Float_stencil8 // MTLPixelFormatDepth32Float_Stencil8
//        self.mtkView.colorPixelFormat = .bgra8Unorm
//        self.mtkView.sampleCount = 1
//        self.canvasContext = metalDeviceToRustContext(self.mtkView, self.metalDevice, self.metalQueue)
//        self.mtkView.delegate = self
//    }
//}



//class DevMetalView: UI.LL.View, MTKViewDelegate {
//    var metalQueue: MTLCommandQueue!
//    var canvasContext: OpaquePointer!
//    var canvasSurface: OpaquePointer!
//    var mtkView: MTKView!
//    var metalDevice: MTLDevice!
//    
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
//    func draw(in view: MTKView) {
//        // RUST SKIA
//        let _canvasSurface = mtkViewToCanvasSurface(view, self.canvasContext);
//        app_logic_flush_canvas_surface(_canvasSurface);
//        // METAL - PRESENT & COMMIT
//        let commandBuffer: MTLCommandBuffer = self.metalQueue.makeCommandBuffer()!
//        commandBuffer.present(view.currentDrawable!)
//        commandBuffer.commit()
//    }
//    
//    func setup() {
//        self.metalDevice = MTLCreateSystemDefaultDevice()
//        self.metalQueue = self.metalDevice.makeCommandQueue()
//        self.mtkView = MTKView()
//        self.mtkView.translatesAutoresizingMaskIntoConstraints = false
//        self.mtkView.device = self.metalDevice
//        self.mtkView.enableSetNeedsDisplay = true
//        self.addSubview(self.mtkView)
//        NSLayoutConstraint.activate([
//            self.mtkView.topAnchor.constraint(equalTo: self.topAnchor),
//            self.mtkView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
//            self.mtkView.leftAnchor.constraint(equalTo: self.leftAnchor),
//            self.mtkView.rightAnchor.constraint(equalTo: self.rightAnchor),
//        ])
//        self.mtkView.depthStencilPixelFormat = .depth32Float_stencil8 // MTLPixelFormatDepth32Float_Stencil8
//        self.mtkView.colorPixelFormat = .bgra8Unorm
//        self.mtkView.sampleCount = 1
//        self.canvasContext = metalDeviceToRustContext(self.mtkView, self.metalDevice, self.metalQueue)
//        self.mtkView.delegate = self
//    }
//}





