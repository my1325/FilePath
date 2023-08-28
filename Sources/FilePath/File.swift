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
    
    func writeData(_ data: Data) throws
    
    func readData() throws -> Data
    
    func fileIterator() throws -> FileIterator
    
    func readLine(_ block: @escaping (String) -> Void) throws
    
    func readLines() throws -> [String]
}

extension FilePath {
    public var pathExtension: String {
        if let index = path.lastIndex(of: ".") {
            let startIndex = path.index(index, offsetBy: 1)
            return String(path[startIndex ..< path.endIndex])
        }
        return ""
    }
    
    public var parent: DirectoryPath {
        if let index = path.lastIndex(of: "/") {
            let range = path.startIndex ..< index
            return Directory(path: String(path[range]))
        }
        return Directory(path: path)
    }
    
    public func createIfNotExists() throws {
        guard !isExists else { return }
        try parent.createIfNotExists()
        FileManager.default.createFile(atPath: path, contents: nil)
    }
    
    public func rename(_ newName: String) throws -> Path {
        let newPath: FilePath = parent.appendFileName(newName)
        try FileManager.default.moveItem(atPath: path, toPath: newPath.path)
        return newPath
    }
    
    public func remove() throws {
        try FileManager.default.removeItem(atPath: path)
    }
    
    public func writeData(_ data: Data) throws {
        try createIfNotExists()
        try data.write(to: URL(fileURLWithPath: path))
    }
    
    public func readData() throws -> Data {
        return try Data(contentsOf: URL(fileURLWithPath: path))
    }
    
    public func fileIterator() throws -> FileIterator {
        return try FileIterator(url: URL(fileURLWithPath: path))
    }
    
    public func readLine(_ block: @escaping (String) -> Void) throws {
        for line in try fileIterator() {
            block(line)
        }
    }
    
    public func readLines() throws -> [String] {
        var lines: [String] = []
        for line in try fileIterator() {
            lines.append(line)
        }
        return lines
    }
}

struct File: FilePath {
    let path: String
}

public extension DirectoryPath {
    func appendFileName(_ name: String, ext: String = "") -> FilePath {
        File(path: String(format: "%@/%@%@", path, name, ext))
    }
}
