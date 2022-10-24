//
//  Page.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/20/22.
//

import SwiftUI

extension SS1 {
    final class PageModel: ObservableObject, Codable {
        @Published
        var id: UUID = UUID()
        @Published
        var entries: Array<PageEntryModel> = [
            PageEntryModel.init(h1: "Hello World"),
            PageEntryModel.init(h2: "Sub-Title"),
            PageEntryModel.init(h3: "Some Drawing"),
            PageEntryModel.init(drawings: [
                CanvasModel()
            ]),
        ]
        init() {}
        init(entries: Array<PageEntryModel>) {
            self.entries = entries
        }
        enum CodingKeys: CodingKey {
            case pageTitle, entries
        }
        func encode(to encoder: Encoder) throws {
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try! container.encode(pageTitle, forKey: .pageTitle)
//            try! container.encode(entries, forKey: .entries)
        }
        required init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            pageTitle = try container.decode(String.self, forKey: .pageTitle)
//            entries = try container.decode(Array.self, forKey: .entries)
        }
    }
    struct PageView: View {
        @ObservedObject var pageModel: PageModel
        
        @StateObject private var toolbarModel: ToolBarModel = SS1.ToolBarModel()
        
        @Environment(\.colorScheme) private var colorScheme
        
        @ViewBuilder private var gutterBorder: some View {
            HStack(alignment: .center, spacing: 0) {Spacer()}
                .background(Rectangle().foregroundColor(
                    colorScheme == .dark
                        ? SS1.StaticSettings.DarkMode.Canvas.BG2
                        : SS1.StaticSettings.LightMode.Canvas.BG2
                ))
                .padding([.top, .bottom], 4)
                .border(edges: [.bottom, .top])
        }
        @State private var showPenListEditor: Bool = false
        var body: some View {
            VStack(alignment: .center, spacing: 0) {
//                gutterBorder
                ToolBarView(
                    toolbarModel: toolbarModel,
                    toggleColorScheme: {
                        
                    },
                    goBack: {
                        
                    },
                    onSave: {
                        
                    },
                    showPenListEditor: $showPenListEditor
                )
                    .frame(height: 40)
                CustomScroller { customScrollerCoordinator in
                    let view = VStack(alignment: .center, spacing: 0) {
                        gutterBorder
                        PageEntryView.Gutter(entryIndex: nil, pageDataModel: pageModel)
                            .border(edges: .top)
                        ForEach(Array(pageModel.entries.enumerated()), id: \.1.id) { (ix, entry) in
                            PageEntryView(index: ix, pageDataModel: pageModel, pageEntryModel: entry)
                                .border(edges: .bottom)
                        }
                    }
                    if colorScheme == .dark {
                        view.background(Color(UI.DefaultColors.DARK_BG_COLOR))
                    } else {
                        view
                    }
                }
            }
            .sheet(isPresented: $showPenListEditor, content: {
                SS1.ToolBarView.PenListEditorView(toolbarModel: toolbarModel)
            })
        }
    }
//    struct PageView: View {
//        @StateObject private var canvasModel = SS1.CanvasModel()
//        var body: some View {
//            VStack(alignment: .center, spacing: 0) {
//                CustomScroller { customScrollerCoordinator in
//                    VStack(alignment: .center, spacing: 0) {
//                        SS1.CanvasView(
//                            canvasModel: canvasModel,
//                            updateLayouts: {
//                                customScrollerCoordinator.refresh()
//                            },
//                            isFirstChild: true,
//                            isLastChild: true,
//                            deleteMe: {
//                                customScrollerCoordinator.refresh()
//                            },
//                            insertNewEntry: {
//                                customScrollerCoordinator.refresh()
//                            },
//                            toggleVisibility: {
//                                customScrollerCoordinator.refresh()
//                            }
//                        )
//                        Spacer()
//                    }
//                }
//            }
//        }
//    }
}
