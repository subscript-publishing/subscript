//
//  FileTreeModel.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/12/22.
//

import Foundation
import Combine

extension SS1 {
    struct FS {}
}

extension SS1.FS {
    enum FileType: String, Equatable, CaseIterable, Hashable {
        case file
        case folder
    }
    class File: Identifiable, ObservableObject {
        let id: UUID
        let name: String
        let type: FileType
        @Published
        var children: Array<File> = []
        @Published
        var selected: Bool = false
        var isFolder: Bool {
            self.type == .folder
        }
        var isFile: Bool {
            self.type == .file
        }
        init(
            name: String,
            type: FileType,
            children: Array<File> = []
        ) {
            self.id = UUID()
            self.name = name
            self.type = type
            self.children = children
        }
        static func newFolder(
            name: String,
            children: Array<File>
        ) -> File {
            return File.init(name: name, type: FileType.folder, children: children)
        }
        static func newFile(name: String) -> File {
            return File.init(name: name, type: FileType.file, children: [])
        }
    }
}


