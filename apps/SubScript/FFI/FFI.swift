//
//  FFI.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/19/22.
//

import Foundation
import SwiftUI

extension CGPoint {
    var toCFFI: SSPoint {
        SSPoint(x: Float(self.x), y: Float(self.y))
    }
}

extension ColorScheme {
    var toCFFI: SSColorSchemeType {
        switch self {
        case .light: return SSColorSchemeType_Light
        case .dark: return SSColorSchemeType_Dark
        default: return SSColorSchemeType_Light
        }
    }
}

extension UI.LL.Color {
    var toCFFI: SSFatColor {
        let rgba = self.rgba;
        let hsba = self.hsba;
        return SSFatColor(
            hsba: SSHSBA(
                hue: hsba.hue,
                saturation: hsba.saturation,
                brightness: hsba.brightness,
                alpha: hsba.alpha
            ),
            rgba: SSRGBA(
                red: rgba.red,
                green: rgba.green,
                blue: rgba.blue,
                alpha: rgba.alpha
            )
        )
    }
}

extension UI.ColorType.HSBA {
    var toCFFI: SSHSBA {
        SSHSBA(
            hue: self.hue,
            saturation: self.saturation,
            brightness: self.brightness,
            alpha: self.alpha
        )
    }
}
extension UI.ColorType.RGBA {
    var toCFFI: SSRGBA {
        SSRGBA(red: self.red, green: self.green, blue: self.blue, alpha: self.alpha)
    }
}


//
extension SS1.PenModel.DualColor {
    var toCFFI: SSDualColors {
        let hsbaDark = self.darkUI;
        let rgbaDark = self.darkUI.asXColor.rgba
        let hsbaLight = self.lightUI;
        let rgbaLight = self.lightUI.asXColor.rgba
        return SSDualColors(
            dark_ui: SSFatColor(hsba: hsbaDark.toCFFI, rgba: rgbaDark.toCFFI),
            light_ui: SSFatColor(hsba: hsbaLight.toCFFI, rgba: rgbaLight.toCFFI)
        )
    }
}

extension SS1.PenModel.DynamicPenStyle.Easing {
    var toCFFI: SSEasing {
        switch self {
        case .linear: return SSEasing_Linear
        case .easeInQuad: return SSEasing_EaseInQuad
        case .easeOutQuad: return SSEasing_EaseOutQuad
        case .easeInOutQuad: return SSEasing_EaseInOutQuad
        case .easeInCubic: return SSEasing_EaseInCubic
        case .easeOutCubic: return SSEasing_EaseOutCubic
        case .easeInOutCubic: return SSEasing_EaseInOutCubic
        case .easeInQuart: return SSEasing_EaseInQuart
        case .easeOutQuart: return SSEasing_EaseOutQuart
        case .easeInOutQuart: return SSEasing_EaseInOutQuart
        case .easeInQuint: return SSEasing_EaseInQuint
        case .easeOutQuint: return SSEasing_EaseOutQuint
        case .easeInOutQuint: return SSEasing_EaseInOutQuint
        case .easeInSine: return SSEasing_EaseInSine
        case .easeOutSine: return SSEasing_EaseOutSine
        case .easeInOutSine: return SSEasing_EaseInOutSine
        case .easeInExpo: return SSEasing_EaseInExpo
        case .easeOutExpo: return SSEasing_EaseOutExpo
        }
    }
}

extension SS1.PenModel.DynamicPenStyle.Layer {
    var toCFFI: SSCanvasPlacement {
        switch self {
        case .foreground: return SSCanvasPlacement_Foreground
        case .background: return SSCanvasPlacement_Background
        }
    }
}

extension SS1.PenModel.DynamicPenStyle.StartCap {
    var toCFFI: SSStrokeCap {
        SSStrokeCap(cap: self.cap, taper: Float(self.taper), easing: self.easing.toCFFI)
    }
}
extension SS1.PenModel.DynamicPenStyle.EndCap {
    var toCFFI: SSStrokeCap {
        SSStrokeCap(cap: self.cap, taper: Float(self.taper), easing: self.easing.toCFFI)
    }
}

