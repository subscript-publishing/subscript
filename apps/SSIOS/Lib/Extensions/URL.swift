//
//  URL.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/22/22.
//

import Foundation
import os


extension URL {
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        assert(paths.count == 1)
        let documentsDirectory = paths.first!
        return documentsDirectory
    }
    static func tmpDir() -> URL {
        return FileManager.default.temporaryDirectory
    }
    func read<T: Codable>(type: T.Type) -> Optional<T> {
        let decoder = PropertyListDecoder()
        if let data = try? Data(contentsOf: self) {
            return try? decoder.decode(T.self, from: data)
        } else {
            return .none
        }
    }
    func readUtf8String() -> Optional<String> {
        return try? String(contentsOf: self, encoding: .utf8)
    }
    func readBinary() -> Optional<Data> {
        return try? Data(contentsOf: self)
    }
    func write<C: Codable>(value: C) {
        let encoder = PropertyListEncoder()
        let data = try! encoder.encode(value)
        try! data.write(to: self)
    }
}

