//
//  FileTreeUI_New.swift
//  SubScript
//
//  Created by Colbyn Wadman on 11/8/22.
//

import SwiftUI
import Combine

//extension Optional {
//    var asBindingRef: Binding<Optional>
//}
//
fileprivate struct FileSystemModel {
    enum FileTree: Identifiable {
        case file(File)
        case folder(Folder)
        var id: UUID {
            get {
                switch self {
                case .file(let file): return file.id
                case .folder(let folder): return folder.id
                }
            }
        }
        var fileType: FileType {
            get {
                switch self {
                case .file(_): return FileType.file
                case .folder(_): return FileType.folder
                }
            }
        }
        var isFile: Bool {
            get { self.fileType.isFile }
        }
        var isFolder: Bool {
            get { self.fileType.isFolder }
        }
        var fileName: String {
            get {
                switch self {
                case .file(let file): return file.name
                case .folder(let folder): return folder.name
                }
            }
        }
        init(fileName: String) {
            self = FileTree.file(File(name: fileName))
        }
        init(dirName: String, children: Array<FileTree>) {
            self = FileTree.folder(Folder(name: dirName, children: children))
        }
        static func sampleData() -> Array<FileTree> {
            return [
                FileTree.init(dirName: "Physics", children: [
                    FileTree(fileName: "Page1"),
                    FileTree(fileName: "Page2"),
                    FileTree(fileName: "Page3"),
                ]),
                FileTree.init(dirName: "Chemistry", children: [
                    FileTree(fileName: "Page1"),
                    FileTree(fileName: "Page2"),
                ]),
                FileTree.init(dirName: "Biology", children: [
                    FileTree(fileName: "Page1"),
                ]),
            ]
        }
    }
    enum FileType {
        case file
        case folder
        
        var isFile: Bool {
            switch self {
            case .file: return true
            default: return false
            }
        }
        var isFolder: Bool {
            switch self {
            case .folder: return true
            default: return false
            }
        }
    }
    class File: ObservableObject {
        let id: UUID
        let name: String
        init(name: String) {
            self.id = UUID()
            self.name = name
        }
        static func empty() -> File {
            return File(name: "")
        }
    }
    class Folder: ObservableObject {
        let id: UUID
        let name: String
        @Published
        var children: Array<FileTree>
        
        init(name: String, children: Array<FileTree>) {
            self.id = UUID()
            self.name = name
            self.children = children
        }
        static func empty() -> Folder {
            return Folder(name: "", children: [])
        }
    }
}


