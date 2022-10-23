//
//  Pen.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/19/22.
//

import SwiftUI

extension SS1 {
    struct Pen: Codable, Identifiable {
        var id: UUID = UUID()
        var style: PenStyle = PenStyle()
        var templateColor: UI.ColorType.HSBA = UI.ColorType.HSBA(from: #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1))
        var active: Bool = false
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
        
        /// The options object for `getStroke` or `getStrokePoints`.
        struct PenStyle: Equatable, Hashable, Codable {
            typealias HSBA = UI.ColorType.HSBA
            typealias ColorMode<T> = UI.ColorMode<T>
            typealias DualColor = UI.ColorMode<HSBA>
            
            var color: DualColor = DualColor(
                lightUI: HSBA.black,
                darkUI: HSBA.white
            )
            var layer: Layer = Layer.foreground
            
            /// The base size (diameter) of the stroke.
            var size: CGFloat = PenStyle.defaultSize
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
            
            static let defaultSize: CGFloat = 2.5
            static let defaultThinning: CGFloat = 0.5
            static let defaultSmoothing: CGFloat = 0.5
            static let defaultStreamline: CGFloat = 0.5
            static let defaultEasing: CGFloat = 0.5
            
            static let maxSize: CGFloat = 60.0
            static let maxThinning: CGFloat = 1.0
            static let maxSmoothing: CGFloat = 1.0
            static let maxStreamline: CGFloat = 1.0
            
            static let minSize: CGFloat = 1.0
            static let minThinning: CGFloat = -1.0
            static let minSmoothing: CGFloat = 0.0
            static let minStreamline: CGFloat = 0.0
            
            enum Layer: String, Codable {
                case foreground
                case background
            }
            
//            struct ColorMode: Equatable, Hashable, Codable {
//                var lightUI: CodableColor = CodableColor.black
//                var darkUI: CodableColor = CodableColor.white
//                func get(for colorScheme: ColorScheme) -> UI.LL.Color {
//                    switch colorScheme {
//                    case .light: return self.lightUI.color
//                    case .dark: return self.darkUI.color
//                    default: return self.lightUI.color
//                    }
//                }
//                func get(for colorScheme: ColorScheme, maybeInvert: Bool) -> UI.LL.Color {
//                    if maybeInvert {
//                        switch colorScheme {
//                        case .light: return self.get(for: .dark)
//                        case .dark: return self.get(for: .light)
//                        default: return self.get(for: .dark)
//                        }
//                    }
//                    return self.get(for: colorScheme)
//                }
//            }
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
}
