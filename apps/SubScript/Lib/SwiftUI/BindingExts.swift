//
//  Combine.swift
//  Superscript
//
//  Created by Colbyn Wadman on 12/29/21.
//

import SwiftUI

public extension Binding {
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
    
    static func observedProxy(
        _ source: Binding<Value>,
        onSet: @escaping () -> ()
    ) -> Binding<Value> {
        self.init(
            get: {
                return source.wrappedValue
            },
            set: {
                onSet()
                source.wrappedValue = $0
            }
        )
    }
}

