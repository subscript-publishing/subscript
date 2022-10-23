//
//  UI+LL.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/22/22.
//

import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif


#if os(iOS)
extension UI {
    struct LL {
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
}
#elseif os(macOS)
extension UI {
    struct LL {
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
}
#endif

extension UI.LL.View {
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


extension UI.LL.Color {
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
    var hsba: UI.ColorType.HSBA {
#if os(iOS)
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        self.getHue(
            &hue,
            saturation: &saturation,
            brightness: &brightness,
            alpha: &alpha
        )
        return UI.ColorType.HSBA(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
#elseif os(macOS)
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        let color = self.usingColorSpace(NSColorSpace.sRGB)!
        color.getHue(
            &hue,
            saturation: &saturation,
            brightness: &brightness,
            alpha: &alpha
        )
        return UI.ColorType.HSBA(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
#endif
    }
}

