//
//  FileTreeUI.swift
//  SubScript
//
//  Created by Colbyn Wadman on 11/7/22.
//

import SwiftUI

fileprivate struct FileEntry: Identifiable {
    var id: UUID = UUID()
    var name: String
    var type: FileType
    
    static func newPage(name: String) -> FileEntry {
        return FileEntry(id: UUID(), name: name, type: FileType.page)
    }
    static func newFolder(name: String) -> FileEntry {
        return FileEntry(id: UUID(), name: name, type: FileType.folder)
    }
    
    enum FileType {
        case page
        case folder
    }
}

fileprivate struct FileToolbarView: View {
    let parent: Array<String>
    @Binding var files: Array<FileEntry>
    @State private var showNewFilePopup: Bool = false
    @State private var showNewFolderPopup: Bool = false
    @State private var newFileName: String = ""
    @State private var newFolderName: String = ""
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder private func popupViewTemplate(
        type: FileEntry.FileType,
        titleBinding: Binding<String>,
        onClose: @escaping () -> (),
        onSubmit: @escaping () -> ()
    ) -> some View {
        let checkFileValidity: () -> Bool = {
            var isValid = true
            if titleBinding.wrappedValue.count < 1 {
                isValid = false
            }
            for file in self.files {
                if file.name == titleBinding.wrappedValue {
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
            type: FileEntry.FileType.folder,
            titleBinding: $newFolderName,
            onClose: { showNewFolderPopup = false },
            onSubmit: {
                let newFile = FileEntry(name: newFolderName, type: FileEntry.FileType.folder)
                self.files.append(newFile)
                print("self.files:", self.files.count)
                newFolderName = ""
                showNewFolderPopup = false
            }
        )
    }
    @ViewBuilder private func newFileView() -> some View {
        popupViewTemplate(
            type: FileEntry.FileType.page,
            titleBinding: $newFileName,
            onClose: { showNewFilePopup = false },
            onSubmit: {
                let newFile = FileEntry(name: newFileName, type: FileEntry.FileType.page)
                self.files.append(newFile)
                print("self.files:", self.files.count)
                newFileName = ""
                showNewFilePopup = false
            }
        )
    }
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            UI.Btn.Rounded(action: {showNewFolderPopup = true}) {
                Image(systemName: "folder.badge.plus")
            }
            .popover(isPresented: $showNewFolderPopup, content: newFolderView)
            UI.Btn.Rounded(action: {showNewFilePopup = true}) {
                Image(systemName: "doc.badge.plus")
            }
            .popover(isPresented: $showNewFilePopup, content: newFileView)
        }
    }
}

fileprivate struct FileEntryView: View {
    let parent: Array<String>
    @Binding var fileEntry: FileEntry
    private var navBar: UI.Hacks.NavBar {
        let dirPath = self.parent.joined(separator: "/")
        return UI.Hacks.NavBar(
            title: dirPath,
            withBackBtn: !self.parent.isEmpty,
            leading: {
                EmptyView()
            },
            trailing: {
                FileToolbarView(parent: parent, files: Binding.constant([]))
            }
        )
    }
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text("TODO")
            Spacer()
            UI.Hacks.NavigationStackViewLink(
                navBar: self.navBar,
                destination: {
                    Text("TODO")
                },
                label: {
                    Image(systemName: "chevron.right")
                }
            )
        }
    }
}

//fileprivate struct FileNameTextFieldStyle: TextFieldStyle {
////    var borderColor: Bool
//    func _body(configuration: TextField<Self._Label>) -> some View {
//        configuration
//        .padding(10)
////        .background(
////            RoundedRectangle(cornerRadius: 10, style: .continuous)
////                .stroke(focused ? Color.red : Color.gray, lineWidth: 3)
////        )
//        .padding()
//    }
//}

fileprivate struct FileTreeContentView: View {
    let parent: Array<String>
    @State fileprivate var files: Array<FileEntry> = []
    @Environment(\.colorScheme) private var colorScheme
    private func onMove(from source: IndexSet, to destination: Int) {
        self.files.move(fromOffsets: source, toOffset: destination)
    }
    func onDelete(at offsets: IndexSet) {
        self.files.remove(atOffsets: offsets)
    }
    var body: some View {
//        let dirPath = self.parent.joined(separator: "/")
//        let navBar = UI.Hacks.NavBar(
//            title: dirPath,
//            withBackBtn: !self.parent.isEmpty,
//            leading: {
//                EmptyView()
//            },
//            trailing: {
//                HStack(alignment: .center, spacing: 5) {
//                    UI.Btn.Rounded(action: {showNewFolderPopup = true}) {
//                        Image(systemName: "folder.badge.plus")
//                    }
//                    .popover(isPresented: $showNewFolderPopup, content: newFolderView)
//                    UI.Btn.Rounded(action: {showNewFilePopup = true}) {
//                        Image(systemName: "doc.badge.plus")
//                    }
//                    .popover(isPresented: $showNewFilePopup, content: newFileView)
//                }
//            }
//        )
        VStack(alignment: .center, spacing: 0) {
//            FileToolbarView(parent: <#T##[String]#>, files: <#T##[FileEntry]#>, colorScheme: <#T##arg#>, body: <#T##View#>)
            List {
                ForEach(Array(self.files.enumerated()), id: \.1.id) { (ix, entry) in
//                    let innerParent = self.parent
                    FileEntryView(
                        parent: parent,
                        fileEntry: Binding.proxy($files[ix])
                    )
                }
                .onDelete(perform: onDelete)
                .onMove(perform: onMove)
                .listRowBackground(UI.DEFAULT_BG_COLOR.getAsColor(for: colorScheme))
            }
            .listStyle(.plain)
        }
    }
}


extension SS1 {
    struct FileTreeView: View {
        var body: some View {
//            let navBar = UI.Hacks.NavBar(
//                title: nil,
//                withBackBtn: false,
//                leading: {
//                    EmptyView()
//                },
//                trailing: {
//                    HStack(alignment: .center, spacing: 5) {
//                        UI.Btn.Rounded(action: {showNewFolderPopup = true}) {
//                            Image(systemName: "folder.badge.plus")
//                        }
//                        .popover(isPresented: $showNewFolderPopup, content: newFolderView)
//                        UI.Btn.Rounded(action: {showNewFilePopup = true}) {
//                            Image(systemName: "doc.badge.plus")
//                        }
//                        .popover(isPresented: $showNewFilePopup, content: newFileView)
//                    }
//                }
//            )
            UI.Hacks.NavigationStackView(navBar: nil) {
                FileTreeContentView(parent: [])
            }
        }
    }
}

