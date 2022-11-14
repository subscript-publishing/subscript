//
//  XI.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/8/22.
//
//  The XI namespace (for ‘X’ interface) is for lower-level platform specific type aliases (mostly UI stuff).
//  I wanted something short since I refer to the platform specific color type and whatnot quite frequently.
//

import SwiftUI

struct XI {}

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - CORE TYPES - IOS -

#if os(iOS)
extension XI {
    typealias Color = UIColor
    typealias View = UIView;
    typealias StackView = UIStackView
    typealias ScrollView = UIScrollView
    typealias ViewController = UIViewController;
    typealias ViewRepresentable = UIViewRepresentable;
    typealias ViewControllerRepresentable = UIViewControllerRepresentable;
    typealias GestureRecognizer = UIGestureRecognizer
    typealias HostingController = UIHostingController;
}
#endif

// MARK: - CORE TYPES - MacOS -

#if os(macOS)
extension XI {
    typealias Color = NSColor
    typealias View = NSView;
    typealias StackView = NSStackView
    typealias ScrollView = NSScrollView
    typealias ViewController = NSViewController;
    typealias ViewRepresentable = NSViewRepresentable;
    typealias ViewControllerRepresentable = NSViewControllerRepresentable;
    typealias GestureRecognizer = NSGestureRecognizer
    typealias HostingController = NSHostingController;
}
#endif


// MARK: - MacOS Miscellaneous -

#if os(macOS)
extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}
#endif
