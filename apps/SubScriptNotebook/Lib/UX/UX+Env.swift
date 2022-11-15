//
//  UI+Env.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/8/22.
//

import SwiftUI

extension UX {
    struct Env {
        struct Scope {
            var clickable: Bool = false
            var fgColor: UX.ColorMap? = nil
            var bgColor: UX.ColorMap? = nil
        }
        enum StackAxis {
            case horizontal
            case vertical
        }
    }
}

fileprivate struct FgColorMapKey: EnvironmentKey {
    static let defaultValue: UX.ColorMap? = nil
}
fileprivate struct BgColorMapKey: EnvironmentKey {
    static let defaultValue: UX.ColorMap? = nil
}
fileprivate struct BorderColorMapKey: EnvironmentKey {
    static let defaultValue: UX.ColorMap? = nil
}
fileprivate struct BorderLineWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0.5
}
fileprivate struct ScopeKey: EnvironmentKey {
    static let defaultValue: UX.Env.Scope = UX.Env.Scope()
}
fileprivate struct LayoutAxisKey: EnvironmentKey {
    static let defaultValue: UX.Env.StackAxis? = nil
}


extension EnvironmentValues {
    var fgColorMap: UX.ColorMap? {
        get {
            self[FgColorMapKey.self]
        }
        set(newValue) {
            self[FgColorMapKey.self] = newValue
        }
    }
    var bgColorMap: UX.ColorMap? {
        get {
            self[BgColorMapKey.self]
        }
        set(newValue) {
            self[BgColorMapKey.self] = newValue
        }
    }
    var borderColorMap: UX.ColorMap? {
        get {
            self[BorderColorMapKey.self]
        }
        set(newValue) {
            self[BorderColorMapKey.self] = newValue
        }
    }
    var borderLineWidth: CGFloat {
        get {
            self[BorderLineWidthKey.self]
        }
        set(newValue) {
            self[BorderLineWidthKey.self] = newValue
        }
    }
    var layoutAxis: UX.Env.StackAxis? {
        get {
            self[LayoutAxisKey.self]
        }
        set(newValue) {
            self[LayoutAxisKey.self] = newValue
        }
    }
}

// MARK: - VIEW UTILS -

extension View {
    func fgColorMap(color: UX.ColorMap) -> some View {
        return self.environment(\.fgColorMap, color)
    }
    func bgColorMap(color: UX.ColorMap) -> some View {
        return self.environment(\.bgColorMap, color)
    }
    func borderColorMap(_ color: UX.ColorMap) -> some View {
        return self.environment(\.borderColorMap, color)
    }
    func borderLineWidth(_ width: CGFloat) -> some View {
        return self.environment(\.borderLineWidth, width)
    }
}

// MARK: - PRESET COLORS -

extension View {
    func dangerousFgColorMap() -> some View {
        let fgColorMap = UX.ColorMap(
            lightMode: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1),
            darkMode: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        )
        return self.environment(\.fgColorMap, fgColorMap)
    }
    func safeFgColorMap() -> some View {
        let fgColorMap = UX.ColorMap(
            lightMode: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1),
            darkMode: #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        )
        return self.environment(\.fgColorMap, fgColorMap)
    }
}


//fileprivate struct ButtonModifier: ViewModifier {
//    // EXTRNAL API
//    let element: ElementType
//    enum ElementType {
//        case text
//        case button
//    }
//    
//    // INETRNAL
//    @Environment(\.colorScheme) private var colorScheme
//    
//    func body(content: Content) -> some View {
//        
//    }
//}


