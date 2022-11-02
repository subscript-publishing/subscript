//
//  Page.swift
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
    struct HeadingView: View {
        @Binding var title: SS1.Heading
        let deleteMe: () -> ()
        
        @State private var showLeftOptions: Bool = false
        @State private var showRightOptions: Bool = false
        
        @ViewBuilder func selectHeadingType() -> some View {
            Picker("Type", selection: $title.type) {
                Text("H1").tag(SS1.Heading.HeadingType.h1)
                Text("H2").tag(SS1.Heading.HeadingType.h2)
                Text("H3").tag(SS1.Heading.HeadingType.h3)
                Text("H4").tag(SS1.Heading.HeadingType.h4)
                Text("H5").tag(SS1.Heading.HeadingType.h5)
                Text("H6").tag(SS1.Heading.HeadingType.h6)
            }
            .pickerStyle(SegmentedPickerStyle())
            .btnLabelTheme()
            .padding(15)
        }
        
        @ViewBuilder func options() -> some View {
            VStack(alignment: .leading, spacing: 8) {
                Button(action: {
                    showRightOptions = false
                    deleteMe()
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
                left: {
                    Button(
                        action: {showLeftOptions = true},
                        label: {
                            Text(title.type.asString)
                                .btnLabelTheme()
                                .padding(12)
                        }
                    )
                        .buttonStyle(PlainButtonStyle())
                        .popover(isPresented: $showLeftOptions, content: selectHeadingType)
                },
                center: {
                    TextField("Title", text: $title.text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .textTheme()
//#if os(iOS)
//                        .autocapitalization(NSTextAutocapitalizationType.words)
//#endif
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
                        .buttonStyle(PlainButtonStyle())
                        .popover(isPresented: $showRightOptions, content: options)
                }
            )
            .border(width: 0.5, edges: [.top])
        }
    }
}

extension SS1 {
    fileprivate class XToggleHack: ObservableObject {
        @Published var toggle: Bool = false
    }
    struct PageView: View {
        @ObservedObject var pageModel: PageModel
        @StateObject private var toolbarModel: ToolBarModel = SS1.ToolBarModel()
        @Environment(\.colorScheme) private var colorScheme
        @StateObject private var xToggleHack: XToggleHack = XToggleHack()
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
        func onSave() {
            SSByteArrayPointer.with_codable(value: self.pageModel) { ptr in
                app_data_model_save_state(ptr)
            }
        }
        @State private var showPenListEditor: Bool = false
        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                gutterBorder
                ToolBarView(
                    toolbarModel: toolbarModel,
                    showPenListEditor: $showPenListEditor,
                    toggleColorScheme: {
                        
                    },
                    goBack: {
                        
                    },
                    onSave: self.onSave
                )
                    .frame(height: 45)
                CustomScroller { actions in
                    let onUpdate: () -> () = {
                        actions.updateLayout()
                    }
                    let view = VStack(alignment: .center, spacing: 0) {
                        gutterBorder
                        PageEntryView.Gutter(
                            entryIndex: nil,
                            pageDataModel: pageModel,
                            onUpdate: onUpdate
                        )
                            .border(edges: .top)
                        ForEach(Array(pageModel.entries.enumerated()), id: \.1.id) { (ix, _) in
                            PageEntryView(
                                index: ix,
                                pageDataModel: pageModel,
                                pageEntryModel: pageModel.entries[ix],
                                onUpdate: onUpdate
                            )
                                .border(edges: .bottom)
                        }
                    }
                    if colorScheme == .dark {
                        view.background(Color(UI.DefaultColors.DARK_BG_COLOR))
                    } else {
                        view
                    }
                }
//                VStack(alignment: .center, spacing: 0) {
//                    let onUpdate: () -> () = {
//
//                    }
//                    let view = VStack(alignment: .center, spacing: 0) {
//                        gutterBorder
//                        PageEntryView.Gutter(
//                            entryIndex: nil,
//                            pageDataModel: pageModel,
//                            onUpdate: onUpdate
//                        )
//                            .border(edges: .top)
//                        ForEach(Array(pageModel.entries.enumerated()), id: \.1.id) { (ix, _) in
//                            PageEntryView(
//                                index: ix,
//                                pageDataModel: pageModel,
//                                pageEntryModel: pageModel.entries[ix],
//                                onUpdate: onUpdate
//                            )
//                                .border(edges: .bottom)
//                        }
//                    }
//                    if colorScheme == .dark {
//                        view.background(Color(UI.DefaultColors.DARK_BG_COLOR))
//                    } else {
//                        view
//                    }
//                    Spacer()
//                }
            }
            .sheet(isPresented: $showPenListEditor, content: {
                SS1.ToolBarView.PenListEditorView(toolbarModel: toolbarModel)
            })
        }
    }
}
