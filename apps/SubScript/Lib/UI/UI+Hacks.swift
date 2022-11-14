//
//  SwiftUIExtras.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/21/22.
//

import SwiftUI
import Combine

fileprivate class NavigationStackState: ObservableObject {
    
}

extension UI.Hacks {
    struct BackButton: View {
        init() {}
        @State private var childNavCmd: ChildNavCmd = ChildNavCmd(op: ChildNavCmd.Op.noOp)
        @Environment(\.colorScheme) private var colorScheme
        @EnvironmentObject private var childViewStack: ChildViewStack
        private var backgroundColor = UI.LL.ColorMap(
            lightUI: UI.LL.Color(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.01),
            darkUI: UI.LL.Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.01)
        )
        var body: some View {
            let action = {
                self.childNavCmd = ChildNavCmd.pop()
            }
            UI.Btn.Rounded(action: action) {
                Image(systemName: "chevron.left")
            }
            .preference(key: ChildNavCmdPreferenceKey.self, value: childNavCmd)
            .hidden(childViewStack.stack.isEmpty)
        }
    }
    struct NavBar {
        fileprivate var withBackBtn: Bool
        fileprivate var title: String?
        fileprivate var leading: AnyView?
        fileprivate var trailing: AnyView?
        init<L: View, R: View>(
            title: String? = nil,
            withBackBtn: Bool = true,
            @ViewBuilder leading: @escaping () -> L,
            @ViewBuilder trailing: @escaping () -> R
        ) {
            self.title = title
            self.withBackBtn = withBackBtn
            self.leading = AnyView(leading())
            self.trailing = AnyView(trailing())
        }
        static func defaultNavBar(
            title: String? = nil,
            withBackBtn: Bool = true
        ) -> NavBar {
            NavBar(
                title: title,
                withBackBtn: withBackBtn,
                leading: {
                    EmptyView()
                },
                trailing: {
                    EmptyView()
                }
            )
        }
        static func defaultNavBar<V: View>(
            title: String? = nil,
            withBackBtn: Bool = true,
            @ViewBuilder trailing: @escaping () -> V
        ) -> NavBar {
            NavBar(
                title: title,
                withBackBtn: withBackBtn,
                leading: {
                    EmptyView()
                },
                trailing: trailing
            )
        }
    }
    struct NavigationStackViewLink<L: View, D: View>: View {
        let destination: () -> D
        let label: () -> L
        let navBar: NavBar?
        init(
            navBar: NavBar? = nil,
            @ViewBuilder destination: @escaping () -> D,
            @ViewBuilder label: @escaping () -> L
        ) {
            self.navBar = navBar
            self.destination = destination
            self.label = label
        }
        @EnvironmentObject private var childViewStack: ChildViewStack
//        @State
//        private var pushChildCmd: ChildNavCmd = ChildNavCmd(op: ChildNavCmd.Op.noOp)
        var body: some View {
            let action = {
                let newView = destination()
                childViewStack.stack.append(ChildViewStack.ChildEntry(
                    navBar: navBar,
                    view: {
                        AnyView(newView)
                    }
                ))
            }
            UI.Btn.Rounded(action: action, label)
        }
    }
    struct NavigationStackView<V: View>: View {
        let view: V
        let navBar: NavBar?
        init(navBar: NavBar? = nil, @ViewBuilder _ view: @escaping () -> V) {
            self.navBar = navBar
            self.view = view()
        }
        @Environment(\.bgColorMap) private var bgColor
        @Environment(\.colorScheme) private var colorScheme
        @StateObject private var childViewStack: ChildViewStack = ChildViewStack()
        @StateObject private var toggle: Toggle = Toggle()
        @ViewBuilder private func navBarView(navBar: NavBar) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                HStack(alignment: .center, spacing: 10) {
                    if navBar.withBackBtn {
                        BackButton()
                    }
                    if let leading = navBar.leading {
                        leading
                    }
                    Spacer()
                    if let title = navBar.title {
                        Text(title)
                    }
                    Spacer()
                    if let trailing = navBar.trailing {
                        trailing
                    }
                }
                Spacer()
            }
            .frame(height: 50)
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            .background(Color(UI.DefaultColors.NAV_BAR_BG.get(for: colorScheme)))
            .border(edges: .bottom)
        }
        var body: some View {
            let bgColor = bgColor ?? UI.DEFAULT_BG_COLOR
            Group {
                if let last = childViewStack.stack.last {
                    VStack(alignment: .center, spacing: 0) {
                        if let navBar = last.navBar {
                            navBarView(navBar: navBar)
                        }
                        last.view()
                    }
                } else {
                    VStack(alignment: .center, spacing: 0) {
                        if let navBar = self.navBar {
                            navBarView(navBar: navBar)
                        }
                        self.view
                    }
                }
            }
            .environmentObject(childViewStack)
            .onPreferenceChange(ChildNavCmdPreferenceKey.self, perform: { cmd in
                if cmd.isPop() {
                    print("POP LAST")
                    let _ = self.childViewStack.stack.popLast()
                }
            })
            .background(bgColor.get(for: colorScheme).asColor)
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
    
    fileprivate class Toggle: ObservableObject {
        func refresh() {
            self.objectWillChange.send()
        }
    }
    
    fileprivate class ChildViewStack: ObservableObject {
        var pushChildView: Bool = false
        var ignoreList: Set<UUID> = []
        @Published var stack: Array<ChildEntry> = []
        struct ChildEntry {
            let navBar: NavBar?
            let view: () -> AnyView
        }
    }
    
    fileprivate struct ChildNavCmd: Equatable {
        let id = UUID()
        let op: Op
        static func noOp() -> ChildNavCmd {
            return ChildNavCmd(op: Op.noOp)
        }
        static func push() -> ChildNavCmd {
            return ChildNavCmd(op: Op.pushChild)
        }
        static func pop() -> ChildNavCmd {
            return ChildNavCmd(op: Op.popChild)
        }
        func isPop() -> Bool {
            switch self.op {
            case .popChild: return true
            default: return false
            }
        }
        func isPush() -> Bool {
            switch self.op {
            case .pushChild: return true
            default: return false
            }
        }
        enum Op: Equatable {
            case noOp
            case pushChild
            case popChild
        }
    }
    fileprivate struct ChildNavCmdPreferenceKey: PreferenceKey {
        typealias Value = ChildNavCmd
        static var defaultValue: ChildNavCmd {
            ChildNavCmd.noOp()
        }

        static func reduce(
            value: inout ChildNavCmd,
            nextValue: () -> ChildNavCmd
        ) {
            let received = nextValue()
            if received.isPop() {
                value = received
            }
        }
    }
}

