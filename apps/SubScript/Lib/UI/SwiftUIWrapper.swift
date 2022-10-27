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

struct WrapView<UIViewType: UI.LL.View>: UI.LL.ViewRepresentable {
#if os(iOS)
    typealias UIViewType = UIViewType
#elseif os(macOS)
    typealias NSViewType = UIViewType
#endif
    typealias Updater = (UIViewType, Context) -> Void
    
    fileprivate var makeView: (Context) -> UIViewType
    fileprivate var update: (UIViewType, Context) -> ()

    init(_ setup: @escaping (Context) -> UIViewType) {
        self.makeView = setup
        self.update = {(_, _) in ()}
    }

    init(setup: @escaping (Context) -> UIViewType, update: @escaping (UIViewType) -> ()) {
        self.makeView = setup
        self.update = {(wrapper, _) in update(wrapper)}
    }
    
#if os(iOS)
    func makeUIView(context: Context) -> UIViewType {
        return makeView(context)
    }
    func updateUIView(_ view: UIViewType, context: Context) {
        update(view, context)
    }
#elseif os(macOS)
    func makeNSView(context: Context) -> UIViewType {
        return makeView(context)
    }
    func updateNSView(_ view: UIViewType, context: Context) {
        update(view, context)
    }
#endif
}


/* ///////////////////////////////////////////////////////////////////////////////// */
// MARK: - WRAPPING UIKIT VIEW-CONTROLLERS -
/* ///////////////////////////////////////////////////////////////////////////////// */




struct WrapViewController<UIViewCtl: UI.LL.ViewController>: UI.LL.ViewControllerRepresentable {
#if os(iOS)
    typealias UIViewControllerType = UIViewCtl
#elseif os(macOS)
    typealias NSViewControllerType = UIViewCtl
#endif
    typealias Updater = (UIViewCtl, Context) -> Void
    fileprivate var makeViewCtl: (Context) -> UIViewCtl
    fileprivate var update: (UIViewCtl, Context) -> ()
    init(_ setup: @escaping (Context) -> UIViewCtl) {
        self.makeViewCtl = setup
        self.update = { _, _ in }
    }
    init(
        onUpdate: @escaping (UIViewCtl, Context) -> (),
        setup: @escaping (Context) -> UIViewCtl
    ) {
        self.makeViewCtl = setup
        self.update = onUpdate
    }
#if os(iOS)
    func makeUIViewController(context: Self.Context) -> UIViewCtl {
        makeViewCtl(context)
    }
    func updateUIViewController(_ ctl: UIViewCtl, context: Self.Context) {
        update(ctl, context)
    }
#elseif os(macOS)
    func makeNSViewController(context: Self.Context) -> UIViewCtl {
        let ctl = makeViewCtl(context)
        return ctl
    }
    func updateNSViewController(_ ctl: UIViewCtl, context: Self.Context) {
        update(ctl, context)
    }
#endif
}







