//
//  Toolbar.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/19/22.
//

import Foundation
import SwiftUI
import Combine

//
fileprivate let DARK_TOOLBAR_FOREGROUND_COLOR: UI.LL.Color = #colorLiteral(red: 0.1744112816, green: 0.197636486, blue: 0.2650109351, alpha: 1)
fileprivate let LIGHT_TOOLBAR_FOREGROUND_COLOR: UI.LL.Color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

fileprivate let iconColor: Color = Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
fileprivate let disabledIconColor: Color = Color(#colorLiteral(red: 0.5570612527, green: 0.633860792, blue: 0.6627638421, alpha: 1))
fileprivate let textColor: Color = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
fileprivate let borderColor: Color = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
fileprivate let buttonBgColor: Color = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))

fileprivate enum LayerViewToggle {
    case foreground
    case background
    case both
}



fileprivate struct EraserTool: View {
    let active: Bool
    let onClick: () -> ()
    
    var body: some View {
        Button(
            action: onClick,
            label: {
                let fg = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                ZStack(alignment: Alignment.top) {
                    BackgroundGraphic(active: active)
                        .scale(1.0)
                        .foregroundColor(Color(fg))
                    TopGraphic(active: active)
                        .scale(0.95)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)),
                                        Color(#colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)),
                                    ]
                                ),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    BottomGraphic(active: active)
                        .scale(0.95)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color(#colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)),
                                        Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                                    ]
                                ),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .offset(x: 0, y: self.active ? 10 : 0)
                .foregroundColor(Color.clear)
            }
        )
    }
    private struct BackgroundGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.62))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.62))
            path.closeSubpath()
            return path
        }
    }
    private struct TopGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.4))
            path.closeSubpath()
            return path
        }
    }
    private struct BottomGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.6))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.6))
            path.closeSubpath()
            return path
        }
    }
}
fileprivate struct SelectionTool: View {
    let active: Bool
    let onClick: () -> ()
    
    var body: some View {
        Button(
            action: onClick,
            label: {
                ZStack(alignment: Alignment.top) {
                    BackgroundGraphic(active: active)
                        .scale(1.0)
                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                    TopGraphic(active: active)
                        .scale(0.95)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)),
                                        Color(#colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)),
                                    ]
                                ),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    BottomGraphic(active: active)
                        .scale(0.95)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color(#colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)),
                                        Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                                    ]
                                ),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .offset(x: 0, y: self.active ? 8 : 0)
                .foregroundColor(Color.clear)
            }
        )
    }
    private struct BackgroundGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.42))
            path.addLine(to: CGPoint(x: rect.maxX / 2, y: rect.maxY * 0.752))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.42))
            path.closeSubpath()
            return path
        }
    }
    private struct TopGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.4))
            path.closeSubpath()
            return path
        }
    }
    private struct BottomGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: rect.maxX / 2, y: rect.maxY * 0.75))
//            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.6))
            path.closeSubpath()
            return path
        }
    }
}

