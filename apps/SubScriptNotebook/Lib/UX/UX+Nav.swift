//
//  UX+Nav.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/12/22.
//

import SwiftUI
import Combine

// MARK: - Public Namespace -

extension UX {
    struct Nav {}
}

// MARK: - VIEW PAGE MODIFIDER -

fileprivate struct PageViewModifier: ViewModifier {
    let trailing: AnyView
    @EnvironmentObject private var columnEnv: UX.Nav.ColumnEnv
    init(trailing: AnyView) {
        self.trailing = trailing
    }
    func body(content: Content) -> some View {
        content
            .preference(key: NavBarTrailingPreferenceKey.self, value: NavBarTrailingPreference(
                id: columnEnv.id,
                view: self.trailing
            ))
    }
}

//extension View {
//    func uxNavShowBackBtn(_ show: Bool = true) -> some View {
////        return self.environment(\.fgColorMap, color)
////        return self.environmentObject()
//        return modifier(PageViewModifier(
//            showBackBtn: show
////            showToolbar: <#T##Bool?#>,
////            title: <#T##String?#>,
////            leading: <#T##(() -> AnyView)?##(() -> AnyView)?##() -> AnyView#>,
////            trailing: <#T##(() -> AnyView)?##(() -> AnyView)?##() -> AnyView#>
//        ))
//    }
//}

