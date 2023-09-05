//
//  File 2.swift
//  
//
//  Created by mayong on 2023/8/28.
//

import Foundation

public class DirectoryIterator: Sequence, IteratorProtocol {
    public typealias Element = PathProtocol
    private var nextIndex = 0
    let directory: DirectoryPathProtocol
    let subpaths: [String]
    init(directory: DirectoryPathProtocol) {
        self.directory = directory
        self.subpaths = directory.subpaths
    }
    
    public func makeIterator() -> DirectoryIterator {
        nextIndex = 0
        return self
    }
    
    public func next() -> Element? {
        defer { nextIndex += 1 }
        return DirectoryPath(path: subpaths[nextIndex])
    }
}
