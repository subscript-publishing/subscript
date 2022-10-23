//
//  ToolTypes.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/22/22.
//

import Foundation
import struct CoreGraphics.CGPoint

extension SS1.CanvasModel {
    struct SamplePoint {
        var point: CGPoint
        var force: CGFloat? = nil
    }
}
