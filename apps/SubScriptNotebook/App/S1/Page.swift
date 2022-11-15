//
//  Page.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/15/22.
//

import Foundation

// MARK: - DATA MODEL -

extension S1 {
    final class Page: ObservableObject, Identifiable {
        @Published var id: UUID = UUID()
        @Published var sections: Array<SectionEntry> = []
    }
}

extension S1.Page {
    final class SectionEntry: ObservableObject, Identifiable {
        @Published var id: UUID = UUID()
        @Published var type: SectionType
        @Published var heading: Heading = Heading()
        @Published var drawing: Array<Canvas> = []
        init(heading: Heading) {
            self.type = SectionType.heading
            self.heading = heading
        }
        init(drawing: Array<Canvas>) {
            self.type = SectionType.drawing
            self.drawing = drawing
        }
    }
}

extension S1.Page {
    enum SectionType: String, Codable, Equatable {
        case heading, drawing, include
        var isHeading: Bool { self == .heading }
        var isDrawing: Bool { self == .drawing }
    }
}

extension S1.Page {
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
    }
}

extension S1.Page.Heading {
    enum HeadingType: String, CaseIterable, Codable, Equatable {
        case h1, h2, h3, h4, h5, h6
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

extension S1.Page {
    final class Canvas: ObservableObject, Identifiable {
        @Published var id = UUID.init()
        @Published var height: CGFloat = 200
        @Published var visible: Bool = true
//        var pointer: SSRootScenePointer = root_scene_new()
    }
}


// MARK: - INITIALIZER HELPERS -

//extension S1.Page.Entry {
//
//}

