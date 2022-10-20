//
//  FFI.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/19/22.
//

import Foundation
import SwiftUI

extension UI.Color {
    var asSSV1RGBAColor: SSV1RGBAColor {
        let (r,g,b,a) = self.rgba;
        return SSV1RGBAColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension SS1.ColorMode {
    var asSSV1ColorModes: SSV1ColorModes {
        SSV1ColorModes(
            light: self.lightUIColorMode.color.asSSV1RGBAColor,
            dark: self.darkUIColorMode.color.asSSV1RGBAColor
        )
    }
}

extension SS1.Pen {
    var asSSV1Pen: SSV1Pen {
        SSV1Pen(color: self.color.asSSV1ColorModes)
    }
    func setToCurrentPen() {
        ssv1_global_runtime_set_active_pen(self.asSSV1Pen)
    }
}

extension SS1 {
    class CanvasRuntime {
        private var ptr: SSV1CanvasRuntimePtr
        init() {
            self.ptr = ssv1_init_canvas_runtime()
        }
        func beginStroke() {
            ssv1_canvas_runtime_begin_stroke(self.ptr)
        }
        func recordStrokePoint(width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat) {
            ssv1_canvas_runtime_record_stroke_point(self.ptr, width, height, x, y)
        }
        func endStroke() {
            ssv1_canvas_runtime_end_stroke(self.ptr)
        }
        func draw(width: CGFloat, height: CGFloat, context: CGContext) {
            ssv1_canvas_runtime_draw(self.ptr, width, height, context)
        }
        func setColorScheme(colorScheme: ColorScheme) {
            switch colorScheme {
            case .light: ssv1_canvas_runtime_set_color_scheme(self.ptr, SSColorSchemeLight)
            case .dark: ssv1_canvas_runtime_set_color_scheme(self.ptr, SSColorSchemeDark)
            @unknown default: ()
            }
        }
    }
}

//fileprivate func test() {
//    let result = ssv1_init_canvas_runtime()
//}
