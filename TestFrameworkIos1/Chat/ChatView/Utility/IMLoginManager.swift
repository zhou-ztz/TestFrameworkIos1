//
//  LoginData.swift
//  Yippi
//
//  Created by Tinnolab on 15/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class IMLoginData: NSObject {
    var account: String = ""
    var token: String = ""
    
    init(account: String, token: String) {
        self.account = account
        self.token = token
    }
}

class IMLoginManager: NSObject {
    var currentLoginData: IMLoginData?
    var filepath: String

    static let shared: IMLoginManager = {
        let filepath = URL(fileURLWithPath: IMFileLocationHelper().appDocumentPath()).appendingPathComponent("nim_sdk_ntes_login_data").absoluteString
        var instance = IMLoginManager(path: filepath)
        return instance
    }()
    
    init(path filepath: String) {
        self.filepath = filepath
        super.init()
        self.readData()
    }
    
    func setCurrentLoginData(_ currentLoginData: IMLoginData) {
        self.currentLoginData = currentLoginData
        saveData()
    }
    
    func readData() {
        let filepath = self.filepath
        if FileManager.default.fileExists(atPath: filepath) {
            if let object = NSKeyedUnarchiver.unarchiveObject(withFile: filepath) as? IMLoginData {
                currentLoginData = object
            }
        }
    }
    
    func saveData() {
        if let login_data = currentLoginData {
            let data = NSKeyedArchiver.archivedData(withRootObject: login_data)
            let filepathUrl = URL(fileURLWithPath:filepath)
            do {
            try data.write(to: filepathUrl)
            } catch {}
        }
    }
}
