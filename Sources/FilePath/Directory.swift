//
//  File.swift
//
//
//  Created by mayong on 2023/8/25.
//

import Foundation

public protocol DirectoryPath: Path {
    var parent: DirectoryPath { get }
    
    var subpaths: [String] { get }
    
    var isEmpty: Bool { get }
        
    func appendConponent(_ name: String) -> DirectoryPath
}

public extension DirectoryPath {
    var subpaths: [String] {
        FileManager.default.subpaths(atPath: path) ?? []
    }
    
    var isEmpty: Bool {
        subpaths.isEmpty
    }
    
    func createIfNotExists() throws {
        guard !isExists else { return }
        try parent.createIfNotExists()
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
    }
    
    func rename(_ newName: String) throws -> Path {
        let newPath: DirectoryPath = parent.appendConponent(newName)
        try FileManager.default.moveItem(atPath: path, toPath: newPath.path)
        return newPath
    }
    
    func remove() throws {
        var fileStack: [String] = [path]
        while !fileStack.isEmpty {
            let file = fileStack.last!
            
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: file, isDirectory: &isDirectory) else {
                fileStack.removeLast()
                continue
            }
            
            if !isDirectory.boolValue {
                try FileManager.default.removeItem(atPath: file)
                fileStack.removeLast()
            } else {
                let subpaths = FileManager.default.subpaths(atPath: file) ?? []
                if subpaths.isEmpty {
                    try FileManager.default.removeItem(atPath: file)
                    fileStack.removeLast()
                } else {
                    for subpath in subpaths {
                        let fullPath = String(format: "%@/%@", file, subpath)
                        fileStack.append(fullPath)
                    }
                }
            }
        }
    }
}

public struct Directory {
    public let path: String
    
    public static let document = Directory(path: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    public static let library = Directory(path: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0])
    public static let cache = Directory(path: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0])
    
    public static let desktop = Directory(path: NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)[0])
    public static let download = Directory(path: NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)[0])
    
    public static let infoPlist = Directory(path: Bundle.main.path(forResource: "Info", ofType: "plist")!)

    public static let temp = Directory(path: NSTemporaryDirectory())
    public static let home = Directory(path: NSHomeDirectory())
    
    public static let mainBundle = Directory(path: Bundle.main.bundlePath)
}

extension Directory: DirectoryPath {
    public func appendConponent(_ name: String) -> DirectoryPath {
        let fullPath = String(format: "%@/%@", path, name)
        return Directory(path: fullPath)
    }
    
    public var parent: DirectoryPath {
        if let index = path.lastIndex(of: "/") {
            let range = path.startIndex ..< index
            return Directory(path: String(path[range]))
        }
        return self
    }
}
