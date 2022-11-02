//
//  ColorModel.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/22/22.
//



import Foundation
import struct SwiftUI.Color
import enum SwiftUI.ColorScheme

extension UI {
    struct ColorMode<T> {
        var lightUI: T
        var darkUI: T
        
        func get(for colorScheme: ColorScheme) -> T {
            switch colorScheme {
            case .light: return self.lightUI
            case .dark: return self.darkUI
            default: return self.lightUI
            }
        }
        func get(for colorScheme: ColorScheme, withInvert: Bool) -> T {
            if withInvert {
                switch colorScheme {
                case .light: return self.get(for: .dark)
                case .dark: return self.get(for: .light)
                default: return self.get(for: .dark)
                }
            }
            return self.get(for: colorScheme)
        }
    }
}

extension UI.ColorMode: Equatable where T: Equatable {}
extension UI.ColorMode: Hashable where T: Hashable {}
extension UI.ColorMode: Codable where T: Codable {}


extension UI.LL {
    typealias ColorMap = UI.ColorMode<UI.LL.Color>
}
extension UI.LL.ColorMap {
    func getAsColor(for colorScheme: ColorScheme) -> Color {
        Color(self.get(for: colorScheme))
    }
}

protocol AsColorType {
    var asCGColor: CGColor {get}
    var asXColor: UI.LL.Color {get}
    var asColor: Color {get}
}

extension UI.LL.Color: AsColorType {
    var asCGColor: CGColor {
        return self.cgColor
    }
    var asXColor: UI.LL.Color {
        return self
    }
    var asColor: Color {
        Color(self)
    }
}

extension UI {
    struct ColorType {
        struct RGBA: Codable, Equatable, Hashable {
            var red: CGFloat
            var green: CGFloat
            var blue: CGFloat
            var alpha: CGFloat
        }
        struct HSBA: Codable, Equatable, Hashable, AsColorType {
            var hue: CGFloat
            var saturation: CGFloat
            var brightness: CGFloat
            var alpha: CGFloat
            init(
                hue: CGFloat,
                saturation: CGFloat,
                brightness: CGFloat,
                alpha: CGFloat = 1.0
            ) {
                self.hue = hue
                self.saturation = saturation
                self.brightness = brightness
                self.alpha = alpha
            }
            init<T>(from color: T) where T: AsColorType {
                self = color.asXColor.hsba
            }
            init(fromLL color: UI.LL.Color) {
                self = color.hsba
            }
            var asCGColor: CGColor {
                get {
                    self.asXColor.cgColor
                }
                set(newValue) {
#if os(iOS)
                    self = UI.LL.Color.init(cgColor: newValue).hsba
#elseif os(macOS)
                    self = UI.LL.Color.init(cgColor: newValue)!.hsba
#endif
                }
            }
            var asXColor: UI.LL.Color {
                return UI.LL.Color(
                    hue: self.hue,
                    saturation: self.saturation,
                    brightness: self.brightness,
                    alpha: self.alpha
                )
            }
            var asColor: Color {
                return Color(self.asXColor)
            }
            func with(alpha: CGFloat) -> HSBA {
                return HSBA(
                    hue: self.hue,
                    saturation: self.saturation,
                    brightness: self.brightness,
                    alpha: alpha
                )
            }
            static let white: HSBA = HSBA(
                hue: 0.0,
                saturation: 0.0,
                brightness: 1.0,
                alpha: 1.0
            )
            static let black: HSBA = HSBA(
                hue: 0.0,
                saturation: 0.0,
                brightness: 0.0,
                alpha: 1.0
            )
        }
    }
}



