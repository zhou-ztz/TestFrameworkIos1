//
//  UserDefaults+Extensions.swift
//  YippiCore
//
//  Created by francis on 29/07/2019.
//  Copyright © 2019 Chew. All rights reserved.
//

import Foundation
import UIKit

fileprivate let standardDefaults = UserDefaults.standard

public protocol VerifyCacheAccountInfo {
    func setCache(name: String, idnum: String, bday: Date)
    func getAccountCache() -> (name: String, idnum: String, bday: Date)?
    func clearVerifyAccCache()
}

public protocol VerifyCacheUserInfo {
    func setCache(for objects: [VerifyImageCacheObject])
    func getImageCache() -> [VerifyImageCacheObject]?
    func clearVerifyUserCache() 
}

public protocol VerifyAddressUserInfo {
    func setCache(for objects: [String: String])
    func getAddressCache() -> [String: String]?
    func clearCache()
}


extension UserDefaults: VerifyCacheAccountInfo {
    
    public func clearVerifyAccCache() {
        standardDefaults.removeObject(forKey: "verify_account_cache")
        standardDefaults.synchronize()
    }
    
    public func setCache(name: String, idnum: String, bday: Date) {
        let dictionary: [String: Any] = [
            "name": name,
            "idnum": idnum,
            "bday": bday.timeIntervalSinceReferenceDate
        ]
        
        standardDefaults.set(dictionary, forKey: "verify_account_cache")
        standardDefaults.synchronize()
    }
    
    public func getAccountCache() -> (name: String, idnum: String, bday: Date)? {
        
        guard let dictionary: [String: Any] = standardDefaults.dictionary(forKey: "verify_account_cache") else { return nil }
        
        guard let name = (dictionary["name"] as? String),
            let idnum = (dictionary["idnum"] as? String),
            let bday = (dictionary["bday"] as? TimeInterval) else {
            return nil
        }
        
        return (name: name, idnum: idnum, bday: Date.init(timeIntervalSinceReferenceDate: bday))
    }
    
}

extension UserDefaults: VerifyCacheUserInfo {
    
    public func clearVerifyUserCache() {
        standardDefaults.removeObject(forKey: "verify_user_cache_object")
        standardDefaults.synchronize()
    }

    public func setCache(for objects: [VerifyImageCacheObject]) {
        var data: [[String: Any]] = []
        
        for item in objects {
            let dict: [String : Any] = [
                "image": item.image.saveImage(name: "\(item.imageType.rawValue)-verify"),
                "type": item.imageType.rawValue
                ]
            
            data.append(dict)
        }
        
        standardDefaults.set(data, forKey: "verify_user_cache_object")
        standardDefaults.synchronize()
    }
    
    public func getImageCache() -> [VerifyImageCacheObject]? {
        guard let cacheData = standardDefaults.object(forKey: "verify_user_cache_object") as? [[String: Any]] else { return nil }
        
        var results: [VerifyImageCacheObject] = []
        
        for data in cacheData {
            if let imagePath = data["image"] as? String,
                let rawType = data["type"] as? String,
                let image = UIImage.loadImageFromDocumentsDirectory(for: imagePath),
                let imageType = VerifyCacheUserImageType(rawValue: rawType) {
                
                let obj = VerifyImageCacheObject(image: image, imageType: imageType)
                results.append(obj)
            }
        }
        
        return results
    }
}

extension UserDefaults: VerifyAddressUserInfo {
    
    public func clearCache() {
        standardDefaults.removeObject(forKey: "verify_user_address_dictionary")
        standardDefaults.synchronize()
    }
    
    
    public func setCache(for objects: [String: String]) {
        var cache: [String: String]
        
        if let _cache = (self as VerifyAddressUserInfo).getAddressCache()   {
            cache = _cache
        } else {
            cache = [:]
        }
        
        for (key, value) in objects {
            cache[key] = value
        }
        
        standardDefaults.set(cache, forKey: "verify_user_address_dictionary")
        standardDefaults.synchronize()
    }
    
    
    public func getAddressCache() -> [String: String]? {
        guard let dictionary: [String: String] = standardDefaults.dictionary(forKey: "verify_user_address_dictionary") as? [String : String] else { return nil }

        return dictionary
    }
    
}

public enum VerifyCacheUserImageType: String, Codable {
    case front = "front"
    case selfie = "selfie"
}

public struct VerifyImageCacheObject {
    public let image: UIImage
    public let imageType: VerifyCacheUserImageType
    
    public init(image: UIImage, imageType: VerifyCacheUserImageType) {
        self.image = image
        self.imageType = imageType
    }
}
