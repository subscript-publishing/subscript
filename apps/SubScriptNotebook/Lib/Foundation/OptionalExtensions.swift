//
//  Optional.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/9/22.
//

import Foundation

extension Optional {
    var isNone: Bool {
        switch self {
        case .none: return true
        case .some(_): return false
        }
    }
    var isSome: Bool {
        switch self {
        case .none: return false
        case .some(_): return true
        }
    }
}
