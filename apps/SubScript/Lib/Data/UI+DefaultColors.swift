//
//  UI+Theme.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/20/22.
//

import SwiftUI

extension UI {
    struct DefaultColors {
        static let BTN_FG: ColorMode<UI.Color> = ColorMode(
            lightUIMode: #colorLiteral(red: 0.07268141563, green: 0.1460210236, blue: 0.9764705896, alpha: 1),
            darkUIMode: #colorLiteral(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
        )
        static let BTN_FG_DANGEROUS: ColorMode<UI.Color> = ColorMode(
            lightUIMode: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1),
            darkUIMode: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        )
        /// Deemphasized background button colors.
        static let DEEMPHASIZED_BTN_BG: ColorMode<UI.Color> = ColorMode(
            lightUIMode: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
            darkUIMode: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        )
        /// Deemphasized foreground button colors.
        static let DEEMPHASIZED_BTN_FG: ColorMode<UI.Color> = ColorMode(
            lightUIMode: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
            darkUIMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        )
        /// Deemphasized foreground button colors.
        static let DEEMPHASIZED_BTN_ON_PRESS: ColorMode<UI.Color> = ColorMode(
            lightUIMode: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1),
            darkUIMode: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        )
        /// For e.g. labels with borders that aren't buttons, or e.g. inactive/disabled buttons.
        static let INERT_BORDER: ColorMode<UI.Color> = ColorMode(
            lightUIMode: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
            darkUIMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        )
    }
}

