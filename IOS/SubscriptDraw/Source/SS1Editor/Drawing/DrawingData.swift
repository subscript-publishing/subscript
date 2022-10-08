//
//  DrawingData.swift
//  Subscript
//
//  Created by Colbyn Wadman on 3/30/22.
//

import Foundation
import CoreGraphics
import UIKit

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DEBUG STUFF
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//extension CGRect {
//    func debugLabel() -> String {
//        let x = self.debugDescription
//        "\(width)x\(height)"
//    }
//}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// BASICS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extension SS1 {
    struct SSBoundingBox {
        let minX: CGFloat
        let minY: CGFloat
        let maxX: CGFloat
        let maxY: CGFloat
        var cgRect: CGRect {
            CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        }
        var center: CGPoint {
            CGPoint(x: self.cgRect.midX, y: self.cgRect.midY)
        }
        static func fromStroke(_ stroke: Stroke) -> Optional<SSBoundingBox> {
            var xs: Array<CGFloat> = []
            var ys: Array<CGFloat> = []
            for sample in stroke.samples {
                xs.append(sample.point.x)
                ys.append(sample.point.y)
            }
            guard let minX = xs.min() else {return .none}
            guard let minY = ys.min() else {return .none}
            guard let maxX = xs.max() else {return .none}
            guard let maxY = ys.max() else {return .none}
            return SSBoundingBox(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        }
        func contains(point: CGPoint) -> Bool {
            let x = (point.x >= minX) && (point.x <= maxX)
            let y = (point.y >= minY) && (point.y <= maxY)
            let result = x && y
            return result
        }
        func debugLabel() -> String {
            "(\(minX), \(minY), \(maxX), \(maxY))"
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SAMPLE
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// STROKE
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extension SS1 {
    struct Stroke: Equatable, Hashable, Codable {
        var uid = UUID()
        var options = Options()
        var samples: Array<Sample> = []
        var isEmpty: Bool {samples.isEmpty}
        var count: Int {samples.count}

        
        init() {
            self.uid = UUID()
        }
        
        init(
            options: Stroke.Options,
            samples: Array<Sample>
        ) {
            self.uid = UUID()
            self.samples = samples
            self.options = options
        }
        
        @inline(__always)
        func boundingBox(maxWidth: CGFloat) -> Optional<SSBoundingBox> {
            SSBoundingBox.fromStroke(self).map { box in
                let xScale = MathUtils.newLinearScale(domain: (0, 1000), range: (0, maxWidth))
                return SSBoundingBox(
                    minX: xScale(box.minX),
                    minY: box.minY,
                    maxX: xScale(box.maxX),
                    maxY: box.maxY
                )
            }
        }
        
        
        var totalLength: CGFloat {
            var length: CGFloat = 0
            var lastSample: Sample? = nil
            for sample in samples {
                if let lastSample = lastSample {
                    let distance = lastSample.point.lengthBetween(other: sample.point)
                    length += distance
                }
                lastSample = sample
            }
            return length
        }
        private func renderBetween(
            tops: inout Array<CGPoint>,
            bots: inout Array<CGPoint>,
            start: CGPoint,
            end: CGPoint,
            isStart: Bool = false,
            isEnd: Bool = false
        ) {
            let xScale = MathUtils.newLinearScale(domain: (0, 100), range: (start.x, end.x))
            let yScale = MathUtils.newLinearScale(domain: (0, 100), range: (start.y, end.y))
            let vector = start.rightTriangle(other: end)
            for ix in [0, 100] {
                let distance: CGFloat = self.options.size
                let basePoint = CGPoint(x: xScale(CGFloat(ix)), y: yScale(CGFloat(ix)))
                let topPoint = basePoint.offset(
                    distance: distance,
                    radians: vector.atan2() + (CGFloat.tau * 0.25)
                )
                let botPoint = basePoint.offset(
                    distance: distance,
                    radians: vector.atan2() + (CGFloat.tau * 0.75)
                )
                tops.append(topPoint)
                bots.append(botPoint)
            }
        }
        
        private func simpleOutlinePointsHelper() -> (Array<CGPoint>, Array<CGPoint>) {
            var tops: Array<CGPoint> = []
            var bots: Array<CGPoint> = []
            var lastSample: CGPoint? = nil
            for (ix, sample) in samples.enumerated() {
                let isStart = ix == 1
                let isEnd = (ix + 1) == samples.count
                if let lastSample = lastSample {
                    renderBetween(
                        tops: &tops,
                        bots: &bots,
                        start: lastSample,
                        end: sample.point,
                        isStart: isStart,
                        isEnd: isEnd
                    )
                }
                lastSample = sample.point
            }
            return (tops, bots)
        }
        
        func simpleOutlinePoints() -> Array<CGPoint> {
            let (tops, bots) = simpleOutlinePointsHelper()
            var closedPoints: Array<CGPoint> = []
            closedPoints.append(contentsOf: tops)
            closedPoints.append(contentsOf: bots.reversed())
            return closedPoints
        }
        
        func complexOutlinePoints() -> Array<CGPoint> {
            return self.vectorOutlinePoints()
        }
        
        func simplify() -> Stroke {
            return self
    //        var newSamples: Array<Sample> = []
    //        for (ix, sample) in self.samples.enumerated() {
    //            if let last = newSamples.last {
    //                if let next = self.samples.get(index: ix + 1) {
    //                    let angle = MathUtils.threeWayAngle(left: last.point, center: sample.point, right: next.point)
    //                    let distance = last.point.lengthBetween(other: next.point)
    //                    if angle < CGFloat.tau * (1/4) && distance > 5.0 {
    //                        newSamples.append(sample)
    //                    }
    //                } else {
    //                    newSamples.append(sample)
    //                }
    //            } else {
    //                newSamples.append(sample)
    //            }
    //        }
    //        var new = self
    //        new.samples = newSamples
    //        return new
        }
    }
}

extension SS1.Stroke {
    struct Sample: Equatable, Hashable, Codable {
        var point: CGPoint
        var pressure: CGFloat = 0.5
        var layer: SS1.Stroke.Layer = SS1.Stroke.Layer.foreground
    }
    
    enum Layer: String, Codable {
        case foreground
        case background
    }
    
    /// The options object for `getStroke` or `getStrokePoints`.
    struct Options: Equatable, Hashable, Codable {
        var darkUIColorSchemeColor: CodableColor = CodableColor.init(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.9042767643))
        var lightUIColorSchemeColor: CodableColor = CodableColor.init(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.9103134788))
        /// The base size (diameter) of the stroke.
        var size: CGFloat = 5
        /// The effect of pressure on the stroke's size.
        var thinning: CGFloat = 0.5
        /// How much to soften the stroke's edges.
        var smoothing: CGFloat = 0.5
        /// TODO
        var streamline: CGFloat = 0.5
        /// An easing function to apply to each point's pressure.
        var easing: Easing = Easing.linear
        /// Whether to simulate pressure based on velocity.
        var simulatePressure: Bool = true
        /// Cap, taper and easing for the start of the line.
        var start: StartCap = StartCap()
        /// Cap, taper and easing for the end of the line.
        var end: EndCap = EndCap()
        
        
        static let maxSize: CGFloat = 60.0
        static let maxThinning: CGFloat = 1.0
        static let maxSmoothing: CGFloat = 1.0
        static let maxStreamline: CGFloat = 1.0
        
        static let minSize: CGFloat = 1.0
        static let minThinning: CGFloat = -1.0
        static let minSmoothing: CGFloat = 0.0
        static let minStreamline: CGFloat = 0.0
        
        enum Easing: String, Equatable, Hashable, Codable {
            case linear
            case easeInQuad
            case easeOutQuad
            case easeInOutQuad
            case easeInCubic
            case easeOutCubic
            case easeInOutCubic
            case easeInQuart
            case easeOutQuart
            case easeInOutQuart
            case easeInQuint
            case easeOutQuint
            case easeInOutQuint
            case easeInSine
            case easeOutSine
            case easeInOutSine
            case easeInExpo
            case easeOutExpo
            
            func toFunction() -> (CGFloat) -> (CGFloat) {
                switch self {
                case .linear: return self.linear
                case .easeInQuad: return self.easeInQuad
                case .easeOutQuad: return self.easeOutQuad
                case .easeInOutQuad: return self.easeInOutQuad
                case .easeInCubic: return self.easeInCubic
                case .easeOutCubic: return self.easeOutCubic
                case .easeInOutCubic: return self.easeInOutCubic
                case .easeInQuart: return self.easeInQuart
                case .easeOutQuart: return self.easeOutQuart
                case .easeInOutQuart: return self.easeInOutQuart
                case .easeInQuint: return self.easeInQuint
                case .easeOutQuint: return self.easeOutQuint
                case .easeInOutQuint: return self.easeInOutQuint
                case .easeInSine: return self.easeInSine
                case .easeOutSine: return self.easeOutSine
                case .easeInOutSine: return self.easeInOutSine
                case .easeInExpo: return self.easeInExpo
                case .easeOutExpo: return self.easeOutExpo
                }
            }
            
            private func linear(t: CGFloat) -> CGFloat {t}
            private func easeInQuad(t: CGFloat) -> CGFloat {t * t}
            private func easeOutQuad(t: CGFloat) -> CGFloat {t * (2 - t)}
            private func easeInOutQuad(t: CGFloat) -> CGFloat {
                (t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t)
            }
            private func easeInCubic(t: CGFloat) -> CGFloat {t * t * t}
            private func easeOutCubic(t: CGFloat) -> CGFloat {(t - 1) * t * t + 1}
            private func easeInOutCubic(t: CGFloat) -> CGFloat {
                t < 0.5 ? 4 * t * t * t : (t - 1) * (2 * t - 2) * (2 * t - 2) + 1
            }
            private func easeInQuart(t: CGFloat) -> CGFloat {t * t * t * t}
            private func easeOutQuart(t: CGFloat) -> CGFloat {1 - (t - 1) * t * t * t}
            private func easeInOutQuart(t: CGFloat) -> CGFloat {
                t < 0.5 ? 8 * t * t * t * t : 1 - 8 * (t - 1) * t * t * t
            }
            private func easeInQuint(t: CGFloat) -> CGFloat {t * t * t * t * t}
            private func easeOutQuint(t: CGFloat) -> CGFloat {1 + (t - 1) * t * t * t * t}
            private func easeInOutQuint(t: CGFloat) -> CGFloat {
                t < 0.5 ? 16 * t * t * t * t * t : 1 + 16 * (t - 1) * t * t * t * t
            }
            private func easeInSine(t: CGFloat) -> CGFloat {1 - cos((t * CGFloat.pi) / 2)}
            private func easeOutSine(t: CGFloat) -> CGFloat {sin((t * CGFloat.pi) / 2)}
            private func easeInOutSine(t: CGFloat) -> CGFloat {-(cos(CGFloat.pi * t) - 1) / 2}
            private func easeInExpo(t: CGFloat) -> CGFloat {t <= 0 ? 0 : pow(2, 10 * t - 10)}
            private func easeOutExpo(t: CGFloat) -> CGFloat {t >= 1 ? 1 : 1 - pow(2, -10 * t)}
        }
        
        struct StartCap: Equatable, Hashable, Codable {
            var cap: Bool = true
            var taper: CGFloat = 0
            var easing: Easing = Easing.linear
        }

        struct EndCap: Equatable, Hashable, Codable {
            var cap: Bool = true
            var taper: CGFloat = 0
            var easing: Easing = Easing.linear
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DRAWING DATA MODEL
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extension SS1 {
    class CanvasDataModel: ObservableObject, Codable {
        @Published
        var entries: Array<DrawingDataModel> = [
            DrawingDataModel()
        ]
        
        enum CodingKeys: CodingKey {
            case entries
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try! container.encode(entries, forKey: .entries)
        }
        init() {}
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            entries = try container.decode(Array.self, forKey: .entries)
        }
        
//        func toSVG() -> String {
//            var paths: Array<String> = []
//            var xs: Array<CGFloat> = []
//            var ys: Array<CGFloat> = []
//            var hightOffset: CGFloat = 0
//            for entry in entries {
//                var entryYValues: Array<CGFloat> = []
//                for stroke in entry.strokes {
//                    var pathData = ""
//                    for (ix, point) in stroke.vectorOutlinePoints().enumerated() {
//                        let x = round((point.x) * 10) / 10.0
//                        let y = round((point.y + hightOffset) * 10) / 10.0
//                        xs.append(x)
//                        ys.append(y)
//                        entryYValues.append(y)
//                        if ix == 0 {
//                            pathData += "M \(x) \(y) L"
//                        } else {
//                            pathData += " \(x) \(y)"
//                        }
//                    }
//                    let (r, g, b, a): (Int, Int, Int, Int) = {
//                        let scale = MathUtils.newLinearScale(domain: (0.0, 1.0), range: (0, 255))
//                        let (r, g, b, a) = stroke.options.color.color.rgbaComponents
//                        let newRed = Int(scale(r).rounded())
//                        let newBlue = Int(scale(g).rounded())
//                        let newGreen = Int(scale(b).rounded())
//                        let newAlpha = Int(scale(a).rounded())
//                        return (newRed, newBlue, newGreen, newAlpha)
//                    }()
//                    let pathAttr = "d=\"\(pathData)\""
//                    let fillAttr = "fill=\"rgba(\(r), \(g), \(b), \(a))\""
//                    paths.append("<path \(fillAttr) \(pathAttr) />")
//                }
//                switch (entryYValues.max(), entryYValues.min()) {
//                case (let .some(maxHeight), let .some(minHeight)):
//                    hightOffset += (maxHeight - minHeight)
//                case (let .some(maxHeight), _):
//                    hightOffset += maxHeight
//                default: ()
//                }
//            }
//            if paths.isEmpty {
//                return ""
//            }
//            let minX = xs.min()!
//            let maxX = xs.max()!
//            let minY = ys.min()!
//            let maxY = ys.max()!
//            let styleAttr = "style=\"max-width: \(maxX)px;\""
//            let viewBoxAttr = "viewBox=\"\(minX) \(minY) \(maxX) \(maxY)\""
//            let attrs = "xmlns=\"http://www.w3.org/2000/svg\" \(styleAttr) \(viewBoxAttr)"
//            let svg = "<svg \(attrs)>\(paths.joined(separator: " "))</svg>"
//            return svg
//        }
        func save(filePath: URL) {
            let encoder = PropertyListEncoder()
            let data = try! encoder.encode(self)
            try! data.write(to: filePath)
        }
        static func load(filePath: URL) -> Optional<CanvasDataModel> {
            let decoder = PropertyListDecoder()
            let data = try? Data(contentsOf: filePath)
            if let data = data {
                return try? decoder.decode(CanvasDataModel.self, from: data)
            } else {
                return .none
            }
        }
    }
}



