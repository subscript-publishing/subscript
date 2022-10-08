//
//  SS.swift
//  SubscriptTablet
//
//  Created by Colbyn Wadman on 9/23/22.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let ss1DrawingFilePackageType: UTType = UTType(exportedAs: "app.subscript.ss1-drawing")
    static let ss1CompositionFilePackageType: UTType = UTType(exportedAs: "app.subscript.ss1-composition")
}


/// Subscript Version 1 Namespace
struct SS1 {
    static let DEBUG_MODE: Bool = false
    struct Drawing {}

    /// Drawing only file document.
    class DrawingFileDocument: FileDocument, ObservableObject {
        static var readableContentTypes: [UTType] {[.ss1DrawingFilePackageType]}
        init() {
            if SS1.DEBUG_MODE {
                print("[init notebook]")
            }
        }
        required init(configuration: ReadConfiguration) throws {
            if SS1.DEBUG_MODE {
                print("[load notebook]")
            }
        }
        func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
            if let existingFile = configuration.existingFile {
                assert(existingFile.isRegularFile)
                return existingFile
            }
            let rootDirectory = FileWrapper(regularFileWithContents: Data())
            assert(rootDirectory.isRegularFile)
            return rootDirectory
        }
    }
    
    /// Composition file document (drawings are organized into sections with HTML-like headings).
    class CompositionFileDocument: FileDocument, ObservableObject {
        static var readableContentTypes: [UTType] {[.ss1CompositionFilePackageType]}
        init() {
            if SS1.DEBUG_MODE {
                print("[init notebook]")
            }
        }
        required init(configuration: ReadConfiguration) throws {
            if SS1.DEBUG_MODE {
                print("[load notebook]")
            }
        }
        func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
            if let existingFile = configuration.existingFile {
                assert(existingFile.isRegularFile)
                return existingFile
            }
            let rootDirectory = FileWrapper(regularFileWithContents: Data())
            assert(rootDirectory.isRegularFile)
            return rootDirectory
        }
    }
    
    struct CompositionEditorScene: Scene {
        @StateObject private var document = SS1.CompositionFileDocument()
        @StateObject private var runtimeModel: SS1.RuntimeDataModel = SS1.RuntimeDataModel.loadDefault()
        @StateObject private var pageModel: SS1.PageDataModel = SS1.PageDataModel()
        @State private var documentFilePath: Optional<URL> = .none
        @State private var loaded: Bool = false
        private func load(with file: FileDocumentConfiguration<SS1.CompositionFileDocument>) -> () -> () {
            documentFilePath = file.fileURL!
            return {
                if let model = SS1.PageDataModel.load(path: file.fileURL!) {
                    self.pageModel.entries = model.entries
                }
                self.loaded = true
            }
        }
        var body: some Scene {
            DocumentGroup(newDocument: document) { file in
                NavigationView {
                    if loaded {
                        SS1.PageEditor(
                            runtimeModel: runtimeModel,
                            pageModel: pageModel,
                            goBack: {
                                UIApplication.shared.windows
                                    .first?
                                    .rootViewController?
                                    .dismiss(animated: true, completion: nil)
                            },
                            onSave: {
                                self.runtimeModel.saveDefault()
                                self.pageModel.save(filePath: documentFilePath!)
                            }
                        )
                            .navigationViewStyle(StackNavigationViewStyle())
                            .navigationBarTitle("")
                            .navigationBarHidden(true)
                    } else {
                        Text("Loading...")
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .edgesIgnoringSafeArea(.all)
                .onAppear(perform: self.load(with: file))
            }
        }
    }

    struct DrawingEditorScene: Scene {
        @StateObject private var document = SS1.DrawingFileDocument()
        @StateObject private var runtimeModel: SS1.RuntimeDataModel = SS1.RuntimeDataModel.loadDefault()
        @StateObject private var canvasModel: SS1.CanvasDataModel = SS1.CanvasDataModel()
        @State private var documentFilePath: Optional<URL> = .none
        @State private var loaded: Bool = false
        @State private var displayStyle: ColorScheme = ColorScheme.dark
        private func load(with file: FileDocumentConfiguration<SS1.DrawingFileDocument>) -> () -> () {
            documentFilePath = file.fileURL!
            return {
                if case let .some(model) = SS1.CanvasDataModel.load(filePath: file.fileURL!) {
                    self.canvasModel.entries = model.entries
                }
                self.loaded = true
            }
        }
        var body: some Scene {
            DocumentGroup(newDocument: document) { file in
                NavigationView {
                    if loaded {
                        SS1.CanvasEditor(
                            displayStyle: $displayStyle,
                            canvasModel: canvasModel,
                            runtimeModel: runtimeModel,
                            goBack: {
                                UIApplication.shared.windows
                                    .first?
                                    .rootViewController?
                                    .dismiss(animated: true, completion: nil)
                            },
                            onSave: {
                                self.runtimeModel.saveDefault()
                                self.canvasModel.save(filePath: documentFilePath!)
                            }
                        )
                            .navigationViewStyle(StackNavigationViewStyle())
                            .navigationBarTitle("")
                            .navigationBarHidden(true)
                    } else {
                        Text("Loading...")
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .edgesIgnoringSafeArea(.all)
                .onAppear(perform: self.load(with: file))
            }
        }
    }
}
