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
    @Binding var editMode: Bool
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
            .isHidden(columnEnv.index > 4)
        let editIcon = editMode ? "lock.open" : "lock"
        UX.RoundBtn(icon: editIcon, action: {
            editMode.toggle()
            clearNav()
        })
    }
}

fileprivate struct DirectoryView: View {
    @Binding var children: Array<SS1.FS.File>
    @Binding var editMode: Bool
    @Environment(\.colorScheme) private var colorScheme
    @State private var selection = Set<UUID>()
    @EnvironmentObject private var columnEnv: UX.Nav.ColumnEnv
    func onDelete(at offsets: IndexSet) {
        children.remove(atOffsets: offsets)
    }
    var body: some View {
        let bgColor = BACKGROUND_COLOR_MAP.get(for: colorScheme).asColor
        List {
            ForEach($children) { child in
                FileListEntry(file: child.wrappedValue, editMode: $editMode)
            }
            .onDelete(perform: onDelete)
            .listRowBackground(bgColor)
        }
        .listStyle(.plain)
        .frame(minWidth: 400)
    }
    fileprivate struct FileListEntry: View {
        @ObservedObject var file: SS1.FS.File
        @Binding var editMode: Bool
        @State private var active: Bool = false
        @State private var childEditMode: Bool = false
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.fgColorMap) private var fgColorMap
        private var page: UX.Nav.Page {
            UX.Nav.PageBuilder()
                .showBackBtn(true)
                .showToolbar(true)
                .withTitleOpt(title: file.name)
                .withTrailing { columnEnv in
                    FolderTrailingToolbar(
                        editMode: $childEditMode,
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
                .onPop {
                    self.childEditMode = false
                }
                .build(id: file.id, destination: { _ in
                    FileView(file: file, editMode: $childEditMode)
                })
        }
        fileprivate var icon: String {
            file.type == .folder ? "folder" : "doc.richtext"
        }
        @ViewBuilder private var contentView: some View {
            let backgroundColor = UX.DefaultButtonStyle.UNNOTICEABLE_BG.get(for: colorScheme).asColor
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: self.icon)
                Text(file.name)
                Spacer()
                Image(systemName: "chevron.forward").isHidden(editMode)
            }
            .font(FS_FONT)
            .background(backgroundColor)
        }
        @ViewBuilder private func linkView() -> some View {
            UX.Nav.Link(page: page) {
                contentView
            }
        }
        @ViewBuilder private func editView() -> some View {
            let targetFgColorMap = (file.selected) ? UX.Nav.ColumnEnv.ACTIVE_FG_COLOR_MAP : fgColorMap
            let onClick = {
                if file.selected {
                    file.selected = false
                } else {
                    file.selected = true
                }
            }
            UX.Btn(action: onClick) {
                contentView
            }
            .environment(\.fgColorMap, targetFgColorMap)
        }
        var body: some View {
            if editMode {
                editView()
            } else {
                linkView()
            }
        }
    }
}

fileprivate struct FileView: View {
    @ObservedObject var file: SS1.FS.File
    @Binding var editMode: Bool
    var body: some View {
        switch file.type {
        case .file:
            Text("TODO")
        case .folder:
            DirectoryView(children: $file.children, editMode: $editMode)
        }
    }
}

extension SS1.FS {
    struct RootDirectoryView: View {
        @Binding var files: Array<SS1.FS.File>
        @State private var editMode: Bool = false
        private let rootID: UUID = UUID()
        @Environment(\.colorScheme) private var colorScheme
        var rootPage: UX.Nav.Page {
            UX.Nav.PageBuilder()
                .withTrailing { columnEnv in
                    FolderTrailingToolbar(
                        editMode: $editMode,
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
                    self.editMode = false
                }
                .build(id: self.rootID, destination: { _ in
                    DirectoryView(children: $files, editMode: $editMode)
                })
        }
        var body: some View {
            let bgColor = BACKGROUND_COLOR_MAP.get(for: colorScheme).asColor
            UX.Nav.RootView(page: rootPage)
                .background(bgColor)
        }
    }
}
