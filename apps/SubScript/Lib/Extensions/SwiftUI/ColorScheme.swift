//
//  ColorScheme.swift
//  SSIOS
//
//  Created by Colbyn Wadman on 10/7/22.
//

import SwiftUI

extension ColorScheme {
    enum BinaryColorScheme {
        case light
        case dark
    }
    func toBinaryOption() -> BinaryColorScheme? {
        switch self {
        case .light: return .some(BinaryColorScheme.light)
        case .dark: return .some(BinaryColorScheme.dark)
        default: return .none
        }
    }
}

//extension ColorScheme {
//    func forEach<T>(
//        lightMode: () -> T,
//        darkMode: () -> T,
//    ) {
//        switch self {
//        case .light:
//            <#code#>
//        case .dark:
//            <#code#>
//        }
//    }
//}

