//
//  String.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/12/22.
//

import Foundation


extension String {
    func oneOf(_ options: [String]) -> Bool {
        for option in options {
            if self == option {
                return true
            }
        }
        return false
    }
    func stripPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
