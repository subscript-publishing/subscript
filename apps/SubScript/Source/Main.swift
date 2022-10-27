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
//    @StateObject private var pageEntryModel = SS1.PageEntryModel(h1: "Hello Drawing", drawings: [SS1.CanvasModel()])
    @StateObject private var pageModel = SS1.PageModel()
    @State private var penSet = SS1.Pen.PenSet.set1
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        UI.Hacks.NavigationStackView {
            SS1.PageView(pageModel: pageModel)
        }
    }
}

//typealias X = MetalCanvasViewController


//@main
//struct RustSkiaCanvasApp: App {
//    var body: some Scene {
//        WindowGroup {
////            Text("TODO")
////            WrapView { _ in
////                let view = DevMetalView()
////                view.setup()
////                return view
////            }
////            WrapViewController { _ in
////                let ctl = DevMetalView()
////                return ctl
////            }
//        }
//    }
//}

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
