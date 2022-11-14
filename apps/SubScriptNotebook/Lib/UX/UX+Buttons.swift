//
//  UI+Misc.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/9/22.
//

import SwiftUI

extension UX {
    struct DefaultButtonStyle: SwiftUI.ButtonStyle {
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.fgColorMap) private var fgColorMap
        @Environment(\.bgColorMap) private var bgColorMap
        @Environment(\.isEnabled) private var isEnabled
        func targetFgColorMap(isPressed: Bool) -> UX.ColorMap {
            if !isEnabled {
                return DefaultButtonStyle.DEFAULT_DISABLED_FG_COLOR
            }
            if isPressed {
                return DefaultButtonStyle.DEFAULT_CLICK_COLOR
            }
            return fgColorMap ?? DefaultButtonStyle.DEFAULT_BTN_FG
        }
        private var targetBgColorMap: UX.ColorMap {
            return bgColorMap ?? DefaultButtonStyle.UNNOTICEABLE_BG
        }
        func makeBody(configuration: Configuration) -> some View {
            let fgColorMap = targetFgColorMap(isPressed: configuration.isPressed)
            let fgColor = fgColorMap.get(for: colorScheme).asColor
            configuration.label
                .font(UX.Sticker.DEFAULT_FONT)
                .fgColorMap(color: fgColorMap)
                .bgColorMap(color: targetBgColorMap)
                .foregroundColor(fgColor)
                .animation(.easeOut(duration: 0.5), value: configuration.isPressed)
        }
        static let UNNOTICEABLE_BG: UX.ColorMap = UX.ColorMap(
            lightMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.01),
            darkMode: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.01235708773)
        )
        static let DEFAULT_BTN_FG: UX.ColorMap = UX.ColorMap(
            lightMode: #colorLiteral(red: 0.07268141563, green: 0.1460210236, blue: 0.9764705896, alpha: 1),
            darkMode: #colorLiteral(red: 0.750361383, green: 0.3517298102, blue: 0.9495057464, alpha: 1)
        )
        static let DEFAULT_CLICK_COLOR: UX.ColorMap = UX.ColorMap(
            lightMode: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),
            darkMode: #colorLiteral(red: 0.5221483077, green: 0.8354237356, blue: 0.9686274529, alpha: 1)
        )
        static let DEFAULT_DISABLED_FG_COLOR: UX.ColorMap = UX.ColorMap(
            lightMode: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
            darkMode: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        )
    }
    struct Btn<V: View>: View {
        private let action: () -> ()
        private let label: () -> V
        init(action: @escaping () -> (), @ViewBuilder _ label: @escaping () -> V) {
            self.action = action
            self.label = label
        }
        var body: some View {
            Button(action: self.action, label: self.label)
                .buttonStyle(UX.DefaultButtonStyle())
        }
    }
    struct PopoverBtn<V: View, P: View>: View {
        private let label: () -> V
        private let popover: (Binding<Bool>) -> P
        @State private var showPopover: Bool = false
        init(
            @ViewBuilder label: @escaping () -> V,
            @ViewBuilder popover: @escaping (Binding<Bool>) -> P
        ) {
            self.label = label
            self.popover = popover
        }
        var body: some View {
            Button(action: {showPopover = true}, label: self.label)
                .buttonStyle(UX.DefaultButtonStyle())
                .popover(isPresented: $showPopover, content: {
                    popover($showPopover)
                })
        }
    }
    struct RoundBtn<V: View>: View {
        private let action: () -> ()
        private let label: () -> V
        init(action: @escaping () -> (), @ViewBuilder _ label: @escaping () -> V) {
            self.action = action
            self.label = label
        }
        var body: some View {
            UX.Btn(action: self.action) {
                UX.Sticker.Round(self.label)
            }
        }
    }
    struct RoundPopoverBtn<V: View, P: View>: View {
        private let label: () -> V
        private let popover: (Binding<Bool>) -> P
        init(
            @ViewBuilder label: @escaping () -> V,
            @ViewBuilder popover: @escaping (Binding<Bool>) -> P
        ) {
            self.label = label
            self.popover = popover
        }
        @State private var showPopover: Bool = false
        var body: some View {
            UX.Btn(action: {showPopover = true}) {
                UX.Sticker.Round(self.label)
            }
            .popover(isPresented: $showPopover, content: {
                popover($showPopover)
            })
        }
    }
    struct PillBtn<L: View, T: View>: View {
        private let action: () -> ()
        private let leading: () -> L
        private let trailing: () -> T
        init(
            action: @escaping () -> (),
            @ViewBuilder leading: @escaping () -> L,
            @ViewBuilder trailing: @escaping () -> T
        ) {
            self.action = action
            self.leading = leading
            self.trailing = trailing
        }
        var body: some View {
            UX.Btn(action: self.action) {
                UX.Sticker.Pill(leading: self.leading, trailing: self.trailing)
            }
        }
    }
    struct PillPopoverBtn<L: View, T: View, P: View>: View {
        private let leading: () -> L
        private let trailing: () -> T
        private let popover: (Binding<Bool>) -> P
        init(
            @ViewBuilder leading: @escaping () -> L,
            @ViewBuilder trailing: @escaping () -> T,
            @ViewBuilder popover: @escaping (Binding<Bool>) -> P
        ) {
            self.leading = leading
            self.trailing = trailing
            self.popover = popover
        }
        @State private var showPopover: Bool = false
        var body: some View {
            UX.Btn(action: {showPopover = true}) {
                UX.Sticker.Pill(leading: self.leading, trailing: self.trailing)
            }
            .popover(isPresented: $showPopover, content: {
                popover($showPopover)
            })
        }
    }
    struct ThreeColumnView<L, C, T>: View where L: View, C: View, T: View {
        private let leading: () -> L
        private let center: () -> C
        private let trailing: () -> T
        init(
            @ViewBuilder leading: @escaping () -> L,
            @ViewBuilder center: @escaping () -> C,
            @ViewBuilder trailing: @escaping () -> T
        ) {
            self.leading = leading
            self.center = center
            self.trailing = trailing
        }
        var body: some View {
            ZStack(alignment: .center) {
                HStack(alignment: .center, spacing: 5) {
                    leading()
                    Spacer()
                }
                HStack(alignment: .center, spacing: 5) {
                    Spacer()
                    center()
                    Spacer()
                }
                HStack(alignment: .center, spacing: 5) {
                    Spacer()
                    trailing()
                }
            }
        }
    }
}

