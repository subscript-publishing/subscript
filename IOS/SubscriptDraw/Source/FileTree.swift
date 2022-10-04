//
//  FileTree.swift
//  SubscriptDraw
//
//  Created by Colbyn Wadman on 9/29/22.
//

import SwiftUI

private struct FileTree: Identifiable {
    let id = UUID()
    let name: String
    var children: Array<FileTree> = []
    let fileType: FileType
    enum FileType {
        case folder
        case drawingFile
    }
    
    init(drawingFileName: String) {
        self.name = drawingFileName
        self.fileType = .drawingFile
    }
    init(folderName: String, children: Array<FileTree>) {
        self.name = folderName
        self.fileType = .folder
        self.children = children
    }
    
    static func sample() -> Array<FileTree> {
        [
            FileTree(folderName: "physics", children: [
                FileTree(folderName: "1d-motion", children: [
                    
                ]),
                FileTree(folderName: "2d-motion", children: [
                    
                ]),
                FileTree(folderName: "forces-newtons-laws", children: [
                    FileTree(folderName: "inclined-planes-friction", children: [
                        
                    ]),
                    FileTree(folderName: "balanced-unbalanced-forces", children: [
                        
                    ]),
                    FileTree(folderName: "newton-laws-motion", children: [
                        
                    ]),
                    FileTree(folderName: "normal-contact-force", children: [
                        
                    ]),
                    FileTree(folderName: "tension", children: [
                        
                    ]),
                ]),
            ]),
            FileTree(folderName: "math", children: [
                FileTree(folderName: "algebra", children: [
                    
                ]),
                FileTree(folderName: "trig", children: [
                    
                ]),
            ]),
            FileTree(folderName: "chem", children: [
                
            ]),
            FileTree.init(drawingFileName: "sample.ss-drawing"),
        ]
    }
}

private struct FileTreeView: View {
    var path: Array<String> = []
    @Binding var fileTree: Array<FileTree>
    @Binding var navToggle: Bool
    private var columns: [GridItem] {
        Array(repeating: .init(.adaptive(minimum: 400)), count: 2)
    }
    @State private var showNewFolderPopup: Bool = false
    @State private var showNewDrawingPopup: Bool = false
    @State private var newFolderText: String = ""
    @State private var newDrawingText: String = ""
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            if !path.isEmpty {
                Divider()
                HStack(alignment: .center, spacing: 10) {
                    Button(
                        action: {
                            navToggle.toggle()
                        },
                        label: {
                            Image(systemName: "chevron.backward")
                        }
                    )
                    Spacer()
                    Text(path.joined(separator: "/"))
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    Spacer()
                }
                .padding([.leading, .trailing], 20)
                Divider()
            }
            buttons
            Divider()
            List {
                ForEach($fileTree) { item in
                    ItemView(path: path, item: item)
                }
            }
        }
        .padding(.top, path.isEmpty ? 10 : 0)
    }
    @ViewBuilder private var buttons: some View {
        HStack(alignment: .center, spacing: 10) {
            Button(
                action: {
                    showNewFolderPopup = true
                },
                label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: "folder.badge.plus")
                        Text("New Folder")
                    }
                    .popover(
                        isPresented: $showNewFolderPopup,
                        content: {
                            newResource(
                                label: "New folder",
                                ext: .none,
                                text: $newFolderText,
                                onClick: {
                                    if newFolderText.isEmpty {
                                        return
                                    }
                                    showNewFolderPopup = false
                                    let newFile = FileTree.init(
                                        folderName: newFolderText,
                                        children: []
                                    )
                                    fileTree.append(newFile)
                                    newFolderText = ""
                                }
                            )
                        }
                    )
                }
            )
            Spacer()
            Button(
                action: {
                    showNewDrawingPopup = true
                },
                label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: "rectangle.stack.badge.plus")
                        Text("New Drawing")
                    }
                    .popover(
                        isPresented: $showNewDrawingPopup,
                        content: {
                            newResource(
                                label: "New drawing",
                                ext: ".ss-drawing",
                                text: $newDrawingText,
                                onClick: {
                                    if newDrawingText.isEmpty {
                                        return
                                    }
                                    showNewDrawingPopup = false
                                    let fileName = "\(newDrawingText).ss-drawing"
                                    let newFile = FileTree.init(drawingFileName: fileName)
                                    fileTree.append(newFile)
                                    newDrawingText = ""
                                }
                            )
                        }
                    )
                }
            )
        }
        .padding([.leading, .trailing], 20)
    }
    @ViewBuilder private func newResource(
        label: String,
        ext: Optional<String>,
        text: Binding<String>,
        onClick: @escaping () -> ()
    ) -> some View {
        VStack(alignment: .center, spacing: 20) {
            HStack(alignment: .center, spacing: 5) {
                TextField(label, text: text)
                    .autocapitalization(UITextAutocapitalizationType.none)
                    .disableAutocorrection(true)
                    .font(Font.system(size: 25, weight: Font.Weight.light, design: Font.Design.monospaced))
                if let ext = ext  {
                    Text(ext)
                }
            }
            Button(
                action: onClick,
                label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: "plus")
                        Spacer()
                        Text("Create")
                    }
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                }
            )
        }
        .padding(20)
        .frame(minWidth: 500)
    }
    struct FolderView: View {
        let path: Array<String>
        @Binding var item: FileTree
        @State private var navToggle: Bool = false
        var body: some View {
            NavigationLink(
                isActive: $navToggle,
                destination: {
                    var subPath = path
                    let _ = subPath.append(item.name)
                    FileTreeView(path: subPath, fileTree: $item.children, navToggle: $navToggle)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarHidden(true)
                },
                label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: "folder")
                        Text(item.name)
                        Spacer()
                    }
                    .font(.system(size: 20, weight: Font.Weight.light, design: Font.Design.monospaced))
                }
            )
        }
    }
    struct DrawingFileView: View {
        let path: Array<String>
        @Binding var item: FileTree
        @State private var navToggle: Bool = false
        @State private var canvasModel = SS.CanvasDataModel()
        @StateObject private var runtimeModel = SS.RuntimeDataModel()
        var body: some View {
            NavigationLink(
                isActive: $navToggle,
                destination: {
                    SS.Canvas(
                        canvasModel: canvasModel,
                        runtimeModel: runtimeModel,
                        goBack: {
                            navToggle.toggle()
                        },
                        onSave: {
                            
                        },
                        onCompile: {
                            
                        }
                    )
                        .environment(\.colorScheme, .dark)
                },
                label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: "doc")
                        Text(item.name)
                        Spacer()
                    }
                    .font(.system(size: 20, weight: Font.Weight.light, design: Font.Design.monospaced))
                }
            )
        }
    }
    struct ItemView: View {
        let path: Array<String>
        @Binding var item: FileTree
        var body: some View {
            if item.fileType == .folder {
                FolderView(path: path, item: $item)
            } else if item.fileType == .drawingFile {
                DrawingFileView(path: path, item: $item)
            }
        }
    }
}

struct FileTreeEntrypoint: View {
    @State private var fileTree: Array<FileTree> = FileTree.sample()
    var body: some View {
        NavigationView {
            FileTreeView(fileTree: $fileTree, navToggle: Binding.constant(true))
                .navigationBarHidden(true)
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
}

