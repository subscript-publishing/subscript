//
//  FSViewNew.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/14/22.
//

import SwiftUI

fileprivate let FS_FONT: Font = .system(size: 18, weight: Font.Weight.medium, design: Font.Design.monospaced)
fileprivate let MAIN_BACKGROUND_COLOR_MAP = UX.ColorMap(
    lightMode: LL.Color.clear,
    darkMode: #colorLiteral(red: 0.1094526425, green: 0.1094526425, blue: 0.1094526425, alpha: 1)
)
fileprivate let TOOLBAR_BACKGROUND_COLOR_MAP = UX.ColorMap(
    lightMode: LL.Color.clear,
    darkMode: #colorLiteral(red: 0.1587452292, green: 0.1587452292, blue: 0.1587452292, alpha: 1)
)
fileprivate let LIST_BORDER_COLOR_MAP = UX.ColorMap(
    lightMode: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
    darkMode: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
)
fileprivate let PRIMARY_BORDER_COLOR_MAP = UX.ColorMap(
    lightMode: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
    darkMode: #colorLiteral(red: 0.2084548352, green: 0.2210372187, blue: 0.2333485778, alpha: 1)
)
fileprivate let ACTIVE_FG_COLOR_MAP = UX.ColorMap(
    lightMode: #colorLiteral(red: 0.9319887833, green: 0, blue: 0.7358607531, alpha: 1),
    darkMode: #colorLiteral(red: 0.3864123721, green: 0.9764705896, blue: 0.8876167637, alpha: 1)
)
fileprivate let SELECTED_FG_COLOR_MAP = UX.ColorMap(
    lightMode: #colorLiteral(red: 0.9319887833, green: 0, blue: 0.7358607531, alpha: 1),
    darkMode: #colorLiteral(red: 0.3864123721, green: 0.9764705896, blue: 0.8876167637, alpha: 1)
)
fileprivate let SECONDARY_SELECTED_FG_COLOR_MAP = UX.ColorMap(
    lightMode: #colorLiteral(red: 0.9319887833, green: 0, blue: 0.7358607531, alpha: 1),
    darkMode: #colorLiteral(red: 0.07250152658, green: 0.9764705896, blue: 0.8408752301, alpha: 1)
)
fileprivate let FILE_ENTRY_BG_COLOR_MAP_EVEN = UX.ColorMap(
    lightMode: #colorLiteral(red: 0.9465519786, green: 0.9465519786, blue: 0.9465519786, alpha: 1),
    darkMode: #colorLiteral(red: 0.1393855214, green: 0.1393855214, blue: 0.1393855214, alpha: 1)
)

fileprivate struct SizeAccumulatorPreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        let nextValue = nextValue()
        let width = max(value.width, nextValue.width)
        let height = max(value.height, nextValue.height)
        value = CGSize(width: width, height: height)
    }
}


fileprivate struct FileNameField: View {
    let renameMode: Bool
    let lsDir: () -> Array<String>
    let onSubmit: (String) -> ()
    @Binding var fileType: SS1.FS.FileType
    @State var nameField: String
    @Environment(\.colorScheme) private var colorScheme
    
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
    private func onSubmitWrapper() {
        if isValidFileName() {
            // TODO
            self.onSubmit(nameField)
        }
    }
    var body: some View {
        let validName = isValidFileName()
        let textColorScheme = UX.ColorMap(
            lightMode: validName ? #colorLiteral(red: 0.1447366774, green: 0.1447366774, blue: 0.1447366774, alpha: 1) : LL.Color.red,
            darkMode: validName ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : LL.Color.red
        )
        let borderColorScheme = UX.ColorMap(
            lightMode: validName ? #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1) : LL.Color.red,
            darkMode: validName ? #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1) : LL.Color.red
        )
        let textColor = textColorScheme.get(for: colorScheme).asColor
        let borderColor = borderColorScheme.get(for: colorScheme).asColor
        let title = fileType == .folder ? "New Folder Name" : "New Page Name"
        if !renameMode {
            UX.FormUtils.enumPicker(title: "File Type", value: $fileType)
        }
        TextField(title, text: $nameField, onCommit: onSubmitWrapper)
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
        UX.RoundBtn(action: onSubmitWrapper) {
            HStack(alignment: .center, spacing: 10) {
                Spacer()
                Text("Submit")
                Spacer()
            }
        }
    }
}



