//
//  SS1.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/19/22.
//

import Foundation
import Combine


/// SubScript Version 1 Namespace
struct SS1 {
    struct ColorMode: Codable {
        var lightUIColorMode: CodableColor = CodableColor.black
        var darkUIColorMode: CodableColor = CodableColor.white
    }
    enum CanvasLayer: String, Codable {
        case foreground
        case background
    }
    enum CurrentToolType {
        case pen
        case selection
        case eraser
        
        var isPen: Bool {
            switch self {
            case .pen: return true
            default: return false
            }
        }
        var isSelection: Bool {
            switch self {
            case .selection: return true
            default: return false
            }
        }
        var isEraser: Bool {
            switch self {
            case .eraser: return true
            default: return false
            }
        }
    }
    struct Canvas {
        
    }
}
