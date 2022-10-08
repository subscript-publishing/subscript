//
//  Main.swift
//  SubscriptDraw
//
//  Created by Colbyn Wadman on 9/29/22.
//

import SwiftUI
import UniformTypeIdentifiers


@main
struct SubscriptDrawApp: App {
    var body: some Scene {
#if SubscriptCompositionTarget
        SS1.CompositionEditorScene()
#elseif SubscriptDrawTarget
        SS1.DrawingEditorScene()
#else
        WindowGroup {
            Text("Empty Target (Nothing Specified)")
        }
#endif
    }
}


