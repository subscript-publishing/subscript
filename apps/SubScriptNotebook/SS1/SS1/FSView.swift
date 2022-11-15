//
//  FSView.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/12/22.
//

import SwiftUI

fileprivate let FS_FONT: Font = .system(size: 15, weight: Font.Weight.medium, design: Font.Design.monospaced)

fileprivate let BACKGROUND_COLOR_MAP = UX.ColorMap(
    lightMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
    darkMode: #colorLiteral(red: 0.1094526425, green: 0.1094526425, blue: 0.1094526425, alpha: 1)
)

fileprivate struct FolderTrailingToolbar: View {
    @Binding var showDirEditor: Bool
    let clearNav: () -> ()
    let onNewFile: (String) -> ()
    let onNewFolder: (String) -> ()
    let lsDir: () -> Array<String>
    @State private var fileType: SS1.FS.FileType = .folder
    @State private var nameField: String = ""
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var columnEnv: UX.Nav.ColumnEnv
    private func isValidFileName() -> Bool {
        var isValid = true
        if nameField.count < 1 {
            isValid = false
        }
        for name in lsDir() {
            if name == nameField {
                isValid = false
            }
        }
        return isValid
    }
    private func onSubmit() {
        if isValidFileName() {
            switch fileType {
            case .file: onNewFile(nameField)
            case .folder: onNewFolder(nameField)
            }
        }
    }
    @ViewBuilder private func popupView(toggle: Binding<Bool>) -> some View {
        let onClose = {
            toggle.wrappedValue = false
        }
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                UX.RoundBtn(action: onClose) {
                    Text("Close")
                }
                Spacer()
            }
            .padding(10)
            .withBorder(edges: .bottom)
            .padding(.bottom, 10)
            VStack(alignment: .center, spacing: 10) {
                let validName = isValidFileName()
                let textColorScheme = UX.ColorMap(
                    lightMode: validName ? #colorLiteral(red: 0.1447366774, green: 0.1447366774, blue: 0.1447366774, alpha: 1) : XI.Color.red,
                    darkMode: validName ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : XI.Color.red
                )
                let borderColorScheme = UX.ColorMap(
                    lightMode: validName ? #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1) : XI.Color.red,
                    darkMode: validName ? #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1) : XI.Color.red
                )
                let textColor = textColorScheme.get(for: colorScheme).asColor
                let borderColor = borderColorScheme.get(for: colorScheme).asColor
                let title = fileType == .folder ? "New Folder Name" : "New Page Name"
                UX.FormUtils.enumPicker(title: "File Type", value: $fileType)
                TextField(title, text: $nameField, onCommit: onSubmit)
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
                UX.RoundBtn(action: onSubmit) {
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
    var body: some View {
        UX.RoundPopoverBtn(icon: "doc.fill.badge.plus", popover: popupView)
        UX.RoundBtn(icon: "gear", action: {
            showDirEditor = !showDirEditor
        })
    }
}

fileprivate struct DirectoryViewEditor: View {
    @Binding var showDirEditor: Bool
    @Binding var children: Array<SS1.FS.File>
    @Binding var deleteSet: Set<UUID>
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.fgColorMap) private var fgColorMap
    func onDelete(at offsets: IndexSet) {
        for ix in offsets {
            let item = self.children[ix]
            self.deleteSet.insert(item.id)
        }
    }
    @ViewBuilder private func entry(file: SS1.FS.File) -> some View {
        let targetFgColorMap = (file.selected) ? UX.Nav.ColumnEnv.ACTIVE_FG_COLOR_MAP : fgColorMap
        let onClick = {
            if file.selected {
                file.selected = false
            } else {
                file.selected = true
            }
        }
        UX.Btn(action: onClick) {
            let icon = file.type == .folder ? "folder" : "doc.richtext"
            let backgroundColor = UX.DefaultButtonStyle.UNNOTICEABLE_BG.get(for: colorScheme).asColor
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: icon)
                Text(file.name)
                Spacer()
            }
            .font(FS_FONT)
            .background(backgroundColor)
        }
        .environment(\.fgColorMap, targetFgColorMap)
    }
    var body: some View {
        let bgColor = BACKGROUND_COLOR_MAP.get(for: colorScheme).asColor
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                UX.RoundBtn(text: "Close", action: {
                    showDirEditor = false
                })
                Spacer()
            }
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            .withBorder(edges: .bottom)
            List {
                ForEach(Binding.proxy($children)) { child in
                    if !self.deleteSet.contains(child.wrappedValue.id) {
                        self.entry(file: child.wrappedValue)
                    }
                }
                .onDelete(perform: onDelete)
                .listRowBackground(bgColor)
            }
            .listStyle(.plain)
            .frame(minWidth: 400)
        }
    }
}

