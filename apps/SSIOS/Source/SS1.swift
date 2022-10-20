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
    struct StaticSettings {
        struct Canvas {
            static let ignoreSafeAreas: Bool = true
        }
        
        struct DarkMode {
            struct Page {
                static let BG = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
                static let HEADER_BG = Color(#colorLiteral(red: 0.1848134301, green: 0.1951491004, blue: 0.234029349, alpha: 1))
            }
            struct Canvas {
                static let BG: Color = Color(#colorLiteral(red: 0.1339184344, green: 0.1339184344, blue: 0.1339184344, alpha: 1))
                /// In between entries
                static let BG2: Color = Color(#colorLiteral(red: 0.1999768615, green: 0.1999768615, blue: 0.1999768615, alpha: 1))
                
//                static let BG: Color = Color(#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1))
//                /// In between entries
//                static let BG2: Color = Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
            }
        }
        struct LightMode {
            struct Page {
                static let BG = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                static let HEADER_BG = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            }
            struct Canvas {
                static let BG: Color = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                /// In between entries
                static let BG2: Color = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            }
        }
    }
    struct Drawing {}

    /// Drawing only file document.
    class DrawingFileDocument: FileDocument, ObservableObject {
        static var readableContentTypes: [UTType] {[.ss1DrawingFilePackageType]}
        init() {
            if SS1.DEBUG_MODE {
                print("[INFO] DrawingFileDocument.init()")
            }
        }
        required init(configuration: ReadConfiguration) throws {
            if SS1.DEBUG_MODE {
                print("[INFO] DrawingFileDocument.init(configuration)")
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
                print("[INFO] CompositionFileDocument.init()")
            }
        }
        required init(configuration: ReadConfiguration) throws {
            if SS1.DEBUG_MODE {
                print("[INFO] CompositionFileDocument.init(configuration)")
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
        @State private var documentFilePath: URL? = nil
        @State private var loaded: Bool = false
        @State private var displayStyle: ColorScheme = ColorScheme.dark
        private func load(with file: FileDocumentConfiguration<SS1.CompositionFileDocument>) -> () -> () {
            return {
                if documentFilePath != nil {
                    // DO SOMETHING TO TRY TO FORCE SWIFTUI TO RE-FRESH
                    self.pageModel.entries = []
                    self.pageModel.pageTitle = ""
                    runtimeModel.objectWillChange.send()
                    pageModel.objectWillChange.send()
                }
                documentFilePath = file.fileURL!
                if let model = SS1.PageDataModel.load(path: file.fileURL!) {
                    print("model.entries [\(model.pageTitle)]: \(model.entries.count)")
                    self.pageModel.entries = model.entries
                    self.pageModel.pageTitle = model.pageTitle
                    runtimeModel.objectWillChange.send()
                    pageModel.objectWillChange.send()
                } else {
                    if SS1.DEBUG_MODE {
                        print("[ERROR] Page Model Load Failed")
                    }
                }
                self.loaded = true
            }
        }
        private func getWindow() -> UIWindow? {
            return UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow})
                .first
        }
        private func toggleColorScheme() {
            switch self.displayStyle {
            case .light:
                displayStyle = .dark
            case .dark:
                displayStyle = .light
            default: ()
            }
            self.syncColorScheme()
        }
        private func syncColorScheme() {
            let defaultWindow = UIApplication.shared.windows.first!
            let keyWindow = getWindow() ?? defaultWindow
            switch self.displayStyle {
            case .light:
                keyWindow.overrideUserInterfaceStyle = .light
            case .dark:
                keyWindow.overrideUserInterfaceStyle = .dark
            default: ()
            }
        }
        @ViewBuilder private func entrypoint(
            file: FileDocumentConfiguration<SS1.CompositionFileDocument>
        ) -> some View {
            Group {
                if loaded {
                    SS1.PageEditor(
                        runtimeModel: runtimeModel,
                        pageModel: pageModel,
                        toggleColorScheme: toggleColorScheme,
                        goBack: {
                            self.pageModel.save(filePath: documentFilePath!)
                            self.runtimeModel.saveDefault()
                            if case let .some(window) = self.getWindow() {
                                window.rootViewController?.dismiss(animated: true, completion: nil)
                            }
//                            UIApplication.shared.windows
//                                .first?
//                                .rootViewController?
//                                .dismiss(animated: true, completion: nil)
                        },
                        onSave: {
                            if SS1.DEBUG_MODE {
                                print("[INFO] SAVING DOCUMENT")
                            }
                            self.runtimeModel.saveDefault()
                            self.pageModel.save(filePath: documentFilePath!)
                        }
                    )
                } else {
                    Text("Loading...").onAppear(perform: {
                        if loaded == true {
                            if SS1.DEBUG_MODE {
                                print("[INFO] DATA LOADED BUT VIEW WAS NOT UPDATED")
                            }
                            // DO SOMETHING TO TRY TO FORCE SWIFTUI TO RE-FRESH
                            toggleColorScheme()
                            toggleColorScheme()
                        }
                    })
                }
            }
        }
        var body: some Scene {
            DocumentGroup(newDocument: document) { file in
                entrypoint(file: file)
                    .colorScheme(displayStyle)
                    .navigationViewStyle(StackNavigationViewStyle())
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .environment(\.colorScheme, displayStyle)
                    .preferredColorScheme(displayStyle)
                    .colorScheme(displayStyle)
                    .onAppear(perform: self.load(with: file))
                    .onAppear(perform: self.syncColorScheme)
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
            return {
                if documentFilePath != nil {
                    // DO SOMETHING TO TRY TO FORCE SWIFTUI TO RE-FRESH
                    self.canvasModel.entries = SS1.CanvasDataModel().entries
                    runtimeModel.objectWillChange.send()
                    canvasModel.objectWillChange.send()
                }
                documentFilePath = file.fileURL!
                if case let .some(model) = SS1.CanvasDataModel.load(filePath: file.fileURL!) {
                    self.canvasModel.entries = model.entries
                }
                self.loaded = true
            }
        }
        private func getWindow() -> UIWindow? {
            return UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow})
                .first
        }
        private func toggleColorScheme() {
            switch self.displayStyle {
            case .light:
                displayStyle = .dark
            case .dark:
                displayStyle = .light
            default: ()
            }
            self.syncColorScheme()
        }
        private func syncColorScheme() {
            let keyWindow = getWindow()!
            switch self.displayStyle {
            case .light:
                keyWindow.overrideUserInterfaceStyle = .light
            case .dark:
                keyWindow.overrideUserInterfaceStyle = .dark
            default: ()
            }
        }
        @ViewBuilder private var entrypoint: some View {
            SS1.CanvasEditor(
                title: Binding.constant(SS1.Title()),
                displayTitle: false,
                canvasModel: canvasModel,
                runtimeModel: runtimeModel,
                toggleColorScheme: toggleColorScheme,
                goBack: {
                    self.canvasModel.save(filePath: documentFilePath!)
                    self.runtimeModel.saveDefault()
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
        }
        var body: some Scene {
            DocumentGroup(newDocument: document) { file in
                NavigationView {
                    entrypoint
                        .onAppear(perform: self.load(with: file))
                        .onAppear(perform: self.syncColorScheme)
                        .environment(\.colorScheme, displayStyle)
                        .preferredColorScheme(displayStyle)
                        .colorScheme(displayStyle)
                        .navigationViewStyle(StackNavigationViewStyle())
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .navigationBarBackButtonHidden(true)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationViewStyle(StackNavigationViewStyle())
                }
                .environment(\.colorScheme, displayStyle)
                .preferredColorScheme(displayStyle)
                .colorScheme(displayStyle)
                .navigationViewStyle(StackNavigationViewStyle())
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}
