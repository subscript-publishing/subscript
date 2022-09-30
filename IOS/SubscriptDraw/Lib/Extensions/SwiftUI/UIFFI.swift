//
//  UIFFI.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/10/22.
//

import SwiftUI
import UIKit

/* ///////////////////////////////////////////////////////////////////////////////// */
// MARK: - WRAPPING UIKIT VIEWS -
/* ///////////////////////////////////////////////////////////////////////////////// */

struct WrapView<Wrapped: UIView>: UIViewRepresentable {
    typealias UIViewType = Wrapped
    typealias Updater = (Wrapped, Context) -> Void

    fileprivate var makeView: () -> Wrapped
    fileprivate var update: (UIViewType, Context) -> ()

    init(_ setup: @escaping () -> Wrapped) {
        self.makeView = setup
        self.update = {(_, _) in ()}
    }

    init(setup: @escaping () -> Wrapped, update: @escaping (UIViewType) -> ()) {
        self.makeView = setup
        self.update = {(wrapper, _) in update(wrapper)}
    }

    func makeUIView(context: Context) -> Wrapped {
        makeView()
    }

    func updateUIView(_ view: Wrapped, context: Context) {
        update(view, context)
    }
}


/* ///////////////////////////////////////////////////////////////////////////////// */
// MARK: - WRAPPING UIKIT VIEW-CONTROLLERS -
/* ///////////////////////////////////////////////////////////////////////////////// */

struct WrapViewController<Wrapped: UIViewController>: UIViewControllerRepresentable {
    typealias UIViewControllerType = Wrapped
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

    func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType {
        makeView()
    }

    func updateUIViewController(_ ctl: Self.UIViewControllerType, context: Self.Context) {
        update(ctl, context)
    }
}


