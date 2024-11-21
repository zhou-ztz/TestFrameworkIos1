//
//  IMFileLocationHelper.swift
//  Yippi
//
//  Created by Tinnolab on 15/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class IMFileLocationHelper: NSObject {
        
    func addSkipBackupAttributeToItem(at URL: URL?) -> Bool {
        assert(FileManager.default.fileExists(atPath: URL?.path ?? ""))
        
        var success = false
        do {
            try (URL as NSURL?)?.setResourceValue(NSNumber(value: true), forKey: .isExcludedFromBackupKey)
            success = true
        } catch {
        }
        return success
        
    }
    
    func filepath(forDir dirname: String, filename: String?) -> String? {
        return (self.resourceDir(dirname) as NSString).appendingPathComponent(filename ?? "")
    }
    
    func appDocumentPath() -> String {
        
        let appKey = "45c6af3c98409b18a84451215d0bdd6e"
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
        
        let appDocumentPath = "\(paths[0])/\(appKey)/"
        if !FileManager.default.fileExists(atPath: appDocumentPath) {
            do {
                try FileManager.default.createDirectory(
                    atPath: appDocumentPath,
                    withIntermediateDirectories: true,
                    attributes: nil)
            } catch {
            }
        }
        let _ = self.addSkipBackupAttributeToItem(at: URL(fileURLWithPath: appDocumentPath))
        return appDocumentPath
    }

    func getAppTempPath() -> String? {
        return NSTemporaryDirectory()
    }

    func filepath(forVideo filename: String?) -> String? {
        return self.filepath(forDir: "video", filename: filename)
    }

    func filepath(forImage filename: String?) -> String? {
        return self.filepath(forDir: "image", filename: filename)
    }
    
    func userDirectory() -> String? {
        let documentPath = self.appDocumentPath()
        let userID = NIMSDK.shared().loginManager.currentAccount()
        let userDirectory = documentPath + userID + "/"
        if !FileManager.default.fileExists(atPath: userDirectory) {
            do {
                try FileManager.default.createDirectory(
                    atPath: userDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil)
            } catch {
            }
        }
        return userDirectory
    }
    
    func resourceDir(_ resouceName: String?) -> String {
        let dir = (self.userDirectory()! as NSString).appendingPathComponent(resouceName ?? "")
        if !FileManager.default.fileExists(atPath: dir) {
            do {
                try FileManager.default.createDirectory(
                    atPath: dir,
                    withIntermediateDirectories: false,
                    attributes: nil)
            } catch {
            }
        }
        return dir
    }
    
    func genFilename(withExt ext: String?) -> String? {
        let uuid = CFUUIDCreate(nil)
        let uuidString = CFUUIDCreateString(nil, uuid) as String
        let uuidStr = uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        let name = "\(uuidStr)"
        return (ext?.count ?? 0) != 0 ? "\(name).\(ext ?? "")" : name
    }
}