fileprivate struct FolderToolbarView: View {
    let title: String?
    let onNewFile: (String) -> ()
    let onNewFolder: (String) -> ()
    let lsDir: () -> Array<String>
    @State private var showNewFilePopup: Bool = false
    @State private var showNewFolderPopup: Bool = false
    @State private var newFileName: String = ""
    @State private var newFolderName: String = ""
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder private func popupViewTemplate(
        type: FileSystemModel.FileType,
        titleBinding: Binding<String>,
        onClose: @escaping () -> (),
        onSubmit: @escaping () -> ()
    ) -> some View {
        let checkFileValidity: () -> Bool = {
            var isValid = true
            if titleBinding.wrappedValue.count < 1 {
                isValid = false
            }
            for name in lsDir() {
                if name == titleBinding.wrappedValue {
                    isValid = false
                }
            }
            return isValid
        }
        let onSubmitWrapper = {
            if checkFileValidity() {
                onSubmit()
            }
        }
        VStack(alignment: .center, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                UI.Btn.Rounded(action: onClose) {
                    Text("Close")
                }
                Spacer()
            }
            .padding(10)
            .border(edges: .bottom)
            VStack(alignment: .center, spacing: 10) {
                let validName = checkFileValidity()
                let textColorScheme: UI.ColorMode<UI.LL.Color> = UI.ColorMode(
                    lightUI: validName ? #colorLiteral(red: 0.1447366774, green: 0.1447366774, blue: 0.1447366774, alpha: 1) : UI.LL.Color.red,
                    darkUI: validName ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : UI.LL.Color.red
                )
                let borderColorScheme: UI.ColorMode<UI.LL.Color> = UI.ColorMode(
                    lightUI: validName ? #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1) : UI.LL.Color.red,
                    darkUI: validName ? #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1) : UI.LL.Color.red
                )
                let textColor = textColorScheme.getAsColor(for: colorScheme)
                let borderColor = borderColorScheme.getAsColor(for: colorScheme)
                let title = type == .folder ? "New Folder Name" : "New Page Name"
                TextField(
                    title,
                    text: titleBinding,
                    onEditingChanged: { _ in
                        
                    },
                    onCommit: {
                        onSubmitWrapper()
                    }
                )
                    .textFieldStyle(.plain)
                    .font(.system(size: 20, weight: Font.Weight.medium))
                    .foregroundColor(textColor)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 3.0)
                            .stroke()
                            .foregroundColor(borderColor)
                    )
                    .padding([.leading, .trailing], 5)
                UI.Btn.Rounded(action: onSubmitWrapper) {
                    HStack(alignment: .center, spacing: 10) {
                        Spacer()
                        Text("Submit")
                        Spacer()
                    }
                }
            }
            .padding([.leading, .trailing], 10)
            Spacer()
        }
        .frame(width: 400)
    }
    @ViewBuilder private func newFolderView() -> some View {
        popupViewTemplate(
            type: FileSystemModel.FileType.folder,
            titleBinding: $newFolderName,
            onClose: { showNewFolderPopup = false },
            onSubmit: {
                let nameCopy = newFolderName
                newFolderName = ""
                showNewFolderPopup = false
                self.onNewFolder(nameCopy)
            }
        )
    }
    @ViewBuilder private func newFileView() -> some View {
        popupViewTemplate(
            type: FileSystemModel.FileType.file,
            titleBinding: $newFileName,
            onClose: { showNewFilePopup = false },
            onSubmit: {
                let nameCopy = newFileName
                newFileName = ""
                showNewFilePopup = false
                self.onNewFile(nameCopy)
            }
        )
    }
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            UI.Hacks.BackButton()
            Spacer()
            Group {
                if let title = title {
                    Text(title)
                }
            }
            Spacer()
            UI.Btn.Rounded(action: {showNewFolderPopup = true}) {
                Image(systemName: "folder.badge.plus")
            }
            .popover(isPresented: $showNewFolderPopup, content: newFolderView)
            UI.Btn.Rounded(action: {showNewFilePopup = true}) {
                Image(systemName: "doc.badge.plus")
            }
            .popover(isPresented: $showNewFilePopup, content: newFileView)
        }
        .padding(10)
    }
}

fileprivate struct FileView: View {
    @ObservedObject var file: FileSystemModel.File
    var body: some View {
        Text("TODO")
    }
}
fileprivate struct FolderView: View {
    @ObservedObject var folder: FileSystemModel.Folder
    var body: some View {
        ContentView(title: folder.name, children: $folder.children)
    }
    fileprivate struct ContentView: View {
        let title: String?
        @Binding var children: Array<FileSystemModel.FileTree>
        private func onMove(from source: IndexSet, to destination: Int) {
            children.move(fromOffsets: source, toOffset: destination)
        }
        func onDelete(at offsets: IndexSet) {
            children.remove(atOffsets: offsets)
        }
        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                FolderToolbarView(
                    title: title,
                    onNewFile: { name in
                        let newChild = FileSystemModel.FileTree.init(fileName: name)
                        children.append(newChild)
                    },
                    onNewFolder: { name in
                        let newChild = FileSystemModel.FileTree.init(dirName: name, children: [])
                        children.append(newChild)
                    },
                    lsDir: {
                        var names: Array<String> = []
                        for entry in children {
                            names.append(entry.fileName)
                        }
                        return names
                    }
                )
                List {
                    ForEach(children) { child in
                        let iconName = child.isFolder ? "folder" : "doc.richtext"
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: iconName)
                            Text(child.fileName)
                            Spacer()
                            UI.Hacks.NavigationStackViewLink(
                                destination: {
                                    FileTreeView(fileTree: child)
                                },
                                label: {
                                    Image(systemName: "chevron.forward")
                                }
                            )
                        }
                    }
                    .onDelete(perform: onDelete)
                    .onMove(perform: onMove)
                }
            }
        }
    }
}
fileprivate struct FileTreeView: View {
    let fileTree: FileSystemModel.FileTree
    var body: some View {
        switch self.fileTree {
        case .file(let file): FileView(file: file)
        case .folder(let folder): FolderView(folder: folder)
        }
    }
}

fileprivate struct GitInfoSidebar: View {
    var body: some View {
        Text("TODO")
    }
}

struct DevFileSystemView: View {
    @State private var directory: Array<FileSystemModel.FileTree> = FileSystemModel.FileTree.sampleData()
    var body: some View {
        UI.Hacks.NavigationStackView {
            FolderView.ContentView(title: nil, children: $directory)
        }
    }
}
