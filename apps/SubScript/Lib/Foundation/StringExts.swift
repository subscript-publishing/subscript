//
//  String.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/10/22.
//

import Foundation

extension String.Element {
    func oneOf(_ options: [String.Element]) -> Bool {
        for option in options {
            if self == option {
                return true
            }
        }
        return false
    }
}

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

extension String {
    func save(path: URL) -> Result<(), Error> {
        let encoding = self.fastestEncoding
        do {
            try self.write(to: path, atomically: true, encoding: encoding)
        } catch {
            return Result.failure(error)
        }
        return Result.success(())
    }
    
//    func save(path: String) -> Result<(), Error> {
//        let encoding = self.fastestEncoding
//        do {
//            try self.write(to: URL(string: path)!, atomically: true, encoding: encoding)
//        } catch {
//            return Result.failure(error)
//        }
//        return Result.success(())
//    }
    
//    static func read(path: String) -> Result<String, Error> {
//        do {
//            let data = try String(contentsOfFile: path)
//            return Result.success(data)
//        } catch {
//            return Result.failure(error)
//        }
//    }
    
    static func read(path: URL) -> Result<String, Error> {
        do {
            let data = try String(contentsOf: path)
            return Result.success(data)
        } catch {
            return Result.failure(error)
        }
    }
}
