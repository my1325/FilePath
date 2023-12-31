//
//  File.swift
//  
//
//  Created by mayong on 2023/8/18.
//

import Foundation

public class FileIterator: Sequence, IteratorProtocol {
    public typealias Element = String
    
    let encoding: String.Encoding
    let chunkSize: Int
    let fileHandle: FileHandle
    let delimPattern: Data
    var buffer: Data
    var isAtEOF: Bool = false
    
    init(url: URL, delimeter: String = "\n", encoding: String.Encoding = .utf8, chunkSize: Int = 4096) throws
    {
        fileHandle = try FileHandle(forReadingFrom: url)
        self.chunkSize = chunkSize
        self.encoding = encoding
        buffer = Data(capacity: chunkSize)
        delimPattern = delimeter.data(using: .utf8)!
    }
    
    deinit {
        fileHandle.closeFile()
    }
    
    public func makeIterator() -> FileIterator {
        fileHandle.seek(toFileOffset: 0)
        buffer.removeAll(keepingCapacity: true)
        isAtEOF = false
        return self
    }
    
    public func next() -> Element? {
        if isAtEOF { return nil }
        repeat {
            if let range = buffer.range(of: delimPattern, options: [], in: buffer.startIndex..<buffer.endIndex) {
                let subData = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
                let line = String(data: subData, encoding: encoding)
                buffer.replaceSubrange(buffer.startIndex..<range.upperBound, with: [])
                return line
            } else {
                let tempData = fileHandle.readData(ofLength: chunkSize)
                if tempData.count == 0 {
                    isAtEOF = true
                    return (buffer.count > 0) ? String(data: buffer, encoding: encoding) : nil
                }
                buffer.append(tempData)
            }
        } while true
    }
}
 
