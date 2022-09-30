//
//  Main.swift
//  SubscriptDraw
//
//  Created by Colbyn Wadman on 9/29/22.
//

import SwiftUI
import UniformTypeIdentifiers

fileprivate class OptionalBox<T>: ObservableObject {
    @Published
    var ref: Optional<T> = .none
    var exist: Bool {ref != nil}
}

class FileDataModel: ObservableObject, Codable {
    var canvas: SS.CanvasDataModel = SS.CanvasDataModel()
    @Published
    var filePath: URL? = nil
    
    enum CodingKeys: CodingKey {
        case canvas
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try! container.encode(canvas, forKey: .canvas)
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        canvas = try container.decode(SS.CanvasDataModel.self, forKey: .canvas)
    }
    init() {}
    func save(path: URL) {
        let encoder = PropertyListEncoder()
        let data = try! encoder.encode(self)
        try! data.write(to: path)
    }
    static func load(path: URL) -> Optional<FileDataModel> {
        let decoder = PropertyListDecoder()
        let data = try? Data(contentsOf: path)
        if let data = data {
            return try? decoder.decode(FileDataModel.self, from: data)
        } else {
            return .none
        }
    }
}



@main
struct SubscriptDrawApp: App {
    @StateObject private var document = DrawingDocumentHandle()
    @StateObject private var notebookModel: OptionalBox<FileDataModel> = OptionalBox()
    
    var body: some Scene {
        DocumentGroup(newDocument: document) { file in
            rootView
                .onAppear(perform: load(with: file))
                .navigationViewStyle(StackNavigationViewStyle())
                .navigationBarHidden(true)
        }
    }
    @ViewBuilder private var rootView: some View {
        if notebookModel.ref != nil {
            rootNotebookView()
        } else {
            Text("Loading...")
        }
    }
    
    @ViewBuilder private func rootNotebookView() -> some View {
        NavigationView {
            let view = DrawingEntryPoint(
                canvas: notebookModel.ref!.canvas,
                onSave: { canavs in
                    self.notebookModel.ref!.canvas = canavs
                    self.notebookModel.ref!.save(path: self.notebookModel.ref!.filePath!)
                }
            )
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .edgesIgnoringSafeArea(.all)
#if targetEnvironment(macCatalyst)
            view.padding(.top, 1)
#else
            view
#endif
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .ignoresSafeArea(.container, edges: .all)
        .statusBar(hidden: true)
    }
    
    private func load(with file: FileDocumentConfiguration<DrawingDocumentHandle>) -> () -> () {
        return {
            let notebookFilePath = file.fileURL!
            self.notebookModel.ref = FileDataModel.load(path: file.fileURL!) ?? FileDataModel()
            self.notebookModel.ref!.filePath = notebookFilePath
            if SS.DEBUG_MODE {
                print("[LOADED NOTEBOOK DATA FILE]")
            }
        }
    }
    
    struct DrawingEntryPoint: View {
        @StateObject var canvas: SS.CanvasDataModel
        let onSave: (SS.CanvasDataModel) -> ()
        var body: some View {
            SS.Canvas(
                canvasModel: canvas,
                goBack: {
                    UIApplication.shared.windows
                        .first?
                        .rootViewController?
                        .dismiss(animated: true, completion: nil)
                },
                onSave: {
                    onSave(canvas)
                },
                onCompile: {
                    
                }
            )
                .environment(\.colorScheme, .dark)
        }
    }

}


extension UTType {
    static let subscriptDrawingFilePackageType: UTType = UTType(exportedAs: "app.subscript.ssd1")
}

class DrawingDocumentHandle: FileDocument, ObservableObject {
    static var readableContentTypes: [UTType] {[.subscriptDrawingFilePackageType]}
    init() {
        if SS.DEBUG_MODE {
            print("[init notebook]")
        }
    }
    required init(configuration: ReadConfiguration) throws {
        if SS.DEBUG_MODE {
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
