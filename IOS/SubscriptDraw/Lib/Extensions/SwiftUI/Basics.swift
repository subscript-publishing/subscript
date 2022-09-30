//
//  Basics.swift
//  Superscript
//
//  Created by Colbyn Wadman on 1/7/22.
//

import SwiftUI

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide { hidden() }
        else { self }
    }
}


