//
//  ViewMods.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/9/22.
//

import SwiftUI

fileprivate let DEFAULT_DISABLED_FG_COLOR = UX.ColorMap(
    lightMode: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
    darkMode: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
)

fileprivate struct ViewBorderModifier: ViewModifier {
    let edges: Edge.Set
    @Environment(\.fgColorMap) private var fgColorMap
    @Environment(\.colorScheme) private var colorScheme
    private var targetColorMap: UX.ColorMap {
        return fgColorMap ?? UX.Divider.DEFAULT_BORDER_COLOR_MAP
    }
    func body(content: Content) -> some View {
        let size = UX.Divider.DEFAULT_LINE_WIDTH
        let color = targetColorMap.get(for: colorScheme).asColor
        let border = EdgeBorderShape(width: size, edges: edges).foregroundColor(color)
        if !edges.isEmpty {
            content.overlay(border)
        } else {
            content
        }
    }
    private struct EdgeBorderShape: Shape {
        var width: CGFloat
        var edges: Edge.Set

        func path(in rect: CGRect) -> Path {
            var path = Path()
            var edgeList: Array<Edge> = []
            if edges.contains(.top) {
                edgeList.append(.top)
            }
            if edges.contains(.leading) {
                edgeList.append(.leading)
            }
            if edges.contains(.bottom) {
                edgeList.append(.bottom)
            }
            if edges.contains(.trailing) {
                edgeList.append(.trailing)
            }
            for edge in edgeList {
                var x: CGFloat {
                    switch edge {
                    case .top, .bottom, .leading: return rect.minX
                    case .trailing: return rect.maxX - width
                    }
                }
                var y: CGFloat {
                    switch edge {
                    case .top, .leading, .trailing: return rect.minY
                    case .bottom: return rect.maxY - width
                    }
                }
                var w: CGFloat {
                    switch edge {
                    case .top, .bottom: return rect.width
                    case .leading, .trailing: return self.width
                    }
                }
                var h: CGFloat {
                    switch edge {
                    case .top, .bottom: return self.width
                    case .leading, .trailing: return rect.height
                    }
                }
                path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
            }
            return path
        }
    }
}


//fileprivate struct ViewButtonModifier: ViewModifier {
//    let action: () -> ()
//    init(action: @escaping () -> ()) {
//        self.action = action
//    }
//    @Environment(\.colorScheme) private var colorScheme
//    @Environment(\.fgColorMap) private var fgColorMap
//    @Environment(\.isEnabled) private var isEnabled
//    private var targetColorMap: UI.ColorMap {
//        return fgColorMap ?? UI.Divider.DEFAULT_BORDER_COLOR_MAP
//    }
//    func body(content: Content) -> some View {
//        Button(action: self.action, label: {
//            content
//        })
//            .buttonStyle(NoDefaultButtonStyle())
//    }
//}


extension View {
    func withBorder(edges: Edge.Set) -> some View {
        modifier(ViewBorderModifier(edges: edges))
    }
}

