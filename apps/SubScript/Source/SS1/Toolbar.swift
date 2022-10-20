//
//  Toolbar.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/19/22.
//

import Foundation

extension SS1 {
    static let globalToolbar = ToolBar.loadDefault()
    class ToolBar: ObservableObject, Codable {
        @Published var invertPenColors: Bool = false
        @Published var templatePen: Pen = Pen()
        @Published var pens: Array<Pen> = []
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
        static func load(path: URL) -> Optional<ToolBar> {
            let decoder = PropertyListDecoder()
            let data = try? Data(contentsOf: path)
            if let data = data {
                return try? decoder.decode(ToolBar.self, from: data)
            } else {
                return .none
            }
        }
        static let defaultFileName = "ToolBar.data"
        static func loadDefault() -> ToolBar {
            let path = URL
                .getDocumentsDirectory()
                .appendingPathComponent(ToolBar.defaultFileName, isDirectory: false)
            if let data = ToolBar.load(path: path) {
                return data
            } else {
                return ToolBar()
            }
        }
        func saveDefault() {
            let path = URL.getDocumentsDirectory().appendingPathComponent(ToolBar.defaultFileName, isDirectory: false)
            self.save(path: path)
        }
    }
}
