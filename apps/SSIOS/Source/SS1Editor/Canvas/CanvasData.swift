//
//  CanvasData.swift
//  Subscript
//
//  Created by Colbyn Wadman on 3/30/22.
//

import Foundation
import CoreGraphics
import UIKit


extension SS1 {
    typealias StrokeBucket = Array<SS1.Stroke>
    class DrawingDataModel: ObservableObject, Codable {
        private(set) var id = UUID.init()
        /// Drawn strokes
        var foregroundStrokes: Array<Stroke> = []
        var backgroundStrokes: Array<Stroke> = []
        /// Active stroke
        var active: Stroke = Stroke()
        var activeLayer: SS1.Stroke.Layer = SS1.Stroke.Layer.foreground
        @Published
        var height: CGFloat = 200
        @Published
        var visible: Bool = true
        @Published
        var visibilityToggleable: Bool = false
        @Published
        var highlights: Set<UUID> = []
        
        enum CodingKeys: CodingKey {
            case foregroundStrokes, backgroundStrokes, height, visible
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try! container.encode(foregroundStrokes, forKey: .foregroundStrokes)
            try! container.encode(backgroundStrokes, forKey: .backgroundStrokes)
            try! container.encode(height, forKey: .height)
            try! container.encode(visible, forKey: .visible)
        }
        init() {}
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            foregroundStrokes = try container.decode(Array.self, forKey: .foregroundStrokes)
            backgroundStrokes = try container.decode(Array.self, forKey: .backgroundStrokes)
            height = try container.decode(CGFloat.self, forKey: .height)
            visible = (try? container.decode(Bool.self, forKey: .visible)) ?? true
        }
        
        func updateHighlights(withinRegion region: SSBoundingBox) {
            clearHighlights()
            for stroke in foregroundStrokes {
                inner: for point in stroke.samples.map({$0.point}) {
                    if region.contains(point: point) {
                        highlights.insert(stroke.uid)
                        break inner
                    }
                }
            }
            for stroke in backgroundStrokes {
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
            foregroundStrokes = foregroundStrokes.filter({!highlights.contains($0.uid)})
            backgroundStrokes = backgroundStrokes.filter({!highlights.contains($0.uid)})
            clearHighlights()
        }
        func highlightBox(maxWidth: CGFloat) -> SSBoundingBox? {
            let xScale = MathUtils.newLinearScale(domain: (0, 1000), range: (0, maxWidth))
            if self.highlights.isEmpty {
                return nil
            }
            
            var highlightXS: Array<CGFloat> = []
            var highlightYS: Array<CGFloat> = []
            
            for stroke in self.foregroundStrokes {
                if self.highlights.contains(stroke.uid) {
                    for sample in stroke.samples {
                        highlightXS.append(sample.point.x)
                        highlightYS.append(sample.point.y)
                    }
                }
            }
            for stroke in self.backgroundStrokes {
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
            
            for stroke in self.foregroundStrokes {
                if self.highlights.contains(stroke.uid) {
                    for sample in stroke.samples {
                        xs.append(sample.point.x)
                        ys.append(sample.point.y)
                    }
                }
            }
            for stroke in self.backgroundStrokes {
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
        func finalizeActiveStroke(runtimeModel: SS1.RuntimeDataModel) {
            if !self.active.isEmpty {
                switch self.activeLayer {
                case .foreground: self.foregroundStrokes.append(self.active.finalize(
                    runtimeMode: runtimeModel
                ))
                case .background: self.backgroundStrokes.append(self.active.finalize(
                    runtimeMode: runtimeModel
                ))
                }
                clearActiveStroke()
            }
        }
        func clearActiveStroke() {
            self.active.samples.removeAll(keepingCapacity: true)
        }
    }
}

