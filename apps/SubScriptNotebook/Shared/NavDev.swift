//
//  NavDev.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/14/22.
//

import SwiftUI

struct NavDev: View {
    @Binding var data: Array<Entry>
    @State private var rootID = UUID()
    func onDelete(at offsets: IndexSet) {
        print("onDelete")
        data.remove(atOffsets: offsets)
    }
    var rootPage: UX.Nav.Page {
        UX.Nav.PageBuilder()
            .withTitle(title: "Hello World")
            .build(id: rootID, destination: { _ in
                List {
                    ForEach($data) { entry in
                        EntryView(entry: entry.wrappedValue)
                    }
                    .onDelete(perform: onDelete)
                }
            })
    }
    var body: some View {
//        UX.Nav.RootView(page: rootPage)
        List {
            ForEach(data) { entry in
                EntryView(entry: entry)
            }
            .onDelete(perform: onDelete)
        }
    }
    struct Entry: Identifiable {
        let id: UUID
        let value: Int
    }
    struct EntryView: View {
        let entry: Entry
        var body: some View {
            HStack(alignment: .center, spacing: 10) {
                Text("\(entry.id)")
                Spacer()
                Text("\(entry.value)")
            }
        }
    }
}


