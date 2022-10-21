//
//  Optional.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/17/22.
//

import Foundation

extension Optional {
    func filter(_ f: (Wrapped) -> Bool) -> Optional<Wrapped> {
        if let value = self {
            if f(value) {
                return Optional.some(value)
            }
        }
        return Optional.none
    }
}
