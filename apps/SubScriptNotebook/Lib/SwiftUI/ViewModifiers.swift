//
//  ViewMods.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/9/22.
//

import SwiftUI


fileprivate struct ViewBorderModifier: ViewModifier {
    let edges: Edge.Set
    @Environment(\.borderColorMap) private var borderColorMap
    @Environment(\.borderLineWidth) private var borderLineWidth
    @Environment(\.colorScheme) private var colorScheme
    private var targetColorMap: UX.ColorMap {
        return borderColorMap ?? UX.Divider.DEFAULT_BORDER_COLOR_MAP
    }
    func body(content: Content) -> some View {
        let size = borderLineWidth
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

extension View {
    func withBorder(edges: Edge.Set) -> some View {
        modifier(ViewBorderModifier(edges: edges))
    }
    func withBorder(show: Bool, edges: Edge.Set) -> some View {
        modifier(ViewBorderModifier(edges: show ? edges : []))
    }
}

