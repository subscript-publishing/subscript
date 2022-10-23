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
    var bgColor: UI.ColorMode<UI.LL.Color>? = nil
    var fgColor: UI.ColorMode<UI.LL.Color?>? = nil
    @Environment(\.colorScheme) private var colorScheme
    init(
        width: CGFloat,
        height: CGFloat,
        bgColor: UI.ColorMode<UI.LL.Color>? = nil,
        fgColor: UI.ColorMode<UI.LL.Color?>? = nil
    ) {
        self.width = width
        self.height = height
        self.bgColor = bgColor
        self.fgColor = fgColor
    }
    func makeBody(configuration: Configuration) -> some View {
        let defaultFgColor = UI.DefaultColors.DEEMPHASIZED_BTN_FG
        let defaultBgColor = UI.DefaultColors.DEEMPHASIZED_BTN_BG
        let fgColor = self.fgColor?.get(for: colorScheme) ?? defaultFgColor.get(for: colorScheme)
        let bgColor = (self.bgColor ?? defaultBgColor).get(for: colorScheme)
        let activeColor = UI.DefaultColors.DEEMPHASIZED_BTN_ON_PRESS.get(for: colorScheme)
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


struct PlainButtonStyle: ButtonStyle {
    var bgColor: UI.ColorMode<UI.LL.Color>? = nil
    var fgColor: UI.ColorMode<UI.LL.Color?>? = nil
    @Environment(\.colorScheme) private var colorScheme
    init(
        bgColor: UI.ColorMode<UI.LL.Color>? = nil,
        fgColor: UI.ColorMode<UI.LL.Color?>? = nil
    ) {
        self.bgColor = bgColor
        self.fgColor = fgColor
    }
    func makeBody(configuration: Configuration) -> some View {
        let defaultFgColor = UI.DefaultColors.BTN_FG
        let fgColor = self.fgColor?.get(for: colorScheme) ?? defaultFgColor.get(for: colorScheme)
        let activeColor = UI.DefaultColors.BTN_ON_PRESS.get(for: colorScheme)
        configuration
            .label
            .foregroundColorIf(given: configuration.isPressed, ifTrue: activeColor, ifFalse: fgColor)
    }
}

struct RoundedButtonStyle: ButtonStyle {
//    var useAltColor: Bool
    var useMonospacedFont: Bool
    var useDangerousColor: Bool
    init(
        useMonospacedFont: Bool = false,
//        useAltColor: Bool = false,
        useDangerousColor: Bool = false
    ) {
        self.useMonospacedFont = useMonospacedFont
        self.useDangerousColor = useDangerousColor
    }
    
    @Environment(\.colorScheme) private var colorScheme
    private var backgroundColor = UI.LL.ColorMap(
        lightUI: UI.LL.Color(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.01),
        darkUI: UI.LL.Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.01)
    )
    func makeBody(configuration: Configuration) -> some View {
        let fgColorMap = configuration.isPressed
            ? UI.DefaultColors.BTN_ON_PRESS
            : (self.useDangerousColor ? UI.DefaultColors.BTN_FG_DANGEROUS : UI.DefaultColors.BTN_FG)
        let fgColor = fgColorMap.get(for: colorScheme)
        let fontDesign = self.useMonospacedFont ? Font.Design.monospaced : Font.Design.default
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 0) {
                configuration.label
                    .foregroundColor(Color(fgColor))
                    .font(.system(size: 10, weight: Font.Weight.light, design: fontDesign))
                    .padding(5)
                    .background(Color(
                        backgroundColor.get(for: colorScheme)
                    ))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(fgColor), lineWidth: 1)
                    )
            }
        }
    }
}


//struct RoundedPillButtonStyle: ButtonStyle {
////    var useAltColor: Bool
//    var useMonospacedFont: Bool
//    var useDangerousColor: Bool
//    init(
//        useMonospacedFont: Bool = false,
////        useAltColor: Bool = false,
//        useDangerousColor: Bool = false
//    ) {
//        self.useMonospacedFont = useMonospacedFont
//        self.useDangerousColor = useDangerousColor
//    }
//
//    @Environment(\.colorScheme) private var colorScheme
//    func makeBody(configuration: Configuration) -> some View {
//        let fgColorMap = configuration.isPressed
//            ? UI.DefaultColors.BTN_ON_PRESS
//            : (self.useDangerousColor ? UI.DefaultColors.BTN_FG_DANGEROUS : UI.DefaultColors.BTN_FG)
//        let fgColor = fgColorMap.get(colorScheme)
//        let fontDesign = self.useMonospacedFont ? Font.Design.monospaced : Font.Design.default
//        HStack(alignment: .center, spacing: 0) {
//            VStack(alignment: .center, spacing: 0) {
//                configuration.label
//                    .foregroundColor(Color(fgColor))
//                    .font(.system(size: 10, weight: Font.Weight.light, design: fontDesign))
//                    .padding(5)
//            }
//        }
//        .overlay(
//            RoundedRectangle(cornerRadius: 5)
//                .stroke(Color(fgColor), lineWidth: 1)
//        )
//    }
//}