fileprivate struct DirectoryEditorView: View {
    let currentFolderID: UUID
    @Binding var files: Array<SS1.FS.File>
    @Binding var showDirectoryEditor: Bool
    var onDeleteSet: (Set<UUID>) -> ()
    var onDeleteOffsets: (IndexSet) -> ()
    var onMove: (Set<UUID>, Array<String>) -> ()
    var rename: (UUID, String) -> ()
    
    @Environment(\.colorScheme)     private var colorScheme
    @Environment(\.fgColorMap)      private var fgColorMap
    @Environment(\.bgColorMap)      private var bgColorMap
    @Environment(\.borderLineWidth) private var borderLineWidth
    @EnvironmentObject              private var rootDirectoryEnv: RootDirectoryEnv
    @State                          private var sizeAccumulator: CGSize? = nil
    @State                          private var selectedFiles: Set<UUID> = []
    @State                          private var lastSelectedFile: SS1.FS.File? = nil
    @ViewBuilder private func fileEntryLabel(file: SS1.FS.File) -> some View {
        let icon = file.type == .folder ? "folder" : "doc.richtext"
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
            if lastSelectedFile?.id == file.id {
                Text(file.name)
                    .underline(true, color: SECONDARY_SELECTED_FG_COLOR_MAP.get(for: colorScheme).asColor)
            } else {
                Text(file.name)
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 10))
        .font(FS_FONT)
    }
    var body: some View {
        let onClick: (SS1.FS.File) -> () -> () = { file in
            return {
                if selectedFiles.contains(file.id) {
                    selectedFiles.remove(file.id)
                    lastSelectedFile = nil
                } else {
                    selectedFiles.insert(file.id)
                    lastSelectedFile = file
                }
            }
        }
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                UX.RoundBtn(text: "Close", action: {self.showDirectoryEditor = false})
                Spacer()
            }
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            .withBorder(edges: .bottom)
            List {
                ForEach(files) {file in
                    let targetFgColorMap = lastSelectedFile?.id == file.id
                        ? SECONDARY_SELECTED_FG_COLOR_MAP
                        : (selectedFiles.contains(file.id)
                            ? SELECTED_FG_COLOR_MAP
                            : fgColorMap)
                    UX.Btn(action: onClick(file)) {
                        fileEntryLabel(file: file)
                    }
                    .environment(\.fgColorMap, targetFgColorMap)
                }
                .onDelete(perform: onDeleteOffsets)
            }
            Spacer()
            HStack(alignment: .center, spacing: 10) {
                UX.PillPopoverBtn(
                    leading: {
                        Image(systemName: "trash")
                    },
                    trailing: {
                        Text("Delete")
                    },
                    popover: { toggle in
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .center, spacing: 0) {
                                Spacer()
                                Text("Are you sure?")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding([.top, .bottom], 20)
                            .withBorder(edges: .bottom)
                            HStack(alignment: .center, spacing: 0) {
                                UX.RoundBtn(action: {
                                    toggle.wrappedValue = false
                                    self.onDeleteSet(self.selectedFiles)
                                }) {
                                    HStack(alignment: .bottom, spacing: 0) {
                                        Spacer()
                                        Text("Yes")
                                        Spacer()
                                    }
                                }
                                .dangerousFgColorMap()
                                Spacer()
                                UX.RoundBtn(action: {
                                    toggle.wrappedValue = false
                                }) {
                                    HStack(alignment: .bottom, spacing: 0) {
                                        Spacer()
                                        Text("Cancel")
                                        Spacer()
                                    }
                                }
                                    .safeFgColorMap()
                            }
                            .padding(20)
                        }
                        .frame(minWidth: 400)
                    }
                )
                    .dangerousFgColorMap()
                    .disabled(selectedFiles.isEmpty)
                UX.PillPopoverBtn(
                    leading: {
                        Image(systemName: "arrow.triangle.turn.up.right.circle")
                    },
                    trailing: {
                        Text("Move To")
                    },
                    popover: { toggle in
                        SelectFolderTree(
                            fileTree: rootDirectoryEnv.rootFileTree,
                            showSelectFolderTree: toggle,
                            currentFolderID: currentFolderID,
                            onSubmit: { targetFolder in
                                print("popover: OnSubmit")
                                toggle.wrappedValue = false
                                self.onMove(self.selectedFiles, targetFolder.filePathParts)
                            }
                        )
                    }
                )
                    .disabled(selectedFiles.isEmpty)
                Spacer()
                UX.RoundPopoverBtn(text: "Rename", popover: { renameToggle in
                    if let selectedFile = lastSelectedFile {
                        VStack(alignment: .center, spacing: 0) {
                            HStack(alignment: .center, spacing: 10) {
                                UX.RoundBtn(text: "Close", action: {
                                    renameToggle.wrappedValue = false
                                })
                                Spacer()
                            }
                            .padding(10)
                            .withBorder(edges: .bottom)
                            VStack(alignment: .center, spacing: 10) {
                                HStack(alignment: .center, spacing: 10) {
                                    Text("Renaming")
                                    Text(selectedFile.name)
                                    Spacer()
                                }
                                .font(.system(size: 18, weight: Font.Weight.bold, design: Font.Design.monospaced))
                                FileNameField(
                                    renameMode: true,
                                    lsDir: {
                                        return self.files.map({$0.name})
                                    },
                                    onSubmit: { newName in
                                        renameToggle.wrappedValue = false
                                        
                                        self.rename(selectedFile.id, newName)
                                    },
                                    fileType: Binding.constant(selectedFile.type),
                                    nameField: selectedFile.name
                                )
                            }
                            .padding([.leading, .trailing], 10)
                            .padding([.top, .bottom], 10)
                        }
                        .frame(minWidth: 400)
                    }
                })
                    .disabled(selectedFiles.isEmpty)
                UX.RoundBtn(text: "Clear Selected", action: {
                    self.selectedFiles.removeAll(keepingCapacity: true)
                    self.lastSelectedFile = nil
                })
                    .disabled(selectedFiles.isEmpty)
            }
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            .withBorder(edges: .top)
        }
    }
}

