//
//  UI+Label.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/8/22.
//

import SwiftUI

extension UX {
    struct Sticker {}
}

//fileprivate let DEFAULT_BG_COLOR = UI.ColorMap(
//    lightMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
//    darkMode: #colorLiteral(red: 0.09171843193, green: 0.1322061844, blue: 0.1834368639, alpha: 1)
//)

extension UX.Sticker {
    static let DEFAULT_LABEL_FG_COLOR = UX.ColorMap(
        lightMode: #colorLiteral(red: 0.09322258437, green: 0.1003935516, blue: 0.1104329056, alpha: 1),
        darkMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    )
    static let DEFAULT_FONT: Font = .system(size: 12, weight: Font.Weight.medium)
    struct Round<V: View>: View {
        fileprivate let label: () -> V
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.fgColorMap) private var fgColorMap
        @Environment(\.bgColorMap) private var bgColorMap
        init(@ViewBuilder _ label: @escaping () -> V) {
            self.label = label
        }
        private var targetBorderColorMap: UX.ColorMap {
            return fgColorMap ?? UX.Divider.DEFAULT_BORDER_COLOR_MAP
        }
        private var targetLabelColorMap: UX.ColorMap {
            return fgColorMap ?? UX.Sticker.DEFAULT_LABEL_FG_COLOR
        }
        var body: some View {
            let borderColor = targetBorderColorMap.get(for: colorScheme).asColor
            let labelColor = targetLabelColorMap.get(for: colorScheme).asColor
            label()
                .font(UX.Sticker.DEFAULT_FONT)
                .foregroundColor(labelColor)
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(bgColorMap?.get(for: colorScheme).asColor ?? Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(borderColor, lineWidth: 1)
                )
                .padding(5)
        }
    }
    struct Pill<L: View, R: View>: View {
        fileprivate let left: () -> L
        fileprivate let right: () -> R
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.fgColorMap) private var fgColorMap
        @Environment(\.bgColorMap) private var bgColorMap
        init(
            @ViewBuilder leading: @escaping () -> L,
            @ViewBuilder trailing: @escaping () -> R
        ) {
            self.left = leading
            self.right = trailing
        }
        private var targetBorderColorMap: UX.ColorMap {
            return fgColorMap ?? UX.Divider.DEFAULT_BORDER_COLOR_MAP
        }
        private var targetLabelColorMap: UX.ColorMap {
            return fgColorMap ?? UX.Sticker.DEFAULT_LABEL_FG_COLOR
        }
        var body: some View {
            let borderColor = targetBorderColorMap.get(for: colorScheme).asColor
            let labelColor = targetLabelColorMap.get(for: colorScheme).asColor
            let size = UX.Divider.DEFAULT_LINE_WIDTH
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .center, spacing: 0) {
                    self.left()
                        .font(UX.Sticker.DEFAULT_FONT)
                        .padding(5)
                        .foregroundColor(labelColor)
                        .fgColorMap(color: targetLabelColorMap)
                }
                UX.HD().fgColorMap(color: targetBorderColorMap)
                VStack(alignment: .center, spacing: 0) {
                    self.right()
                        .font(UX.Sticker.DEFAULT_FONT)
                        .padding(5)
                        .foregroundColor(labelColor)
                        .fgColorMap(color: targetLabelColorMap)
                }
            }
            .fixedSize()
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(borderColor, lineWidth: size)
            )
            .padding(5)
        }
    }
}


//extension UI.Sticker.Rounded where V == Text {
//    init(text: String) {
//        self.view = Text(text)
//    }
//}
//extension UI.Sticker.Rounded where V == Image {
//    init(icon: String) {
//        self.view = Image(systemName: icon)
//    }
//}
