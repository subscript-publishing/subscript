//
//  Buttons.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/20/22.
//

import SwiftUI


struct CircleButton: ButtonStyle {
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var bgColor: UI.ColorMode<UI.Color>? = nil
    var fgColor: UI.ColorMode<UI.Color?>? = nil
    @Environment(\.colorScheme) private var colorScheme
    init(
        width: CGFloat,
        height: CGFloat,
        bgColor: UI.ColorMode<UI.Color>? = nil,
        fgColor: UI.ColorMode<UI.Color?>? = nil
    ) {
        self.width = width
        self.height = height
        self.bgColor = bgColor
        self.fgColor = fgColor
    }
    func makeBody(configuration: Configuration) -> some View {
        let defaultFgColor = UI.DefaultColors.DEEMPHASIZED_BTN_FG
        let defaultBgColor = UI.DefaultColors.DEEMPHASIZED_BTN_BG
        let fgColor = self.fgColor?.get(colorScheme) ?? defaultFgColor.get(colorScheme)
        let bgColor = (self.bgColor ?? defaultBgColor).get(colorScheme)
        let activeColor = UI.DefaultColors.DEEMPHASIZED_BTN_ON_PRESS.get(colorScheme)
        configuration.label
            .foregroundColorIf(given: configuration.isPressed, ifTrue: activeColor, ifFalse: fgColor)
            .frame(width: self.width, height: self.height, alignment: .center)
            .background(
                Circle()
                    .fill(
                        fillStyle: Color(bgColor),
                        stroke: Color(configuration.isPressed ? activeColor : bgColor),
                        lineWidth: 2.0
                    )
            )
    }
}

