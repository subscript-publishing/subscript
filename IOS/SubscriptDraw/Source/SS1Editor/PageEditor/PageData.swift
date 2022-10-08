//
//  File.swift
//  Subscript
//
//  Created by Colbyn Wadman on 3/30/22.
//

import Foundation
import CoreGraphics

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PAGE DATA MODEL
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extension SS1 {
    class PageDataModel: ObservableObject, Codable {
        @Published
        var id: UUID = UUID()
        @Published
        var pageTitle: String = ""
        var pageFileName: String {
            return pageTitle.replacingOccurrences(of: " ", with: "-")
        }
        @Published
        var entries: Array<PageEntry> = [
            PageEntry.newTitleEntry(type: .h1, text: "Hello World"),
            PageEntry.newDrawingEntry(type: .h2, text: "Hello Drawing")
        ]
        
        enum CodingKeys: CodingKey {
            case pageTitle, entries
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try! container.encode(pageTitle, forKey: .pageTitle)
            try! container.encode(entries, forKey: .entries)
        }
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            pageTitle = try container.decode(String.self, forKey: .pageTitle)
            entries = try container.decode(Array.self, forKey: .entries)
        }
        
        init() {}
        init(pageTitle: String, entries: Array<PageEntry>) {
            self.pageTitle = pageTitle
            self.entries = entries
        }
        
        func save(filePath: URL) {
            let encoder = PropertyListEncoder()
            let data = try! encoder.encode(self)
            try! data.write(to: filePath)
        }
        static func load(path: URL) -> Optional<PageDataModel> {
            let decoder = PropertyListDecoder()
            let data = try? Data(contentsOf: path)
            if let data = data {
                return try? decoder.decode(PageDataModel.self, from: data)
            } else {
                return .none
            }
        }
        
        
        func addEntryWithAutoType(newEntry _newEntry: PageEntry, index: Int) {
            var newEntry = _newEntry
            for (_, entry) in entries.enumerated().filter({$0.0 < index}).reversed() {
                if entry.type.isTitle && newEntry.type.isDrawing {
                    newEntry.title.type = entry.title.type.decremented
                    break
                } else if entry.type.isTitle && newEntry.type.isTitle {
                    newEntry.title.type = entry.title.type
                    break
                }
            }
            self.entries.insert(newEntry, at: index)
        }
//        func toHTMLPage(notebookTitle: String) -> String {
//            var content: String = ""
//            var tocChildren = ""
//            for entry in entries {
//                let section = entry.compileToHTMLSection()
//                content += section
//                tocChildren += entry.title.toHTMLToc(indexPreview: false)
//            }
//            let pageFilePathStr = "\(pageFileName).html"
//            let nav = "<nav><h1><a href=\"index.html\">\(notebookTitle)</a></h1><span>•</span><h1><a href=\"\(pageFilePathStr)\">\(pageTitle)</a></h1></nav>"
//            let toc = "<div toc>\(nav)<h1>Table Of Contents</h1><ul>\(tocChildren)</ul></div>"
//            let article = "<article>\(content)</article>"
//            let body = "<body>\(toc)<main>\(article)</main></body>"
//            return SS.Compiler.pack(title: pageTitle, body: body)
//        }
        static func testData() -> PageDataModel {
            let page = PageDataModel(
                pageTitle: "Math",
                entries: [
                    PageEntry.newTitleEntry(type: .h1, text: "Hello World"),
                    PageEntry.newTitleEntry(type: .h2, text: "Subsection Text"),
                    PageEntry.newTitleEntry(type: .h3, text: "Subsection Text"),
                    PageEntry.newTitleEntry(type: .h4, text: "Subsection Text"),
                    PageEntry.newTitleEntry(type: .h5, text: "Subsection Text"),
                    PageEntry.newTitleEntry(type: .h6, text: "Subsection Text"),
                    PageEntry.newTitleEntry(type: .h1, text: "Math"),
                    PageEntry.newTitleEntry(type: .h2, text: "Algebra"),
                    PageEntry.newDrawingEntry(type: .h3, text: "Algebra Formulas"),
                    PageEntry.newTitleEntry(type: .h3, text: "Linear Algebra"),
                    PageEntry.newTitleEntry(type: .h2, text: "Pre Calculus"),
                    PageEntry.newTitleEntry(type: .h3, text: "Limits"),
                    PageEntry.newDrawingEntry(type: .h4, text: "Limit Formulas"),
                    PageEntry.newTitleEntry(type: .h2, text: "Calculus"),
                    PageEntry.newTitleEntry(type: .h3, text: "Derivatives"),
                    PageEntry.newDrawingEntry(type: .h4, text: "Derivative Formulas"),
                    PageEntry.newTitleEntry(type: .h3, text: "Integrals"),
                    PageEntry.newDrawingEntry(type: .h4, text: "Integral Formulas"),
                ]
            )
            return page
        }
        static func testData2() -> PageDataModel {
            let page = PageDataModel(
                pageTitle: "Biology",
                entries: [
                    PageEntry.newTitleEntry(type: .h1, text: "Hello World"),
                    PageEntry.newTitleEntry(type: .h2, text: "Subsection Text"),
                    PageEntry.newTitleEntry(type: .h3, text: "Subsection Text"),
                    PageEntry.newTitleEntry(type: .h4, text: "Subsection Text"),
                    PageEntry.newTitleEntry(type: .h5, text: "Subsection Text"),
                    PageEntry.newTitleEntry(type: .h6, text: "Subsection Text"),
                    PageEntry.newTitleEntry(type: .h1, text: "Biology"),
                    PageEntry.newDrawingEntry(type: .h2, text: "Class 2: What is Life?"),
                    PageEntry.newDrawingEntry(type: .h2, text: "Class 3: Chemistry of Life"),
                    PageEntry.newDrawingEntry(type: .h2, text: "Class 4: Water"),
                    PageEntry.newDrawingEntry(type: .h2, text: "Class 5: pH and Building blocks of life"),
                    PageEntry.newDrawingEntry(type: .h2, text: "Class 6: Nucleic Acids"),
                    PageEntry.newDrawingEntry(type: .h2, text: "Class 7 Proteins- Structure relates to Functions"),
                    PageEntry.newDrawingEntry(type: .h2, text: "Class 8: Enzymes"),
                    PageEntry.newDrawingEntry(type: .h2, text: "Class 9: Biomolecules Capstone"),
                ]
            )
            return page
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// BASICS
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extension SS1 {
    struct PageEntry: Identifiable, Codable {
        var id: UUID = UUID()
        var type: EntryType
        var title: Title = Title()
        var drawing: CanvasDataModel = CanvasDataModel()
//        func compileToHTMLSection() -> String {
//            let title = title.toHTMLHeading()
//            let svg = drawing.toSVG()
//            let section = "<section>\(title)\(svg)</section>"
//            return section
//        }
        static func newTitleEntry() -> PageEntry {
            PageEntry(type: EntryType.title)
        }
        static func newTitleEntry(type: Title.HeadingType, text: String) -> PageEntry {
            PageEntry(type: EntryType.title, title: Title(type: type, text: text))
        }
        static func newDrawingEntry(type: Title.HeadingType, text: String) -> PageEntry {
            var entry = PageEntry(type: EntryType.drawing)
            entry.title.type = type
            entry.title.text = text
            return entry
        }
        enum EntryType: String, Codable {
            case title
            case drawing
            
            var isTitle: Bool {
                switch self {
                case.title: return true
                default: return false
                }
            }
            
            var isDrawing: Bool {
                switch self {
                case.drawing: return true
                default: return false
                }
            }
        }
    }
    
    struct Title: Codable {
        var type: HeadingType = HeadingType.h1
        var text: String = "New Title"
        func toHTMLHeading() -> String {
            let hrefId = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let attrs = "id=\"\(hrefId)\""
            let openTag = type.openTag(attrs: attrs)
            return "\(openTag)\(text)\(type.closeTag)"
        }
        func toHTMLToc(indexPreview: Bool, link: String? = nil) -> String {
            let attrs = "heading=\"\(type.asString.lowercased())\""
            let child: String
            if let link = link {
                child = "<a href=\"\(link)\">\(text)</a>"
            } else {
                let hrefId = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                child = "<a href=\"#\(hrefId)\">\(text)</a>"
            }
            if indexPreview {
                return "<li sublisting \(attrs)>\(child)</li>"
            } else {
                return "<li page-entry \(attrs)>\(child)</li>"
            }
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
                case .h2: return 20
                case .h3: return 30
                case .h4: return 40
                case .h5: return 50
                case .h6: return 60
                }
            }
            var decremented: HeadingType {
                switch self {
                case .h1: return HeadingType.h2
                case .h2: return HeadingType.h3
                case .h3: return HeadingType.h4
                case .h4: return HeadingType.h5
                case .h5: return HeadingType.h6
                case .h6: return HeadingType.h6
                }
            }
            func openTag(attrs: String) -> String {
                switch self {
                case .h1: return "<h1 \(attrs)>"
                case .h2: return "<h2 \(attrs)>"
                case .h3: return "<h3 \(attrs)>"
                case .h4: return "<h4 \(attrs)>"
                case .h5: return "<h5 \(attrs)>"
                case .h6: return "<h6 \(attrs)>"
                }
            }
            var closeTag: String {
                switch self {
                case .h1: return "</h1>"
                case .h2: return "</h2>"
                case .h3: return "</h3>"
                case .h4: return "</h4>"
                case .h5: return "</h5>"
                case .h6: return "</h6>"
                }
            }
        }
    }
}

