//
//  Theme.swift
//  SSIOS
//
//  Created by Colbyn Wadman on 10/6/22.
//

import SwiftUI

fileprivate struct Theme {
    struct DarkMode {
        static let textColor = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        static let buttonColor = Color.purple
    }
    struct LightMode {
        static let textColor = Color(#colorLiteral(red: 0.1337402463, green: 0.1337402463, blue: 0.1337402463, alpha: 1))
        static let buttonColor = Color(#colorLiteral(red: 0.07268141563, green: 0.1460210236, blue: 0.9764705896, alpha: 1))
    }
}

private struct ThemeModifier: ViewModifier {
    // EXTRNAL API
    let element: ElementType
    
    enum ElementType {
        case text
        case button
    }
    
    // INETRNAL
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        switch (self.element, colorScheme) {
        case (.text, .dark): content.foregroundColor(Theme.DarkMode.textColor)
        case (.text, .light): content.foregroundColor(Theme.LightMode.textColor)
        case (.button, .dark): content.foregroundColor(Theme.DarkMode.buttonColor)
        case (.button, .light): content.foregroundColor(Theme.LightMode.buttonColor)
        case (_, _): content
        }
    }
}


extension View {
    func textTheme() -> some View {
        modifier(ThemeModifier(element: .text))
    }
    func btnLabelTheme() -> some View {
        modifier(ThemeModifier(element: .button))
    }
}

