//
//  ViewUtils.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/8/22.
//  Miscellaneous SwiftUI View utilities.
//

import SwiftUI



extension UX {
    struct HL<V: View>: View {
        private let alignment: VerticalAlignment
        private let spacing: CGFloat
        private let content: () -> V
        init(
            alignment: VerticalAlignment = .center,
            spacing: CGFloat = 0,
            @ViewBuilder _ content: @escaping () -> V
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.content = content
        }
        var body: some View {
            HStack(alignment: self.alignment, spacing: self.spacing, content: self.content)
                .environment(\.layoutAxis, UX.Env.StackAxis.horizontal)
        }
    }
    struct VL<V: View>: View {
        private let alignment: HorizontalAlignment
        private let spacing: CGFloat
        private let content: () -> V
        init(
            alignment: HorizontalAlignment = .center,
            spacing: CGFloat = 0,
            @ViewBuilder _ content: @escaping () -> V
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.content = content
        }
        var body: some View {
            VStack(alignment: self.alignment, spacing: self.spacing, content: self.content)
                .environment(\.layoutAxis, UX.Env.StackAxis.vertical)
        }
    }
    /// Horizontal divider.
    struct HD: View {
        var lineWidth: CGFloat? = nil
        var body: some View {
            Divider(lineWidth: lineWidth).environment(\.layoutAxis, UX.Env.StackAxis.horizontal)
        }
    }
    /// Vertical divider.
    struct VD: View {
        var lineWidth: CGFloat? = nil
        var body: some View {
            Divider(lineWidth: lineWidth).environment(\.layoutAxis, UX.Env.StackAxis.vertical)
        }
    }
    /// Some divider along the axis environment.
    struct Divider: View {
        static let DEFAULT_LINE_WIDTH: CGFloat = 0.5
        static let DEFAULT_BORDER_COLOR_MAP = Divider.BOLD_BORDER_COLOR_MAP
        static let LIGHT_BORDER_COLOR_MAP = UX.ColorMap(
            lightMode: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
            darkMode: #colorLiteral(red: 0.2595916603, green: 0.2595916603, blue: 0.2595916603, alpha: 1)
        )
        static let BOLD_BORDER_COLOR_MAP = UX.ColorMap(
            lightMode: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
            darkMode: #colorLiteral(red: 0.4284313075, green: 0.4284313075, blue: 0.4284313075, alpha: 1)
        )
        var lineWidth: CGFloat? = nil
        @Environment(\.layoutAxis) private var stackAxis
        @Environment(\.fgColorMap) private var fgColorMap
        @Environment(\.colorScheme) private var colorScheme
        private var targetColorMap: UX.ColorMap {
            return fgColorMap ?? Divider.DEFAULT_BORDER_COLOR_MAP
        }
        var body: some View {
            let size = lineWidth ?? Divider.DEFAULT_LINE_WIDTH
            let color = targetColorMap.get(for: colorScheme).asColor
            if let stackAxis = stackAxis {
                let view = DividerShape(axis: stackAxis)
                    .stroke(lineWidth: size)
                    .foregroundColor(color)
                switch stackAxis {
                case .vertical:
                    view.frame(height: size)
                case .horizontal:
                    view.frame(width: size)
                }
            } else {
                EmptyView()
            }
        }
        fileprivate struct DividerShape: Shape {
            let axis: UX.Env.StackAxis
            func path(in rect: CGRect) -> Path {
#if os(iOS)
                let transform = CGAffineTransform.identity
#elseif os(macOS)
                let transform = CGAffineTransform
                    .init(scaleX: 1.0, y: -1.0)
                    .translatedBy(x: 0.0, y: -rect.height)
#endif
                var path = Path()
                switch self.axis {
                case .vertical:
                    let start = CGPoint(x: 0.0, y: rect.midY)
                        .applying(transform)
                    let end = CGPoint(x: rect.width, y: rect.midY)
                        .applying(transform)
                    path.move(to: start)
                    path.addLine(to: end)
                case .horizontal:
                    let start = CGPoint(x: rect.midX, y: 0)
                        .applying(transform)
                    let end = CGPoint(x: rect.midX, y: rect.height)
                        .applying(transform)
                    path.move(to: start)
                    path.addLine(to: end)
                }
                return path
            }
        }
    }
}




