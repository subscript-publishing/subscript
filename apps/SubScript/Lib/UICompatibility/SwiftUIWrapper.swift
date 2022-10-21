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
    
    fileprivate var makeView: (Context) -> Wrapped
    fileprivate var update: (Wrapped, Context) -> ()

    init(_ setup: @escaping (Context) -> Wrapped) {
        self.makeView = setup
        self.update = {(_, _) in ()}
    }

    init(setup: @escaping (Context) -> Wrapped, update: @escaping (Wrapped) -> ()) {
        self.makeView = setup
        self.update = {(wrapper, _) in update(wrapper)}
    }
    
#if os(iOS)
    func makeUIView(context: Context) -> Wrapped {
        return makeView(context)
    }
    func updateUIView(_ view: Wrapped, context: Context) {
        update(view, context)
    }
#elseif os(macOS)
    func makeNSView(context: Context) -> Wrapped {
        return makeView(context)
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
    fileprivate var makeViewCtl: (Context) -> Wrapped
    fileprivate var update: (Wrapped, Context) -> ()
    init(_ setup: @escaping (Context) -> Wrapped) {
        self.makeViewCtl = setup
        self.update = { _, _ in }
    }
    init(
        onUpdate: @escaping (Wrapped, Context) -> (),
        setup: @escaping (Context) -> Wrapped
    ) {
        self.makeViewCtl = setup
        self.update = onUpdate
    }
#if os(iOS)
    func makeUIViewController(context: Self.Context) -> Wrapped {
        makeViewCtl(context)
    }
    func updateUIViewController(_ ctl: Wrapped, context: Self.Context) {
        update(ctl, context)
    }
#elseif os(macOS)
    func makeNSViewController(context: Self.Context) -> Wrapped {
        let ctl = makeViewCtl(context)
        return ctl
    }
    func updateNSViewController(_ ctl: Wrapped, context: Self.Context) {
        update(ctl, context)
    }
#endif
}







