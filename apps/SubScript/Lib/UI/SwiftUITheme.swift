//
//  SwiftUITheme.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/21/22.
//

import SwiftUI
import Combine

fileprivate struct FgColorMapKey: EnvironmentKey {
    static let defaultValue: UI.ColorMode<UI.LL.Color>? = nil
}
fileprivate struct BgColorMapKey: EnvironmentKey {
    static let defaultValue: UI.ColorMode<UI.LL.Color>? = nil
}

extension EnvironmentValues {
    var fgColorMap: UI.ColorMode<UI.LL.Color>? {
        get { self[FgColorMapKey.self] }
        set { self[FgColorMapKey.self] = newValue }
    }
    var bgColorMap: UI.ColorMode<UI.LL.Color>? {
        get { self[BgColorMapKey.self] }
        set { self[BgColorMapKey.self] = newValue }
    }
}

extension View {
    func fgColorMap(_ color: UI.LL.ColorMap) -> some View {
        return self.environment(\.fgColorMap, color)
    }
    func fgColorMap(lightMode: UI.LL.Color, darkMode: UI.LL.Color) -> some View {
        return self.environment(\.fgColorMap, UI.LL.ColorMap(lightUI: lightMode, darkUI: darkMode))
    }
    func useDangerousFgColor() -> some View {
        let colors = UI.ColorMode(
            lightUI: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1),
            darkUI: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        )
        return self.environment(\.fgColorMap, colors)
    }
    func bgColorMap(_ color: UI.LL.ColorMap) -> some View {
        return self.environment(\.bgColorMap, color)
    }
    func bgColorMap(lightMode: UI.LL.Color, darkMode: UI.LL.Color) -> some View {
        return self.environment(\.bgColorMap, UI.LL.ColorMap(lightUI: lightMode, darkUI: darkMode))
    }
}

//fileprivate struct PopupViewModifier: ViewModifier {
//    // EXTRNAL API
//
//    // INETRNAL
//    @Environment(\.colorScheme) private var colorScheme
//
//    func body(content: Content) -> some View {
//        switch (self.element, colorScheme) {
//        case (.text, .dark): content.foregroundColor(Theme.DarkMode.textColor)
//        case (.text, .light): content.foregroundColor(Theme.LightMode.textColor)
//        case (.button, .dark): content.foregroundColor(Theme.DarkMode.buttonColor)
//        case (.button, .light): content.foregroundColor(Theme.LightMode.buttonColor)
//        case (_, _): content
//        }
//    }
//}