fileprivate func penSet(
    templateColor: UI.LL.Color,
    color: SS1.Pen.PenStyle.DualColor,
    penSet: SS1.Pen.PenSet = SS1.Pen.PenSet.set1,
    fgPen1Map: Optional<(inout SS1.Pen.PenStyle) -> ()> = .none,
    fgPen2Map: Optional<(inout SS1.Pen.PenStyle) -> ()> = .none,
    bgPen1Map: Optional<(inout SS1.Pen.PenStyle) -> ()> = .none,
    bgPen2Map: Optional<(inout SS1.Pen.PenStyle) -> ()> = .none
) -> Array<SS1.Pen> {
    let highlightColor = SS1.Pen.PenStyle.DualColor(
        lightUI: color.lightUI.with(alpha: 0.6),
        darkUI: color.darkUI.with(alpha: 0.6)
    )
    var pen1Options = SS1.Pen.PenStyle(
        color: color,
        layer: SS1.Pen.PenStyle.Layer.foreground,
        size: SS1.Pen.defaultFgThinPenSize
    )
    if case let .some(f) = fgPen1Map {
        f(&pen1Options)
    }
    let pen1 = SS1.Pen(
        style: pen1Options,
        templateColor: UI.ColorType.HSBA(from: templateColor),
        penSet: penSet
    )
    var pen2Options = SS1.Pen.PenStyle(
        color: color,
        layer: SS1.Pen.PenStyle.Layer.foreground,
        size: SS1.Pen.defaultFgThickPenSize
    )
    if case let .some(f) = fgPen2Map {
        f(&pen2Options)
    }
    let pen2 = SS1.Pen(
        style: pen2Options,
        templateColor: UI.ColorType.HSBA(from: templateColor),
        penSet: penSet
    )
    var pen3Options = SS1.Pen.PenStyle(
        color: highlightColor,
        layer: SS1.Pen.PenStyle.Layer.background,
        size: SS1.Pen.defaultBgThinPenSize
    )
    if case let .some(f) = bgPen1Map {
        f(&pen3Options)
    }
    defaultBgMarkerConfig(&pen3Options)
    let pen3 = SS1.Pen(
        style: pen3Options,
        templateColor: UI.ColorType.HSBA(from: templateColor),
        penSet: penSet
    )
    var pen4Options = SS1.Pen.PenStyle(
        color: highlightColor,
        layer: SS1.Pen.PenStyle.Layer.background,
        size: SS1.Pen.defaultBgThickPenSize
    )
    defaultBgMarkerConfig(&pen4Options)
    if case let .some(f) = bgPen2Map {
        f(&pen4Options)
    }
    let pen4 = SS1.Pen(
        style: pen4Options,
        templateColor: UI.ColorType.HSBA(from: templateColor),
        penSet: penSet
    )
    return [pen1, pen2, pen3, pen4]
}

fileprivate func concat<T>(
    _ value: Array<Array<T>>
) -> Array<T> {
    Array(value.joined())
}
fileprivate func defaultBgMarkerConfig(_ withSize: CGFloat) -> (_ opt: inout SS1.Pen.PenStyle) -> () {
    return {opt in
        opt.size = withSize
        opt.thinning = 0.0
        opt.smoothing = 1.0
        opt.streamline = 1.0
        opt.start.cap = false
        opt.end.cap = false
    }
}
fileprivate func defaultBgMarkerConfig(_ opt: inout SS1.Pen.PenStyle) {
    opt.thinning = 0.0
    opt.smoothing = 1.0
    opt.streamline = 1.0
    opt.start.cap = false
    opt.end.cap = false
}
fileprivate func defaultFgExtraThinConfig(_ opt: inout SS1.Pen.PenStyle) {
    opt.size = SS1.Pen.defaultExtraThinPenSize
    opt.thinning = 0.0
    opt.smoothing = 1.0
    opt.streamline = 1.0
    opt.start.cap = false
    opt.end.cap = false
}
fileprivate func defaultBgExtraThinConfig(_ opt: inout SS1.Pen.PenStyle) {
    opt.size = SS1.Pen.defaultExtraThinPenSize
    opt.thinning = 0.0
    opt.smoothing = 1.0
    opt.streamline = 1.0
    opt.start.cap = false
    opt.end.cap = false
}
fileprivate func defaultFgExtraThickConfig(_ opt: inout SS1.Pen.PenStyle) {
    opt.size = SS1.Pen.defaultExtraThickPenSize
    opt.thinning = 0.0
    opt.smoothing = 1.0
    opt.streamline = 1.0
    opt.start.cap = false
    opt.end.cap = false
}
fileprivate func defaultBgExtraThickConfig(_ opt: inout SS1.Pen.PenStyle) {
    opt.size = SS1.Pen.defaultExtraThickPenSize
    opt.thinning = 0.0
    opt.smoothing = 1.0
    opt.streamline = 1.0
    opt.start.cap = false
    opt.end.cap = false
}