fileprivate struct NavBarTrailingPreference: Equatable {
    var id: UUID
    var view: AnyView
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
fileprivate struct NavBarTrailingPreferenceKey: PreferenceKey {
    typealias Value = NavBarTrailingPreference?
    static var defaultValue: NavBarTrailingPreference? = nil
    static func reduce(
        value: inout Self.Value,
        nextValue: () -> Self.Value
    ) {
        if let nextValue = nextValue() {
            value = nextValue
        }
    }
}

//fileprivate struct NavBarTrailingKey: EnvironmentKey {
//    static let defaultValue: NavBarTrailingPreference? = nil
//}
//extension EnvironmentValues {
//    fileprivate var navBarTrailing: NavBarTrailingPreference? {
//        get {
//            self[NavBarTrailingKey.self]
//        }
//        set(newValue) {
//            self[NavBarTrailingKey.self] = newValue
//        }
//    }
//}

extension View {
    func uxNavBar<V: View>(@ViewBuilder trailing: @escaping () -> V) -> some View {
        return modifier(PageViewModifier(trailing: AnyView(trailing())))
    }
}


// MARK: - Miscellaneous -


fileprivate struct IsNavLinkActiveKey: EnvironmentKey {
    static let defaultValue: Bool? = false
}
extension EnvironmentValues {
    var isNavLinkActive: Bool? {
        get {
            self[IsNavLinkActiveKey.self]
        }
        set(newValue) {
            self[IsNavLinkActiveKey.self] = newValue
        }
    }
}




// MARK: - Child To Parent Data Flow -

fileprivate enum NavCmd: Equatable {
    case noOp
    case pop
    var isNoOp: Bool { self == .noOp }
    var isPop: Bool { self == .pop }
}
fileprivate struct NavCmdPreferenceKey: PreferenceKey {
    typealias Value = NavCmd
    static var defaultValue: NavCmd = NavCmd.noOp
    static func reduce(
        value: inout Self.Value,
        nextValue: () -> Self.Value
    ) {
        if nextValue().isPop {
            value = .pop
        }
    }
}


// MARK: - Column View -

fileprivate struct ColumnView: View {
    @ObservedObject var columnEnv: UX.Nav.ColumnEnv
    @State private var showBackBtnOverride: Bool? = nil
    @State private var showToolbarOverride: Bool? = nil
    @State private var titleOverride: String? = nil
    @State private var leadingOverride: AnyView? = nil
    @State private var trailingOverride: AnyView? = nil
    @EnvironmentObject private var rootViewEnv: UX.Nav.RootViewEnv
    
    @ViewBuilder private func header() -> some View {
        UX.Nav.Toolbar(
            leading: {
                if let leading = leadingOverride {
                    leading
                    if showBackBtnOverride != false && columnEnv.page.showBackBtn {
                        UX.Nav.BackBtn()
                    }
                } else if let leading = columnEnv.page.leading {
                    leading(columnEnv)
                    if showBackBtnOverride != false && columnEnv.page.showBackBtn {
                        UX.Nav.BackBtn()
                    }
                } else if showBackBtnOverride != false && columnEnv.page.showBackBtn {
                    UX.Nav.BackBtn()
                } else {
                    EmptyView()
                }
            },
            center: {
                if let title = titleOverride ?? columnEnv.page.title {
                    Text(title)
                        .fixedSize(horizontal: true, vertical: true)
                        .font(.system(size: 14, weight: Font.Weight.medium, design: Font.Design.monospaced))
                }
            },
            trailing: {
                if let trailing = trailingOverride {
                    trailing
                } else if let trailing = columnEnv.page.trailing {
                    trailing(columnEnv)
                } else {
                    EmptyView()
                }
            }
        )
    }
    @ViewBuilder private var nextView: some View {
        if let next = self.columnEnv.next {
            ColumnView(columnEnv: next)
                .onPreferenceChange(NavCmdPreferenceKey.self, perform: { cmd in
                    if cmd.isPop {
                        withAnimation {
                            columnEnv.pop()
                        }
                    }
                })
                .preference(key: NavCmdPreferenceKey.self, value: NavCmd.noOp)
                .withBorder(edges: .leading)
                .transition(.move(edge: .trailing))
                .onAppear(perform: {
//                    if next.next.isNone {
//                        print("rootViewEnv.scrollToIndex(next.index)")
//                    }
//                    rootViewEnv.scrollToEnd()
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        rootViewEnv.scrollToEnd()
//                    }
                })
        } else {
            EmptyView()
        }
    }
    var body: some View {
        if columnEnv.display {
            VStack(alignment: .center, spacing: 0) {
                header()
                columnEnv.page.destination(columnEnv)
                Spacer()
            }
            .environmentObject(self.columnEnv)
            .id(self.columnEnv.id)
            .id(self.columnEnv.index)
        }
        nextView
    }
}


// MARK: - Column Environment -

extension UX.Nav {
    class ColumnEnv: ObservableObject {
        var id: UUID {
            get {self.page.id}
        }
        var index: Int {
            get {self._index}
        }
        fileprivate
        var next: ColumnEnv? {
            get {
                return self._next
            }
        }
        @Published fileprivate var page: UX.Nav.Page
        @Published fileprivate var display: Bool = true
        @Published private var _next: ColumnEnv? = nil
        fileprivate var _index: Int = 0
        fileprivate var isRoot: Bool = false
        fileprivate init(rootPage: UX.Nav.Page) {
            self.page = rootPage
            self.isRoot = true
        }
        init(page: UX.Nav.Page) {
            self.page = page
        }
        func clearNext() {
            self._next?.clearNext()
            if let f = self._next?.page.onPop {
                f()
            }
            self._next = nil
        }
        func push(newPage: UX.Nav.Page) {
            clearNext()
            self._next = ColumnEnv(page: newPage)
            self._next!._index = self._index + 1
        }
        func pop() {
            clearNext()
        }
        func clear() {
            clearNext()
        }
        static let ACTIVE_FG_COLOR_MAP = UX.ColorMap(
            lightMode: #colorLiteral(red: 0.9319887833, green: 0, blue: 0.7358607531, alpha: 1),
            darkMode: #colorLiteral(red: 0.3864123721, green: 0.9764705896, blue: 0.8876167637, alpha: 1)
        )
    }
    fileprivate class RootViewEnv: ObservableObject {
        var rootID: UUID = UUID()
        var scrollToID: ((UUID) -> ())!
        var scrollToIndex: ((Int) -> ())!
        var scrollToEnd: (() -> ())!
    }
    struct RootView: View {
        @StateObject private var rootColumnEnv: ColumnEnv
        @StateObject private var rootViewEnv: RootViewEnv = RootViewEnv()
        init(page: UX.Nav.Page) {
            self._rootColumnEnv = StateObject(wrappedValue: ColumnEnv(rootPage: page))
        }
//        init<V: View>(
//            id: UUID,
//            @ViewBuilder view: @escaping (ColumnEnv) -> V
//        ) {
//            let page = Page(id: id, view)
//            self._rootColumnEnv = StateObject(wrappedValue: ColumnEnv(rootPage: page))
//        }
        var body: some View {
            ScrollViewReader { scroller in
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 0) {
                        ColumnView(columnEnv: self.rootColumnEnv)
                    }
                    .id(rootViewEnv.rootID)
                    .frame(maxWidth: .infinity)
                    .withBorder(edges: [.leading, .trailing])
                }
                .environmentObject(rootViewEnv)
                .onAppear(perform: {
                    rootViewEnv.scrollToID = { id in
                        print("rootViewEnv.scrollToID")
                        scroller.scrollTo(id, anchor: UnitPoint.topTrailing)
                    }
                    rootViewEnv.scrollToIndex = { ix in
                        print("rootViewEnv.scrollToIndex")
                        scroller.scrollTo(ix, anchor: UnitPoint.topTrailing)
                    }
                    rootViewEnv.scrollToEnd = {
                        scroller.scrollTo(rootViewEnv.rootID, anchor: UnitPoint.topTrailing)
                    }
                })
            }
        }
    }
    struct Link<V: View>: View {
        fileprivate let page: UX.Nav.Page
        fileprivate let label: () -> V
        @EnvironmentObject private var columnEnv: ColumnEnv
        @EnvironmentObject private var rootViewEnv: RootViewEnv
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.fgColorMap) private var fgColorMap
        init(page: UX.Nav.Page, @ViewBuilder label: @escaping () -> V) {
            self.page = page
            self.label = label
        }
