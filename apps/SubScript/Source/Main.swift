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
    @StateObject private var pageModel = SS1.PageModel()
    @State private var penSet = SS1.PenModel.PenSet.set1
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        UI.Hacks.NavigationStackView {
            SS1.PageView(pageModel: pageModel)
        }
    }
}


@main
struct SubscriptDrawApp: App {
    @Environment(\.colorScheme) private var colorScheme
    var body: some Scene {
#if os(iOS)
        WindowGroup {
            AppView()
        }
#elseif os(macOS)
        WindowGroup {
            let view = AppView()
                .frame(minWidth: 400, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity, alignment: .center)
            if colorScheme == .dark {
                view.background(Color(UI.DefaultColors.DARK_BG_COLOR))
            } else {
                view
            }

        }
#else
        WindowGroup {
            Text("Empty Target (Nothing Specified)")
        }
#endif
    }
}
//
//
