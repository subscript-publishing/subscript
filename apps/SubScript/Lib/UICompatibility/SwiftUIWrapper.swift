//
//  UIFFI.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/10/22.
//

import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/* ///////////////////////////////////////////////////////////////////////////////// */
// MARK: - WRAPPING UIKIT VIEWS -
/* ///////////////////////////////////////////////////////////////////////////////// */

struct WrapView<Wrapped: UI.View>: UI.ViewRepresentable {
#if os(iOS)
    typealias UIViewType = Wrapped
#elseif os(macOS)
    typealias NSViewType = Wrapped
#endif
    typealias Updater = (Wrapped, Context) -> Void
    
    fileprivate var makeView: () -> Wrapped
    fileprivate var update: (Wrapped, Context) -> ()

    init(_ setup: @escaping () -> Wrapped) {
        self.makeView = setup
        self.update = {(_, _) in ()}
    }

    init(setup: @escaping () -> Wrapped, update: @escaping (Wrapped) -> ()) {
        self.makeView = setup
        self.update = {(wrapper, _) in update(wrapper)}
    }
    
#if os(iOS)
    func makeUIView(context: Context) -> Wrapped {
        makeView()
    }
    func updateUIView(_ view: Wrapped, context: Context) {
        update(view, context)
    }
#elseif os(macOS)
    func makeNSView(context: Context) -> Wrapped {
        makeView()
    }
    func updateNSView(_ view: Wrapped, context: Context) {
        update(view, context)
    }
#endif
}


/* ///////////////////////////////////////////////////////////////////////////////// */
// MARK: - WRAPPING UIKIT VIEW-CONTROLLERS -
/* ///////////////////////////////////////////////////////////////////////////////// */


struct WrapViewController<Wrapped: UI.ViewController>: UI.ViewControllerRepresentable {
#if os(iOS)
    typealias UIViewControllerType = Wrapped
#elseif os(macOS)
    typealias NSViewControllerType = Wrapped
#endif
    typealias Updater = (Wrapped, Context) -> Void
    fileprivate var makeView: () -> Wrapped
    fileprivate var update: (Wrapped, Context) -> ()
    init(_ setup: @escaping () -> Wrapped) {
        self.makeView = setup
        self.update = { _, _ in }
    }
    init(
        setup: @escaping () -> Wrapped,
        update: @escaping (Wrapped, Context) -> ()
    ) {
        self.makeView = setup
        self.update = update
    }
    
#if os(iOS)
    func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType {
        makeView()
    }
    func updateUIViewController(_ ctl: Self.UIViewControllerType, context: Self.Context) {
        update(ctl, context)
    }
#elseif os(macOS)
    func makeNSViewController(context: Self.Context) -> Self.NSViewControllerType {
        makeView()
    }
    func updateNSViewController(_ ctl: Self.NSViewControllerType, context: Self.Context) {
        update(ctl, context)
    }
#endif
}







