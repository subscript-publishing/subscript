//
//  Page.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/20/22.
//

import SwiftUI

extension SS1 {
    class PageModel: ObservableObject, Codable {
        @Published
        var id: UUID = UUID()
        @Published
        var pageTitle: String = ""
        @Published
        var entries: Array<PageEntryModel> = []
        
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
        @StateObject private var canvasModel = SS1.CanvasModel()
        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                CustomScroller { customScrollerCoordinator in
                    VStack(alignment: .center, spacing: 0) {
                        SS1.CanvasView(
                            canvasModel: canvasModel,
                            updateLayouts: {
                                customScrollerCoordinator.refresh()
                            },
                            isFirstChild: true,
                            isLastChild: true,
                            deleteMe: {
                                customScrollerCoordinator.refresh()
                            },
                            insertNewEntry: {
                                customScrollerCoordinator.refresh()
                            },
                            toggleVisibility: {
                                customScrollerCoordinator.refresh()
                            }
                        )
                        Spacer()
                    }
                    .background(Color.yellow)
                }
            }
        }
    }
}
