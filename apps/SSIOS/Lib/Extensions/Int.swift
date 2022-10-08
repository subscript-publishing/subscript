//
//  Int.swift
//  SubscriptTablet
//
//  Created by Colbyn Wadman on 9/24/22.
//

import Foundation

extension Int {
    static func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
}
