//
//  SwiftUI.swift
//  Superscript
//
//  Created by Colbyn Wadman on 3/29/22.
//

import SwiftUI

fileprivate let DARK_UI_BORDER_COLOR = Color.purple
fileprivate let LIGHT_UI_BORDER_COLOR = Color(#colorLiteral(red: 0.07268141563, green: 0.1460210236, blue: 0.9764705896, alpha: 1))

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
    let left: () -> L
    let right: () -> R
    @Environment(\.colorScheme) private var colorScheme
    
    init(@ViewBuilder left: @escaping () -> L, @ViewBuilder right: @escaping () -> R) {
        self.left = left
        self.right = right
    }
    
    var body: some View {
        let borderColor = colorScheme == .dark
            ? DARK_UI_BORDER_COLOR
            : LIGHT_UI_BORDER_COLOR
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
    @Environment(\.colorScheme) private var colorScheme
    
    init(@ViewBuilder label: @escaping () -> V) {
        self.label = label
    }
    
    var body: some View {
        let borderColor = colorScheme == .dark
            ? DARK_UI_BORDER_COLOR
            : LIGHT_UI_BORDER_COLOR
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
