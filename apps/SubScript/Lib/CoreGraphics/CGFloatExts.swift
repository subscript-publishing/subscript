//
//  CGFloat.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/22/22.
//

import CoreGraphics

extension CGFloat {
    func clamp(min: CGFloat, max: CGFloat) -> CGFloat {
        if self < min {
            return min
        }
        if self > max {
            return max
        }
        return self
    }
}
