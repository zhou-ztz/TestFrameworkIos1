//
//  TSAccountTokenModel.swift
//  Thinksns Plus
//
//  Created by lip on 2017/1/6.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  账户口令数据模型

import UIKit
import SwiftyJSON
import ObjectMapper

class TSAccountTokenModel: Mappable, Decodable {
    
    static let TSAccountNeteaseTokenKey = "TSAccountNeteaseTokenSaveKey"
    static let TSAccountTokenKey = "TSAccountTokenSaveKey"
    static let TSAccountExpireIntervalKey = "TSAccountExpireIntervalKey"
    static let TSAccountCreateDateKey = "TSAccountCreateDateKey"
    static let TSAccountTokenType = "TSAccountTokenType"

    /// Token to log in IM
    var neteaseToken: String = ""
    var token: String = ""
    /// Authorization code expiration interval(TTL time in minutes)
    var expireInterval: Int = 0
    /// Use the authorization code to refresh the interval of the authorization code.
    var refreshTTL: Int = 0
    /// Token type
    var tokenType: String = ""

    /// 创建日期，使用请求之前的
    var createInterval: Int = Int(Date().timeIntervalSince1970)
    
    enum CodingKeys: String, CodingKey {
        case token = "access_token"
        case tokenType = "token_type"
        case expireInterval = "expires_in"
        case refreshTTL = "refresh_ttl"
    }

    /// 持久化相关信息
    func save() {
        UserDefaults.standard.setValue(self.neteaseToken, forKey: TSAccountTokenModel.TSAccountNeteaseTokenKey)
        UserDefaults.standard.setValue(self.token, forKey: TSAccountTokenModel.TSAccountTokenKey)
        UserDefaults.standard.setValue(self.expireInterval, forKey: TSAccountTokenModel.TSAccountExpireIntervalKey)
        UserDefaults.standard.setValue(self.createInterval, forKey: TSAccountTokenModel.TSAccountCreateDateKey)
        UserDefaults.standard.setValue(self.tokenType, forKey: TSAccountTokenModel.TSAccountTokenType)
        UserDefaults.standard.synchronize()
    }

    /// 重置相关信息
    static func reset() {
        userConfiguration = nil
        
        UserDefaults.standard.removeObject(forKey: TSAccountTokenModel.TSAccountNeteaseTokenKey)
        UserDefaults.standard.removeObject(forKey: TSAccountTokenModel.TSAccountTokenKey)
        UserDefaults.standard.removeObject(forKey: TSAccountTokenModel.TSAccountExpireIntervalKey)
        UserDefaults.standard.removeObject(forKey: TSAccountTokenModel.TSAccountCreateDateKey)
        UserDefaults.standard.removeObject(forKey: TSAccountTokenModel.TSAccountTokenType)
        //remove advert repeat flag
        UserDefaults.standard.removeObject(forKey: "AdvertRepeatFlag")
    }
    
    init?(with token: String, neteaseToken: String = "", expireInterval: Int, refreshTTL: Int, tokenType: String) {
        self.neteaseToken = neteaseToken
        self.tokenType = tokenType
        self.token = token
        self.expireInterval = expireInterval
        self.refreshTTL = refreshTTL
    }

    /// 通过沙盒内数据初始化
    // invalid redeclaration of init
    init?() {
        let token = UserDefaults.standard.string(forKey: TSAccountTokenModel.TSAccountTokenKey)
        if nil == token || token!.isEmpty {
            return nil
        }
        self.token = token!
        self.neteaseToken = UserDefaults.standard.string(forKey: TSAccountTokenModel.TSAccountNeteaseTokenKey).orEmpty
        self.expireInterval = UserDefaults.standard.integer(forKey: TSAccountTokenModel.TSAccountExpireIntervalKey)
        self.createInterval = UserDefaults.standard.integer(forKey: TSAccountTokenModel.TSAccountCreateDateKey)
        self.tokenType = UserDefaults.standard.string(forKey: TSAccountTokenModel.TSAccountTokenType) ?? "Bearer"
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        token <- map["access_token"]
        if token.count <= 0 {
            token <- map["token"]
        }
        expireInterval <- map["expires_in"]
        if expireInterval <= 0 {
            expireInterval <- map["ttl"]
        }
        refreshTTL <- map["refresh_ttl"]
    }
}
