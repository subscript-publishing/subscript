//
//  ToolbarDocs.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/21/22.
//

import SwiftUI

fileprivate let MIN_WIDTH_PANEL_WIDTH: CGFloat = 600

extension SS1.ToolBarView {
    struct PenListEditorView: View {
        @ObservedObject var toolbarModel: SS1.ToolBarModel
        @State private var editMode: Bool = false
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.presentationMode) private var presentationMode
        private enum InsertNewPenOrder {
            case front
            case back
        }
        @State private var showInsertNewPenMenu: Bool = false
        @State private var insertNewPenOrder: InsertNewPenOrder = InsertNewPenOrder.back
        @State private var settingsLock: Bool = true
        enum PenListFilter: String, Equatable, Codable {
            case showAll
            case showSet1
            case showSet2
            case showSet3
            case showSet4
        }
        @State private var penListFilter = PenListFilter.showAll
        func hasLotsOfPens() -> Bool {
            var penCounter = 0
            for pen in self.toolbarModel.pens {
                switch (penListFilter, pen.penSet) {
                case (.showAll, _): penCounter = penCounter + 1
                case (.showSet1, .set1): penCounter = penCounter + 1
                case (.showSet2, .set2): penCounter = penCounter + 1
                case (.showSet3, .set3): penCounter = penCounter + 1
                case (.showSet4, .set4): penCounter = penCounter + 1
                default: ()
                }
            }
            return penCounter > 10
        }
        private func insertPenBtnAction() {
            let lotsOfPens = hasLotsOfPens()
            if !lotsOfPens {
                var newPen = toolbarModel.templatePen
                newPen.id = UUID()
                switch self.penListFilter {
                case .showSet1: newPen.penSet = .set1
                case .showSet2: newPen.penSet = .set2
                case .showSet3: newPen.penSet = .set3
                case .showSet4: newPen.penSet = .set4
                case .showAll: ()
                }
                toolbarModel.pens.append(newPen)
            } else {
                showInsertNewPenMenu = true
            }
        }
        @ViewBuilder private var insertPenBtn: some View {
            let lotsOfPens = hasLotsOfPens()
            UI.Btn.Pill(
                action: self.insertPenBtnAction,
                left: {
                    if lotsOfPens {
                        Image(systemName: "rectangle.badge.plus")
                    } else {
                        Image(systemName: "plus")
                    }
                },
                right: {
                    if lotsOfPens {
                        Text("Insert New Pen (Options)")
                    } else {
                        Text("Insert New Pen")
                    }
                }
            )
                .popover(isPresented: $showInsertNewPenMenu, content: {
                    let addPenAction = {
                        var newPen = toolbarModel.templatePen
                        newPen.id = UUID()
                        switch self.penListFilter {
                        case .showSet1: newPen.penSet = .set1
                        case .showSet2: newPen.penSet = .set2
                        case .showSet3: newPen.penSet = .set3
                        case .showSet4: newPen.penSet = .set4
                        case .showAll: ()
                        }
                        switch self.insertNewPenOrder {
                        case .back: toolbarModel.pens.append(newPen)
                        case .front:
                            if toolbarModel.pens.isEmpty {
                                toolbarModel.pens.append(newPen)
                            } else {
                                toolbarModel.pens.insert(newPen, at: 0)
                            }
                        }
                    }
                    VStack(alignment: .center, spacing: 20) {
                        Text("It looks like you have a lot of pens, for your convenience, I can insert the new pen at the beginning of the list, or at the back of the list.")
                            .multilineTextAlignment(.center)
                            .textTheme()
                            .frame(width: 400)
                        Picker("Layer", selection: $insertNewPenOrder) {
                            Text("Front").tag(InsertNewPenOrder.front)
                            Text("Back").tag(InsertNewPenOrder.back)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        UI.Btn.Rounded(action: addPenAction) {
                            HStack(alignment: .center, spacing: 0) {
                                Spacer()
                                Text("Insert")
                                Spacer()
                            }
                        }
                    }
                    .padding(20)
                })
        }
        @ViewBuilder private func penListEntry(pen: Binding<SS1.PenModel>) -> some View {
            HStack(alignment: .center, spacing: 5) {
                let darkColor = Color(pen.wrappedValue.dynamicPenStyle.color.darkUI.asCGColor)
                let lightColor = Color(pen.wrappedValue.dynamicPenStyle.color.lightUI.asCGColor)
                let darkIcon = Image(systemName: "moon")
                let lightIcon = Image(systemName: "sun.min")
                RoundedLabel(inactive: true, label: {
                    switch pen.penSet.wrappedValue {
                    case .set1: Text("{1}")
                    case .set2: Text("{2}")
                    case .set3: Text("{3}")
                    case .set4: Text("{4}")
                    }
                })
                Text(String(format: "%.1fpx", pen.dynamicPenStyle.size.wrappedValue))
                Spacer()
                if pen.active.wrappedValue {
                    RoundedLabel(altColor: true, label: {
                        Text("Active")
                    })
                }
                Spacer()
                RoundedLabel(inactive: true, label: {
                    if pen.wrappedValue.dynamicPenStyle.layer == .foreground {
                        Text("Foreground")
                    } else {
                        Text("Background")
                    }
                })
                RoundedPill(inactive: true, left: {darkIcon}, right: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            fillStyle: darkColor,
                            stroke: Color.black,
                            lineWidth: 1
                        )
                        .frame(width: 50, alignment: .center)
                })
                RoundedPill(inactive: true, left: {lightIcon}, right: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            fillStyle: lightColor,
                            stroke: Color.white,
                            lineWidth: 1
                        )
                        .frame(width: 50, alignment: .center)
                    }
                )
                UI.Hacks.NavigationStackViewLink(
                    navBar: UI.Hacks.NavBar.defaultNavBar(
                        title: "Edit Pen",
                        withBackBtn: true,
                        trailing: {
                            UI.Hacks.NavigationStackViewLink(
                                navBar: UI.Hacks.NavBar.defaultNavBar(
                                    title: "Pen Docs",
                                    withBackBtn: true
                                ),
                                destination: {
                                    SS1.ToolBarView.PenSettingsForm.DocView()
                                },
                                label: {
                                    Text("Info")
                                }
                            )
                        }
                    ),
                    destination: {
//                        PenSettingsPanel(toolbarModel: toolbarModel, pen: pen)
                        PenSettingsForm(toolbarModel: toolbarModel, pen: pen)
                    },
                    label: {
                        Image(systemName: "chevron.forward")
                    }
                )
            }
        }
        @ViewBuilder private var penList: some View {
            List {
                ForEach(Array(toolbarModel.pens.enumerated()), id: \.1.id) {(ix, pen) in
                    let view = penListEntry(pen: $toolbarModel.pens[ix])
                    switch (penListFilter, pen.penSet) {
                    case (.showAll, _): view
                    case (.showSet1, .set1): view
                    case (.showSet2, .set2): view
                    case (.showSet3, .set3): view
                    case (.showSet4, .set4): view
                    default: EmptyView()
                    }
                }
                .onMove(perform: onMove)
                .onDelete(perform: onDelete)
            }
            .frame(minWidth: MIN_WIDTH_PANEL_WIDTH, minHeight: 400)
        }
        var body: some View {
            let navBar = UI.Hacks.NavBar(
                title: "Pen List Editor",
                withBackBtn: false,
                leading: {
                    UI.Btn.Rounded(action: {presentationMode.wrappedValue.dismiss()}) {
                        Text("Close")
                    }
                    UI.Btn.Rounded(toggle: $settingsLock) {
                        if settingsLock {
                            Image(systemName: "lock")
                        } else {
                            Image(systemName: "lock.open")
                        }
                    }
                    .useDangerousFgColor()
                },
                trailing: {
                    UI.Btn.Pill(
                        action: {
                            if !settingsLock {
                                let newModel = SS1.ToolBarModel()
                                toolbarModel.pens = newModel.pens
                                toolbarModel.templatePen = newModel.templatePen
                            }
                        },
                        left: {
                            if settingsLock {
                                Image(systemName: "lock")
                            } else {
                                Image(systemName: "lock.open")
                            }
                        },
                        right: {
                            Text("Reset Pens")
                        }
                    )
                        .useDangerousFgColor()
                        .disabled(settingsLock)
                }
            )
            UI.Hacks.NavigationStackView(navBar: navBar) {
                content
            }
        }
        private var content: some View {
            VStack(alignment: .center, spacing: 10) {
                Divider()
                HStack(alignment: .center, spacing: 10) {
                    UI.Btn.Rounded(toggle: $editMode) {
                        Text("Toggle Edit Mode")
                    }
                    Spacer()
                    insertPenBtn
                    Spacer()
                    UI.Hacks.NavigationStackViewLink(
                        navBar: UI.Hacks.NavBar.defaultNavBar(),
                        destination: {
                            SS1.ToolBarView.PenSettingsForm(
                                toolbarModel: toolbarModel,
                                pen: $toolbarModel.templatePen
                            )
                        },
                        label: {
                            Text("Edit Template Pen")
                        }
                    )
                }
                .padding([.leading, .trailing], 10)
                HStack(alignment: .center, spacing: 10) {
                    Spacer()
                    Text("Show")
                    Picker("Filter", selection: $penListFilter) {
                        Text("All Pens").tag(PenListFilter.showAll)
                        Text("{1}").tag(PenListFilter.showSet1)
                        Text("{2}").tag(PenListFilter.showSet2)
                        Text("{3}").tag(PenListFilter.showSet3)
                        Text("{4}").tag(PenListFilter.showSet4)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Spacer()
                }
                let list = penList
                if editMode {
//                    list.environment(\.editMode, Binding.constant(EditMode.active)).border(edges: [.top])
                    list.border(edges: [.top])
                } else {
                    list.border(edges: [.top])
                }
            }
        }
        private func onDelete(offsets: IndexSet) {
            toolbarModel.pens.remove(atOffsets: offsets)
        }
        private func onMove(source: IndexSet, destination: Int) {
            toolbarModel.pens.move(fromOffsets: source, toOffset: destination)
        }
    }
}

