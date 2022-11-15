//
//  UX+NewNav.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/14/22.
//

import SwiftUI
import Combine

struct Dev {}

extension Dev {
    class NavigationEnv: ObservableObject {
        
    }
    class ColumnEnv: ObservableObject {
        var id: UUID = UUID()
        var next: ColumnEnv? = nil
    }
    struct ColumnView: View {
        @EnvironmentObject private var columnEnv: ColumnEnv
//        private let content: V
        var body: some View {
//            self.content
//            if let next = columnEnv.next {
//
//            }
            Text("TODO")
        }
    }
    struct Link<L: View, D: View>: View {
        private let id: UUID
        private let label: () -> L
        private let destination: D
        init(
            id: UUID,
            @ViewBuilder label: @escaping () -> L,
            @ViewBuilder destination: @escaping () -> D
        ) {
            self.id = id
            self.label = label
            self.destination = destination()
        }
        @EnvironmentObject private var columnEnv: ColumnEnv
        private func onClick() {
            
        }
        var body: some View {
            UX.Btn(action: self.onClick, self.label)
        }
    }
    struct RootView<V: View>: View {
        private let id: UUID
        private let content: V
        init(id: UUID, @ViewBuilder content: @escaping () -> V) {
            self.id = id
            self.content = content()
        }
        var body: some View {
            Text("TODO")
        }
    }
}