fileprivate struct DirectoryView: View {
    @Binding var children: Array<SS1.FS.File>
    @Environment(\.colorScheme) private var colorScheme
    @State private var selection = Set<UUID>()
    @EnvironmentObject private var columnEnv: UX.Nav.ColumnEnv
    func onDelete(at offsets: IndexSet) {
        children.remove(atOffsets: offsets)
    }
    var body: some View {
        let bgColor = BACKGROUND_COLOR_MAP.get(for: colorScheme).asColor
        List {
            ForEach(Binding.proxy($children)) { child in
                FileListEntry(file: child.wrappedValue)
            }
            .onDelete(perform: onDelete)
            .listRowBackground(bgColor)
        }
        .listStyle(.plain)
        .frame(minWidth: 400)
//        ScrollView {
//            VStack(alignment: .leading, spacing: 0) {
//                ForEach(Array(self.children)) { (ix, child) in
//                    FileListEntry(file: child)
//                }
//            }
//        }
    }
    fileprivate struct FileListEntry: View {
        @ObservedObject var file: SS1.FS.File
        @State private var active: Bool = false
        @State private var childEditMode: Bool = false
        @State private var showDirEditor: Bool = false
        @State private var deleteSet: Set<UUID> = []
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.fgColorMap) private var fgColorMap
        private var page: UX.Nav.Page {
            UX.Nav.PageBuilder()
                .showBackBtn(true)
                .showToolbar(true)
                .withTitleOpt(title: file.name)
                .withTrailing { columnEnv in
                    FolderTrailingToolbar(
                        showDirEditor: $showDirEditor,
                        clearNav: {
                            columnEnv.clear()
                        },
                        onNewFile: { name in
                            let newFile = SS1.FS.File.newFile(name: name)
                            file.children.append(newFile)
                        },
                        onNewFolder: { name in
                            let newFile = SS1.FS.File.newFolder(name: name, children: [])
                            file.children.append(newFile)
                        },
                        lsDir: {
                            return file.children.map({$0.name})
                        }
                    )
                        .isHidden(file.isFile)
                }
                .build(id: file.id, destination: { _ in
                    FileView(file: file)
                        .sheet(
                            isPresented: $showDirEditor,
                            onDismiss: {
                                
                            },
                            content: {
                                DirectoryViewEditor(
                                    showDirEditor: $showDirEditor,
                                    children: Binding.proxy($file.children),
                                    deleteSet: $deleteSet
                                )
                                    .frame(minWidth: 400, minHeight: 400)
                            }
                        )
                })
        }
        var body: some View {
            UX.Nav.Link(page: page) {
                let icon = file.type == .folder ? "folder" : "doc.richtext"
                let backgroundColor = UX.DefaultButtonStyle.UNNOTICEABLE_BG.get(for: colorScheme).asColor
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: icon)
                    Text(file.name)
                    Spacer()
                    Image(systemName: "chevron.forward")
                }
                .font(FS_FONT)
                .background(backgroundColor)
            }
        }
    }
}

fileprivate struct FileView: View {
    @ObservedObject var file: SS1.FS.File
    var body: some View {
        switch file.type {
        case .file:
            Text("TODO")
        case .folder:
            DirectoryView(children: Binding.proxy($file.children))
        }
    }
}

fileprivate func removeFiles(
    deleteSet: Set<UUID>,
    files: inout Array<SS1.FS.File>
) {
    var removed: Array<SS1.FS.File> = []
    if !deleteSet.isEmpty {
        let poped = files.removeFirst()
        removed.append(poped)
//        for (ix, file) in files.enumerated().reversed() {
//            if deleteSet.contains(file.id) {
//                let file = files.remove(at: ix)
//                removed.append(file)
//            }
//        }
    }
}

extension SS1.FS {
    struct RootDirectoryView: View {
        @Binding var files: Array<SS1.FS.File>
        private let rootID: UUID = UUID()
        @State private var showDirEditor: Bool = false
        @State private var deleteSet: Set<UUID> = []
        @Environment(\.colorScheme) private var colorScheme
        var rootPage: UX.Nav.Page {
            UX.Nav.PageBuilder()
                .withTrailing { columnEnv in
                    FolderTrailingToolbar(
                        showDirEditor: $showDirEditor,
                        clearNav: {
                            columnEnv.clear()
                        },
                        onNewFile: { name in
                            let newFile = SS1.FS.File.newFile(name: name)
                            files.append(newFile)
                        },
                        onNewFolder: { name in
                            let newFile = SS1.FS.File.newFolder(name: name, children: [])
                            files.append(newFile)
                        },
                        lsDir: {
                            return files.map({$0.name})
                        }
                    )
                }
                .onPop {
                    
                }
                .build(id: self.rootID, destination: { columnEnv in
                    DirectoryView(children: Binding.proxy($files))
                        .sheet(
                            isPresented: $showDirEditor,
                            onDismiss: {
                                columnEnv.clear()
                                let _ = self.files.remove(at: 1)
//                                removeFiles(deleteSet: self.deleteSet, files: &self.files)
                            },
                            content: {
                                DirectoryViewEditor(
                                    showDirEditor: $showDirEditor,
                                    children: Binding.proxy($files),
                                    deleteSet: $deleteSet
                                )
                                    .frame(minWidth: 400, minHeight: 400)
                            }
                        )
                })
        }
        var body: some View {
            let bgColor = BACKGROUND_COLOR_MAP.get(for: colorScheme).asColor
            UX.Nav.RootView(page: rootPage)
                .background(bgColor)
        }
    }
}
