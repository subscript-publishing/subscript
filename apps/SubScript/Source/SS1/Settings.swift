//
//  Settings.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/20/22.
//

import Foundation
import SwiftUI

extension SS1 {
    static let DEBUG_MODE: Bool = false
    struct StaticSettings {
        struct Canvas {
            static let ignoreSafeAreas: Bool = true
        }
        struct DarkMode {
            struct Page {
                static let BG = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
                static let HEADER_BG = Color(#colorLiteral(red: 0.1848134301, green: 0.1951491004, blue: 0.234029349, alpha: 1))
            }
            struct Canvas {
                static let BG: Color = Color(#colorLiteral(red: 0.1339184344, green: 0.1339184344, blue: 0.1339184344, alpha: 1))
                /// In between entries
                static let BG2: Color = Color(#colorLiteral(red: 0.1999768615, green: 0.1999768615, blue: 0.1999768615, alpha: 1))
                
//                static let BG: Color = Color(#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1))
//                /// In between entries
//                static let BG2: Color = Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
            }
        }
        struct LightMode {
            struct Page {
                static let BG = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                static let HEADER_BG = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            }
            struct Canvas {
                static let BG: Color = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                /// In between entries
                static let BG2: Color = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            }
        }
    }
}