extension UX.Btn{
    init(icon: String, action: @escaping () -> ()) where V == Image {
        self.init(action: action, {
            Image(systemName: icon)
        })
    }
}
extension UX.RoundBtn{
    init(icon: String, action: @escaping () -> ()) where V == Image {
        self.init(action: action, {
            Image(systemName: icon)
        })
    }
}
extension UX.Btn{
    init(text: String, action: @escaping () -> ()) where V == Text {
        self.init(action: action, {
            Text(text)
        })
    }
}
extension UX.RoundBtn{
    init(text: String, action: @escaping () -> ()) where V == Text {
        self.init(action: action, {
            Text(text)
        })
    }
}


extension UX.PopoverBtn {
    init(
        icon: String,
        @ViewBuilder popover: @escaping (Binding<Bool>) -> P
    ) where V == Image {
        self.init(label: {Image(systemName: icon)}, popover: popover)
    }
}
extension UX.RoundPopoverBtn{
    init(
        icon: String,
        @ViewBuilder popover: @escaping (Binding<Bool>) -> P
    ) where V == Image {
        self.init(label: {Image(systemName: icon)}, popover: popover)
    }
}
extension UX.PopoverBtn {
    init(
        text: String,
        @ViewBuilder popover: @escaping (Binding<Bool>) -> P
    ) where V == Text {
        self.init(label: {Text(text)}, popover: popover)
    }
}
extension UX.RoundPopoverBtn{
    init(
        text: String,
        @ViewBuilder popover: @escaping (Binding<Bool>) -> P
    ) where V == Text {
        self.init(label: {Text(text)}, popover: popover)
    }
}
