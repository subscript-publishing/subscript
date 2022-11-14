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


