//
//  PageEntry.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/20/22.
//

import SwiftUI

fileprivate struct SegmentedViewWrapper<L: View, C: View, R: View>: View {
//    let viewport: CGSize
    var height: CGFloat? = nil
    @ViewBuilder var left: L
    @ViewBuilder var center: C
    @ViewBuilder var right: R
    var body: some View {
        let foregroundColor = Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        HStack(alignment: .center, spacing: 0) {
            left.frame(width: 50, height: height, alignment: .center)
            center
                .frame(height: height, alignment: .leading)
                .border(edges: [.leading, .trailing])
            right.frame(width: 50, height: height)
        }
        .frame(height: height)
        .foregroundColor(foregroundColor)
    }
}

extension SS1 {
    final class PageEntryModel: ObservableObject, Codable, Identifiable {
        @Published var id: UUID = UUID()
        @Published var type: EntryType = EntryType.drawing
        @Published var heading: Heading = Heading()
        @Published var drawings: Array<CanvasModel> = [
            CanvasModel()
        ]
        init(drawings: Array<CanvasModel>) {
            self.heading = Heading()
            self.drawings = drawings
            self.type = EntryType.drawing
        }
        init(h1 text: String) {
            self.heading = Heading(heading: .h1, text: text)
            self.drawings = []
            self.type = EntryType.heading
        }
        init(h2 text: String) {
            self.heading = Heading(heading: .h2, text: text)
            self.drawings = []
            self.type = EntryType.heading
        }
        init(h3 text: String) {
            self.heading = Heading(heading: .h3, text: text)
            self.drawings = []
            self.type = EntryType.heading
        }
        init(title: Heading) {
            self.heading = title
            self.drawings = []
            self.type = EntryType.heading
        }
        enum CodingKeys: CodingKey {
            case title, titleOnly, entries
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
        
        enum EntryType: String, Codable {
            case heading
            case drawing
            
            var isHeading: Bool {
                switch self {
                case .heading: return true
                default: return false
                }
            }
            
            var isDrawing: Bool {
                switch self {
                case .drawing: return true
                default: return false
                }
            }
        }
    }
    struct PageEntryView: View {
        let index: Int
        @ObservedObject var pageDataModel: SS1.PageModel
        @ObservedObject var pageEntryModel: PageEntryModel
        @Environment(\.colorScheme) private var colorScheme
        @ViewBuilder private var gutterBorder: some View {
            HStack(alignment: .center, spacing: 0) {Spacer()}
                .background(Rectangle().foregroundColor(
                    colorScheme == .dark
                        ? SS1.StaticSettings.DarkMode.Canvas.BG2
                        : SS1.StaticSettings.LightMode.Canvas.BG2
                ))
                .padding([.top, .bottom], 4)
                .border(edges: [.bottom])
        }
        @ViewBuilder private var gutterMenu: some View {
            SegmentedViewWrapper(
//                height: 50,
                left: {
                    Spacer()
                },
                center: {
                    Spacer()
                },
                right: {
                    Spacer()
                }
            )
        }
        var body: some View {
            if pageEntryModel.type.isHeading {
                HeadingView(
                    title: $pageEntryModel.heading,
                    deleteMe: {
                        
                    }
                )
                Gutter(
                    entryIndex: index,
                    pageDataModel: pageDataModel
                )
            }
            if pageEntryModel.type.isDrawing {
                VStack(alignment: .center, spacing: 0) {
//                    let topGutter = gutterBorder
//                    if colorScheme == .dark {
//                        topGutter.background(Color(UI.DefaultColors.DARK_BG_COLOR_LIGHTER))
//                    } else {
//                        topGutter
//                    }
                    ForEach(Array(pageEntryModel.drawings.enumerated()), id: \.1.id) { (ix, canvas) in
                        VStack(alignment: .center, spacing: 0) {
                            SS1.CanvasView(
                                index: ix,
                                canvasModel: canvas,
                                updateLayouts: {
                                    
                                },
                                isFirstChild: ix == 0,
                                isLastChild: ix + 1 == pageEntryModel.drawings.count,
                                deleteMe: {
                                    if ix > 0 {
                                        pageEntryModel.drawings.remove(at: ix)
                                    }
                                },
                                insertNewEntry: {
                                    let newEntry = CanvasModel()
                                    if ix + 1 < pageEntryModel.drawings.endIndex {
                                        pageEntryModel.drawings.insert(newEntry, at: ix + 1)
                                    } else {
                                        pageEntryModel.drawings.append(newEntry)
                                    }
                                },
                                toggleVisibility: {
                                    
                                }
                            )
                        }
                    }
                    Gutter(
                        entryIndex: index,
                        pageDataModel: pageDataModel
                    )
                        .border(edges: .top)
                }
            }
        }
        struct Gutter: View {
            let entryIndex: Int?
            @ObservedObject var pageDataModel: SS1.PageModel
            @State private var showOptions: Bool = false
            @ViewBuilder func options() -> some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Insert New Entry")
                        .textTheme()

                    Divider()
                    Button(action: {
        //                let newEntry = SS1.PageEntry.newTitleEntry(type: .h1, text: "New Title")
                        showOptions = false
//                        if let entryIndex = entryIndex {
//        //                    pageDataModel.addEntryWithAutoType(newEntry: newEntry, index: entryIndex + 1)
//                        } else {
//        //                    pageDataModel.addEntryWithAutoType(newEntry: newEntry, index: 0)
//                        }
                    }, label: {
                        Text("Title Entry")
                            .btnLabelTheme()
                    })
                        .buttonStyle(PlainButtonStyle())
                        .padding(8)
                        .border(edges: .all)
                    Button(action: {
        //                let newEntry = SS1.PageEntry.newDrawingEntry(type: .h1, text: "")
                        showOptions = false
//                        if let entryIndex = entryIndex {
//        //                    pageDataModel.addEntryWithAutoType(newEntry: newEntry, index: entryIndex + 1)
//                        } else {
//        //                    pageDataModel.addEntryWithAutoType(newEntry: newEntry, index: 0)
//                        }
                    }, label: {
                        Text("Drawing Entry")
                            .btnLabelTheme()
                    })
                        .buttonStyle(PlainButtonStyle())
                        .padding(8)
                        .border(edges: .all)
                }
                .padding(12)
            }
            var body: some View {
                SegmentedViewWrapper(
        //            viewport: viewport,
                    height: 35,
                    left: {
                        Button(
                            action: {showOptions = true},
                            label: {
                                Image(systemName: "plus")
                                    .btnLabelTheme()
                                    .font(.system(size: 20))
                                    .frame(width: 40, height: 40)
                            }
                        )
                            .buttonStyle(PlainButtonStyle())
                            .popover(isPresented: $showOptions, content: options)
                    },
                    center: {
                        Spacer()
                    },
                    right: {
                        Spacer()
                    }
                )
            }
        }
    }
}