fileprivate var DEFAULT_PENS: Array<SS1.Pen> {
    concat([
        penSet(
            templateColor: #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.1522153874, green: 0.1522153874, blue: 0.1522153874, alpha: 0.9480085944)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.3562028628, blue: 0.3234998193, alpha: 0.9536794495)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.4533152416, blue: 0.4255452278, alpha: 0.9335713892))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.9853975177, green: 0.9960361123, blue: 0, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.8595820573, blue: 0, alpha: 0.9599663519)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.9853975177, green: 0.9960361123, blue: 0, alpha: 1))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.1820927858, green: 0.9942755103, blue: 0.008088083938, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.1820927858, green: 0.9942755103, blue: 0.008088083938, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.4050822258, green: 0.9107592702, blue: 0.3064689636, alpha: 1))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.03801821545, green: 0.7668590459, blue: 0.9436975718, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.03801821545, green: 0.7668590459, blue: 0.9436975718, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.1981527805, green: 0.9152255654, blue: 0.9221068621, alpha: 1))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.0006549843238, green: 0.1723237932, blue: 0.9950235486, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.0006549843238, green: 0.1723237932, blue: 0.9950235486, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.4912772218, green: 0.5628710919, blue: 0.911735177, alpha: 1))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.8881010415, green: 0.6503296282, blue: 1, alpha: 1))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 1, green: 0.2187052982, blue: 0.7401167801, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.2187052982, blue: 0.7401167801, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.9836834073, green: 0.01610323042, blue: 0.01610323042, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.9836834073, green: 0.01610323042, blue: 0.01610323042, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.923746407, green: 0.5437585418, blue: 0.5513613933, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.9836834073, green: 0.4915673948, blue: 0.01610323042, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.9836834073, green: 0.4915673948, blue: 0.01610323042, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.923746407, green: 0.598991043, blue: 0.4473902994, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.9836834073, green: 0.8120082, blue: 0.01610323042, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.9836834073, green: 0.8120082, blue: 0.01610323042, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.923746407, green: 0.8480549868, blue: 0.5567146521, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.6896855942, green: 0.923746407, blue: 0.2139444053, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.6896855942, green: 0.923746407, blue: 0.2139444053, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.7753242077, green: 0.923746407, blue: 0.4892397564, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.1930225866, green: 0.9836834073, blue: 0.01610323042, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.1930225866, green: 0.9836834073, blue: 0.01610323042, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.6009957053, green: 0.9836834073, blue: 0.5153649771, alpha: 0.9529471683))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.3484312771, green: 1, blue: 0, alpha: 0.94),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.3484312771, green: 1, blue: 0, alpha: 0.94)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.5998694567, green: 1, blue: 0.385896638, alpha: 0.9308121501))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0, green: 1, blue: 0.5583703604, alpha: 0.94),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0, green: 1, blue: 0.5583703604, alpha: 0.94)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.385896638, green: 1, blue: 0.8693810537, alpha: 0.9308121501))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0, green: 0.8359576278, blue: 1, alpha: 0.94),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0, green: 0.8359576278, blue: 1, alpha: 0.94)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.385896638, green: 0.9012365223, blue: 1, alpha: 0.9308121501))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0, green: 0.5678111642, blue: 1, alpha: 0.94),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0, green: 0.5678111642, blue: 1, alpha: 0.94)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.385896638, green: 0.7952249831, blue: 1, alpha: 0.9308121501))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.01610323042, green: 0.9836834073, blue: 0.9756202392, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.01610323042, green: 0.9836834073, blue: 0.9756202392, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.4918417037, green: 0.9836834073, blue: 0.9795847264, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.7612673015, green: 0.6585746401, blue: 0.9686274529, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.4572930815, green: 0, blue: 1, alpha: 0.94),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.4572930815, green: 0, blue: 1, alpha: 0.94)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.7858035736, green: 0.5667474595, blue: 1, alpha: 0.9308121501))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.08712213245, green: 0, blue: 1, alpha: 0.94),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.08712213245, green: 0, blue: 1, alpha: 0.94)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.5528893269, green: 0.6628325972, blue: 1, alpha: 0.9308121501))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.8194490579, green: 0, blue: 1, alpha: 0.94),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.8194490579, green: 0, blue: 1, alpha: 0.94)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.9275795289, green: 0.385896638, blue: 1, alpha: 0.9308121501))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 1, green: 0, blue: 0.5195422284, alpha: 0.94),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0, blue: 0.5195422284, alpha: 0.94)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.5, blue: 0.8799946326, alpha: 0.9308121501))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 1, green: 0.3132912363, blue: 0.7992954836, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.3132912363, blue: 0.7992954836, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.2615669501, blue: 0.744681838, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.1522153874, green: 0.1522153874, blue: 0.1522153874, alpha: 0.9480085944),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.1522153874, green: 0.1522153874, blue: 0.1522153874, alpha: 0.9480085944)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
        penSet(
            templateColor: #colorLiteral(red: 1, green: 0.3562028628, blue: 0.3234998193, alpha: 0.9536794495),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.3562028628, blue: 0.3234998193, alpha: 0.9536794495)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.4533152416, blue: 0.4255452278, alpha: 0.9335713892))
            ),
            penSet: SS1.Pen.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
        penSet(
            templateColor: #colorLiteral(red: 1, green: 0.8595820573, blue: 0, alpha: 0.9599663519),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.8595820573, blue: 0, alpha: 0.9599663519)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.9853975177, green: 0.9960361123, blue: 0, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.1820927858, green: 0.9942755103, blue: 0.008088083938, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.1820927858, green: 0.9942755103, blue: 0.008088083938, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.4050822258, green: 0.9107592702, blue: 0.3064689636, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.03801821545, green: 0.7668590459, blue: 0.9436975718, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.03801821545, green: 0.7668590459, blue: 0.9436975718, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.1981527805, green: 0.9152255654, blue: 0.9221068621, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.0006549843238, green: 0.1723237932, blue: 0.9950235486, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.0006549843238, green: 0.1723237932, blue: 0.9950235486, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.4912772218, green: 0.5628710919, blue: 0.911735177, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.8881010415, green: 0.6503296282, blue: 1, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
        penSet(
            templateColor: #colorLiteral(red: 1, green: 0.2187052982, blue: 0.7401167801, alpha: 1),
            color: SS1.Pen.PenStyle.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.2187052982, blue: 0.7401167801, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1))
            ),
            penSet: SS1.Pen.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
    ])
}

