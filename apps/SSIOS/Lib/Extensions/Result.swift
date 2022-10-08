//
//  Result.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/13/22.
//

import Foundation

extension Result {
    func ok() -> Optional<Success> {
        switch self {
        case .success(let x): return x
        case .failure(_): return nil
        }
    }
}
