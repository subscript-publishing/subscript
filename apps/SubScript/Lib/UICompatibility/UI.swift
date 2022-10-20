//
//  LowLevelUI.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/19/22.
//
import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct UI {}


#if os(iOS)
extension UI {
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
#elseif os(macOS)
extension UI {
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

extension UI.Color {
    var rgba: (CGFloat, CGFloat, CGFloat, CGFloat) {
#if os(iOS)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
#elseif os(macOS)
        let red = self.redComponent;
        let green = self.greenComponent;
        let blue = self.blueComponent;
        let alpha = self.alphaComponent;
        return (red, green, blue, alpha)
#endif
    }
}


extension UI.View {
#if os(iOS)
    var colorScheme: ColorScheme {
        if traitCollection.userInterfaceStyle == .light {
            return ColorScheme.light
        } else {
            return ColorScheme.dark
        }
    }
    func getCGContext() -> CGContext? {
        return UIGraphicsGetCurrentContext()
    }
#elseif os(macOS)
    var colorScheme: ColorScheme {
        if UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark" {
            return ColorScheme.dark
        } else {
            return ColorScheme.light
        }
    }
    func getCGContext() -> CGContext? {
        return NSGraphicsContext.current?.cgContext
    }
#endif
}
