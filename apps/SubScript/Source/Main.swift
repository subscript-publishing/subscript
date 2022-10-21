//
//  Main.swift
//  SubscriptDraw
//
//  Created by Colbyn Wadman on 9/29/22.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers


struct AppView: View {
    var body: some View {
        SS1.PageView()
    }
}

@main
struct SubscriptDrawApp: App {
    var body: some Scene {
#if os(iOS)
        WindowGroup {
            AppView()
        }
#elseif os(macOS)
        WindowGroup {
            AppView()
            .frame(minWidth: 800, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity, alignment: .center)
        }
#else
        WindowGroup {
            Text("Empty Target (Nothing Specified)")
        }
#endif
    }
}


