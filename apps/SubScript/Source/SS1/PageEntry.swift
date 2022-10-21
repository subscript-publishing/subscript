//
//  PageEntry.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/20/22.
//

import SwiftUI

extension SS1 {
    struct Title: Codable {
        var type: HeadingType = HeadingType.h1
        var text: String = "New Title"
        enum HeadingType: String, CaseIterable, Codable {
            case h1
            case h2
            case h3
            case h4
            case h5
            case h6
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
    
    class PageEntryModel: ObservableObject, Codable {
        @Published var title: Title = Title()
        @Published var canvas: CanvasModel = CanvasModel()
        @Published var type: EntryType = EntryType.title
        
        enum CodingKeys: CodingKey {
            case title, titleOnly, entries
        }
        func encode(to encoder: Encoder) throws {
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try! container.encode(pageTitle, forKey: .pageTitle)
//            try! container.encode(entries, forKey: .entries)
        }
        required init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            pageTitle = try container.decode(String.self, forKey: .pageTitle)
//            entries = try container.decode(Array.self, forKey: .entries)
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
    struct PageEntryView: View {
        @ObservedObject var pageEntryModel: PageEntryModel
        var body: some View {
            Text("View")
        }
    }
}
