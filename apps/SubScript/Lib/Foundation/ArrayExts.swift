//
//  Array.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/22/22.
//

import Foundation

extension Array {
    // Safely lookup an index that might be out of bounds,
    // returning nil if it does not exist
    func get(index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}


