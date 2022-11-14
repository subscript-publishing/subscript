//
//  UI+Color.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/8/22.
//

import SwiftUI

extension UX {
    struct ColorMap {
        var lightMode: XI.Color
        var darkMode: XI.Color
        
        func get(for colorScheme: ColorScheme) -> XI.Color {
            switch colorScheme {
            case .light: return self.lightMode
            case .dark: return self.darkMode
            @unknown default: return self.lightMode
            }
        }
    }
}

protocol AsColor {
    var asColor: Color {get}
}

extension XI.Color: AsColor {
    var asColor: Color {
        Color(self)
    }
}