fileprivate struct SelectFolderTree: View {
//    @EnvironmentObject private var rootDirectoryEnv: RootDirectoryEnv
    let fileTree: Array<SS1.FS.File>
    @Binding
    var showSelectFolderTree: Bool
    let currentFolderID: UUID
    let onSubmit: (FileTreeItem) -> ()
    @State private var selectedFile: FileTreeItem? = nil
    @Environment(\.colorScheme) private var colorScheme
    @State private var rootID: UUID = UUID()
    private var selectedFilePath: String? { selectedFile?.filePath }
    private func onSubmitWrapper() {
        if let file = self.selectedFile {
            onSubmit(file)
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                UX.RoundBtn(text: "Close", action: {
                    self.showSelectFolderTree = false
                })
                Spacer()
            }
            .padding(10)
            .withBorder(edges: .bottom)
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    HStack(alignment: .center, spacing: 10) {
                        let font = Font.system(size: 20, weight: Font.Weight.medium, design: Font.Design.monospaced)
                        let icon = "chevron.down"
                        let bgColorMap = selectedFile?.id == self.rootID ? SELECTED_FG_COLOR_MAP : nil
                        UX.Sticker.Round {
                            Image(systemName: icon)
                                .font(font)
                                .frame(width: 25, height: 25, alignment: .center)
                        }
                        UX.Btn(action: {
                            self.selectedFile = FileTreeItem(
                                id: self.rootID,
                                name: "",
                                path: [],
                                children: []
                            )
                            self.selectedFile!.isRoot = true
                        }) {
                            Text("/ (Package Root)")
                                .font(font)
                            Spacer()
                        }
                        .environment(\.fgColorMap, bgColorMap)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(fileTree) { file in
                            if let fileItem = FileTreeItem(parent: [], fromFSFile: file) {
                                TreeOutline(
                                    currentFolderID: self.currentFolderID,
                                    folder: fileItem,
                                    onSubmit: onSubmitWrapper,
                                    selectedFile: $selectedFile
                                )
                            }
                        }
                    }
                    .padding(.leading, 10)
                    .withBorder(edges: .leading)
                    .padding(.leading, 20)
                }
            }
            .padding(10)
            Spacer()
            HStack(alignment: .center, spacing: 10) {
                UX.Sticker.Pill(
                    leading: {
                        Text("Selected")
                            .font(.system(size: 20, weight: Font.Weight.light, design: Font.Design.monospaced))
                    },
                    trailing: {
                        let color = SELECTED_FG_COLOR_MAP.get(for: colorScheme).asColor
                        Text(self.selectedFilePath ?? "VOID")
                            .font(.system(size: 20, weight: Font.Weight.light, design: Font.Design.monospaced))
                            .foregroundColor(color)
                    }
                )
                    .isHidden(selectedFilePath.isNone)
                Spacer()
                UX.RoundBtn(action: onSubmitWrapper) {
                    Text("Submit")
                        .font(.system(size: 20, weight: Font.Weight.light, design: Font.Design.monospaced))
                        .disabled(self.selectedFile.isNone)
                }
            }
            .padding(10)
            .withBorder(edges: .top)
        }
    }
    struct TreeOutline: View {
        let currentFolderID: UUID
        let folder: FileTreeItem
        let onSubmit: () -> ()
        @Binding var selectedFile: FileTreeItem?
        @State private var expand: Bool = false
        var targetFgColorMap: UX.ColorMap? {
            if folder.id == currentFolderID {
                return nil
            }
            if selectedFile?.id == folder.id {
                return SELECTED_FG_COLOR_MAP
            }
            return nil
        }
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                let font = Font.system(size: 20, weight: Font.Weight.medium, design: Font.Design.monospaced)
                let toggleExpand = {
                    self.expand.toggle()
                }
                let makeActive = {
                    self.expand = true
                    selectedFile = folder
                }
                HStack(alignment: .center, spacing: 10) {
                    let icon = expand ? "chevron.down" : "minus"
                    UX.RoundBtn(action: toggleExpand) {
                        Image(systemName: icon)
                            .font(font)
                            .frame(width: 25, height: 25, alignment: .center)
                    }
                    .disabled(folder.children.isEmpty)
                    .disabled(folder.id == currentFolderID)
                    UX.Btn(action: makeActive) {
                        Text(folder.name)
                            .font(font)
                        Spacer()
                    }
                    .environment(\.fgColorMap, targetFgColorMap)
                    .disabled(folder.id == currentFolderID)
                }
                if expand {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(folder.children) { item in
                            TreeOutline(
                                currentFolderID: self.currentFolderID,
                                folder: item,
                                onSubmit: onSubmit,
                                selectedFile: $selectedFile
                            )
                        }
                    }
                    .padding(.leading, 10)
                    .withBorder(edges: .leading)
                    .padding(.leading, 20)
                }
            }
        }
    }
    fileprivate struct FileTreeItem: Hashable, Identifiable {
        var id: UUID
        var name: String
        var path: Array<String>
        var children: [FileTreeItem] = []
        var isRoot: Bool = false
        init(
            id: UUID,
            name: String,
            path: Array<String>,
            children: [FileTreeItem] = []
        ) {
            self.id = id
            self.name = name
            self.path = path
            self.children = children
        }
        init?(parent: Array<String>, fromFSFile file: SS1.FS.File) {
            if file.isFolder {
                self.id = file.id
                self.name = file.name
                self.path = parent
                var newPath = parent
                newPath.append(self.name)
                var xs: [FileTreeItem] = []
                for child in file.children {
                    if let item = FileTreeItem.init(parent: newPath, fromFSFile: child) {
                        xs.append(item)
                    }
                }
                self.children = xs
//                if !xs.isEmpty {
//                    self.children = xs
//                }
            } else {
                return nil
            }
        }
        var filePath: String? {
            if self.isRoot {
                return "/ (Package Root)"
            } else {
                var path = self.path
                path.append(self.name)
                return path.joined(separator: "/")
            }
        }
        var filePathParts: Array<String> {
            var path = self.path
            if !self.isRoot {
                path.append(self.name)
            }
            return path
        }
    }
}

