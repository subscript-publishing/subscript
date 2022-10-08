//
//  PageEditorPrototype.swift
//  Subscript
//
//  Created by Colbyn Wadman on 5/31/22.
//

import SwiftUI

private let shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
private let strokeColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)

fileprivate struct SegmentedViewWrapper<L: View, C: View, R: View>: View {
    let viewport: CGSize
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
        .frame(width: viewport.width, height: height)
        .foregroundColor(foregroundColor)
    }
}

fileprivate struct LayoutEditor: View {
    @ObservedObject
    var pageDataModel: SS1.PageDataModel
    @Environment(\.presentationMode) private var presentationMode
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Close")
                })
                Spacer()
            }
            .padding(12)
            .border(edges: .bottom)
            List {
                ForEach(Array(pageDataModel.entries.enumerated()), id: \.1.id) {(ix, _) in
                    VStack(alignment: .center, spacing: 0) {
                        if pageDataModel.entries[ix].type.isTitle {
                            LayoutTitleEntry(
                                type: pageDataModel.entries[ix].type,
                                title: $pageDataModel.entries[ix].title
                            )
                        }
                        if pageDataModel.entries[ix].type.isDrawing {
                            LayoutDrawingEntry(title: $pageDataModel.entries[ix].title)
                        }
                    }
                }
                .onMove(perform: onMove)
                .onDelete(perform: onDelete)
            }
        }
        .environment(\.editMode, Binding.constant(EditMode.active))
    }
    private func onDelete(offsets: IndexSet) {
        pageDataModel.entries.remove(atOffsets: offsets)
    }
    private func onMove(source: IndexSet, destination: Int) {
        pageDataModel.entries.move(fromOffsets: source, toOffset: destination)
    }
    private struct LayoutTitleEntry: View {
        let type: SS1.PageEntry.EntryType
        @Binding
        var title: SS1.Title
        var body: some View {
            HStack(alignment: .center, spacing: 8) {
                Text(title.type.asString)
                Text(">")
                Text(title.text)
                Spacer()
            }
        }
    }
    private struct LayoutDrawingEntry: View {
        @Binding
        var title: SS1.Title
        var body: some View {
            HStack(alignment: .center, spacing: 8) {
                Text("Drawing")
                Text(">")
                Text(title.text)
                Spacer()
            }
        }
    }
}


extension SS1 {
    struct PageEditor: View {
        @ObservedObject var runtimeModel: SS1.RuntimeDataModel
        @ObservedObject var pageModel: SS1.PageDataModel
        @State private var showLayoutEditor: Bool = false
        @Environment(\.presentationMode) private var mode: Binding<PresentationMode>
        @State private var displayStyle: ColorScheme = ColorScheme.dark
        let goBack: () -> ()
        let onSave: () -> ()
        
        @ViewBuilder var header: some View {
            HStack(alignment: .center, spacing: 5) {
                HStack(alignment: .center, spacing: 5) {
                    Button(
                        action: goBack,
                        label: {
                            Image(systemName: "chevron.left")
                        }
                    )
                    Spacer()
                }
                Spacer()
                HStack(alignment: .center, spacing: 5) {
                    Spacer()
                    Button(
                        action: {
                            switch displayStyle {
                            case .dark: displayStyle = .light
                            case .light: displayStyle = .dark
                            default:
                                displayStyle = ColorScheme.light
                            }
                        },
                        label: {
                            RoundedPill(
                                left: {
                                    let darkIcon = Image(systemName: "moon")
                                    let lightIcon = Image(systemName: "sun.min")
                                    displayStyle == .dark ? darkIcon : lightIcon
                                },
                                right: {
                                    Text("Toggle Display Mode")
                                }
                            )
                        }
                    )
                    Spacer()
                }
                Spacer()
                HStack(alignment: .center, spacing: 5) {
                    Spacer()
                    Button(
                        action: {showLayoutEditor = true},
                        label: {
                            RoundedPill(
                                left: {
                                    Image(systemName: "arrow.up.arrow.down")
                                },
                                right: {
                                    Text("Rearrange")
                                }
                            )
                        }
                    )
                    Button(
                        action: onSave,
                        label: {
                            RoundedLabel(
                                label: {
                                    Text("Save")
                                }
                            )
                        }
                    )
                }
            }
            .padding(10)
        }
        
