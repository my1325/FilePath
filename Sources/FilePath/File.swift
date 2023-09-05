//
//  File.swift
//  
//
//  Created by mayong on 2023/8/25.
//

import Foundation

public protocol FilePathProtocol: PathProtocol {
    var parent: DirectoryPathProtocol { get }
    
    var pathExtension: String { get }
    
    func writeData(_ data: Data) throws
    
    func readData() throws -> Data
    
    func fileIterator() throws -> FileIterator
    
    func readLine(_ block: @escaping (String) -> Void) throws
    
    func readLines() throws -> [String]
}

extension FilePathProtocol {
    public var pathExtension: String {
        if let index = path.lastIndex(of: ".") {
            let startIndex = path.index(index, offsetBy: 1)
            return String(path[startIndex ..< path.endIndex])
        }
        return ""
    }
    
    public var parent: DirectoryPathProtocol {
        if let index = path.lastIndex(of: "/") {
            let range = path.startIndex ..< index
            return DirectoryPath(path: String(path[range]))
        }
        return DirectoryPath(path: path)
    }
    
    public func createIfNotExists() throws {
        guard !isExists else { return }
        try parent.createIfNotExists()
        FileManager.default.createFile(atPath: path, contents: nil)
    }
    
    public func rename(_ newName: String) throws -> PathProtocol {
        let newPath: FilePathProtocol = parent.appendFileName(newName)
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

public struct FilePath: FilePathProtocol {
    public let path: String
    public init(path: String) {
        self.path = path
    }
}

public extension DirectoryPathProtocol {
    func appendFileName(_ name: String, ext: String = "") -> FilePathProtocol {
        FilePath(path: String(format: "%@/%@.%@", path, name, ext))
    }
}