fileprivate struct PenView: View {
    let width: CGFloat
    let setToPen: (UUID) -> ()
    @ObservedObject var toolbarModel: SS1.ToolBarModel
    @Binding var pen: SS1.Pen
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var showPopUp: Bool = false
    
    @ViewBuilder private func penPopup() -> some View {
        SS1.ToolBarView.PenSettingsPanel(
            onDelete: nil,
            onSave: {
                
            },
            toolbarModel: toolbarModel,
            pen: $pen
        )
    }
    var body: some View {
        Button(action: onClick, label: self.label)
            .popover(isPresented: $showPopUp, content: penPopup)
    }
    
    private func onClick() {
        if pen.active {
            showPopUp = true
        } else {
            setToPen(pen.id)
        }
    }
    
    @ViewBuilder private func label() -> some View {
        GeometryReader { geo in
            let graphic = ZStack(alignment: Alignment.top) {
                let backColor: UI.LL.Color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                let frontColor: UI.LL.Color = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                let invertToggle = toolbarModel.invertPenColors
                let penColor = pen.style.color.get(for: colorScheme, withInvert: invertToggle).asColor
                Top(active: pen.active)
                    .foregroundColor(Color(backColor))
                Top(active: pen.active)
                    .scale(0.95)
                    .foregroundColor(Color(frontColor))
                Top(active: pen.active)
                    .scale(0.90)
                    .offset(y: -2.0)
                    .foregroundColor(penColor)
                Bottom(active: pen.active)
                    .foregroundColor(Color(backColor))
                Bottom(active: pen.active)
                    .scale(0.95)
                    .foregroundColor(Color(frontColor))
                Bottom(active: pen.active)
                    .scale(0.9)
                    .offset(y: -1.0)
                    .foregroundColor(penColor)
            }
            if self.pen.active {
                graphic.offset(x: 0, y: 6.0)
            } else {
                graphic.offset(x: 0, y: -2.0)
            }
        }
    }
    
    private struct Top: Shape {
        let active: Bool
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -8.0))
            path.addLine(to: CGPoint(x: rect.maxX, y: -8.0))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.2))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.2))
            path.closeSubpath()
            return path
        }
    }
    
    private struct Bottom: Shape {
        let active: Bool
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: rect.maxY * 0.2))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.2))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX / 2, y: rect.maxY * 0.8),
                control: CGPoint(x: rect.maxX, y: rect.maxY / 2)
            )
            path.addQuadCurve(
                to: CGPoint(x: 0, y: rect.maxY * 0.2),
                control: CGPoint(x: 0, y: rect.maxY / 2)
            )
            path.closeSubpath()
            return path
        }
    }
    
    private struct Background: Shape {
        let active: Bool
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -8.0))
            path.addLine(to: CGPoint(x: rect.maxX, y: -8.0))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.21))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX / 2, y: rect.maxY * 0.8),
                control: CGPoint(x: rect.maxX, y: rect.maxY / 2)
            )
            path.addQuadCurve(
                to: CGPoint(x: 0, y: rect.maxY * 0.21),
                control: CGPoint(x: 0, y: rect.maxY / 2)
            )
            path.closeSubpath()
            return path
        }
    }
}

