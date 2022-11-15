//
//  SubScriptNotebookApp.swift
//  Shared
//
//  Created by Colbyn Wadman on 11/8/22.
//

import SwiftUI

@main
struct SubScriptNotebookApp: App {
    struct TestValue: Identifiable {
        var id: UUID
        var value: Int
    }
    @State private var testFiles: Array<S1.FS.File> = S1.FS.File.sampleData()
    let rootID = UUID()
    @ViewBuilder private var main: some View {
        S1.FS.RootDirectoryViewNew(files: $testFiles)
    }
    var body: some Scene {
//        DocumentGroup(newDocument: SubScriptNotebookDocument()) { file in
//            ContentView(document: file.$document)
//        }
        WindowGroup {
#if os(iOS)
            main
#elseif os(macOS)
            main
                .frame(minWidth: 400, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity, alignment: .center)
#endif
        }
    }
}
