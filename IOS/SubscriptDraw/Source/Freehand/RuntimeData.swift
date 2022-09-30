//
//  RuntimeData.swift
//  Subscript
//
//  Created by Colbyn Wadman on 3/30/22.
//

import Foundation
import CoreGraphics

extension SS {
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

extension SS {
    class RuntimeDataModel: ObservableObject, Codable {
        @Published var currentToolType: CurrentToolType = CurrentToolType.pen
        @Published var pens: Array<Pen> = [
            Pen(options: Stroke.Options(
                color: CodableColor(color: #colorLiteral(red: 0.1522153874, green: 0.1522153874, blue: 0.1522153874, alpha: 0.9)),
                size: Pen.defaultThickPenSize
            )),
            Pen(options: Stroke.Options(
                color: CodableColor(color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)),
                size: 20
            )),
            Pen(
                options: Stroke.Options(
                    color: CodableColor(color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)),
                    size: Pen.defaultThickPenSize
                ),
                layer: .background
            ),
            Pen(options: Stroke.Options(
                color: CodableColor(color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)),
                size: 20
            )),
            Pen(options: Stroke.Options(
                color: CodableColor(color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)),
                size: Pen.defaultThickPenSize
            )),
            Pen(options: Stroke.Options(
                color: CodableColor(color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)),
                size: Pen.defaultThickPenSize
            )),
            Pen(options: Stroke.Options(
                color: CodableColor(color: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)),
                size: Pen.defaultThickPenSize
            )),
            Pen(options: Stroke.Options(
                color: CodableColor(color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)),
                size: Pen.defaultThickPenSize
            )),
            Pen(options: Stroke.Options(
                color: CodableColor(color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)),
                size: Pen.defaultThickPenSize
            )),
            Pen(options: Stroke.Options(
                color: CodableColor(color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)),
                size: Pen.defaultThickPenSize
            )),
            Pen(options: Stroke.Options(
                color: CodableColor(color: #colorLiteral(red: 0.1522153874, green: 0.1522153874, blue: 0.1522153874, alpha: 0.9)),
                size: Pen.defaultThinPenSize
            )),
            Pen(options: Stroke.Options(
                color: CodableColor(color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)),
                size: Pen.defaultThinPenSize
            )),
            Pen(options: Stroke.Options(
                color: CodableColor(color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)),
                size: Pen.defaultThinPenSize
            )),
            Pen(options: Stroke.Options(
                color: CodableColor(color: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)),
                size: Pen.defaultThinPenSize
            )),
            Pen(options: Stroke.Options(
                color: CodableColor(color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)),
                size: Pen.defaultThinPenSize
            )),
            Pen(options: Stroke.Options(
                color: CodableColor(color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)),
                size: Pen.defaultThinPenSize
            )),
            Pen(options: Stroke.Options(
                color: CodableColor(color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)),
                size: Pen.defaultThinPenSize
            )),
        ]
        
        enum CodingKeys: CodingKey {
            case pens
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try! container.encode(pens, forKey: .pens)
        }
        init() {}
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            pens = try container.decode(Array.self, forKey: .pens)
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
        }
        static func loadDefault() -> RuntimeDataModel {
            let path = URL.getDocumentsDirectory().appendingPathComponent("SubscriptRuntimeState.data", isDirectory: false)
            if let data = RuntimeDataModel.load(path: path) {
                print("loaded RuntimeDataModel", path)
                return data
            } else {
                print("init RuntimeDataModel", path)
                return RuntimeDataModel()
            }
        }
        func saveDefault() {
            let path = URL.getDocumentsDirectory().appendingPathComponent("SubscriptRuntimeState.data", isDirectory: false)
            print("save RuntimeDataModel", path)
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
            var layer: SS.Stroke.Layer = SS.Stroke.Layer.foreground
            static let defaultThinPenSize: CGFloat = 2.5
            static let defaultThickPenSize: CGFloat = 4
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