        var body: some View {
            GeometryReader { geo in
                VStack(alignment: .center, spacing: 0) {
                    header
                        .border(width: 0.5, edges: [.bottom])
                    ScrollViewReader { scroller in
                        ScrollView {
                            VStack(alignment: .center, spacing: 0) {
                                SegmentedViewWrapper(
                                    viewport: geo.size,
                                    left: {
                                        Spacer()
                                    },
                                    center: {
                                        TextField("Page Title", text: $pageModel.pageTitle)
                                            .font(.system(size: 28, weight: Font.Weight.medium, design: Font.Design.monospaced))
    //                                        .foregroundColor(SS.theme.textColor)
                                            .padding(12)
                                    },
                                    right: {
                                        Spacer()
                                    }
                                )
                                TableOfContents(
                                    useSegmentedViewWrapper: true,
                                    viewport: geo.size,
                                    scroller: scroller,
                                    pageDataModel: pageModel
                                )
                                    .border(width: 0.5, edges: [.top])
                                Gutter(
                                    viewport: geo.size,
                                    entryIndex: nil,
                                    runtimeModel: runtimeModel,
    //                                notebookDataModel: notebookModel,
                                    pageDataModel: pageModel
                                )
                                    .border(width: 0.5, edges: [.top])
                                    .border(width: 0.5, edges: [.bottom], show: pageModel.entries.isEmpty)
                                ForEach(Array(pageModel.entries.enumerated()), id: \.1.id) {(ix, _) in
                                    let isLastChild = ix == pageModel.entries.count - 1
                                    Heading(
                                        viewport: geo.size,
                                        entryIndex: ix,
                                        runtimeModel: runtimeModel,
                                        pageDataModel: pageModel,
                                        title: Binding.proxy($pageModel.entries[ix].title)
                                    )
                                    if pageModel.entries[ix].type.isDrawing {
                                        DisplayCanvas(
                                            viewport: geo.size,
                                            entryIndex: ix,
                                            displayStyle: $displayStyle,
                                            runtimeModel: runtimeModel,
                                            pageModel: pageModel,
                                            title: Binding.proxy($pageModel.entries[ix].title),
                                            canvas: pageModel.entries[ix].drawing,
                                            onSave: onSave
                                        )
                                    }
                                    Gutter(
                                        viewport: geo.size,
                                        entryIndex: ix,
                                        runtimeModel: runtimeModel,
    //                                    notebookDataModel: notebookModel,
                                        pageDataModel: pageModel
                                    )
                                        .border(width: 0.5, edges: isLastChild ? [.top, .bottom] : [.top])
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .sheet(isPresented: $showLayoutEditor, content: {
                    LayoutEditor(pageDataModel: pageModel)
                })
            }
            .preferredColorScheme(displayStyle)
        }
        
        struct Gutter: View {
            let viewport: CGSize
            let entryIndex: Int?
            @ObservedObject var runtimeModel: SS1.RuntimeDataModel
    //        @ObservedObject var notebookDataModel: SS.NotebookDataModel
            @ObservedObject var pageDataModel: SS1.PageDataModel
            @State private var showOptions: Bool = false
            @ViewBuilder func options() -> some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Insert New Entry")
    //                    .foregroundColor(textColor)
                    Divider()
                    Button(action: {
                        let newEntry = SS1.PageEntry.newTitleEntry(type: .h1, text: "New Title")
                        showOptions = false
                        if let entryIndex = entryIndex {
                            pageDataModel.addEntryWithAutoType(newEntry: newEntry, index: entryIndex + 1)
                        } else {
                            pageDataModel.addEntryWithAutoType(newEntry: newEntry, index: 0)
                        }
                    }, label: {
                        Text("Title Entry")
                    })
                        .padding(8)
                        .border(edges: .all)
                    Button(action: {
                        let newEntry = SS1.PageEntry.newDrawingEntry(type: .h1, text: "")
                        showOptions = false
                        if let entryIndex = entryIndex {
                            pageDataModel.addEntryWithAutoType(newEntry: newEntry, index: entryIndex + 1)
                        } else {
                            pageDataModel.addEntryWithAutoType(newEntry: newEntry, index: 0)
                        }
                    }, label: {
                        Text("Drawing Entry")
                    })
                        .padding(8)
                        .border(edges: .all)
                }
                .padding(12)
            }
            var body: some View {
                SegmentedViewWrapper(
                    viewport: viewport,
                    height: 35,
                    left: {
                        Button(
                            action: {showOptions = true},
                            label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 20))
                                    .frame(width: 40, height: 40)
                            }
                        )
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
        
        struct Heading: View {
            let viewport: CGSize
            let entryIndex: Int
            @ObservedObject var runtimeModel: SS1.RuntimeDataModel
    //        @ObservedObject var notebookDataModel: SS.NotebookDataModel
            @ObservedObject var pageDataModel: SS1.PageDataModel
            
            @Binding var title: SS1.Title
            @State private var showLeftOptions: Bool = false
            @State private var showRightOptions: Bool = false
            
            @ViewBuilder func selectHeadingType() -> some View {
                Picker("Type", selection: $title.type) {
                    Text("H1").tag(SS1.Title.HeadingType.h1)
                    Text("H2").tag(SS1.Title.HeadingType.h2)
                    Text("H3").tag(SS1.Title.HeadingType.h3)
                    Text("H4").tag(SS1.Title.HeadingType.h4)
                    Text("H5").tag(SS1.Title.HeadingType.h5)
                    Text("H6").tag(SS1.Title.HeadingType.h6)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            @ViewBuilder func options() -> some View {
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: {
                        showRightOptions = false
                        pageDataModel.entries.remove(at: entryIndex)
                    }, label: {
                        Text("Delete")
                    })
                        .padding(8)
                        .border(edges: .all)
                }
                .padding(12)
            }
            
            var body: some View {
                SegmentedViewWrapper(
                    viewport: viewport,
                    left: {
                        Button(
                            action: {showLeftOptions = true},
                            label: {
                                Text(title.type.asString)
                                    .padding(12)
                            }
                        )
                            .popover(isPresented: $showLeftOptions, content: selectHeadingType)
                    },
                    center: {
                        TextField("Title", text: $title.text)
                            .autocapitalization(UITextAutocapitalizationType.words)
                            .font(.system(size: 25, weight: Font.Weight.medium, design: Font.Design.monospaced))
    //                        .foregroundColor(SS.theme.textColor)
                            .padding(12)
                    },
                    right: {
                        Button(
                            action: {showRightOptions = true},
                            label: {
                                Image(systemName: "gearshape.fill")
                            }
                        )
                            .popover(isPresented: $showRightOptions, content: options)
                    }
                )
                .border(width: 0.5, edges: [.top])
            }
        }
        
        struct DisplayCanvas: View {
            let viewport: CGSize
            let entryIndex: Int
            @Binding var displayStyle: ColorScheme
            @ObservedObject var runtimeModel: SS1.RuntimeDataModel
            @ObservedObject var pageModel: SS1.PageDataModel
            @Binding var title: SS1.Title
            @ObservedObject var canvas: SS1.CanvasDataModel
            @State private var showChildView: Bool = false
            let onSave: () -> ()
    //        @ViewBuilder var drawingPreview: some View {
    //            VStack(alignment: .center, spacing: 0) {
    //                ForEach(Array(canvas.entries.enumerated()), id: \.1.id) {(ix, _) in
    //                    let drawingModel = canvas.entries[ix]
    //                    let isLastChild = ix == (canvas.entries.count - 1)
    //                    let height = max(100, drawingModel.height)
    //
    //                }
    //            }
    //        }
            @ViewBuilder func destination() -> some View {
                GuardView(show: entryIndex < pageModel.entries.count) {
                    SS1.CanvasEditor(
                        displayStyle: $displayStyle,
                        canvasModel: canvas,
                        runtimeModel: runtimeModel,
                        goBack: {
                            showChildView.toggle()
                        },
                        onSave: onSave
                    )
    //                SS.Canvas(
    //                    runtimeModel: runtimeModel,
    ////                    notebookModel: notebookModel,
    //                    title: Binding.proxy($title),
    //                    canvasModel: pageModel.entries[entryIndex].drawing,
    //                    goBack: {
    //                        showChildView = false
    //                    }
    //                )
    //                .navigationBarTitle("", displayMode: .inline)
    //                .navigationBarHidden(true)
    //                .statusBar(hidden: true)
    //                .padding(.top, 25)
                }
            }
            var body: some View {
                VStack(alignment: .center, spacing: 0) {
                    SegmentedViewWrapper(
                        viewport: viewport,
                        left: {
                            Spacer()
                        },
                        center: {
                            SS1.Drawing.DisplayEntireDrawing(canvasModel: canvas)
                        },
                        right: {
                            NavigationLink(isActive: $showChildView, destination: destination, label: {
                                Image(systemName: "chevron.forward")
                                    .font(.system(size: 20))
                            })
                        }
                    )
                }
            }
        }
        
        fileprivate struct TableOfContents: View {
            var useSegmentedViewWrapper: Bool = false
            var viewport: CGSize? = nil
            var scroller: Optional<ScrollViewProxy>
            @ObservedObject
            var pageDataModel: SS1.PageDataModel
            var foregroundColor: Color? = nil
            var scaleFactor: CGFloat = 1
            var body: some View {
                if let viewport = viewport {
                    let _ = assert(useSegmentedViewWrapper == true)
                    SegmentedViewWrapper(
                        viewport: viewport,
                        left: {Spacer()},
                        center: {
                            content.padding(12)
                        },
                        right: {Spacer()}
                    )
                } else {
                    content
                }
            }
            @ViewBuilder
            var content: some View {
                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .center, spacing: 0) {
                            Spacer()
                            Text("Table Of Contents")
                                .font(Font.system(
                                    size: 20,
                                    weight: SwiftUI.Font.Weight.light,
                                    design: SwiftUI.Font.Design.default
                                ))
    //                            .foregroundColor(foregroundColor ?? SS.theme.textColor)
                            Spacer()
                        }
                        ForEach(Array(pageDataModel.entries.enumerated()), id: \.1.id) {(ix, _) in
                            if let title = pageDataModel.entries[ix].title {
                                let targetId = pageDataModel.entries[ix].id
                                Button(action: {
                                    if let scroller = scroller {
                                        withAnimation {
                                            scroller.scrollTo(targetId, anchor: .top)
                                        }
                                    }
                                }, label: {
                                    Text(title.text)
                                        .font(Font.system(
                                            size: pageDataModel.entries[ix].title.type.defaultTextSize * scaleFactor,
                                            weight: SwiftUI.Font.Weight.light,
                                            design: SwiftUI.Font.Design.monospaced
                                        ))
    //                                    .foregroundColor(foregroundColor ?? iconColor)
                                        .padding(.leading, pageDataModel.entries[ix].title.type.defaultLeadingMargin)
                                })
                                .disabled(scroller == nil)
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }

}
