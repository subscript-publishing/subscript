//
//  UX+XList.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/10/22.
//

import SwiftUI

fileprivate struct DataListDropDelegate: DropDelegate {
    func performDrop(info: DropInfo) -> Bool {
        print("dropEntered: ", info)
        return true
    }
    func dropEntered(info: DropInfo) {
        print("dropEntered: ", info)
    }
}

extension UX {
    struct DataListEntry<T> {
        let item: Binding<T>
        let index: Int
    }
    struct VDataList<T: Identifiable, V: View>: View {
        let forEach: (DataListEntry<T>) -> V
        @Binding var data: Array<T>
        init(
            data: Binding<Array<T>>,
            @ViewBuilder _ forEach: @escaping (DataListEntry<T>) -> V
        ) {
            self._data = data
            self.forEach = forEach
        }
        @Environment(\.colorScheme) private var colorScheme
        var body: some View {
            let evenItemBackgroundColorMap = UX.ColorMap(
                lightMode: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
                darkMode: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            )
            let backgroundColorMap = UX.ColorMap(
                lightMode: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
                darkMode: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            )
            let evenBackgroundColor = evenItemBackgroundColorMap.get(for: colorScheme).asColor
            let backgroundColor = backgroundColorMap.get(for: colorScheme).asColor
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0) {
//                    static let BACKGROUND_COLOR_ODD = UX.ColorMap(
//                        lightMode: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
//                        darkMode: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
//                    )
                    ForEach(Array(data.enumerated()), id: \.1.id) { (ix, _) in
//                        let isLastElement = ix + 1 == data.count
                        let isFirstElement = ix == 0
                        let entry = DataListEntry(item: $data[ix], index: ix)
                        HStack(alignment: .center, spacing: 0) {
                            forEach(entry)
                                .padding(10)
                            Spacer()
                        }
                        .background(ix.isMultiple(of: 2) ? evenBackgroundColor : Color.clear)
                        .withBorder(edges: isFirstElement ? [.top, .bottom] : [.bottom])
                    }
                    Spacer()
                }
            }
            .background(backgroundColor)
        }
    }
}

