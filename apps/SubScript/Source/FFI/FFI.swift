//
//  FFI.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/19/22.
//

import Foundation
import SwiftUI

extension ColorScheme {
    fileprivate var asCDataType: SS1_CAPI_ColorScheme {
        switch self {
        case .light: return Light
        case .dark: return Dark
        default: return Light
        }
    }
}

extension UI.LL.Color {
    fileprivate var asCDataType: SS1_CAPI_Color {
        let (r,g,b,a) = self.rgba;
        let hsba = self.hsba;
        return SS1_CAPI_Color(
            hsba: SS1_CAPI_HSBA(
                hue: hsba.hue,
                saturation: hsba.saturation,
                brightness: hsba.brightness,
                alpha: hsba.alpha
            ),
            rgba: SS1_CAPI_RGBA(
                red: r,
                green: g,
                blue: b,
                alpha: a
            )
        )
    }
}

extension SS1.Pen.PenStyle.DualColor {
    fileprivate var asCDataType: SS1_CAPI_DualColors {
        SS1_CAPI_DualColors(
            dark_ui: self.darkUI.asXColor.asCDataType,
            light_ui: self.lightUI.asXColor.asCDataType
        )
    }
}

extension SS1.Pen.PenStyle.Easing {
    fileprivate var asCDataType: SS1_CAPI_Easing {
        switch self {
        case .linear: return Linear
        case .easeInQuad: return EaseInQuad
        case .easeOutQuad: return EaseOutQuad
        case .easeInOutQuad: return EaseInOutQuad
        case .easeInCubic: return EaseInCubic
        case .easeOutCubic: return EaseOutCubic
        case .easeInOutCubic: return EaseInOutCubic
        case .easeInQuart: return EaseInQuart
        case .easeOutQuart: return EaseOutQuart
        case .easeInOutQuart: return EaseInOutQuart
        case .easeInQuint: return EaseInQuint
        case .easeOutQuint: return EaseOutQuint
        case .easeInOutQuint: return EaseInOutQuint
        case .easeInSine: return EaseInSine
        case .easeOutSine: return EaseOutSine
        case .easeInOutSine: return EaseInOutSine
        case .easeInExpo: return EaseInExpo
        case .easeOutExpo: return EaseOutExpo
        }
    }
}

extension SS1.Pen.PenStyle.Layer {
    fileprivate var asCDataType: SS1_CAPI_Layer {
        switch self {
        case .foreground: return Foreground
        case .background: return Background
        }
    }
}

extension SS1.Pen.PenStyle.StartCap {
    fileprivate var asCDataType: SS1_CAPI_StartCap {
        SS1_CAPI_StartCap(cap: self.cap, taper: self.taper, easing: self.easing.asCDataType)
    }
}
extension SS1.Pen.PenStyle.EndCap {
    fileprivate var asCDataType: SS1_CAPI_EndCap {
        SS1_CAPI_EndCap(cap: self.cap, taper: self.taper, easing: self.easing.asCDataType)
    }
}

extension SS1.Pen.PenStyle {
    fileprivate var asCDataType: SS1_CAPI_StrokeStyle {
        return SS1_CAPI_StrokeStyle(
            color: self.color.asCDataType,
            layer: self.layer.asCDataType,
            size: self.size,
            thinning: self.thinning,
            smoothing: self.smoothing,
            streamline: self.streamline,
            easing: self.easing.asCDataType,
            simulate_pressure: self.simulatePressure,
            start: self.start.asCDataType,
            end: self.end.asCDataType
        )
    }
}

extension SS1.CanvasModel.SamplePoint {
    fileprivate var asCDataType: SS1_CAPI_SamplePoint {
        SS1_CAPI_SamplePoint(
            point: (self.point.x, self.point.y),
            force: self.force ?? 0.0,
            has_force: self.force != nil
        )
    }
}

extension SS1.Pen {
    func setToCurrentPen() {
        ss1_toolbar_runtime_set_active_tool_to_stroke(self.style.asCDataType)
    }
}

extension SS1 {
    class CanvasRuntime {
        private var canvas_runtime_ptr: SS1_CAPI_CanvasRuntimeContextPtr
//        private var metal_view_context_ptr: SS1_CAPI_MetalViewContextPtr!
        
        init() {
            self.canvas_runtime_ptr = ss1_canvas_runtime_context_new()
        }
        func beginStroke() {
            ss1_canvas_runtime_context_begin_stroke(self.canvas_runtime_ptr)
        }
        func recordStrokePoint(
            width: CGFloat,
            height: CGFloat,
            sample: SS1.CanvasModel.SamplePoint
        ) {
            ss1_canvas_runtime_context_record_stroke_sample(self.canvas_runtime_ptr, sample.asCDataType)
        }
        func endStroke() {
            ss1_canvas_runtime_context_end_stroke(self.canvas_runtime_ptr)
        }
        func drawFlushAndSubmit(
            width: CGFloat,
            height: CGFloat,
            colorScheme: ColorScheme,
            metalViewContextPtr: SS1_CAPI_MetalViewContextPtr
        ) {
            self.setViewState(width: width, height: height, colorScheme: colorScheme)
            metal_canvas_view_draw_flush_and_submit(metalViewContextPtr, self.canvas_runtime_ptr);
        }
        func setViewState(width: CGFloat, height: CGFloat, colorScheme: ColorScheme) {
            ss1_canvas_runtime_context_set_view_state(
                self.canvas_runtime_ptr,
                SS1_CAPI_ViewState(
                    width: width,
                    height: height,
                    color_scheme: colorScheme.asCDataType
                )
            )
        }
    }
}