fileprivate struct DirectoryView: View {
    let currentFolderID: UUID
    @Binding var files: Array<SS1.FS.File>
    @ObservedObject                 private var nextValueRef: NextValueRef = NextValueRef()
    @Environment(\.colorScheme)     private var colorScheme
    @Environment(\.fgColorMap)      private var fgColorMap
    @Environment(\.bgColorMap)      private var bgColorMap
    @Environment(\.borderLineWidth) private var borderLineWidth
    @EnvironmentObject              private var rootDirectoryEnv: RootDirectoryEnv
    @State                          private var sizeAccumulator: CGSize? = nil
    @State                          private var showDirectoryEditor: Bool = false
    @State                          private var selectedFiles: Set<UUID> = []
    @State                          private var newFileType: SS1.FS.FileType = SS1.FS.FileType.folder
    private func processDeletedFiles(removed: Array<SS1.FS.File>) {
        print("Removed", removed.map({$0.name}))
    }
    private func deleteSelectedFiles() {
        var removed: Array<SS1.FS.File> = []
        for (ix, file) in files.enumerated().reversed() {
            if selectedFiles.contains(file.id) {
                removed.append(files.remove(at: ix))
            }
        }
        processDeletedFiles(removed: removed)
    }
    private func onDelete(at offsets: IndexSet) {
        var removed: Array<SS1.FS.File> = []
        for ix in offsets.reversed() {
            let file = self.files.remove(at: ix)
            if nextValueRef.next?.file.id == file.id {
                self.nextValueRef.clear()
            }
            removed.append(file)
        }
        processDeletedFiles(removed: removed)
    }
    private func onFileClick(file: SS1.FS.File) -> () {
        if self.nextValueRef.next.isNone {
            self.nextValueRef.next = FileView(file: file, onAppear: {
                rootDirectoryEnv.scrollToID(file.id)
            })
            return
        }
        withAnimation(.easeOut(duration: 0.25)) {
            self.nextValueRef.next = FileView(file: file, onAppear: {
                rootDirectoryEnv.scrollToID(file.id)
            })
        }
    }
    private class NextValueRef: ObservableObject {
        var id: UUID? {
            get {self.next?.file.id}
        }
        @Published var next: FileView? = nil
        func clear() {
            self.next = nil
        }
        func clear(ifMatches id: UUID) {
            if self.next?.file.id == id {
                self.clear()
            }
        }
    }
    private var minWidth: CGFloat {
        return 300
    }
    private var idealWidth: CGFloat? {
        if let width = sizeAccumulator?.width {
            return max(width, self.minWidth)
        }
        return self.minWidth
    }
    @ViewBuilder private func fileEntryLabel(
        file: SS1.FS.File,
        editMode: Bool = false
    ) -> some View {
        let icon = file.type == .folder ? "folder" : "doc.richtext"
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
            Text(file.name)
            Spacer()
            if !editMode {
                Image(systemName: "chevron.forward")
            }
        }
        .padding(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 10))
        .font(FS_FONT)
    }
    @ViewBuilder private func fileEntryView(file: SS1.FS.File) -> some View {
        let backgroundColor = UX.DefaultButtonStyle.UNNOTICEABLE_BG.get(for: colorScheme).asColor
        let isActive = self.nextValueRef.id == file.id
        let targetFgColorMap = isActive ? ACTIVE_FG_COLOR_MAP : fgColorMap
        UX.Btn(action: {onFileClick(file: file)}) {
            self.fileEntryLabel(file: file)
                .frame(minWidth: self.idealWidth)
                .background(backgroundColor)
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: true, vertical: false)
        }
        .environment(\.fgColorMap, targetFgColorMap)
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: SizeAccumulatorPreferenceKey.self,
                    value: geo.size
                )
            }
        )
        .withBorder(edges: .bottom)
    }
    @ViewBuilder private var topToolbar: some View {
        let bgColor = TOOLBAR_BACKGROUND_COLOR_MAP.get(for: colorScheme).asColor
        HStack(alignment: .center, spacing: 5) {
            Spacer()
            UX.RoundBtn(icon: "gear", action: {showDirectoryEditor.toggle()})
            UX.RoundPopoverBtn(icon: "doc.fill.badge.plus", popover: { toggle in
                VStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .center, spacing: 10) {
                        UX.RoundBtn(text: "Close", action: {
                            toggle.wrappedValue = false
                        })
                        Spacer()
                    }
                    .padding(10)
                    .withBorder(edges: .bottom)
                    VStack(alignment: .center, spacing: 10) {
                        FileNameField(
                            renameMode: false,
                            lsDir: {
                                self.files.map({$0.name})
                            },
                            onSubmit: { newName in
                                switch self.newFileType {
                                case .file:
                                    let newFile = SS1.FS.File.newFile(name: newName)
                                    self.files.append(newFile)
                                case .folder:
                                    let newFolder = SS1.FS.File.newFolder(name: newName, children: [])
                                    self.files.append(newFolder)
                                }
                                toggle.wrappedValue = false
                            },
                            fileType: $newFileType,
                            nameField: "New File"
                        )
                    }
                    .padding(10)
                }
                .frame(minWidth: 400)
            })
        }
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        .background(bgColor)
        .bgColorMap(color: TOOLBAR_BACKGROUND_COLOR_MAP)
    }
    @ViewBuilder private func directoryEditor() -> some View {
        DirectoryEditorView(
            currentFolderID: self.currentFolderID,
            files: $files,
            showDirectoryEditor: $showDirectoryEditor,
            onDeleteSet: { ids in
                showDirectoryEditor = false
                for id in ids {
                    self.nextValueRef.clear(ifMatches: id)
                }
            },
            onDeleteOffsets: { offsets in
                showDirectoryEditor = false
                for ix in offsets {
                    self.nextValueRef.clear(ifMatches: self.files[ix].id)
                }
                self.onDelete(at: offsets)
            },
            onMove: { fileIDs,targetPath in
                showDirectoryEditor = false
                for id in fileIDs {
                    self.nextValueRef.clear(ifMatches: id)
                }
                var removedFiles: Array<SS1.FS.File> = []
                for (ix, file) in self.files.enumerated().reversed() {
                    if fileIDs.contains(file.id) {
                        let popedFile = self.files.remove(at: ix)
                        removedFiles.append(popedFile)
                    }
                }
                rootDirectoryEnv.moveFiles(removedFiles, targetPath)
            },
            rename: { id, newName in
                showDirectoryEditor = false
                for file in self.files {
                    if file.id == id {
                        file.name = newName
                        self.nextValueRef.clear(ifMatches: file.id)
                        break
                    }
                }
            }
        )
    }
    var body: some View {
        let evenEntryBgColor = FILE_ENTRY_BG_COLOR_MAP_EVEN.get(for: colorScheme).asColor
        VStack(alignment: .leading, spacing: 0) {
            topToolbar
                .borderLineWidth(borderLineWidth)
                .borderColorMap(LIST_BORDER_COLOR_MAP)
                .withBorder(edges: [.top, .bottom])
                .borderColorMap(PRIMARY_BORDER_COLOR_MAP)
                .borderLineWidth(1.0)
            ForEach(Array(files.enumerated()), id: \.1.id) { (ix, file) in
                fileEntryView(file: file)
                    .background(ix.isMultiple(of: 2) ? evenEntryBgColor : Color.clear)
            }
            Spacer()
        }
        .onPreferenceChange(SizeAccumulatorPreferenceKey.self) { size in
            sizeAccumulator = size
        }
        .frame(minWidth: self.idealWidth)
        .borderLineWidth(borderLineWidth)
        .borderColorMap(LIST_BORDER_COLOR_MAP)
        .withBorder(edges: .trailing)
        .borderColorMap(PRIMARY_BORDER_COLOR_MAP)
        .borderLineWidth(1.0)
        .sheet(
            isPresented: $showDirectoryEditor,
            onDismiss: {
                
            },
            content: directoryEditor
        )
        self.nextValueRef.next
    }
}