extension SS1.PenModel.DynamicPenStyle {
    var toCFFI: SSDynamicStrokeStyle {
        SSDynamicStrokeStyle(
            color: self.color.toCFFI,
            canvas_placement: self.layer.toCFFI,
            size: self.size,
            thinning: self.thinning,
            smoothing: self.smoothing,
            streamline: self.streamline,
            easing: self.easing.toCFFI,
            simulate_pressure: self.simulatePressure,
            start: self.start.toCFFI,
            end: self.end.toCFFI
        )
    }
}

//extension SS1.ToolBarModel.EditToolSettings.SelectionType {
//    var toCFFI: SSSelectionType {
//        switch self {
//        case .strikeThrough: return SSSelectionType_StrikeThrough
//        case .area: return SSSelectionType_Area
//        }
//    }
//}
extension SS1.ToolBarModel.EditToolSettings.ActiveLayer {
    var toCFFI: SSSelectionLayer {
        switch self {
        case .both: return SSSelectionLayer_Both
        case .background: return SSSelectionLayer_Background
        case .foreground: return SSSelectionLayer_Foreground
        }
    }
}

extension SS1.ToolBarModel.EditToolSettings {
    var toCFFI: SSEditToolSettings {
        SSEditToolSettings(
            selection_layer: self.selectionLayer.toCFFI
        )
    }
}

extension SS1.CanvasModel.SamplePoint {
    var toCFFI: SSSamplePoint {
        SSSamplePoint(
            point: self.point.toCFFI,
            force: SSForce(value: Float(self.force ?? 0.0), ignore: self.force == nil)
        )
    }
}

extension SS1.PenModel {
    func setToCurrentPen() {
//        toolbar_set_current_tool_to_stroke(self.style.toCFFI)
        toolbar_set_current_tool_to_dynamic_stroke(self.dynamicPenStyle.toCFFI)
    }
}

fileprivate struct SSPointer: Codable {
    let ptr: UInt
}
extension SSPointer_RootScene {
    fileprivate var toCFFI: SSPointer {
        let ptr = UInt(bitPattern: self.ptr!)
        return SSPointer(ptr: ptr)
    }
}

extension SSPointer_RootScene: Codable {
    public func encode(to encoder: Encoder) throws {
        return try self.toCFFI.encode(to: encoder)
    }
    public init(from decoder: Decoder) throws {
        self.init()
        let result = try SSPointer(from: decoder)
        self.ptr = result.ptr as! OpaquePointer?
    }
}

extension SSByteArrayPointer {
    static func with_codable<T: Encodable>(value: T, _ f: @escaping (SSByteArrayPointer) -> ()) {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(value)
            encoded.withUnsafeBytes { rawBufferPointer in
                let bufferPointer: UnsafePointer<UInt8> = rawBufferPointer.baseAddress!.assumingMemoryBound(to: UInt8.self)
                let count = rawBufferPointer.count
                let ssByteArrayPointer = SSByteArrayPointer(head: bufferPointer, len: UInt(count))
                f(ssByteArrayPointer)
            }
        } catch {
            print("ERROR [SSByteArrayPointer.with_codable]", error)
        }
    }
}

//fileprivate struct ByteArrayPointer {
//    let head:
//}

extension SS1.FFI {
    class CanvasRuntime {
        var rootScenePointer: SSRootScenePointer
        
        init(rootScenePointer: SSRootScenePointer) {
            self.rootScenePointer = rootScenePointer
        }
        
        func beginStroke(startPoint: SS1.CanvasModel.SamplePoint) {
            root_scene_begin_stroke(self.rootScenePointer, startPoint.toCFFI)
        }
        func recordStrokePoint(
            width: CGFloat,
            height: CGFloat,
            sample: SS1.CanvasModel.SamplePoint
        ) {
            root_scene_record_stroke_sample(self.rootScenePointer, sample.toCFFI)
        }
        func endStroke() {
            root_scene_end_stroke(self.rootScenePointer)
        }
    }
}


