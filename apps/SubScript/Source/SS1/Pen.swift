//
//  Pen.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/19/22.
//

import Foundation

extension SS1 {
    struct Pen: Codable, Identifiable {
        var id: UUID = UUID()
        var active: Bool = false
        var color: ColorMode = ColorMode()
        var layer: CanvasLayer = CanvasLayer.foreground
        var penSet: PenSet = PenSet.set1
        enum PenSet: String, Equatable, Codable {
            case set1
            case set2
            case set3
            case set4
        }
        static let defaultFgThinPenSize: CGFloat = 2.5
        static let defaultFgThickPenSize: CGFloat = 4.5
        static let defaultBgThinPenSize: CGFloat = 5
        static let defaultBgThickPenSize: CGFloat = 10
        static let defaultExtraThinPenSize: CGFloat = 1
        static let defaultExtraThickPenSize: CGFloat = 50
    }
}