//        init<D: View>(
//            id: UUID,
//            @ViewBuilder label: @escaping () -> V,
//            @ViewBuilder destination: @escaping (ColumnEnv) -> D
//        ) {
//            self.label = label
//            self.page = UX.Nav.Page(id: id, destination)
//        }
        private func onClickImpl() {
            columnEnv.push(newPage: self.page)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                rootViewEnv.scrollToID(self.page.id)
            }
        }
        private func onClick() {
//            rootViewEnv.scrollTo(self.page.id)
//            self.page.events.onAppear = {
//                rootViewEnv.scrollTo(self.page.id)
//            }
//            if let next = columnEnv.next {
//                if next.next.isSome {
//                    withAnimation(.easeOut(duration: 0.25)) {
//                        onClickImpl()
//                    }
//                } else {
//                    onClickImpl()
//                }
//            } else {
//                withAnimation(.easeOut(duration: 0.25)) {
//                    onClickImpl()
//                }
//            }
            onClickImpl()
        }
        private var btn: some View {
            UX.Btn(action: onClick, self.label)
        }
        private var isActive: Bool {
            if let next = columnEnv.next {
                if next.page.id == self.page.id {
                    return true
                }
            }
            return false
        }
        var body: some View {
            let activeFgColorMap = ColumnEnv.ACTIVE_FG_COLOR_MAP
            btn
                .environment(\.fgColorMap, isActive ? activeFgColorMap : fgColorMap)
                .environment(\.isNavLinkActive, isActive)
        }
    }
    struct BackBtn: View {
        init() {}
        @State private var navCmd: NavCmd = NavCmd.noOp
        @EnvironmentObject private var columnEnv: ColumnEnv
        private func onClick() {
            navCmd = .pop
        }
        var body: some View {
            UX.RoundBtn(icon: "chevron.backward", action: onClick)
                .preference(key: NavCmdPreferenceKey.self, value: navCmd)
                .isHidden(columnEnv.isRoot)
        }
    }
}


// MARK: - HELPERS -

extension UX.Nav {
    static let NAV_BAR_BG = UX.ColorMap(
        lightMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
        darkMode: #colorLiteral(red: 0.2302554846, green: 0.2302554846, blue: 0.2302554846, alpha: 1)
    )
    
    /// The standard toolbar view, used internally, and publicly available for cases where you want a toolbar lookalike.
    struct Toolbar<L, C, T>: View where L: View, C: View, T: View {
        private let leading: () -> L
        private let center: () -> C
        private let trailing: () -> T
        init(
            @ViewBuilder leading: @escaping () -> L,
            @ViewBuilder center: @escaping () -> C,
            @ViewBuilder trailing: @escaping () -> T
        ) {
            self.leading = leading
            self.center = center
            self.trailing = trailing
        }
        @Environment(\.colorScheme) private var colorScheme
        var body: some View {
            let bgColor = NAV_BAR_BG.get(for: colorScheme).asColor
//            ZStack(alignment: .center) {
//                HStack(alignment: .center, spacing: 5) {
//                    leading().fixedSize(horizontal: true, vertical: false)
//                    Spacer()
//                }
//                HStack(alignment: .center, spacing: 5) {
//                    Spacer()
//                    center().fixedSize(horizontal: true, vertical: false)
//                    Spacer()
//                }
//                HStack(alignment: .center, spacing: 5) {
//                    Spacer()
//                    trailing().fixedSize(horizontal: true, vertical: false)
//                }
//            }
            HStack(alignment: .center, spacing: 5) {
                leading()
                Spacer()
                center()
                    .allowsTightening(true)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                Spacer()
                trailing()
            }
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            .background(bgColor)
            .withBorder(edges: [.top, .bottom])
        }
    }
}

// MARK: - PAGE DATA MODEL -

