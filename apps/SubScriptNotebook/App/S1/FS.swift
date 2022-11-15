//
//  FileTreeModel.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/12/22.
//

import Foundation
import Combine

// MARK: - NAMESPACE -

extension S1 {
    struct FS {}
}

// MARK: - DATA-MODEL -

extension S1.FS {
    final class File: Identifiable, ObservableObject {
        let id: UUID
        var name: String
        let type: FileType
        @Published
        var children: Array<File> = []
        @Published
        var selected: Bool = false
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
    }
}

extension S1.FS.File {
    enum FileType: String, Equatable, CaseIterable, Hashable {
        case page
        case folder
        var fileExtension: FileExtension? {
            switch self {
            case .page: return FileExtension.page
            case .folder: return nil
            }
        }
    }
    enum FileExtension: String, Equatable, CaseIterable, Hashable {
        case page
        var asString: String {
            switch self {
            case .page: return "ss1-page"
            }
        }
    }
}

extension S1.FS {
    struct FilePath {
        var parts: Array<String>
    }
}


// MARK: - INITIALIZER HELPERS -

extension S1.FS.File {
    static func newFolder(
        name: String,
        children: Array<S1.FS.File>
    ) -> S1.FS.File {
        return S1.FS.File.init(name: name, type: FileType.folder, children: children)
    }
    static func newFile(name: String) -> S1.FS.File {
        return S1.FS.File.init(name: name, type: FileType.page, children: [])
    }
    static func initRootFile(children: Array<S1.FS.File>) -> S1.FS.File {
        return S1.FS.File.newFolder(name: "", children: children)
    }
}


// MARK: - FILE PROPERTIES -

extension S1.FS.File {
    var isFolder: Bool { self.type == .folder }
    var fileExtension: FileExtension? { self.type.fileExtension }
    var isFile: Bool { self.type == .page }
    func move(
        targetPath: Array<String>,
        newFiles: Array<S1.FS.File>
    ) -> Bool {
        var targetPath = targetPath
        if self.isFolder && targetPath.first == self.name {
            let _ = targetPath.removeFirst()
            if targetPath.isEmpty {
                self.children.append(contentsOf: newFiles)
                return true
            }
            for child in children {
                if child.name == targetPath.first {
                    return child.move(targetPath: targetPath, newFiles: newFiles)
                }
            }
        }
        return false
    }
}

