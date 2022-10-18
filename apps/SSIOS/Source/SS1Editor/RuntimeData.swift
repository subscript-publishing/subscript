//
//  RuntimeData.swift
//  Subscript
//
//  Created by Colbyn Wadman on 3/30/22.
//

import Foundation
import CoreGraphics
import UIKit

extension SS1 {
    enum Placement: String, Codable {
        case foreground
        case background
    }
    enum InkType: String, Codable {
        case regular
        case highlighter
        case filler
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DRAWING RUNTIME STATE
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


fileprivate func penSet(
    color: SS1.Stroke.Options.ColorMap,
    penSet: SS1.RuntimeDataModel.Pen.PenSet = SS1.RuntimeDataModel.Pen.PenSet.set1,
    fgPen1Map: Optional<(inout SS1.Stroke.Options) -> ()> = .none,
    fgPen2Map: Optional<(inout SS1.Stroke.Options) -> ()> = .none,
    bgPen1Map: Optional<(inout SS1.Stroke.Options) -> ()> = .none,
    bgPen2Map: Optional<(inout SS1.Stroke.Options) -> ()> = .none
) -> Array<SS1.RuntimeDataModel.Pen> {
    let highlightColor = SS1.Stroke.Options.ColorMap(
        lightUIMode: color.lightUIMode.withAlpha(0.6),
        darkUIMode: color.darkUIMode.withAlpha(0.6)
    )
    var pen1Options = SS1.Stroke.Options(color: color, size: SS1.RuntimeDataModel.Pen.defaultFgThinPenSize)
    if case let .some(f) = fgPen1Map {
        f(&pen1Options)
    }
    let pen1 = SS1.RuntimeDataModel.Pen(
        options: pen1Options,
        layer: SS1.Stroke.Layer.foreground,
        penSet: penSet
    )
    var pen2Options = SS1.Stroke.Options(color: color, size: SS1.RuntimeDataModel.Pen.defaultFgThickPenSize)
    if case let .some(f) = fgPen2Map {
        f(&pen2Options)
    }
    let pen2 = SS1.RuntimeDataModel.Pen(
        options: pen2Options,
        layer: SS1.Stroke.Layer.foreground,
        penSet: penSet
    )
    var pen3Options = SS1.Stroke.Options(color: highlightColor, size: SS1.RuntimeDataModel.Pen.defaultBgThinPenSize)
    if case let .some(f) = bgPen1Map {
        f(&pen3Options)
    }
    defaultBgMarkerConfig(&pen3Options)
    let pen3 = SS1.RuntimeDataModel.Pen(
        options: pen3Options,
        layer: SS1.Stroke.Layer.background,
        penSet: penSet
    )
    var pen4Options = SS1.Stroke.Options(color: highlightColor, size: SS1.RuntimeDataModel.Pen.defaultBgThickPenSize)
    defaultBgMarkerConfig(&pen4Options)
    if case let .some(f) = bgPen2Map {
        f(&pen4Options)
    }
    let pen4 = SS1.RuntimeDataModel.Pen(
        options: pen4Options,
        layer: SS1.Stroke.Layer.background,
        penSet: penSet
    )
    return [pen1, pen2, pen3, pen4]
}

fileprivate func concat<T>(
    _ value: Array<Array<T>>
) -> Array<T> {
    Array(value.joined())
}
fileprivate func defaultBgMarkerConfig(_ withSize: CGFloat) -> (_ opt: inout SS1.Stroke.Options) -> () {
    return {opt in
        opt.size = withSize
        opt.thinning = 0.0
        opt.smoothing = 1.0
        opt.streamline = 1.0
        opt.start.cap = false
        opt.end.cap = false
    }
}
fileprivate func defaultBgMarkerConfig(_ opt: inout SS1.Stroke.Options) {
    opt.thinning = 0.0
    opt.smoothing = 1.0
    opt.streamline = 1.0
    opt.start.cap = false
    opt.end.cap = false
}
fileprivate func defaultFgExtraThinConfig(_ opt: inout SS1.Stroke.Options) {
    opt.size = SS1.RuntimeDataModel.Pen.defaultExtraThinPenSize
    opt.thinning = 0.0
    opt.smoothing = 1.0
    opt.streamline = 1.0
    opt.start.cap = false
    opt.end.cap = false
}
fileprivate func defaultBgExtraThinConfig(_ opt: inout SS1.Stroke.Options) {
    opt.size = SS1.RuntimeDataModel.Pen.defaultExtraThinPenSize
    opt.thinning = 0.0
    opt.smoothing = 1.0
    opt.streamline = 1.0
    opt.start.cap = false
    opt.end.cap = false
}
fileprivate func defaultFgExtraThickConfig(_ opt: inout SS1.Stroke.Options) {
    opt.size = SS1.RuntimeDataModel.Pen.defaultExtraThickPenSize
    opt.thinning = 0.0
    opt.smoothing = 1.0
    opt.streamline = 1.0
    opt.start.cap = false
    opt.end.cap = false
}
fileprivate func defaultBgExtraThickConfig(_ opt: inout SS1.Stroke.Options) {
    opt.size = SS1.RuntimeDataModel.Pen.defaultExtraThickPenSize
    opt.thinning = 0.0
    opt.smoothing = 1.0
    opt.streamline = 1.0
    opt.start.cap = false
    opt.end.cap = false
}

extension SS1 {
    class RuntimeDataModel: ObservableObject, Codable {
        typealias ColorMap = SS1.Stroke.Options.ColorMap
        typealias PrimaryColorSchemeMode = SS1.RuntimeDataModel.Pen.PrimaryColorSchemeMode
        
