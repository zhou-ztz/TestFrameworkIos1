//
//  Cacher.swift
//  Yippi
//
//  Created by CC Teoh on 31/10/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation

public enum cacheType: Int {
    case video, photo, document
}

public class Cacher: NSObject {
    private(set) var pathComponent: String
    private(set) var cacheType: cacheType?

    public init(with pathComponent: String, cacheType: cacheType) {
        self.pathComponent = pathComponent
        self.cacheType = cacheType
    }
    
    static private func rootPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }
    
    public func cacheDir() -> String {
        let path = (Cacher.rootPath() as NSString).appendingPathComponent(self.pathComponent)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path, isDirectory: nil) == false {
            do {
                try fileManager.createDirectory(atPath: path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                // do nothing
            }
        }
        return path
    }

    public func deleteCache(path: String) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path, isDirectory: nil) == true {
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
                throw error
            }
        }
    }
}