extension SS1 {
    class ToolBarModel: ObservableObject, Codable {
        @Published var currentToolType: CurrentToolType = CurrentToolType.pen
        @Published var invertPenColors: Bool = false
        @Published var templatePen: Pen = Pen()
        @Published var pens: Array<Pen> = DEFAULT_PENS
//        @Published var pens: Array<Pen> = [
//            SS1.Pen(
//                strokeSettings: SS1.Pen.StrokeSettings(
//                    color: SS1.Pen.StrokeSettings.ColorMode(
//                        lightUIColorMode: CodableColor(withColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
//                        darkUIColorMode: CodableColor(withColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
//                    ),
//                    size: 5
//                ),
//                active: true,
////                layer: SS1.CanvasLayer.foreground,
//                penSet: SS1.Pen.PenSet.set1
//            ),
//            SS1.Pen(
//                strokeSettings: SS1.Pen.StrokeSettings(
//                    color: SS1.Pen.StrokeSettings.ColorMode(
//                        lightUIColorMode: CodableColor(withColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)),
//                        darkUIColorMode: CodableColor(withColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
//                    ),
//                    size: 5
//                ),
////                layer: SS1.CanvasLayer.foreground,
//                penSet: SS1.Pen.PenSet.set1
//            ),
//            SS1.Pen(
//                strokeSettings: SS1.Pen.StrokeSettings(
//                    color: SS1.Pen.StrokeSettings.ColorMode(
//                        lightUIColorMode: CodableColor(withColor: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)),
//                        darkUIColorMode: CodableColor(withColor: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1))
//                    ),
//                    size: 5
//                ),
////                layer: SS1.CanvasLayer.foreground,
//                penSet: SS1.Pen.PenSet.set1
//            ),
//            SS1.Pen(
//                strokeSettings: SS1.Pen.StrokeSettings(
//                    color: SS1.Pen.StrokeSettings.ColorMode(
//                        lightUIColorMode: CodableColor(withColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.9031519736)),
//                        darkUIColorMode: CodableColor(withColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.9031519736))
//                    ),
//                    size: 5
//                ),
////                layer: SS1.CanvasLayer.foreground,
//                penSet: SS1.Pen.PenSet.set1
//            ),
//        ]
        enum CodingKeys: CodingKey {
            case pens, templatePen
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try! container.encode(pens, forKey: .pens)
            try! container.encode(templatePen, forKey: .templatePen)
        }
        init() {}
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            pens = try container.decode(Array.self, forKey: .pens)
            templatePen = try container.decode(Pen.self, forKey: .templatePen)
        }
        func save(path: URL) {
            let encoder = PropertyListEncoder()
            let data = try! encoder.encode(self)
            try! data.write(to: path)
        }
        static func load(path: URL) -> Optional<ToolBarModel> {
            let decoder = PropertyListDecoder()
            let data = try? Data(contentsOf: path)
            if let data = data {
                return try? decoder.decode(ToolBarModel.self, from: data)
            } else {
                return .none
            }
        }
        static let defaultFileName = "ToolBar.data"
        static func loadDefault() -> ToolBarModel {
            let path = URL
                .getDocumentsDirectory()
                .appendingPathComponent(ToolBarModel.defaultFileName, isDirectory: false)
            if let data = ToolBarModel.load(path: path) {
                return data
            } else {
                return ToolBarModel()
            }
        }
        func saveDefault() {
            let path = URL.getDocumentsDirectory().appendingPathComponent(ToolBarModel.defaultFileName, isDirectory: false)
            self.save(path: path)
        }
        enum CurrentToolType {
            case pen
            case selection
            case eraser
            
