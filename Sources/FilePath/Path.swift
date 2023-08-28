//
//  File.swift
//  
//
//  Created by mayong on 2023/8/18.
//

import Foundation

public protocol Path {
    var path: String { get }
    
    var isExists: Bool { get }
        
    var lastPathConponent: String { get }
    
    var isFile: Bool { get }
    
    var isDirectory: Bool { get }
        
    func moveToNewPath(_ newPath: Path) throws

    func rename(_ newName: String) throws -> Path
    
    func createIfNotExists() throws
    
    func remove() throws
}

public extension Path {
    var isFile: Bool {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
            return !isDirectory.boolValue
        }
        return false
    }
    
    var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
            return isDirectory.boolValue
        }
        return false
    }
    
    var isExists: Bool {
        FileManager.default.fileExists(atPath: path)
    }
    
    var lastPathConponent: String {
        if let index = path.lastIndex(of: "/") {
            let range = index ..< path.endIndex
            return String(path[range])
        }
        return path
    }
    
    func moveToNewPath(_ newPath: Path) throws {
        try FileManager.default.moveItem(atPath: self.path, toPath: newPath.path)
    }
    
    static func instanceOfPath(_ path: String) -> Path? {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                return Directory(path: path)
            } else {
                return File(path: path)
            }
        }
        return nil
    }
}
