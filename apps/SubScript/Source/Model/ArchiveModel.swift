//
//  ArchiveModel.swift
//  SubScript
//
//  Created by Colbyn Wadman on 11/7/22.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let ss1NotebookPackageType: UTType = UTType(exportedAs: "app.subscript.ss1-notebook")
}

extension SS1 {
    struct Archive {
        struct FileItem: Codable {
            var id: UUID = UUID()
            var name: String
            var type: FileType
            enum FileType: String, Codable {
                case folder
                case page
            }
        }
        class NotebookFileDocument: FileDocument, ObservableObject {
            static var readableContentTypes: [UTType] {[.ss1NotebookPackageType]}
            init() {
//                if SS1.DEBUG_MODE {
//                    print("[INFO] CompositionFileDocument.init()")
//                }
            }
            required init(configuration: ReadConfiguration) throws {
//                if SS1.DEBUG_MODE {
//                    print("[INFO] CompositionFileDocument.init(configuration)")
//                }
            }
            func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
                if let existingFile = configuration.existingFile {
                    assert(existingFile.isDirectory)
                    return existingFile
                }
                let rootDirectory = FileWrapper(directoryWithFileWrappers: [:])
                assert(rootDirectory.isDirectory)
                return rootDirectory
            }
        }
        static func getFiles(path: String) {
            
        }
    }
}