fileprivate struct FileView: View {
    @ObservedObject var file: SS1.FS.File
    @State var onAppear: (() -> ())? = nil
    var body: some View {
        Group {
            if file.isFolder {
                DirectoryView(currentFolderID: file.id, files: $file.children)
            } else if file.isFile {
                Text("TODO")
            } else {
                EmptyView()
            }
        }
        .id(file.id)
        .onAppear(perform: {
            if let f = self.onAppear {
                f()
            }
            self.onAppear = nil
        })
    }
}

fileprivate class RootDirectoryEnv: ObservableObject {
    var scrollToID: (UUID) -> () = {_ in ()}
    var rootFileTree: Array<SS1.FS.File> = []
    var moveFiles: (Array<SS1.FS.File>, FilePathParts) -> () = {(_, _) in ()}
    typealias FilePathParts = Array<String>
}

extension SS1.FS {
    struct RootDirectoryViewNew: View {
        @StateObject private var rootDirectoryEnv = RootDirectoryEnv()
        @Binding var files: Array<SS1.FS.File>
        @State private var rootID: UUID = UUID()
        @State private var showDirEditor: Bool = false
        @State private var deleteSet: Set<UUID> = []
        @Environment(\.colorScheme) private var colorScheme
        @ViewBuilder private var mainContent: some View {
            let bgColor = MAIN_BACKGROUND_COLOR_MAP.get(for: colorScheme).asColor
            ScrollViewReader {scroller in
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 0) {
                        DirectoryView(currentFolderID: self.rootID, files: $files)
                    }
                    .bgColorMap(color: MAIN_BACKGROUND_COLOR_MAP)
                    .onAppear(perform: {
                        rootDirectoryEnv.scrollToID = { id in
                            scroller.scrollTo(id, anchor: .trailing)
                        }
                        rootDirectoryEnv.rootFileTree = self.files
                        rootDirectoryEnv.moveFiles = { newFiles, targetPath in
                            print("Moving \(newFiles.count) to \(targetPath.joined(separator: "/"))")
                            if targetPath.isEmpty {
                                self.files.append(contentsOf: newFiles)
                                return
                            }
                            let head = targetPath.first!
                            var success: Bool? = nil
                            for file in self.files {
                                if file.name == head {
                                    success = file.move(targetPath: targetPath, newFiles: newFiles)
                                    break
                                }
                            }
                            if success == false {
                                self.files.append(contentsOf: newFiles)
                            }
                        }
                    })
                    .environmentObject(rootDirectoryEnv)
                }
                .background(bgColor)
            }
        }
        var body: some View {
            mainContent
        }
    }
}
