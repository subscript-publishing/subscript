//
//  ContentView.swift
//  Shared
//
//  Created by Colbyn Wadman on 11/8/22.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: SubScriptNotebookDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

