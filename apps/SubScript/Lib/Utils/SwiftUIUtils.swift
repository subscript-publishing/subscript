//
//  SwiftUI.swift
//  Superscript
//
//  Created by Colbyn Wadman on 3/29/22.
//

import SwiftUI

fileprivate let DARK_UI_BORDER_COLOR = Color.purple
fileprivate let LIGHT_UI_BORDER_COLOR = Color(#colorLiteral(red: 0.07268141563, green: 0.1460210236, blue: 0.9764705896, alpha: 1))

fileprivate let INACTIVE_DARK_UI_BORDER_COLOR = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
fileprivate let INACTIVE_LIGHT_UI_BORDER_COLOR = Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))

fileprivate let ALT_DARK_UI_BORDER_COLOR = Color(#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1))
fileprivate let ALT_LIGHT_UI_BORDER_COLOR = Color(#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1))

struct GuardView<V: View>: View {
    let show: Bool
    let subview: () -> V
    
    init(show: Bool, @ViewBuilder _ view: @escaping () -> V) {
        self.show = show
        self.subview = view
    }
    
    var body: some View {
        if show {
            subview()
        }
    }
}

struct RoundedPill<L: View, R: View>: View {
    let inactive: Bool
    let altColor: Bool
    let left: () -> L
    let right: () -> R
    @Environment(\.colorScheme) private var colorScheme
    
    init(
        inactive: Bool = false,
        altColor: Bool = false,
        @ViewBuilder left: @escaping () -> L,
        @ViewBuilder right: @escaping () -> R
    ) {
        self.inactive = inactive
        self.altColor = altColor
        self.left = left
        self.right = right
    }
    
    var body: some View {
        let borderColor = colorScheme == .dark
        ? (inactive
            ? INACTIVE_DARK_UI_BORDER_COLOR
            : (altColor ? ALT_DARK_UI_BORDER_COLOR : DARK_UI_BORDER_COLOR))
        : (inactive
            ? INACTIVE_LIGHT_UI_BORDER_COLOR
            : (altColor ? ALT_LIGHT_UI_BORDER_COLOR : LIGHT_UI_BORDER_COLOR))
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 0) {
                left()
                    .foregroundColor(borderColor)
                    .padding(5)
            }
            .border(width: 1, edges: [.trailing], color: borderColor)
            VStack(alignment: .center, spacing: 0) {
                right()
                    .foregroundColor(borderColor)
                    .padding(5)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(borderColor, lineWidth: 1)
        )
        .padding(5)
    }
}

struct RoundedLabel<V: View>: View {
    let label: () -> V
    let inactive: Bool
    let altColor: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    init(inactive: Bool = false, altColor: Bool = false, @ViewBuilder label: @escaping () -> V) {
        self.label = label
        self.inactive = inactive
        self.altColor = altColor
    }
    
    var body: some View {
        let borderColor = colorScheme == .dark
        ? (inactive
            ? INACTIVE_DARK_UI_BORDER_COLOR
            : (altColor ? ALT_DARK_UI_BORDER_COLOR : DARK_UI_BORDER_COLOR))
        : (inactive
            ? INACTIVE_LIGHT_UI_BORDER_COLOR
            : (altColor ? ALT_LIGHT_UI_BORDER_COLOR : LIGHT_UI_BORDER_COLOR))
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 0) {
                label()
                    .foregroundColor(borderColor)
                    .padding(5)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(borderColor, lineWidth: 1)
        )
        .padding(5)
    }
}
