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
    struct PageEntryView: View {
        let index: Int
        @ObservedObject var pageDataModel: SS1.PageModel
        @ObservedObject var pageEntryModel: PageEntryModel
        let onUpdate: () -> ()
        
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
                        pageDataModel.entries.remove(at: index)
                        self.onUpdate()
                    }
                )
                Gutter(
                    entryIndex: index,
                    pageDataModel: pageDataModel,
                    onUpdate: onUpdate
                )
            }
            if pageEntryModel.type.isDrawing {
                VStack(alignment: .center, spacing: 0) {
                    ForEach(Array(pageEntryModel.drawings.enumerated()), id: \.1.id) { (ix, canvas) in
                        VStack(alignment: .center, spacing: 0) {
                            SS1.CanvasView(
                                index: ix,
                                canvasModel: canvas,
                                isFirstChild: ix == 0,
                                isLastChild: ix + 1 == pageEntryModel.drawings.count,
                                deleteMe: {
                                    if ix == 0 {
                                        pageDataModel.entries.remove(at: index)
                                        print("Removed", pageDataModel.entries)
                                    } else {
                                        pageEntryModel.drawings.remove(at: ix)
                                    }
                                    self.onUpdate()
                                },
                                insertNewEntry: {
                                    let newEntry = CanvasModel()
                                    if ix + 1 < pageEntryModel.drawings.endIndex {
                                        pageEntryModel.drawings.insert(newEntry, at: ix + 1)
                                    } else {
                                        pageEntryModel.drawings.append(newEntry)
                                    }
                                    self.onUpdate()
                                },
                                toggleVisibility: {
                                    self.onUpdate()
                                },
                                onUpdate: onUpdate
                            )
                        }
                    }
                    Gutter(
                        entryIndex: index,
                        pageDataModel: pageDataModel,
                        onUpdate: onUpdate
                    )
                        .border(edges: .top)
                }
            }
        }
        struct Gutter: View {
            let entryIndex: Int?
            @ObservedObject var pageDataModel: SS1.PageModel
            
            let onUpdate: () -> ()
            
            @State private var showOptions: Bool = false
            @ViewBuilder func options() -> some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Insert New Entry")
                        .textTheme()

                    Divider()
                    Button(action: {
                        let newEntry = SS1.PageEntryModel(h1: "")
                        showOptions = false
                        pageDataModel.insert(entry: newEntry, after: entryIndex)
                        self.onUpdate()
                        print("inserted", pageDataModel)
                        self.showOptions = false
                    }, label: {
                        Text("Title Entry")
                            .btnLabelTheme()
                    })
                        .buttonStyle(PlainButtonStyle())
                        .padding(8)
                        .border(edges: .all)
                    Button(action: {
                        let newEntry = SS1.PageEntryModel.init(drawings: [
                            CanvasModel()
                        ])
                        pageDataModel.insert(entry: newEntry, after: entryIndex)
                        print("inserted", pageDataModel)
                        self.onUpdate()
                        self.showOptions = false
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
