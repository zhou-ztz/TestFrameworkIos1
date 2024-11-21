//
//  OBSManager.swift
//  RewardsLink
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/4/26.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit
import OBS
import KeychainAccess


let OBS_KEY = "SAVE_OBS_KEY_CHAIN"

///32 字节密钥
let AES_KEY = "325a2cc052914ceeb8c19016c091d2ac"
/// 16 字节IV
let AES_IV = "0123456789abcdef"

class OBSManager: NSObject {
    
    static let shared = OBSManager()
    
    var client: OBSClient!
    
    func initializeOBS(accessKey: String, secretKey: String, securityToken: String){
        // 初始化身份验证
        var credentialProvider = OBSStaticCredentialProvider(accessKey: accessKey, secretKey: secretKey)
        credentialProvider?.securityToken = securityToken
        //初始化服务配置
        let config = OBSServiceConfiguration(urlString: "https://obs.ap-southeast-1.myhuaweicloud.com", credentialProvider: credentialProvider)
        // 初始化client
        client = OBSClient(configuration: config)
        // 分段上传的最大并发数
        client.configuration.maxConcurrentUploadRequestCount = 10
        // 分段上传请求的最大连接数
        client.configuration.uploadSessionConfiguration.httpMaximumConnectionsPerHost = 10
        
    }
}

class OBSHelper: NSObject {
    
    static let shared = OBSHelper()
    
    func setOBSKey(data: Data){
        let keychain = Keychain(service: AppEnvironment.current.bundleIdentifier)
        do {
            try keychain.set(data, key: OBS_KEY)
        } catch let error {
            print("Error saving to keychain: \(error)")
        }
    }
    
    func getOBSKey() ->Data? {
        let keychain = Keychain(service: AppEnvironment.current.bundleIdentifier)
        do {
            let data = try keychain.getData(OBS_KEY)
            return data
        } catch let error {
            print("Error saving to keychain: \(error)")
            return nil
        }
    }
    
    func removeOBSKey(){
        let keychain = Keychain(service: AppEnvironment.current.bundleIdentifier)
        do {
            try keychain.remove(OBS_KEY)

        } catch let error {
            print("Error saving to keychain: \(error)")
        }
    }
    
    func aesDecrypt(value: String) ->String{
        var result = ""
        guard let keyData = AES_KEY.data(using: .utf8),
              let ivData = AES_IV.data(using: .utf8),
              let valueData = Data(base64Encoded: value) else {
            return result
        }
       
        if let data = valueData.aes256Decrypt(key: keyData, iv: ivData), let decryptedString = String(data: data, encoding: .utf8)  {
            result = decryptedString
        }
        print("decryptedString = \(result)")
        return result
    }
    
}
