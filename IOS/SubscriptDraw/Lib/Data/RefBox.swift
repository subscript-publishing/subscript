//
//  Box.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/13/22.
//

import Foundation

final class RefBox<T> {
    var value: T

    init(_ value: T) {
        self.value = value
    }
}
