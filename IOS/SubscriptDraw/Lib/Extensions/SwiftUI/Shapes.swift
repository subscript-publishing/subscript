//
//  Shapes.swift
//  SubscriptDraw
//
//  Created by Colbyn Wadman on 10/6/22.
//

import SwiftUI

extension Shape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(fillStyle: Fill, stroke: Stroke, lineWidth: Double = 1) -> some View {
        self
            .stroke(stroke, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}

extension InsettableShape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(fillStyle: Fill, stroke: Stroke, lineWidth: Double = 1) -> some View {
        self
            .strokeBorder(stroke, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}