extension UI {
    static let DEFAULT_BG_COLOR = UI.ColorMode(
        lightUI: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
        darkUI: #colorLiteral(red: 0.09171843193, green: 0.1322061844, blue: 0.1834368639, alpha: 1)
    )
    struct Btn {
        static private let UNNOTICEABLE_BG: ColorMode<UI.LL.Color> = ColorMode(
            lightUI: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.01),
            darkUI: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.01235708773)
        )
        static private let DEFAULT_BTN_FG: ColorMode<UI.LL.Color> = ColorMode(
            lightUI: #colorLiteral(red: 0.07268141563, green: 0.1460210236, blue: 0.9764705896, alpha: 1),
            darkUI: #colorLiteral(red: 0.750361383, green: 0.3517298102, blue: 0.9495057464, alpha: 1)
        )
        static private let DEFAULT_CLICK_COLOR: ColorMode<UI.LL.Color> = ColorMode(
            lightUI: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),
            darkUI: #colorLiteral(red: 0.5221483077, green: 0.8354237356, blue: 0.9686274529, alpha: 1)
        )
        static private let DEFAULT_DISABLED_FG_COLOR: ColorMode<UI.LL.Color> = ColorMode(
            lightUI: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
            darkUI: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        )
        fileprivate struct NoDefaultButtonStyle: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                VStack(alignment: .center, spacing: 0) {
                    configuration.label
                }
            }
        }
        struct Pill<L: View, R: View>: View {
            private let action: () -> ()
            private let left: L
            private let right: R
            init(
                action: @escaping () -> (),
                @ViewBuilder left: @escaping () -> L,
                @ViewBuilder right: @escaping () -> R
            ) {
                self.action = action
                self.left = left()
                self.right = right()
            }
            @Environment(\.fgColorMap) private var fgColor
            @Environment(\.bgColorMap) private var bgColorMap
            @Environment(\.colorScheme) private var colorScheme
            @Environment(\.isEnabled) private var isEnabled
            @State private var clicked: Bool = false
            var body: some View {
                let defaultFgColor = (fgColor ?? DEFAULT_BTN_FG)
                let clickedFgColor = DEFAULT_CLICK_COLOR
                let fgColorMap = (!isEnabled ? DEFAULT_DISABLED_FG_COLOR : (!clicked ? defaultFgColor : clickedFgColor))
                let fgColor = fgColorMap.getAsColor(for: colorScheme)
                let bgColor = (bgColorMap ?? UNNOTICEABLE_BG).getAsColor(for: colorScheme)
                let padding: CGFloat = 5
                Button(
                    action: {
                        self.action()
                        withAnimation(.linear(duration: 0.15)) {
                            clicked = true
                        }
                        withAnimation(.linear(duration: 0.15).delay(0.25)) {
                            clicked = false
                        }
                    },
                    label: {
                        HStack(alignment: .center, spacing: 0) {
                            self.left
                                .foregroundColor(fgColor)
                                .font(.system(size: 10, weight: Font.Weight.light))
                                .padding(padding)
//                            Divider()
                                .border(width: 1.0, edges: .trailing, color: fgColor)
                            self.right
                                .foregroundColor(fgColor)
                                .font(.system(size: 10, weight: Font.Weight.light))
                                .padding(padding)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(bgColor)
                        )
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(fgColor, lineWidth: 1))
                        .padding(padding)
                    }
                )
                    .buttonStyle(NoDefaultButtonStyle())
            }
        }
        struct Rounded<V: View>: View {
            private let action: () -> ()
            private let label: () -> V
            init(
                action: @escaping () -> (),
                @ViewBuilder _ label: @escaping () -> V
            ) {
                self.action = action
                self.label = label
            }
            init(
                toggle: Binding<Bool>,
                @ViewBuilder _ label: @escaping () -> V
            ) {
                self.action = {
                    toggle.wrappedValue.toggle()
                }
                self.label = label
            }
            @Environment(\.fgColorMap) private var fgColor
            @Environment(\.colorScheme) private var colorScheme
            @Environment(\.bgColorMap) private var bgColorMap
//            @State private var onClickColor = DEFAULT_CLICK_COLOR
            @State private var clicked: Bool = false
            var body: some View {
                let defaultFgColor = (fgColor ?? DEFAULT_BTN_FG).getAsColor(for: colorScheme)
                let clickedFgColor = DEFAULT_CLICK_COLOR.getAsColor(for: colorScheme)
                let fgColor = !clicked ? defaultFgColor : clickedFgColor
                let bgColor = (bgColorMap ?? UNNOTICEABLE_BG).getAsColor(for: colorScheme)
                let padding: CGFloat = 5
                Button(
                    action: {
                        self.action()
                        withAnimation(.linear(duration: 0.15)) {
                            clicked = true
                        }
                        withAnimation(.linear(duration: 0.15).delay(0.25)) {
                            clicked = false
                        }
                    },
                    label: {
                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center, spacing: 0) {
                                if clicked {
                                    self.label()
                                        .foregroundColor(clickedFgColor)
                                        .font(.system(size: 10, weight: Font.Weight.light))
                                        .padding(padding)
                                } else {
                                    self.label()
                                        .foregroundColor(defaultFgColor)
                                        .font(.system(size: 10, weight: Font.Weight.light))
                                        .padding(padding)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(bgColor)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(fgColor, lineWidth: 1)
                        )
                        .padding(padding)
                    }
                )
                    .buttonStyle(NoDefaultButtonStyle())
            }
        }
        struct PopUpLabel<L: View, P: View>: View {
            private let label: L
            private let popup: () -> P
            init(
                @ViewBuilder label: @escaping () -> L,
                @ViewBuilder _ popup: @escaping () -> P
            ) {
                self.label = label()
                self.popup = popup
            }
            @State private var showPopup: Bool = false
            @Environment(\.fgColorMap) private var fgColor
            @Environment(\.bgColorMap) private var bgColorMap
            @Environment(\.colorScheme) private var colorScheme
            @Environment(\.isEnabled) private var isEnabled
            @State private var clicked: Bool = false
            var body: some View {
                Button(
                    action: {
                        showPopup.toggle()
                        withAnimation(.linear(duration: 0.15)) {
                            clicked = true
                        }
                        withAnimation(.linear(duration: 0.15).delay(0.25)) {
                            clicked = false
                        }
                    },
                    label: {
                        let defaultFgColor = (fgColor ?? DEFAULT_BTN_FG).getAsColor(for: colorScheme)
                        let clickedFgColor = DEFAULT_CLICK_COLOR.getAsColor(for: colorScheme)
                        if clicked {
                            self.label
                                .foregroundColor(clickedFgColor)
                                .font(.system(size: 10, weight: Font.Weight.light))
                        } else {
                            self.label
                                .foregroundColor(defaultFgColor)
                                .font(.system(size: 10, weight: Font.Weight.light))
                        }
                    }
                )
                    .buttonStyle(NoDefaultButtonStyle())
                    .popover(isPresented: $showPopup, content: self.popup)
            }
        }
    }
}

