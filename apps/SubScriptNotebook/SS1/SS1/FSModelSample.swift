//
//  FSModelSample.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/12/22.
//

import Foundation

extension SS1.FS.File {
    static func sampleData() -> Array<SS1.FS.File> {
        func file(name: String) -> SS1.FS.File {
            return SS1.FS.File.newFile(name: name)
        }
        func folder(name: String, children: Array<SS1.FS.File>) -> SS1.FS.File {
            return SS1.FS.File.newFolder(name: name, children: children)
        }
        let random = folder(name: "Random", children: [
            folder(name: "Red", children: [
                folder(name: "Red-Alpha", children: [
                    folder(name: "Red-Alpha-X", children: [
                        folder(name: "Red-Alpha-1", children: [
                            
                        ]),
                        folder(name: "Red-Alpha-2", children: [
                            
                        ]),
                    ]),
                    folder(name: "Red-Alpha-Y", children: [
                        folder(name: "Red-Alpha-Y-1", children: [
                            
                        ]),
                        folder(name: "Red-Alpha-Y-2", children: [
                            
                        ]),
                    ]),
                    folder(name: "Red-Alpha-Z", children: [
                        folder(name: "Red-Alpha-Z-1", children: [
                            
                        ]),
                        folder(name: "Red-Alpha-Z-2", children: [
                            
                        ]),
                    ]),
                ]),
                folder(name: "Red-Beta", children: [
                    folder(name: "Red-Beta-X", children: [
                        folder(name: "Red-Beta-1", children: [
                            
                        ]),
                        folder(name: "Red-Beta-2", children: [
                            
                        ]),
                    ]),
                    folder(name: "Red-Beta-Y", children: [
                        folder(name: "Red-Beta-Y-1", children: [
                            
                        ]),
                        folder(name: "Red-Beta-Y-2", children: [
                            
                        ]),
                    ]),
                    folder(name: "Red-Beta-Z", children: [
                        folder(name: "Red-Beta-Z-1", children: [
                            
                        ]),
                        folder(name: "Red-Beta-Z-2", children: [
                            
                        ]),
                    ]),
                ]),
                folder(name: "Red-Gamma", children: [
                    folder(name: "Red-Gamma-X", children: [
                        folder(name: "Red-Gamma-1", children: [
                            
                        ]),
                        folder(name: "Red-Gamma-2", children: [
                            
                        ]),
                    ]),
                    folder(name: "Red-Gamma-Y", children: [
                        folder(name: "Red-Gamma-Y-1", children: [
                            
                        ]),
                        folder(name: "Red-Gamma-Y-2", children: [
                            
                        ]),
                    ]),
                    folder(name: "Red-Gamma-Z", children: [
                        folder(name: "Red-Gamma-Z-1", children: [
                            
                        ]),
                        folder(name: "Red-Gamma-Z-2", children: [
                            
                        ]),
                    ]),
                ]),
            ]),
            folder(name: "Green", children: [
                folder(name: "Green-Alpha", children: [
                    folder(name: "Green-Alpha-X", children: [
                        folder(name: "Green-Alpha-1", children: [
                            
                        ]),
                        folder(name: "Green-Alpha-2", children: [
                            
                        ]),
                    ]),
                    folder(name: "Green-Alpha-Y", children: [
                        folder(name: "Green-Alpha-Y-1", children: [
                            
                        ]),
                        folder(name: "Green-Alpha-Y-2", children: [
                            
                        ]),
                    ]),
                    folder(name: "Green-Alpha-Z", children: [
                        folder(name: "Green-Alpha-Z-1", children: [
                            
                        ]),
                        folder(name: "Green-Alpha-Z-2", children: [
                            
                        ]),
                    ]),
                ]),
                folder(name: "Green-Beta", children: [
                    folder(name: "Green-Beta-X", children: [
                        folder(name: "Green-Beta-1", children: [
                            
                        ]),
                        folder(name: "Green-Beta-2", children: [
                            
                        ]),
                    ]),
                    folder(name: "Green-Beta-Y", children: [
                        folder(name: "Green-Beta-Y-1", children: [
                            
                        ]),
                        folder(name: "Green-Beta-Y-2", children: [
                            
                        ]),
                    ]),
                    folder(name: "Green-Beta-Z", children: [
                        folder(name: "Green-Beta-Z-1", children: [
                            
                        ]),
                        folder(name: "Green-Beta-Z-2", children: [
                            
                        ]),
                    ]),
                ]),
                folder(name: "Green-Gamma", children: [
                    folder(name: "Green-Gamma-X", children: [
                        folder(name: "Green-Gamma-1", children: [
                            
                        ]),
                        folder(name: "Green-Gamma-2", children: [
                            
                        ]),
                    ]),
                    folder(name: "Green-Gamma-Y", children: [
                        folder(name: "Green-Gamma-Y-1", children: [
                            
                        ]),
                        folder(name: "Green-Gamma-Y-2", children: [
                            
                        ]),
                    ]),
                    folder(name: "Green-Gamma-Z", children: [
                        folder(name: "Green-Gamma-Z-1", children: [
                            
                        ]),
                        folder(name: "Green-Gamma-Z-2", children: [
                            
                        ]),
                    ]),
                ]),
            ]),
            folder(name: "1", children: [
                folder(name: "2", children: [
                    folder(name: "3", children: [
                        folder(name: "4", children: [
                            folder(name: "5", children: [
                                folder(name: "6", children: [
                                    folder(name: "7", children: [
                                        folder(name: "8", children: [
                                            folder(name: "9", children: [
                                                folder(name: "10A", children: [
                                                    file(name: "Biology-A"),
                                                    file(name: "Biology-B"),
                                                ]),
                                                folder(name: "10B", children: [
                                                    file(name: "Biology-A"),
                                                    file(name: "Biology-B"),
                                                ]),
                                            ]),
                                            folder(name: "9A", children: [
                                                folder(name: "10B", children: [
                                                    
                                                ]),
                                                folder(name: "10B", children: [
                                                    
                                                ]),
                                            ]),
                                        ]),
                                        folder(name: "8A", children: [
                                            folder(name: "9A", children: [
                                                folder(name: "10A", children: [
                                                    
                                                ]),
                                                folder(name: "10B", children: [
                                                    file(name: "Biology-A"),
                                                    file(name: "Biology-B"),
                                                ]),
                                            ]),
                                            folder(name: "9A", children: [
                                                folder(name: "10B", children: [
                                                    
                                                ]),
                                                folder(name: "10B", children: [
                                                    
                                                ]),
                                            ]),
                                        ]),
                                    ]),
                                    folder(name: "7A", children: [
                                        folder(name: "8A", children: [
                                            folder(name: "9A", children: [
                                                folder(name: "10A", children: [
                                                    file(name: "Biology-A"),
                                                    file(name: "Biology-B"),
                                                ]),
                                                folder(name: "10B", children: [
                                                    
                                                ]),
                                            ]),
                                            folder(name: "9A", children: [
                                                folder(name: "10B", children: [
                                                    
                                                ]),
                                                folder(name: "10B", children: [
                                                    
                                                ]),
                                            ]),
                                        ]),
                                        folder(name: "8A", children: [
                                            folder(name: "9A", children: [
                                                folder(name: "10A", children: [
                                                    
                                                ]),
                                                folder(name: "10B", children: [
                                                    
                                                ]),
                                            ]),
                                            folder(name: "9A", children: [
                                                folder(name: "10B", children: [
                                                    
                                                ]),
                                                folder(name: "10B", children: [
                                                    
                                                ]),
                                            ]),
                                        ]),
                                    ]),
                                ]),
                            ]),
                        ]),
                    ]),
                ]),
            ]),
            folder(name: "Blue", children: [
                folder(name: "Blue-Alpha", children: [
                    
                ]),
                folder(name: "Blue-Beta", children: [
                    
                ]),
                folder(name: "Blue-Gamma", children: [
                    
                ]),
                folder(name: "Blue-Delta", children: [
                    
                ]),
                folder(name: "Blue-Epsilon", children: [
                    
                ]),
                folder(name: "Blue-Zeta", children: [
                    
                ]),
                folder(name: "Blue-Eta", children: [
                    
                ]),
            ]),
        ])
        return [
            file(name: "index"),
            folder(name: "SomeReallyLongFileNameAAAAAAAAAAAAAAAAAAA", children: [
                file(name: "File1"),
                file(name: "File2"),
                file(name: "File3"),
            ]),
            folder(name: "Physics", children: [
                file(name: "Physics-A"),
                file(name: "Physics-B"),
                file(name: "Physics-C"),
            ]),
            folder(name: "Chemistry", children: [
                file(name: "Chemistry-A"),
                file(name: "Chemistry-B"),
                file(name: "Chemistry-C"),
            ]),
            folder(name: "Biology", children: [
                file(name: "Biology-A"),
                file(name: "Biology-B"),
                file(name: "Biology-C"),
            ]),
            folder(name: "Math", children: [
                
            ]),
            random,
        ]
    }
}
