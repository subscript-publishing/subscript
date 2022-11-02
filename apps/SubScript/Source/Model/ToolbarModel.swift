//
//  ToolbarModel.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/31/22.
//

import Foundation
import Combine

fileprivate func penSet(
    templateColor: UI.LL.Color,
    color: SS1.PenModel.DualColor,
    penSet: SS1.PenModel.PenSet = SS1.PenModel.PenSet.set1,
    fgPen1Map: Optional<(inout SS1.PenModel.DynamicPenStyle) -> ()> = .none,
    fgPen2Map: Optional<(inout SS1.PenModel.DynamicPenStyle) -> ()> = .none,
    bgPen1Map: Optional<(inout SS1.PenModel.DynamicPenStyle) -> ()> = .none,
    bgPen2Map: Optional<(inout SS1.PenModel.DynamicPenStyle) -> ()> = .none
) -> Array<SS1.PenModel> {
    let highlightColor = SS1.PenModel.DualColor(
        lightUI: color.lightUI.with(alpha: 0.6),
        darkUI: color.darkUI.with(alpha: 0.6)
    )
    var pen1Options = SS1.PenModel.DynamicPenStyle(
        color: color,
        layer: SS1.PenModel.DynamicPenStyle.Layer.foreground,
        size: SS1.PenModel.defaultFgThinPenSize
    )
    if case let .some(f) = fgPen1Map {
        f(&pen1Options)
    }
    let pen1 = SS1.PenModel(
        dynamicPenStyle: pen1Options,
        templateColor: UI.ColorType.HSBA(from: templateColor),
        penSet: penSet
    )
    var pen2Options = SS1.PenModel.DynamicPenStyle(
        
        color: color,
        layer: SS1.PenModel.DynamicPenStyle.Layer.foreground,
        size: SS1.PenModel.defaultFgThickPenSize
    )
    if case let .some(f) = fgPen2Map {
        f(&pen2Options)
    }
    let pen2 = SS1.PenModel(
        dynamicPenStyle: pen2Options,
        templateColor: UI.ColorType.HSBA(from: templateColor),
        penSet: penSet
    )
    var pen3Options = SS1.PenModel.DynamicPenStyle(
        
        color: highlightColor,
        layer: SS1.PenModel.DynamicPenStyle.Layer.background,
        size: SS1.PenModel.defaultBgThinPenSize
    )
    if case let .some(f) = bgPen1Map {
        f(&pen3Options)
    }
    defaultBgMarkerConfig(&pen3Options)
    let pen3 = SS1.PenModel(
        dynamicPenStyle: pen3Options,
        templateColor: UI.ColorType.HSBA(from: templateColor),
        penSet: penSet
    )
    var pen4Options = SS1.PenModel.DynamicPenStyle(
        
        color: highlightColor,
        layer: SS1.PenModel.DynamicPenStyle.Layer.background,
        size: SS1.PenModel.defaultBgThickPenSize
    )
    defaultBgMarkerConfig(&pen4Options)
    if case let .some(f) = bgPen2Map {
        f(&pen4Options)
    }
    let pen4 = SS1.PenModel(
        dynamicPenStyle: pen4Options,
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
fileprivate func defaultBgMarkerConfig(_ withSize: CGFloat) -> (_ opt: inout SS1.PenModel.DynamicPenStyle) -> () {
    return {opt in
        opt.size = withSize
        opt.thinning = 0.0
        opt.smoothing = 1.0
        opt.streamline = 1.0
        opt.start.cap = false
        opt.end.cap = false
    }
}
fileprivate func defaultBgMarkerConfig(_ opt: inout SS1.PenModel.DynamicPenStyle) {
    opt.thinning = 0.0
    opt.smoothing = 1.0
    opt.streamline = 1.0
    opt.start.cap = false
    opt.end.cap = false
}
fileprivate func defaultFgExtraThinConfig(_ opt: inout SS1.PenModel.DynamicPenStyle) {
    opt.size = SS1.PenModel.defaultExtraThinPenSize
    opt.thinning = 0.0
    opt.smoothing = 1.0
    opt.streamline = 1.0
    opt.start.cap = false
    opt.end.cap = false
}
fileprivate func defaultBgExtraThinConfig(_ opt: inout SS1.PenModel.DynamicPenStyle) {
    opt.size = SS1.PenModel.defaultExtraThinPenSize
    opt.thinning = 0.0
    opt.smoothing = 1.0
    opt.streamline = 1.0
    opt.start.cap = false
    opt.end.cap = false
}
fileprivate func defaultFgExtraThickConfig(_ opt: inout SS1.PenModel.DynamicPenStyle) {
    opt.size = SS1.PenModel.defaultExtraThickPenSize
    opt.thinning = 0.0
    opt.smoothing = 1.0
    opt.streamline = 1.0
    opt.start.cap = false
    opt.end.cap = false
}
fileprivate func defaultBgExtraThickConfig(_ opt: inout SS1.PenModel.DynamicPenStyle) {
    opt.size = SS1.PenModel.defaultExtraThickPenSize
    opt.thinning = 0.0
    opt.smoothing = 1.0
    opt.streamline = 1.0
    opt.start.cap = false
    opt.end.cap = false
}

fileprivate var DEFAULT_PENS: Array<SS1.PenModel> {
    concat([
        penSet(
            templateColor: #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.1522153874, green: 0.1522153874, blue: 0.1522153874, alpha: 0.9480085944)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.3562028628, blue: 0.3234998193, alpha: 0.9536794495)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.4533152416, blue: 0.4255452278, alpha: 0.9335713892))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.9853975177, green: 0.9960361123, blue: 0, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.8595820573, blue: 0, alpha: 0.9599663519)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.9853975177, green: 0.9960361123, blue: 0, alpha: 1))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.1820927858, green: 0.9942755103, blue: 0.008088083938, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.1820927858, green: 0.9942755103, blue: 0.008088083938, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.4050822258, green: 0.9107592702, blue: 0.3064689636, alpha: 1))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.03801821545, green: 0.7668590459, blue: 0.9436975718, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.03801821545, green: 0.7668590459, blue: 0.9436975718, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.1981527805, green: 0.9152255654, blue: 0.9221068621, alpha: 1))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.0006549843238, green: 0.1723237932, blue: 0.9950235486, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.0006549843238, green: 0.1723237932, blue: 0.9950235486, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.4912772218, green: 0.5628710919, blue: 0.911735177, alpha: 1))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.8881010415, green: 0.6503296282, blue: 1, alpha: 1))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 1, green: 0.2187052982, blue: 0.7401167801, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.2187052982, blue: 0.7401167801, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.9836834073, green: 0.01610323042, blue: 0.01610323042, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.9836834073, green: 0.01610323042, blue: 0.01610323042, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.923746407, green: 0.5437585418, blue: 0.5513613933, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.9836834073, green: 0.4915673948, blue: 0.01610323042, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.9836834073, green: 0.4915673948, blue: 0.01610323042, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.923746407, green: 0.598991043, blue: 0.4473902994, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.9836834073, green: 0.8120082, blue: 0.01610323042, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.9836834073, green: 0.8120082, blue: 0.01610323042, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.923746407, green: 0.8480549868, blue: 0.5567146521, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.6896855942, green: 0.923746407, blue: 0.2139444053, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.6896855942, green: 0.923746407, blue: 0.2139444053, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.7753242077, green: 0.923746407, blue: 0.4892397564, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.1930225866, green: 0.9836834073, blue: 0.01610323042, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.1930225866, green: 0.9836834073, blue: 0.01610323042, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.6009957053, green: 0.9836834073, blue: 0.5153649771, alpha: 0.9529471683))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.3484312771, green: 1, blue: 0, alpha: 0.94),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.3484312771, green: 1, blue: 0, alpha: 0.94)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.5998694567, green: 1, blue: 0.385896638, alpha: 0.9308121501))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0, green: 1, blue: 0.5583703604, alpha: 0.94),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0, green: 1, blue: 0.5583703604, alpha: 0.94)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.385896638, green: 1, blue: 0.8693810537, alpha: 0.9308121501))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0, green: 0.8359576278, blue: 1, alpha: 0.94),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0, green: 0.8359576278, blue: 1, alpha: 0.94)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.385896638, green: 0.9012365223, blue: 1, alpha: 0.9308121501))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0, green: 0.5678111642, blue: 1, alpha: 0.94),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0, green: 0.5678111642, blue: 1, alpha: 0.94)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.385896638, green: 0.7952249831, blue: 1, alpha: 0.9308121501))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.01610323042, green: 0.9836834073, blue: 0.9756202392, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.01610323042, green: 0.9836834073, blue: 0.9756202392, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.4918417037, green: 0.9836834073, blue: 0.9795847264, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.7612673015, green: 0.6585746401, blue: 0.9686274529, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.4572930815, green: 0, blue: 1, alpha: 0.94),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.4572930815, green: 0, blue: 1, alpha: 0.94)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.7858035736, green: 0.5667474595, blue: 1, alpha: 0.9308121501))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.08712213245, green: 0, blue: 1, alpha: 0.94),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.08712213245, green: 0, blue: 1, alpha: 0.94)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.5528893269, green: 0.6628325972, blue: 1, alpha: 0.9308121501))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.8194490579, green: 0, blue: 1, alpha: 0.94),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.8194490579, green: 0, blue: 1, alpha: 0.94)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.9275795289, green: 0.385896638, blue: 1, alpha: 0.9308121501))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 1, green: 0, blue: 0.5195422284, alpha: 0.94),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0, blue: 0.5195422284, alpha: 0.94)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.5, blue: 0.8799946326, alpha: 0.9308121501))
            )
        ),
        penSet(
            templateColor: #colorLiteral(red: 1, green: 0.3132912363, blue: 0.7992954836, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.3132912363, blue: 0.7992954836, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.2615669501, blue: 0.744681838, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set2
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.1522153874, green: 0.1522153874, blue: 0.1522153874, alpha: 0.9480085944),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.1522153874, green: 0.1522153874, blue: 0.1522153874, alpha: 0.9480085944)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
        penSet(
            templateColor: #colorLiteral(red: 1, green: 0.3562028628, blue: 0.3234998193, alpha: 0.9536794495),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.3562028628, blue: 0.3234998193, alpha: 0.9536794495)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.4533152416, blue: 0.4255452278, alpha: 0.9335713892))
            ),
            penSet: SS1.PenModel.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
        penSet(
            templateColor: #colorLiteral(red: 1, green: 0.8595820573, blue: 0, alpha: 0.9599663519),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.8595820573, blue: 0, alpha: 0.9599663519)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.9853975177, green: 0.9960361123, blue: 0, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.1820927858, green: 0.9942755103, blue: 0.008088083938, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.1820927858, green: 0.9942755103, blue: 0.008088083938, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.4050822258, green: 0.9107592702, blue: 0.3064689636, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.03801821545, green: 0.7668590459, blue: 0.9436975718, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.03801821545, green: 0.7668590459, blue: 0.9436975718, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.1981527805, green: 0.9152255654, blue: 0.9221068621, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.0006549843238, green: 0.1723237932, blue: 0.9950235486, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.0006549843238, green: 0.1723237932, blue: 0.9950235486, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.4912772218, green: 0.5628710919, blue: 0.911735177, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
        penSet(
            templateColor: #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 0.8881010415, green: 0.6503296282, blue: 1, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
        penSet(
            templateColor: #colorLiteral(red: 1, green: 0.2187052982, blue: 0.7401167801, alpha: 1),
            color: SS1.PenModel.ColorMode(
                lightUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.2187052982, blue: 0.7401167801, alpha: 1)),
                darkUI: UI.ColorType.HSBA(from: #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1))
            ),
            penSet: SS1.PenModel.PenSet.set3,
            fgPen1Map: defaultFgExtraThinConfig,
            fgPen2Map: defaultFgExtraThickConfig,
            bgPen1Map: defaultBgExtraThinConfig,
            bgPen2Map:defaultBgExtraThickConfig
        ),
    ])
}


extension SS1 {
    struct PenModel: Codable, Identifiable {
        var id: UUID = UUID()
        var dynamicPenStyle: DynamicPenStyle = DynamicPenStyle()
        var templateColor: UI.ColorType.HSBA = UI.ColorType.HSBA(from: #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1))
        var useTemplateColor: Bool = true
        var active: Bool = false
        var penSet: PenSet = PenSet.set1
        
        enum PenSet: String, Equatable, Codable, CaseIterable {
            case set1
            case set2
            case set3
            case set4
        }
        static let defaultFgThinPenSize: CGFloat = 2.5
        static let defaultFgThickPenSize: CGFloat = 4.5
        static let defaultBgThinPenSize: CGFloat = 5
        static let defaultBgThickPenSize: CGFloat = 10
        static let defaultExtraThinPenSize: CGFloat = 1
        static let defaultExtraThickPenSize: CGFloat = 50
        
        typealias HSBA = UI.ColorType.HSBA
        typealias ColorMode<T> = UI.ColorMode<T>
        typealias DualColor = UI.ColorMode<HSBA>
        
        struct StaticPenStyle: Equatable, Hashable, Codable {
            
        }
        
        struct DynamicPenStyle: Equatable, Hashable, Codable {
            var color: DualColor = DualColor(
                lightUI: HSBA.black,
                darkUI: HSBA.white
            )
            var layer: Layer = Layer.foreground
            
            /// The base size (diameter) of the stroke.
            var size: CGFloat = DynamicPenStyle.defaultSize
            /// The effect of pressure on the stroke's size.
            var thinning: CGFloat = 0.5
            /// How much to soften the stroke's edges.
            var smoothing: CGFloat = 0.5
            /// TODO
            var streamline: CGFloat = 0.5
            /// An easing function to apply to each point's pressure.
            var easing: Easing = Easing.linear
            /// Whether to simulate pressure based on velocity.
            var simulatePressure: Bool = true
            /// Cap, taper and easing for the start of the line.
            var start: StartCap = StartCap()
            /// Cap, taper and easing for the end of the line.
            var end: EndCap = EndCap()
            
            static let defaultSize: CGFloat = 2.5
            static let defaultThinning: CGFloat = 0.5
            static let defaultSmoothing: CGFloat = 0.5
            static let defaultStreamline: CGFloat = 0.5
            static let defaultEasing: Easing = Easing.linear
            
            static let minSize: CGFloat = 1.0
            static let minThinning: CGFloat = -1.0
            static let minSmoothing: CGFloat = 0.0
            static let minStreamline: CGFloat = 0.0
            
            static let maxSize: CGFloat = 60.0
            static let maxThinning: CGFloat = 1.0
            static let maxSmoothing: CGFloat = 1.0
            static let maxStreamline: CGFloat = 1.0
            
            static let sizeRange: ClosedRange<CGFloat> = minSize...maxSize
            static let thinningRange: ClosedRange<CGFloat> = minThinning...maxThinning
            static let smoothingRange: ClosedRange<CGFloat> = minSmoothing...maxSmoothing
            static let streamlineRange: ClosedRange<CGFloat> = minStreamline...maxStreamline
            
            enum Layer: String, Codable, CaseIterable {
                case foreground
                case background
            }
            enum Easing: String, Equatable, Hashable, Codable, CaseIterable {
                case linear
                case easeInQuad
                case easeOutQuad
                case easeInOutQuad
                case easeInCubic
                case easeOutCubic
                case easeInOutCubic
                case easeInQuart
                case easeOutQuart
                case easeInOutQuart
                case easeInQuint
                case easeOutQuint
                case easeInOutQuint
                case easeInSine
                case easeOutSine
                case easeInOutSine
                case easeInExpo
                case easeOutExpo
                
                func toFunction() -> (CGFloat) -> (CGFloat) {
                    switch self {
                    case .linear: return self.linear
                    case .easeInQuad: return self.easeInQuad
                    case .easeOutQuad: return self.easeOutQuad
                    case .easeInOutQuad: return self.easeInOutQuad
                    case .easeInCubic: return self.easeInCubic
                    case .easeOutCubic: return self.easeOutCubic
                    case .easeInOutCubic: return self.easeInOutCubic
                    case .easeInQuart: return self.easeInQuart
                    case .easeOutQuart: return self.easeOutQuart
                    case .easeInOutQuart: return self.easeInOutQuart
                    case .easeInQuint: return self.easeInQuint
                    case .easeOutQuint: return self.easeOutQuint
                    case .easeInOutQuint: return self.easeInOutQuint
                    case .easeInSine: return self.easeInSine
                    case .easeOutSine: return self.easeOutSine
                    case .easeInOutSine: return self.easeInOutSine
                    case .easeInExpo: return self.easeInExpo
                    case .easeOutExpo: return self.easeOutExpo
                    }
                }
                private func linear(t: CGFloat) -> CGFloat {t}
                private func easeInQuad(t: CGFloat) -> CGFloat {t * t}
                private func easeOutQuad(t: CGFloat) -> CGFloat {t * (2 - t)}
                private func easeInOutQuad(t: CGFloat) -> CGFloat {
                    (t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t)
                }
                private func easeInCubic(t: CGFloat) -> CGFloat {t * t * t}
                private func easeOutCubic(t: CGFloat) -> CGFloat {(t - 1) * t * t + 1}
                private func easeInOutCubic(t: CGFloat) -> CGFloat {
                    t < 0.5 ? 4 * t * t * t : (t - 1) * (2 * t - 2) * (2 * t - 2) + 1
                }
                private func easeInQuart(t: CGFloat) -> CGFloat {t * t * t * t}
                private func easeOutQuart(t: CGFloat) -> CGFloat {1 - (t - 1) * t * t * t}
                private func easeInOutQuart(t: CGFloat) -> CGFloat {
                    t < 0.5 ? 8 * t * t * t * t : 1 - 8 * (t - 1) * t * t * t
                }
                private func easeInQuint(t: CGFloat) -> CGFloat {t * t * t * t * t}
                private func easeOutQuint(t: CGFloat) -> CGFloat {1 + (t - 1) * t * t * t * t}
                private func easeInOutQuint(t: CGFloat) -> CGFloat {
                    t < 0.5 ? 16 * t * t * t * t * t : 1 + 16 * (t - 1) * t * t * t * t
                }
                private func easeInSine(t: CGFloat) -> CGFloat {1 - cos((t * CGFloat.pi) / 2)}
                private func easeOutSine(t: CGFloat) -> CGFloat {sin((t * CGFloat.pi) / 2)}
                private func easeInOutSine(t: CGFloat) -> CGFloat {-(cos(CGFloat.pi * t) - 1) / 2}
                private func easeInExpo(t: CGFloat) -> CGFloat {t <= 0 ? 0 : pow(2, 10 * t - 10)}
                private func easeOutExpo(t: CGFloat) -> CGFloat {t >= 1 ? 1 : 1 - pow(2, -10 * t)}
            }
            struct StartCap: Equatable, Hashable, Codable {
                var cap: Bool = true
                var taper: CGFloat = 0
                var easing: Easing = Easing.linear
            }
            struct EndCap: Equatable, Hashable, Codable {
                var cap: Bool = true
                var taper: CGFloat = 0
                var easing: Easing = Easing.linear
            }
        }
    }
}


extension SS1 {
    final class ToolBarModel: ObservableObject, Codable {
        @Published var currentToolType: CurrentToolType = CurrentToolType.pen
        @Published var invertPenColors: Bool = false
        @Published var templatePen: PenModel = PenModel()
        @Published var pens: Array<PenModel> = DEFAULT_PENS
        @Published var showHSLAColorPicker: Bool = false
        @Published var eraserSettings = EditToolSettings()
        @Published var lassoSettings = EditToolSettings()
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
            templatePen = try container.decode(PenModel.self, forKey: .templatePen)
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
        struct EditToolSettings: Equatable {
            var selectionLayer: ActiveLayer = ActiveLayer.both
            enum ActiveLayer: String, Codable, CaseIterable, Hashable, Equatable {
                case both
                case foreground
                case background
            }
        }
    }
}
