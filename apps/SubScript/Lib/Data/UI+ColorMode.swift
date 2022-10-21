//
//  ColorMap.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/20/22.
//

import Foundation
import SwiftUI

extension UI {
    struct ColorMode<T> {
        let lightUIMode: T
        let darkUIMode: T
        
        func get(_ colorScheme: ColorScheme) -> T {
            switch colorScheme {
            case .light: return self.lightUIMode
            case .dark: return self.darkUIMode
            default: return self.lightUIMode
            }
        }
    }
    typealias ColorMap = ColorMode<UI.Color>
}
