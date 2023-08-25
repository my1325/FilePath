//
//  File.swift
//  
//
//  Created by mayong on 2023/8/25.
//

import Foundation

public protocol FilePath: Path {
    var parent: DirectoryPath { get }
    
    var pathExtension: String { get }
}

extension FilePath {
    public func createIfNotExists() throws {
        guard !isExists else { return }
        try parent.createIfNotExists()
        FileManager.default.createFile(atPath: path, contents: nil)
    }
    
    public func rename(_ newName: String, ext: String = "") throws -> Path {
        parent.appendFileName(newName, ext: ext)
    }
}

public extension DirectoryPath {
    func appendFileName(_ name: String, ext: String = "") -> FilePath {
        File(path: String(format: "%@/%@%@", path, name, ext))
    }
}

struct File: FilePath {
//    var parent: DirectoryPath
//
//    var pathExtension: String
//
//    func remove() throws {
//        <#code#>
//    }
    
    let path: String
}
