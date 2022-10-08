//
//  CGPoint.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/22/22.
//

import Foundation
import CoreGraphics

extension CGPoint: Hashable {
    static func == (lhs: CGPoint, rhs: CGPoint) -> Bool {
        let field1 = lhs.x == rhs.x
        let field2 = lhs.y == rhs.y
        return field1 && field2
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
    }
}



