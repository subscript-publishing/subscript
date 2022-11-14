//
//  SubScriptNotebookApp.swift
//  Shared
//
//  Created by Colbyn Wadman on 11/8/22.
//

import SwiftUI

//fileprivate struct MainTestViewDestination: View {
//    @State private var link1ID = UUID()
//    @State private var page2ID = UUID()
//    
//    @State private var link1AID = UUID()
//    @State private var page2AID = UUID()
//    var body: some View {
//        VStack(alignment: .center, spacing: 10) {
//            Text("Hello World")
//            UX.Nav.PageBuilder()
//                .withTitle(title: "Link 1")
//                .showToolbar(true)
//                .showBackBtn(true)
//                .buildLink(
//                    id: link1ID,
//                    label: {
//                        UX.Sticker.Round {
//                            Text("Link 1")
//                        }
//                    },
//                    destination: { _ in
//                        VStack(alignment: .center, spacing: 10) {
//                            Text("Hello World - From Link 1")
//                            UX.Nav.PageBuilder()
//                                .withTitle(title: "Link 1.A")
//                                .showToolbar(true)
//                                .showBackBtn(true)
//                                .buildLink(
//                                    id: link1AID,
//                                    label: {
//                                        UX.Sticker.Round {
//                                            Text("Link 1.A")
//                                        }
//                                    },
//                                    destination: { _ in
//                                        VStack(alignment: .center, spacing: 10) {
//                                            Text("Hello World - From Link 1.A")
//                                        }
//                                        .padding([.leading, .trailing, .top], 10)
//                                    }
//                                )
//                        }
//                        .padding([.leading, .trailing, .top], 10)
//                    }
//                )
//            UX.Nav.Link(
//                id: page2ID,
//                label: {
//                    UX.Sticker.Round {
//                        Text("Link 2")
//                    }
//                },
//                destination: { _ in
//                    VStack(alignment: .center, spacing: 10) {
//                        Text("Hello World - From Link 2")
//                        UX.Nav.Link(
//                            id: page2AID,
//                            label: {
//                                UX.Sticker.Round {
//                                    Text("Link 2.A")
//                                }
//                            },
//                            destination: { _ in
//                                VStack(alignment: .center, spacing: 10) {
//                                    Text("Hello World - From Link 2.A")
//                                }
//                                .padding([.leading, .trailing, .top], 10)
//                                .uxNavBar(trailing: {
//                                    Text("TODO")
//                                })
//                            }
//                        )
//                    }
//                    .padding([.leading, .trailing, .top], 10)
//                }
//            )
//        }
//        .padding([.leading, .trailing, .top], 10)
//        .uxNavBar(trailing: {
//            Text("TODO")
//        })
//    }
//}

@main
struct SubScriptNotebookApp: App {
    struct TestValue: Identifiable {
        var id: UUID
        var value: Int
    }
    @State private var xs: Array<TestValue> = {
        var xs: [TestValue] = []
        for i in (0...50) {
            xs.append(TestValue(id: UUID(), value: i))
        }
        return xs
    }()
    @State private var testFiles: Array<SS1.FS.File> = SS1.FS.File.sampleData()
//    @ViewBuilder private var content: some View {
//        SS1.FS.RootDirectoryView(files: $testFiles)
//    }
    let rootID = UUID()
    
    @ViewBuilder private func main() -> some View {
        
    }
    @ViewBuilder private var root: some View {
//        let rootPage = UX.Nav.PageBuilder()
//            .withTitle(title: "Child View")
//            .showToolbar(true)
//            .showBackBtn(true)
//            .build(id: rootID, destination: {
//                MainTestViewDestination()
//            })
//        UX.Nav.RootView(page: rootPage)
        SS1.FS.RootDirectoryView(files: $testFiles)
    }
    var body: some Scene {
//        DocumentGroup(newDocument: SubScriptNotebookDocument()) { file in
//            ContentView(document: file.$document)
//        }
        WindowGroup {
#if os(iOS)
            root
#elseif os(macOS)
            root
                .frame(minWidth: 400, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity, alignment: .center)
#endif
        }
    }
}
