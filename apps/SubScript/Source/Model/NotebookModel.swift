//
//  Notebook.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/31/22.
//

import Foundation

extension SS1 {
    final class NotebookModel: ObservableObject, Codable {
        
    }
}

extension SS1 {
    final class PageModel: ObservableObject, Codable {
        @Published
        var id: UUID = UUID()
        @Published
        var entries: Array<PageEntryModel> = [
            PageEntryModel.init(h1: "Hello World"),
            PageEntryModel.init(h2: "Sub-Title"),
            PageEntryModel.init(h3: "Some Drawing"),
            PageEntryModel.init(drawings: [
                CanvasModel()
            ]),
        ]
        init() {}
        init(entries: Array<PageEntryModel>) {
            self.entries = entries
        }
        enum CodingKeys: CodingKey {
            case id, entries
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try! container.encode(id, forKey: .id)
            try! container.encode(entries, forKey: .entries)
        }
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            entries = try container.decode(Array.self, forKey: .entries)
        }
        func insert(entry: PageEntryModel, after: Int?) {
            if let after = after {
                let nextIndex = after + 1
                if nextIndex <= self.entries.count {
                    self.entries.insert(entry, at: nextIndex)
                } else {
                    self.entries.append(entry)
                }
            } else {
                self.entries.append(entry)
            }
        }
    }
}

extension SS1 {
    final class PageEntryModel: ObservableObject, Codable, Identifiable {
        @Published var id: UUID = UUID()
        @Published var type: EntryType = EntryType.drawing
        @Published var heading: Heading = Heading()
        @Published var drawings: Array<CanvasModel> = [
            CanvasModel()
        ]
        init(drawings: Array<CanvasModel>) {
            self.heading = Heading()
            self.drawings = drawings
            self.type = EntryType.drawing
        }
        init(h1 text: String) {
            self.heading = Heading(heading: .h1, text: text)
            self.drawings = []
            self.type = EntryType.heading
        }
        init(h2 text: String) {
            self.heading = Heading(heading: .h2, text: text)
            self.drawings = []
            self.type = EntryType.heading
        }
        init(h3 text: String) {
            self.heading = Heading(heading: .h3, text: text)
            self.drawings = []
            self.type = EntryType.heading
        }
        init(title: Heading) {
            self.heading = title
            self.drawings = []
            self.type = EntryType.heading
        }
        enum CodingKeys: CodingKey {
            case id, type, heading, drawings
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try! container.encode(id, forKey: .id)
            try! container.encode(type, forKey: .type)
            try! container.encode(heading, forKey: .heading)
            try! container.encode(drawings, forKey: .drawings)
        }
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            type = try container.decode(EntryType.self, forKey: .type)
            heading = try container.decode(Heading.self, forKey: .heading)
            drawings = try container.decode(Array.self, forKey: .drawings)
        }
        
        enum EntryType: String, Codable {
            case heading
            case drawing
            
            var isHeading: Bool {
                switch self {
                case .heading: return true
                default: return false
                }
            }
            
            var isDrawing: Bool {
                switch self {
                case .drawing: return true
                default: return false
                }
            }
        }
    }
}

extension SS1 {
    struct Heading: Codable {
        var type: HeadingType = HeadingType.h1
        var text: String = "New Title"
        init() {
            self.type = .h1
            self.text = ""
        }
        init(heading: HeadingType, text: String) {
            self.type = heading
            self.text = text
        }
        init(h1 text: String) {
            self.init(heading: .h1, text: text)
        }
        init(h2 text: String) {
            self.init(heading: .h2, text: text)
        }
        init(h3 text: String) {
            self.init(heading: .h3, text: text)
        }
        init(h4 text: String) {
            self.init(heading: .h4, text: text)
        }
        init(h5 text: String) {
            self.init(heading: .h5, text: text)
        }
        init(h6 text: String) {
            self.init(heading: .h6, text: text)
        }
        enum HeadingType: String, CaseIterable, Codable {
            case h1
            case h2
            case h3
            case h4
            case h5
            case h6
            var asString: String {
                switch self {
                case .h1: return "H1"
                case .h2: return "H2"
                case .h3: return "H3"
                case .h4: return "H4"
                case .h5: return "H5"
                case .h6: return "H6"
                }
            }
            var defaultTextSize: CGFloat {
                switch self {
                case .h1: return 32
                case .h2: return 28
                case .h3: return 24
                case .h4: return 20
                case .h5: return 16
                case .h6: return 12
                }
            }
            var defaultLeadingMargin: CGFloat {
                switch self {
                case .h1: return 0
                case .h2: return 30
                case .h3: return 60
                case .h4: return 90
                case .h5: return 100
                case .h6: return 110
                }
            }
        }
    }
}

