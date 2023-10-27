//
//  File.swift
//
//
//  Created by my on 2023/10/27.
//

import Foundation

public struct FilePath: Hashable, Equatable {
    public let path: String
    public let pathURL: URL
    public let fileManager = FileManager.default
    public init(_ path: String) {
        self.path = path
        self.pathURL = URL(fileURLWithPath: path)
    }
    
    public init(_ fileURL: URL) {
        guard fileURL.isFileURL else {
            fatalError("\(fileURL) is not file URL")
        }
        self.pathURL = fileURL
        self.path = fileURL.relativePath
    }
    
    public var isFile: Bool { isExists && !pathURL.hasDirectoryPath }
    
    public var isDirectory: Bool { isExists && pathURL.hasDirectoryPath }
    
    public var isExists: Bool { fileManager.fileExists(atPath: path) }
    
    public var isReadable: Bool { fileManager.isReadableFile(atPath: path) }

    public var isWritable: Bool { fileManager.isWritableFile(atPath: path) }
    
    public var isExecutable: Bool { fileManager.isExecutableFile(atPath: path) }

    public var isDeletable: Bool { fileManager.isDeletableFile(atPath: path) }
    
    public var displayName: String { fileManager.displayName(atPath: path) }
    
    public func remove() throws { try fileManager.removeItem(atPath: path) }
    
    public func rename(_ newName: String) throws -> FilePath {
        let newPath = deletingLastPathComponent().appendingPathComponent(newName)
        try fileManager.moveItem(atPath: path, toPath: newPath.path)
        return newPath
    }
    
    public func moveTo(_ newPath: FilePath) throws {
        try fileManager.moveItem(atPath: path, toPath: newPath.path)
    }
    
    public func copyTo(_ newPath: FilePath) throws {
        try fileManager.copyItem(atPath: path, toPath: newPath.path)
    }
    
    public func createDirectoryIfNotExists(_ withIntermediateDirectories: Bool = true) throws {
        guard !isDirectory else { return }
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: withIntermediateDirectories)
    }
    
    public func createFileIfNotExists(_ data: Data? = nil) {
        guard !isFile else { return }
        fileManager.createFile(atPath: path, contents: data)
    }
    
    public func currentSubpaths() throws -> [String] {
        guard isDirectory else { return [] }
        return try fileManager.contentsOfDirectory(atPath: path)
    }
    
    public func subpaths() throws -> [String] {
        guard isDirectory else { return [] }
        return try fileManager.subpathsOfDirectory(atPath: path)
    }
}

public extension FilePath {
    var pathExtension: String { pathURL.pathExtension }
    
    var lastPathConponent: String { pathURL.lastPathComponent }
    
    var pathComponents: [String] { pathURL.pathComponents }
    
    var container: FilePath { deletingLastPathComponent() }
    
    func appendingPathComponent(_ component: String) -> FilePath { FilePath(pathURL.appendingPathComponent(component)) }
    
    func appendingPathExtension(_ extension: String) -> FilePath { FilePath(pathURL.appendingPathExtension(`extension`)) }
    
    func deletingPathExtension() -> FilePath { FilePath(pathURL.deletingPathExtension()) }

    func deletingLastPathComponent() -> FilePath { FilePath(pathURL.deletingLastPathComponent()) }
}

public extension FilePath {
    func writeData(_ data: Data) throws { try data.write(to: pathURL) }
    
    func readData() throws -> Data { try Data(contentsOf: pathURL) }
    
    func fileIterator() throws -> FileIterator? { try FileIterator(pathURL) }
    
    func readLine(_ block: @escaping (String) throws -> Void) throws { try fileIterator()?.forEach(block) }
    
    func readLines() throws -> [String] { try fileIterator()?.map({ $0 }) ?? [] }
        
    func currentSubfiles() throws -> [FilePath] { try currentSubpaths().map(appendingPathComponent) }
    
    func subfiles() throws -> [FilePath] { try subpaths().map(appendingPathComponent) }
}

public extension FilePath {
    static let document = FilePath(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    
    static let library = FilePath(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0])
    
    static let cache = FilePath(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0])
    
    static let infoPlist = FilePath(Bundle.main.path(forResource: "Info", ofType: "plist")!)

    static let temp = FilePath(NSTemporaryDirectory())
    
    static let mainBundle = FilePath(Bundle.main.bundlePath)

    static let desktop: FilePath = FilePath(NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)[0])
    
    static let download: FilePath = FilePath(NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)[0])
    
    static let user: FilePath = FilePath(NSSearchPathForDirectoriesInDomains(.userDirectory, .userDomainMask, true)[0])
    
    static let home = FilePath(NSHomeDirectory())
    
    static let current = FilePath(FileManager.default.currentDirectoryPath)
    
    static func changeToCurrent(_ newCurrent: String) { FileManager.default.changeCurrentDirectoryPath(newCurrent) }
}

extension FilePath: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { path.description }
    
    public var debugDescription: String { path.debugDescription }
}
