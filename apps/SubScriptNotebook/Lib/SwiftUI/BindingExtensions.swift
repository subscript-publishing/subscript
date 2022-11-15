//
//  Binding.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/13/22.
//

import SwiftUI

extension Binding {
    static func proxy(_ source: Binding<Value>) -> Binding<Value> {
        self.init(
            get: { source.wrappedValue },
            set: { source.wrappedValue = $0 }
        )
    }
    static func forceProxy(_ source: Binding<Value?>) -> Binding<Value> {
        self.init(
            get: {
                assert(source.wrappedValue != nil)
                return source.wrappedValue!
            },
            set: {
                source.wrappedValue = $0
            }
        )
    }
}
