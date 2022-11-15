//
//  UI+Color.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/8/22.
//

import SwiftUI

extension UX {
    struct ColorMap {
        var lightMode: LL.Color
        var darkMode: LL.Color
        
        func get(for colorScheme: ColorScheme) -> LL.Color {
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

extension LL.Color: AsColor {
    var asColor: Color {
        Color(self)
    }
}
