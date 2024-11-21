//
//  FileManager.swift
//  YippiCore
//
//  Created by Kit Foong on 24/09/2024.
//  Copyright © 2024 Chew. All rights reserved.
//

import Foundation
import UIKit

public class FileControlManager: NSObject {
    public static let shared = FileControlManager()
    
   public  func getFilesFromPath(_ path: URL) -> [URL] {
        let fileManager = FileManager.default
        var files : [URL] = []
        do {
            if let temp = try? fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil) {
                files = temp
            }
        } catch let error {
            printIfDebug(error.localizedDescription)
        }
        return files
    }
    
    @discardableResult public func deleteFile(atPath filePath: String?) -> Bool {
        guard let filePath = filePath else { return false }
        do {
            try FileManager.default.removeItem(atPath: filePath)
            return true
        } catch {
            
        }
        
        return false
    }
    
    public func getFileSizeInMB(for filePath: String) -> Double? {
        let fileManager = FileManager.default
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: filePath)
            
            // Get file size attribute in bytes
            if let fileSize = attributes[.size] as? Int64 {
                // Convert bytes to megabytes (MB)
                let fileSizeInMB = Double(fileSize) / 1_048_576
                return fileSizeInMB
            }
        } catch {
            printIfDebug("Error retrieving file size: \(error.localizedDescription)")
        }
        
        return nil
    }
}