        @Published var currentToolType: CurrentToolType = CurrentToolType.pen
//        @Published var pens: Array<Pen> = defaultPenList()
        @Published var pens: Array<Pen> = concat([
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                )
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.1522153874, green: 0.1522153874, blue: 0.1522153874, alpha: 0.9480085944)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                )
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 1, green: 0.3562028628, blue: 0.3234998193, alpha: 0.9536794495)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 1, green: 0.4533152416, blue: 0.4255452278, alpha: 0.9335713892))
                )
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 1, green: 0.8595820573, blue: 0, alpha: 0.9599663519)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.9853975177, green: 0.9960361123, blue: 0, alpha: 1))
                )
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.1820927858, green: 0.9942755103, blue: 0.008088083938, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.4050822258, green: 0.9107592702, blue: 0.3064689636, alpha: 1))
                )
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.03801821545, green: 0.7668590459, blue: 0.9436975718, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.1981527805, green: 0.9152255654, blue: 0.9221068621, alpha: 1))
                )
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.0006549843238, green: 0.1723237932, blue: 0.9950235486, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.4912772218, green: 0.5628710919, blue: 0.911735177, alpha: 1))
                )
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.8881010415, green: 0.6503296282, blue: 1, alpha: 1))
                )
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 1, green: 0.2187052982, blue: 0.7401167801, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1))
                )
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.9836834073, green: 0.01610323042, blue: 0.01610323042, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.923746407, green: 0.5437585418, blue: 0.5513613933, alpha: 1))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.9836834073, green: 0.4915673948, blue: 0.01610323042, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.923746407, green: 0.598991043, blue: 0.4473902994, alpha: 1))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.9836834073, green: 0.8120082, blue: 0.01610323042, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.923746407, green: 0.8480549868, blue: 0.5567146521, alpha: 1))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.6896855942, green: 0.923746407, blue: 0.2139444053, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.7753242077, green: 0.923746407, blue: 0.4892397564, alpha: 1))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.1930225866, green: 0.9836834073, blue: 0.01610323042, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.6009957053, green: 0.9836834073, blue: 0.5153649771, alpha: 0.9529471683))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.3484312771, green: 1, blue: 0, alpha: 0.94)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.5998694567, green: 1, blue: 0.385896638, alpha: 0.9308121501))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0, green: 1, blue: 0.5583703604, alpha: 0.94)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.385896638, green: 1, blue: 0.8693810537, alpha: 0.9308121501))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0, green: 0.8359576278, blue: 1, alpha: 0.94)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.385896638, green: 0.9012365223, blue: 1, alpha: 0.9308121501))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0, green: 0.5678111642, blue: 1, alpha: 0.94)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.385896638, green: 0.7952249831, blue: 1, alpha: 0.9308121501))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.01610323042, green: 0.9836834073, blue: 0.9756202392, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.4918417037, green: 0.9836834073, blue: 0.9795847264, alpha: 1))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.7612673015, green: 0.6585746401, blue: 0.9686274529, alpha: 1))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.4572930815, green: 0, blue: 1, alpha: 0.94)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.7858035736, green: 0.5667474595, blue: 1, alpha: 0.9308121501))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.08712213245, green: 0, blue: 1, alpha: 0.94)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.5528893269, green: 0.6628325972, blue: 1, alpha: 0.9308121501))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.8194490579, green: 0, blue: 1, alpha: 0.94)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.9275795289, green: 0.385896638, blue: 1, alpha: 0.9308121501))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(color: ColorMap(
                lightUIMode: CodableColor(color: #colorLiteral(red: 1, green: 0, blue: 0.5195422284, alpha: 0.94)),
                darkUIMode: CodableColor(color: #colorLiteral(red: 1, green: 0.5, blue: 0.8799946326, alpha: 0.9308121501))
            )),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 1, green: 0.3132912363, blue: 0.7992954836, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 1, green: 0.2615669501, blue: 0.744681838, alpha: 1))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1))
                ),
                penSet: Pen.PenSet.set2
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                ),
                penSet: Pen.PenSet.set3,
                fgPen1Map: defaultFgExtraThinConfig,
                fgPen2Map: defaultFgExtraThickConfig,
                bgPen1Map: defaultBgExtraThinConfig,
                bgPen2Map:defaultBgExtraThickConfig
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.1522153874, green: 0.1522153874, blue: 0.1522153874, alpha: 0.9480085944)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                ),
                penSet: Pen.PenSet.set3,
                fgPen1Map: defaultFgExtraThinConfig,
                fgPen2Map: defaultFgExtraThickConfig,
                bgPen1Map: defaultBgExtraThinConfig,
                bgPen2Map:defaultBgExtraThickConfig
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 1, green: 0.3562028628, blue: 0.3234998193, alpha: 0.9536794495)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 1, green: 0.4533152416, blue: 0.4255452278, alpha: 0.9335713892))
                ),
                penSet: Pen.PenSet.set3,
                fgPen1Map: defaultFgExtraThinConfig,
                fgPen2Map: defaultFgExtraThickConfig,
                bgPen1Map: defaultBgExtraThinConfig,
                bgPen2Map:defaultBgExtraThickConfig
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 1, green: 0.8595820573, blue: 0, alpha: 0.9599663519)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.9853975177, green: 0.9960361123, blue: 0, alpha: 1))
                ),
                penSet: Pen.PenSet.set3,
                fgPen1Map: defaultFgExtraThinConfig,
                fgPen2Map: defaultFgExtraThickConfig,
                bgPen1Map: defaultBgExtraThinConfig,
                bgPen2Map:defaultBgExtraThickConfig
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.1820927858, green: 0.9942755103, blue: 0.008088083938, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.4050822258, green: 0.9107592702, blue: 0.3064689636, alpha: 1))
                ),
                penSet: Pen.PenSet.set3,
                fgPen1Map: defaultFgExtraThinConfig,
                fgPen2Map: defaultFgExtraThickConfig,
                bgPen1Map: defaultBgExtraThinConfig,
                bgPen2Map:defaultBgExtraThickConfig
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.03801821545, green: 0.7668590459, blue: 0.9436975718, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.1981527805, green: 0.9152255654, blue: 0.9221068621, alpha: 1))
                ),
                penSet: Pen.PenSet.set3,
                fgPen1Map: defaultFgExtraThinConfig,
                fgPen2Map: defaultFgExtraThickConfig,
                bgPen1Map: defaultBgExtraThinConfig,
                bgPen2Map:defaultBgExtraThickConfig
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.0006549843238, green: 0.1723237932, blue: 0.9950235486, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.4912772218, green: 0.5628710919, blue: 0.911735177, alpha: 1))
                ),
                penSet: Pen.PenSet.set3,
                fgPen1Map: defaultFgExtraThinConfig,
                fgPen2Map: defaultFgExtraThickConfig,
                bgPen1Map: defaultBgExtraThinConfig,
                bgPen2Map:defaultBgExtraThickConfig
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 0.8881010415, green: 0.6503296282, blue: 1, alpha: 1))
                ),
                penSet: Pen.PenSet.set3,
                fgPen1Map: defaultFgExtraThinConfig,
                fgPen2Map: defaultFgExtraThickConfig,
                bgPen1Map: defaultBgExtraThinConfig,
                bgPen2Map:defaultBgExtraThickConfig
            ),
            penSet(
                color: ColorMap(
                    lightUIMode: CodableColor(color: #colorLiteral(red: 1, green: 0.2187052982, blue: 0.7401167801, alpha: 1)),
                    darkUIMode: CodableColor(color: #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1))
                ),
                penSet: Pen.PenSet.set3,
                fgPen1Map: defaultFgExtraThinConfig,
                fgPen2Map: defaultFgExtraThickConfig,
                bgPen1Map: defaultBgExtraThinConfig,
                bgPen2Map:defaultBgExtraThickConfig
            ),
        ])
        
        @Published var templatePen: Pen = Pen(
            options: SS1.Stroke.Options(),
            active: false,
            layer: SS1.Stroke.Layer.foreground
        )
        @Published var invertPenColors: Bool = false
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
        static func load(path: URL) -> Optional<RuntimeDataModel> {
            let decoder = PropertyListDecoder()
            let data = try? Data(contentsOf: path)
            if let data = data {
                return try? decoder.decode(RuntimeDataModel.self, from: data)
            } else {
                return .none
            }
//            return .none
        }
        static func loadDefault() -> RuntimeDataModel {
            let defaultFileName = "SubscriptRuntimeState.data"
            let path = URL
                .getDocumentsDirectory()
                .appendingPathComponent(defaultFileName, isDirectory: false)
            if let data = RuntimeDataModel.load(path: path) {
                return data
            } else {
                if SS1.DEBUG_MODE {
                    print("[load pen failed] init new RuntimeDataModel", path)
                }
                return RuntimeDataModel()
            }
        }
        func saveDefault() {
            let path = URL.getDocumentsDirectory().appendingPathComponent("SubscriptRuntimeState.data", isDirectory: false)
            if SS1.DEBUG_MODE {
                print("save RuntimeDataModel", path)
            }
            self.save(path: path)
        }
        
        func getIndexForPen(id: UUID) -> Int {
            var index: Int! = nil
            for (ix, pen) in self.pens.enumerated() {
                if pen.id == id {
                    index = ix
                }
            }
            assert(index != nil)
            return index!
        }
        
        func penMinMaxValues(defPenMin: CGFloat, defPenMax: CGFloat) -> (CGFloat, CGFloat) {
            var values: Array<CGFloat> = []
            for pen in pens {
                values.append(pen.options.size)
            }
            let min = values.min() ?? defPenMin
            let max = values.max() ?? defPenMax
            return (min, max)
        }
        
        struct Pen: Codable, Identifiable {
            var id: UUID = UUID()
            var options: Stroke.Options = Stroke.Options()
            var active: Bool = false
            var layer: SS1.Stroke.Layer = SS1.Stroke.Layer.foreground
            var primaryColorSchemeMode: PrimaryColorSchemeMode = PrimaryColorSchemeMode.both
            var penSet: PenSet = PenSet.set1
            static let defaultFgThinPenSize: CGFloat = 2.5
            static let defaultFgThickPenSize: CGFloat = 6
            static let defaultBgThinPenSize: CGFloat = 5
            static let defaultBgThickPenSize: CGFloat = 10
            static let defaultExtraThinPenSize: CGFloat = 1
            static let defaultExtraThickPenSize: CGFloat = 50
            /// This option defines what pens get filtered out based on the current color scheme.
            ///
            /// For instance regarding the toolbar and specifically the pen list therein:
            /// - `PrimaryColorSchemeMode.light` : the toolbar will only display this pen if the active color scheme is set to `ColorScheme.light`
            /// - `PrimaryColorSchemeMode.dark` : the toolbar will only display this pen if the active color scheme is set to `ColorScheme.dark`
            /// - `PrimaryColorSchemeMode.both` : the toolbar will only display this pen regardless of the current color scheme environment.
            ///
            /// The rationale for this setting is to reduce redundant colors for a given color scheme in the
            /// toolbar UI (specially the pen list therein). Notably for dark color schemes which permit for
            /// more color variations -such as pastel colors- that would otherwise be too faint on light
            /// backgrounds and so the color value for light mode may map to a value that is already
            /// defined by another pen, and so this setting was introduced to reduce redundant colors
            /// in the pen list.
            enum PrimaryColorSchemeMode: String, Equatable, Codable {
                case both
                case light
                case dark
            }
            enum PenSet: String, Equatable, Codable {
                case set1
                case set2
                case set3
                case set4
            }
        }
        
        enum CurrentToolType {
            case pen
            case selection
            case eraser
            
            var isPen: Bool {
                self == .pen
            }
            var isSelection: Bool {
                self == .selection
            }
            var isEraser: Bool {
                self == .eraser
            }
            var isAnyEditToolType: Bool {
                isSelection || isEraser
            }
        }
    }
}


