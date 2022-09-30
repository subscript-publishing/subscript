
//
//  Border.swift
//  Superscript
//
//  Created by Colbyn Wadman on 12/30/21.
//

import SwiftUI

private struct ThemeBorderModifier: ViewModifier {
    var width: CGFloat = 5
    var edges: Edge.Set
    var color: Color? = nil
    var show: Bool
    let defaultColor = Color(#colorLiteral(red: 0.4110215306, green: 0.4110215306, blue: 0.4110215306, alpha: 1))

    func body(content: Content) -> some View {
//        let border = EdgeBorderShape(width: width, edges: edges).foregroundColor(color ?? defaultColor)
        let border = EdgeBorderShape(width: width, edges: edges).foregroundColor(defaultColor)
        if show && !edges.isEmpty {
            content.overlay(border)
        } else {
            content
        }
    }

    struct EdgeBorderShape: Shape {
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
    func border(width: CGFloat = 1.0, edges: Edge.Set, color: Color? = nil, show: Bool = true) -> some View {
        modifier(ThemeBorderModifier(width: width, edges: edges, color: color, show: show))
    }
    func border(edges: Edge.Set) -> some View {
        modifier(ThemeBorderModifier(width: 1.0, edges: edges, color: nil, show: true))
    }
}
