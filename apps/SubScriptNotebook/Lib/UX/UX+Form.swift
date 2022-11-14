//
//  UX+Form.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/12/22.
//

import SwiftUI

extension UX {
    struct FormUtils {}
}


extension UX.FormUtils {
    @ViewBuilder static func enumPicker<T>(
        title: String,
        value: Binding<T>
    ) -> some View where T: CaseIterable, T: Hashable {
        let allCases = Array(T.allCases)
        let pickerView = Picker(
            selection: value,
            content: {
                ForEach(Array(allCases.enumerated()), id: \.1.hashValue, content: { (ix, t) in
                    let typeName = String(reflecting: t)
                        .stripPrefix(String(reflecting: T.self))
                        .stripPrefix(".")
                        .capitalized
                    Text(typeName).tag(t)
                })
            },
            label: {
                Text(title)
            }
        )
        if allCases.count < 5 {
            pickerView.pickerStyle(SegmentedPickerStyle())
        } else {
            pickerView
        }
    }
}

