//
//  CodableColor.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/22/22.
//

import CoreGraphics

struct CodableColor: Codable, Equatable, Hashable {
    static var white: CodableColor {
        CodableColor(withColor: UI.LL.Color.white)
    }
    static var black: CodableColor {
        CodableColor(withColor: UI.LL.Color.black)
    }
    
    var color: UI.LL.Color
    var hsba: UI.ColorType.HSBA {
        get {
            self.color.hsba
        }
        set(newValue) {
            self.color = UI.LL.Color(
                hue: newValue.hue,
                saturation: newValue.saturation,
                brightness: newValue.brightness,
                alpha: newValue.alpha
            )
        }
    }
    var cgColor: CGColor {
        get {
            self.color.cgColor
        }
        set(new) {
#if os(iOS)
            self.color = UI.LL.Color(cgColor: new)
#elseif os(macOS)
            self.color = UI.LL.Color(cgColor: new)!
#endif
        }
    }
    
    init() {
        self.color = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 0.7910221934)
    }
    
    init(withColor: UI.LL.Color) {
        self.color = withColor
    }
    
    public init(from decoder: Decoder) throws {
        let colorStorageModel = try ColorStorageModel.init(from: decoder)
        self.color = UI.LL.Color(
            red: colorStorageModel.red,
            green: colorStorageModel.green,
            blue: colorStorageModel.blue,
            alpha: colorStorageModel.alpha
        )
    }
    public func encode(to encoder: Encoder) throws {
        let rgba = self.color.rgba
        let colorStorageModel = ColorStorageModel(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
        try colorStorageModel.encode(to: encoder)
    }
    private struct ColorStorageModel: Codable {
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let alpha: CGFloat
    }
    
    func withAlpha(_ value: CGFloat) -> CodableColor {
        return CodableColor(withColor: self.color.withAlphaComponent(value))
    }
}


