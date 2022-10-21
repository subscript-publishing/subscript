//
//  CodableColor.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/22/22.
//

import CoreGraphics

struct CodableColor: Codable, Equatable, Hashable {
    static var white: CodableColor {
        CodableColor(withColor: UI.Color.white)
    }
    static var black: CodableColor {
        CodableColor(withColor: UI.Color.black)
    }
    
    var color: UI.Color
    var cgColor: CGColor {
        get {
            self.color.cgColor
        }
        set(new) {
#if os(iOS)
            self.color = UI.Color(cgColor: new)
#elseif os(macOS)
            self.color = UI.Color(cgColor: new)!
#endif
        }
    }
    
    init() {
        self.color = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 0.7910221934)
    }
    
    init(withColor: UI.Color) {
        self.color = withColor
    }
    
    public init(from decoder: Decoder) throws {
        let colorStorageModel = try ColorStorageModel.init(from: decoder)
        self.color = UI.Color(
            red: colorStorageModel.red,
            green: colorStorageModel.green,
            blue: colorStorageModel.blue,
            alpha: colorStorageModel.alpha
        )
    }
    public func encode(to encoder: Encoder) throws {
        let (r, g, b, a) = self.color.rgba
        let colorStorageModel = ColorStorageModel(red: r, green: g, blue: b, alpha: a)
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