extension UX.Nav {
    class PageBuilder {
        fileprivate var showBackBtn: Bool = true
        fileprivate var showToolbar: Bool = true
        fileprivate var title: String? = nil
        fileprivate var leading: ((ColumnEnv) -> AnyView)? = nil
        fileprivate var trailing: ((ColumnEnv) -> AnyView)? = nil
        fileprivate var onPop: (() -> ())? = nil
        init() {}
        @discardableResult
        func showToolbar(_ show: Bool) -> Self {
            self.showToolbar = show
            return self
        }
        @discardableResult
        func showBackBtn(_ show: Bool) -> Self {
            self.showBackBtn = show
            return self
        }
        @discardableResult
        func withTitle(title: String) -> Self {
            self.title = title
            return self
        }
        @discardableResult
        func withTitleOpt(title: String?) -> Self {
            if let title = title {
                self.title = title
            }
            return self
        }
        @discardableResult
        func withLeading<V: View>(@ViewBuilder _ view: @escaping (ColumnEnv) -> V) -> Self {
            self.leading = {
                AnyView(view($0))
            }
            return self
        }
        @discardableResult
        func withTrailing<V: View>(@ViewBuilder _ view: @escaping (ColumnEnv) -> V) -> Self {
            self.trailing = {
                AnyView(view($0))
            }
            return self
        }
        @discardableResult
        func withTrailingIf<V: View>(show: Bool, @ViewBuilder _ view: @escaping (ColumnEnv) -> V) -> Self {
            if show {
                self.trailing = {
                    AnyView(view($0))
                }
            }
            return self
        }
        @discardableResult
        func onPop(_ f: @escaping () -> ()) -> Self {
            self.onPop = f
            return self
        }
        func build<D: View>(id: UUID, @ViewBuilder destination: @escaping (ColumnEnv) -> D) -> Page {
            return Page(
                id: id,
                showBackBtn: self.showBackBtn,
                showToolbar: self.showToolbar,
                title: self.title,
                rawLeading: self.leading,
                rawTrailing: self.trailing,
                rawDestination: {
                    AnyView(destination($0))
                },
                onPop: self.onPop
            )
        }
        func buildLink<V: View, D: View>(
            id: UUID,
            @ViewBuilder label: @escaping () -> V,
            @ViewBuilder destination: @escaping (ColumnEnv) -> D
        ) -> Link<V> {
            let page = Page(
                id: id,
                showBackBtn: self.showBackBtn,
                showToolbar: self.showToolbar,
                title: self.title,
                rawLeading: self.leading,
                rawTrailing: self.trailing,
                rawDestination: {
                    AnyView(destination($0))
                },
                onPop: self.onPop
            )
            return Link(page: page, label: label)
        }
    }
    fileprivate class PageEvents {
        fileprivate var onAppear: (() -> ())? = nil
    }
    struct Page {
        fileprivate let id: UUID
        fileprivate var showBackBtn: Bool = true
        fileprivate var showToolbar: Bool = true
        fileprivate var title: String? = nil
        fileprivate var leading: ((ColumnEnv) -> AnyView)?
        fileprivate var trailing: ((ColumnEnv) -> AnyView)?
        fileprivate var destination: (ColumnEnv) -> AnyView
        fileprivate var onPop: (() -> ())? = nil
        fileprivate var events: PageEvents = PageEvents()
        fileprivate init(
            id: UUID,
            showBackBtn: Bool,
            showToolbar: Bool,
            title: String?,
            rawLeading: ((ColumnEnv) -> AnyView)?,
            rawTrailing: ((ColumnEnv) -> AnyView)?,
            rawDestination: @escaping (ColumnEnv) -> AnyView,
            onPop: (() -> ())? = nil
        ) {
            self.id = id
            self.showBackBtn = showBackBtn
            self.showToolbar = showToolbar
            self.title = title
            self.leading = rawLeading
            self.trailing = rawTrailing
            self.destination = rawDestination
            self.onPop = onPop
        }
//        init<L: View, T: View, D: View>(
//            id: UUID,
//            @ViewBuilder leading: @escaping (ColumnEnv) -> L,
//            @ViewBuilder trailing: @escaping (ColumnEnv) -> T,
//            @ViewBuilder destination: @escaping (ColumnEnv) -> D
//        ) {
//            self.id = id
//            self.leading = {
//                AnyView(leading($0))
//            }
//            self.trailing = {
//                AnyView(trailing($0))
//            }
//            self.destination = {
//                AnyView(destination($0))
//            }
//        }
//        init<D: View>(id: UUID, @ViewBuilder _ destination: @escaping (ColumnEnv) -> D) {
//            self.id = id
//            self.leading = nil
//            self.trailing = nil
//            self.destination = {
//                AnyView(destination($0))
//            }
//        }
    }
}
