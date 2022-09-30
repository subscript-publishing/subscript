//
//  CanvasData.swift
//  Subscript
//
//  Created by Colbyn Wadman on 3/30/22.
//

import Foundation
import CoreGraphics
import UIKit


extension SS {
    typealias StrokeBucket = Array<SS.Stroke>
    class DrawingDataModel: ObservableObject, Codable {
        private(set) var id = UUID()
        /// Drawn strokes
        var strokes: Array<Stroke> = []
        @Published
        var isTitle: Set<UUID> = []
        /// Active stroke
        var active: Stroke = Stroke()
        @Published
        var height: CGFloat = 200
        @Published
        var visible: Bool = true
        @Published
        var highlights: Set<UUID> = []
        
        enum CodingKeys: CodingKey {
            case strokes, height
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try! container.encode(strokes, forKey: .strokes)
            try! container.encode(height, forKey: .height)
        }
        init() {}
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            strokes = try container.decode(Array.self, forKey: .strokes)
            height = try container.decode(CGFloat.self, forKey: .height)
        }
        
        func updateHighlights(withinRegion region: SSBoundingBox) {
            clearHighlights()
            for stroke in strokes {
                inner: for point in stroke.samples.map({$0.point}) {
                    if region.contains(point: point) {
                        highlights.insert(stroke.uid)
                        break inner
                    }
                }
            }
        }
        func clearHighlights() {
            self.highlights.removeAll(keepingCapacity: true)
        }
        func removeHighlights() {
            strokes = strokes.filter({!highlights.contains($0.uid)})
            clearHighlights()
        }
        func highlightBox(maxWidth: CGFloat) -> SSBoundingBox? {
            let xScale = MathUtils.newLinearScale(domain: (0, 1000), range: (0, maxWidth))
            if self.highlights.isEmpty {
                return nil
            }
            
            var highlightXS: Array<CGFloat> = []
            var highlightYS: Array<CGFloat> = []
            
            for stroke in self.strokes {
                if self.highlights.contains(stroke.uid) {
                    for sample in stroke.samples {
                        highlightXS.append(sample.point.x)
                        highlightYS.append(sample.point.y)
                    }
                }
            }
            
            let minX = highlightXS.min()!
            let minY = highlightYS.min()!
            let maxX = highlightXS.max()!
            let maxY = highlightYS.max()!
            
            return SSBoundingBox(minX: xScale(minX), minY: minY, maxX: xScale(maxX), maxY: maxY)
        }
        func boundingBox(viewportWidth: CGFloat) -> SSBoundingBox {
            let xScale = MathUtils.newLinearScale(domain: (0, 1000), range: (0, viewportWidth))
            
            var xs: Array<CGFloat> = []
            var ys: Array<CGFloat> = []
            
            for stroke in self.strokes {
                if self.highlights.contains(stroke.uid) {
                    for sample in stroke.samples {
                        xs.append(sample.point.x)
                        ys.append(sample.point.y)
                    }
                }
            }
            
            let minX = xs.min()!
            let minY = ys.min()!
            let maxX = xs.max()!
            let maxY = ys.max()!
            
            return SSBoundingBox(minX: xScale(minX), minY: minY, maxX: xScale(maxX), maxY: maxY)
        }
        func finalizeActiveStroke() {
            if !self.active.isEmpty {
                self.strokes.append(self.active.simplify())
                clearActiveStroke()
            }
        }
        func clearActiveStroke() {
            self.active.samples.removeAll(keepingCapacity: true)
        }
    }
}

