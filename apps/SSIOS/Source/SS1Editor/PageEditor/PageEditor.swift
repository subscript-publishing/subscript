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
        // PUBLIC API
//        @Binding var displayStyle: ColorScheme
        @ObservedObject var runtimeModel: SS1.RuntimeDataModel
        @ObservedObject var pageModel: SS1.PageDataModel
        let toggleColorScheme: () -> ()
        let goBack: () -> ()
        let onSave: () -> ()
        // PRIVATE
        @State private var showLayoutEditor: Bool = false
        @Environment(\.presentationMode) private var mode: Binding<PresentationMode>
        @Environment(\.colorScheme) private var colorScheme
        
        @ViewBuilder var header: some View {
            HStack(alignment: .center, spacing: 5) {
                HStack(alignment: .center, spacing: 5) {
                    Button(
                        action: goBack,
                        label: {
                            RoundedLabel(label: {
                                Image(systemName: "chevron.left")
                                    .btnLabelTheme()
                            })
                        }
                    )
                    Spacer()
                }
                Spacer()
                HStack(alignment: .center, spacing: 5) {
                    Spacer()
                    Button(
                        action: toggleColorScheme,
                        label: {
                            RoundedPill(
                                left: {
                                    let darkIcon = Image(systemName: "moon")
                                    let lightIcon = Image(systemName: "sun.min")
                                    colorScheme == .dark ? darkIcon : lightIcon
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
                                    Image(systemName: "gear")
                                },
                                right: {
                                    Text("Delete/Rearrange Entries.")
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
                        .background(Rectangle().foregroundColor(
                            colorScheme == .dark
                                ? SS1.StaticSettings.DarkMode.Page.HEADER_BG
                                : SS1.StaticSettings.LightMode.Page.HEADER_BG
                        ))
                        .border(width: 0.5, edges: [.bottom, .top])
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
                                            .textTheme()
                                            .font(.system(size: 28, weight: Font.Weight.medium, design: Font.Design.monospaced))
    //                                        .foregroundColor(SS.theme.textColor)
                                            .padding(12)
                                    },
                                    right: {
                                        Spacer()
                                    }
                                )
                                    .border(edges: [.top])
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
//                                            displayStyle: $displayStyle,
                                            runtimeModel: runtimeModel,
                                            pageModel: pageModel,
                                            title: Binding.proxy($pageModel.entries[ix].title),
                                            canvas: pageModel.entries[ix].drawing,
                                            onSave: onSave,
                                            toggleColorScheme: toggleColorScheme
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
                .background(
                    Rectangle()
                        .foregroundColor(
                            colorScheme == .dark
                                ? SS1.StaticSettings.DarkMode.Page.BG
                                : SS1.StaticSettings.LightMode.Page.BG
                        )
                )
            }
            .ignoresSafeArea()
            .padding(.top, 1)
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
                        .textTheme()

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
                            .btnLabelTheme()
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
                            .btnLabelTheme()
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
                                    .btnLabelTheme()
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
                .btnLabelTheme()
            }
            
            @ViewBuilder func options() -> some View {
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: {
                        showRightOptions = false
                        pageDataModel.entries.remove(at: entryIndex)
                    }, label: {
                        Text("Delete")
                            .btnLabelTheme()
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
                                    .btnLabelTheme()
                                    .padding(12)
                            }
                        )
                            .popover(isPresented: $showLeftOptions, content: selectHeadingType)
                    },
                    center: {
                        TextField("Title", text: $title.text)
                            .textTheme()
                            .autocapitalization(UITextAutocapitalizationType.words)
                            .font(.system(size: 25, weight: Font.Weight.medium, design: Font.Design.monospaced))
                            .padding(12)
                    },
                    right: {
                        Button(
                            action: {showRightOptions = true},
                            label: {
                                Image(systemName: "gearshape.fill")
                                    .btnLabelTheme()
                            }
                        )
                            .popover(isPresented: $showRightOptions, content: options)
                    }
                )
                .border(width: 0.5, edges: [.top])
            }
        }
        
        struct DisplayCanvas: View {
            // EXTERNAL API
            let viewport: CGSize
            let entryIndex: Int
            @ObservedObject var runtimeModel: SS1.RuntimeDataModel
            @ObservedObject var pageModel: SS1.PageDataModel
            @Binding var title: SS1.Title
            @ObservedObject var canvas: SS1.CanvasDataModel
            let onSave: () -> ()
            let toggleColorScheme: () -> ()
            
            // INTERNAL API
            @Environment(\.colorScheme) private var colorScheme
            private let darkBgColor = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
            private let darkMainShadowColor = Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
            private let lightBgColor = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            private let lightMainShadowColor = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
            private var bgColor: Color {
                switch colorScheme {
                case .light: return lightBgColor
                case .dark: return darkBgColor
                default: return Color.clear
                }
            }
            private var shadowColor: Color {
                switch colorScheme {
                case .light: return lightMainShadowColor
                case .dark: return darkMainShadowColor
                default: return Color.clear
                }
            }
            
            // INTERNAL
            @State private var showChildView: Bool = false
            @ViewBuilder private var divider: some View {
                HStack(alignment: .center, spacing: 0) {
                    Spacer()
                }
                .frame(height: 5.0)
                .border(width: 0.5, edges: [.top, .bottom])
                .background(bgColor)
            }
            
            @ViewBuilder func destination() -> some View {
                GuardView(show: entryIndex < pageModel.entries.count) {
                    SS1.CanvasEditor(
                        title: $pageModel.entries[entryIndex].title,
                        displayTitle: true,
                        canvasModel: canvas,
                        runtimeModel: runtimeModel,
                        toggleColorScheme: toggleColorScheme,
                        goBack: {
                            showChildView.toggle()
                        },
                        onSave: onSave
                    )
//                        .environment(\.colorScheme, self.colorScheme)
//                        .preferredColorScheme(self.colorScheme)
//                        .colorScheme(self.colorScheme)
                }
            }
            var body: some View {
                let mask = MaskView().fill()
                VStack(alignment: .center, spacing: 0) {
                    divider
                    ZStack(alignment: .center) {
                        Rectangle()
                            .foregroundColor(bgColor)
                        SegmentedViewWrapper(
                            viewport: viewport,
                            left: {
                                Spacer()
                            },
                            center: {
                                SS1.Drawing.DisplayEntireDrawing(canvasModel: canvas)
                                    .border(width: 1.0, edges: [.bottom])
                            },
                            right: {
                                NavigationLink(isActive: $showChildView, destination: destination, label: {
                                    VStack(alignment: .center, spacing: 0) {
                                        Image(systemName: "chevron.forward")
                                            .btnLabelTheme()
                                            .font(.system(size: 20))
                                            .padding(.top, 20)
                                        Spacer()
                                    }
                                })
                            }
                        )
                    }
                }
                .mask(mask)
                .shadow(color: shadowColor, radius: 2, x: 0, y: 2)
            }
            
            struct MaskView: Shape {
                func path(in rect: CGRect) -> Path {
                    let centerY = rect.height - 25
                    let steps = 545
                    let stepX = rect.width / CGFloat(steps)
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: 0))
                    for i in 0...steps {
                        let x = CGFloat(i) * stepX
                        let y = abs((cos(Double(i) * 0.15) * 10) + Double(centerY))
                        path.addLine(to: CGPoint(x: x, y: CGFloat(y)))
                    }
                    path.addLine(to: CGPoint(x: rect.width, y: 0.0))
                    path.closeSubpath()
                    return path
                }
            }
        }
        
        fileprivate struct TableOfContents: View {
            var useSegmentedViewWrapper: Bool = false
            var viewport: CGSize? = nil
            var scroller: Optional<ScrollViewProxy>
            @ObservedObject var pageDataModel: SS1.PageDataModel
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
            @ViewBuilder var content: some View {
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
                                .textTheme()

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
                                        .padding(.leading, pageDataModel.entries[ix].title.type.defaultLeadingMargin)
                                        .btnLabelTheme()
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
