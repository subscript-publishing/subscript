//
//  View+Extensions.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/20/22.
//

import SwiftUI

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide { hidden() }
        else { self }
    }
    @ViewBuilder func foregroundColorIf(use: Bool, color: UI.Color) -> some View {
        if use {
            self.foregroundColor(Color(color))
        } else {
            self
        }
    }
    func foregroundColorIf(given: Bool, ifTrue: UI.Color, ifFalse: UI.Color) -> some View {
        if given {
            return self.foregroundColor(Color(ifTrue))
        } else {
            return self.foregroundColor(Color(ifFalse))
        }
    }
    @ViewBuilder func foregroundColorOpt(color: UI.Color?) -> some View {
        if let color = color {
            self.foregroundColor(Color(color))
        } else {
            self
        }
    }
}
