//
//  File 2.swift
//  
//
//  Created by mayong on 2023/8/28.
//

import Foundation

public class DirectoryIterator: Sequence, IteratorProtocol {
    public typealias Element = Path
    private var nextIndex = 0
    let directory: DirectoryPath
    let subpaths: [String]
    init(directory: DirectoryPath) {
        self.directory = directory
        self.subpaths = directory.subpaths
    }
    
    public func makeIterator() -> DirectoryIterator {
        nextIndex = 0
        return self
    }
    
    public func next() -> Element? {
        defer { nextIndex += 1 }
        return Directory.instanceOfPath(subpaths[nextIndex])
    }
}
