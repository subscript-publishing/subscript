//
//  UI+Theme.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/20/22.
//

import SwiftUI

extension UI {
    struct DefaultColors {
        static let BTN_FG: ColorMode<UI.LL.Color> = ColorMode(
            lightUI: #colorLiteral(red: 0.07268141563, green: 0.1460210236, blue: 0.9764705896, alpha: 1),
            darkUI: #colorLiteral(red: 0.750361383, green: 0.3517298102, blue: 0.9495057464, alpha: 1)
        )
        static let BTN_ON_PRESS: ColorMode<UI.LL.Color> = ColorMode(
            lightUI: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1),
            darkUI: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        )
        static let BTN_FG_DANGEROUS: ColorMode<UI.LL.Color> = ColorMode(
            lightUI: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1),
            darkUI: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        )
        /// Deemphasized background button colors.
        static let DEEMPHASIZED_BTN_BG: ColorMode<UI.LL.Color> = ColorMode(
            lightUI: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
            darkUI: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        )
        /// Deemphasized foreground button colors.
        static let DEEMPHASIZED_BTN_FG: ColorMode<UI.LL.Color> = ColorMode(
            lightUI: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
            darkUI: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        )
        /// Deemphasized foreground button colors.
        static let DEEMPHASIZED_BTN_ON_PRESS: ColorMode<UI.LL.Color> = ColorMode(
            lightUI: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1),
            darkUI: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        )
        /// For e.g. labels with borders that aren't buttons, or e.g. inactive/disabled buttons.
        static let INERT_BORDER: ColorMode<UI.LL.Color> = ColorMode(
            lightUI: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
            darkUI: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        )
        static let DARK_BG_COLOR: UI.LL.Color = #colorLiteral(red: 0.09171843193, green: 0.1322061844, blue: 0.1834368639, alpha: 1)
        static let DARK_BG_COLOR_LIGHTER: UI.LL.Color = #colorLiteral(red: 0.0961808039, green: 0.0961808039, blue: 0.0961808039, alpha: 0.6494988648)
        static let NAV_BAR_BG: ColorMode<UI.LL.Color> = ColorMode(
            lightUI: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
            darkUI: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        )
    }
}