            var isPen: Bool {
                switch self {
                case .pen: return true
                default: return false
                }
            }
            var isSelection: Bool {
                switch self {
                case .selection: return true
                default: return false
                }
            }
            var isEraser: Bool {
                switch self {
                case .eraser: return true
                default: return false
                }
            }
        }
    }
    struct ToolBarView: View {
        @ObservedObject var toolbarModel: ToolBarModel
//        @ObservedObject var canvasModel: SS1.CanvasDataModel
//        @Binding var displayStyle: ColorScheme
        let toggleColorScheme: () -> ()
//        let openSettings: () -> ()
//        let setToPen: (SS1.Pen) -> ()
//        let setToEraser: () -> ()
//        let setToSelection: () -> ()
        let goBack: () -> ()
        let onSave: () -> ()
        
        private func activatePen(penID: UUID) {
            self.toolbarModel.currentToolType = ToolBarModel.CurrentToolType.pen
            for (ix, _) in self.toolbarModel.pens.enumerated() {
                if self.toolbarModel.pens[ix].active && self.toolbarModel.pens[ix].id != penID {
                    self.toolbarModel.pens[ix].active = false
                }
                if self.toolbarModel.pens[ix].id == penID {
                    self.toolbarModel.pens[ix].active = true
                    self.toolbarModel.pens[ix].setToCurrentPen()
                }
            }
        }
        private func activateEraserTool() {
            usingEraserTool.toggle()
            if usingEraserTool {
                usingSelectionTool = false
                toolbarModel.currentToolType = ToolBarModel.CurrentToolType.eraser
                for (ix, _) in toolbarModel.pens.enumerated() {
                    if toolbarModel.pens[ix].active {
                        toolbarModel.pens[ix].active = false
                    }
                }
                ss1_toolbar_runtime_set_active_tool_to_eraser()
            }
        }
        private func activateSelectionTool() {
            usingSelectionTool.toggle()
            if usingSelectionTool {
                usingEraserTool = false
                self.toolbarModel.currentToolType = ToolBarModel.CurrentToolType.selection
                for (ix, _) in self.toolbarModel.pens.enumerated() {
                    if toolbarModel.pens[ix].active {
                        toolbarModel.pens[ix].active = false
                    }
                }
            }
        }
        
        @State private var usingEraserTool: Bool = false
        @State private var usingSelectionTool: Bool = false
        @Environment(\.colorScheme) private var colorScheme
        @State private var layerViewToggle: LayerViewToggle = .both
        @State private var penSetViewToggle = SS1.Pen.PenSet.set1
        
        @Binding var showPenListEditor: Bool
        
        var body: some View {
            HStack(alignment: .center, spacing: 10) {
                Group {
                    Button(action: goBack, label: {Image(systemName: "chevron.left")})
                        .buttonStyle(RoundedButtonStyle())
                    SelectionTool(active: usingSelectionTool, onClick: self.activateSelectionTool)
                        .frame(width: 30, alignment: .center)
                    EraserTool(active: usingEraserTool, onClick: self.activateEraserTool)
                        .frame(width: 30, alignment: .center)
                    Button(
                        action: {
                            switch self.layerViewToggle {
                            case .both: self.layerViewToggle = .foreground
                            case .foreground: self.layerViewToggle = .background
                            case .background: self.layerViewToggle = .both
                            }
                        },
                        label: {
    #if os(iOS) && !targetEnvironment(macCatalyst)
                            let foreground = "square.2.stack.3d.top.filled"
                            let background = "square.2.stack.3d.bottom.filled"
                            let both = "square.3.layers.3d.down.right"
    #else
                            let foreground = "arrowtriangle.up"
                            let background = "arrowtriangle.down"
                            let both = "chevron.up.chevron.down"
    #endif
                            switch self.layerViewToggle {
                            case .foreground: Image(systemName: foreground)
                            case .background: Image(systemName: background)
                            case .both: Image(systemName: both)
                            }
                        }
                    )
                        .buttonStyle(RoundedButtonStyle())
                    Button(
                        action: {
                            switch self.penSetViewToggle {
                            case .set1: self.penSetViewToggle = SS1.Pen.PenSet.set2
                            case .set2: self.penSetViewToggle = SS1.Pen.PenSet.set3
                            case .set3: self.penSetViewToggle = SS1.Pen.PenSet.set4
                            case .set4: self.penSetViewToggle = SS1.Pen.PenSet.set1
                            }
                        },
                        label: {
                            switch self.penSetViewToggle {
                            case .set1: Text("{1}")
                            case .set2: Text("{2}")
                            case .set3: Text("{3}")
                            case .set4: Text("{4}")
                            }
                        }
                    )
                        .buttonStyle(RoundedButtonStyle(useMonospacedFont: true))
                }
                pensListMenu.border(edges: [.leading, .trailing])
                Group {
                    Button(action: {showPenListEditor = true}, label: {Image(systemName: "scribble.variable")})
                        .buttonStyle(RoundedButtonStyle())
                    Button(
                        action: {
                            toolbarModel.invertPenColors.toggle()
                        },
                        label: {
                            Text("𝑓⁻¹")
                        }
                    )
                        .buttonStyle(RoundedButtonStyle(
                            useMonospacedFont: false,
                            useDangerousColor: toolbarModel.invertPenColors
                        ))
                    Button(
                        action: toggleColorScheme,
                        label: {
                            let darkIcon = Image(systemName: "moon")
                            let lightIcon = Image(systemName: "sun.min")
                            colorScheme == .dark ? darkIcon : lightIcon
                        }
                    )
                        .buttonStyle(RoundedButtonStyle())
                    Button(
                        action: onSave,
                        label: {
                            Text("Save")
                        }
                    )
                        .buttonStyle(RoundedButtonStyle())
                    UI.Hacks.NavigationStackViewLink(
                        navBar: UI.Hacks.NavBar.defaultNavBar(),
                        destination: {
                            SS1.ColorEditor()
                        },
                        label: {
                            Image(systemName: "paintpalette")
                        }
                    )
                }
            }
            .padding([.leading, .trailing], 10)
            .background(Color(colorScheme == .dark ? DARK_TOOLBAR_FOREGROUND_COLOR : LIGHT_TOOLBAR_FOREGROUND_COLOR))
            .border(width: 0.5, edges: .bottom)
            .clipped()
            .buttonStyle(PlainButtonStyle())
        }
        private func getPenSize(_ pen: SS1.Pen) -> CGFloat {
            var sizes: Array<CGFloat> = []
            for pen in toolbarModel.pens {
                if pen.penSet == penSetViewToggle {
                    sizes.append(pen.style.size)
                }
            }
            let min: CGFloat = sizes.min()!
            let max: CGFloat = sizes.max()!
            let delta = max - min
            let outputMin: CGFloat = 25
            let outputMax: CGFloat = delta >= 10 ? 60 : 45
            let xScale: (CGFloat) -> CGFloat = MathUtils.newLinearScale(
                domain: (min, max),
                range: (outputMin, outputMax)
            )
            let penWidthX: CGFloat = xScale(pen.style.size)
            if penWidthX.isNaN {
                return outputMin
            }
            if penWidthX.isZero {
                return outputMin
            }
            if penWidthX.isInfinite {
                return outputMax
            }
            if penWidthX.isSignalingNaN {
                return outputMin
            }
            if penWidthX <= outputMin {
                return outputMin
            } else {
                if penWidthX >= outputMax {
                    return outputMax
                }
                return penWidthX
            }
        }
        @ViewBuilder private func penItemHelper(ix: Int, pen: SS1.Pen) -> some View {
            let width = getPenSize(pen)
            let penView = PenView(
                width: width,
                setToPen: self.activatePen,
                toolbarModel: toolbarModel,
                pen: Binding.proxy($toolbarModel.pens[ix])
            )
            if pen.style.layer == .foreground {
                penView
                    .frame(width: width, alignment: .center)
            } else {
                penView
                    .rotationEffect(Angle.degrees(180))
                    .frame(width: width, alignment: .center)
            }
        }
        @ViewBuilder private func penItem(ix: Int, pen: Pen) -> some View {
            let view = {
                Group {
                    switch (self.layerViewToggle, pen.style.layer) {
                    case (.both, _): penItemHelper(ix: ix, pen: pen)
                    case (.foreground, .foreground): penItemHelper(ix: ix, pen: pen)
                    case (.background, .background): penItemHelper(ix: ix, pen: pen)
                    default: EmptyView()
                    }
                }
            }
            if pen.penSet == self.penSetViewToggle {
                if toolbarModel.invertPenColors {
                    view()
                } else {
                    view()
                }
            } else {
                EmptyView()
            }
        }
        @ViewBuilder private var pensListMenu: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: -5) {
                    ForEach(Array(toolbarModel.pens.enumerated()), id: \.1.id) { (ix, pen) in
                        penItem(ix: ix, pen: pen)
                    }
                    Spacer()
                }
                .padding([.leading, .trailing], 10)
            }
        }
    }
}
