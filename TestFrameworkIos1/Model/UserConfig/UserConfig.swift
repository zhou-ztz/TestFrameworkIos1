//
//  UserConfig.swift
//  Yippi
//
//  Created by Francis Yeap on 04/11/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation


var userConfiguration: UserConfig? {
    set {
        if newValue == nil {
            return
        }
        UserConfig.default = UserConfig.get()
    }
    get {
        return UserConfig.default
    }
}

// Note: should not contain sensitive information here
// 注： 不应包含用户的敏感信息
class UserConfig: Codable {
    
    static var `default` = UserConfig.get()
    // objectbox: index
    var username: String?
    
    // objectbox: index
    var displayname: String?
    var avatarUrl: String?
    var certificateUrl: String?
    var feedcontentCountry: CountryCode?
    var discoverCountry: CountryCode?
    var starRankCountry: CountryCode?
    var liveCountry: CountryCode?
    var miniVideoCountry: CountryCode?
    var discoverLanguageCode: LanguageCode?
    var searchLanguageCode: LanguageCode?
    var liveLanguageCode: LanguageCode?
    var miniVideoLanguageCode: LanguageCode?
    
    var activeSessions: [TSDuration] = [] { didSet { save() } }
    var languageRefreshTime: Date? { didSet { save() } }
    var countryRefreshTime: Date? { didSet { save() } }
    var messageRequestCount: Int? { didSet { save() } }
    
    // objectbox: transient
    let sesssionCheckThrottler: Throttler = Throttler(time: .seconds(1.5), queue: .main, mode: .fixed, immediateFire: true, nil)
    
    // objectbox: transient
    static var fileComponents: FileURLComponents? {
        guard let user = CurrentUserSessionInfo else { return nil }
        return FileURLComponents(fileName: "\(user.username)-config", fileExtension: "", directoryName: nil, directoryPath: .documentDirectory)
    }
    
//    var language: LanguageEntity? {
//        do {            
//            let box = store.box(for: LanguageEntity.self)
//            let query = try box.query {
//                LanguageEntity.code == languageCode.orEmpty
//            }.build()
//            let result = try query.findFirst()
//            return result
//        } catch {
//            return nil
//        }
//    }
    
    enum CodingKeys: String, CodingKey {
        case displayname
        case avatarUrl
        case certificateUrl
        case feedcontentCountry
        case discoverCountry
        case starRankCountry
        case discoverLanguageCode
        case searchLanguageCode
        case activeSessions
        case messageRequestCount
    }
    
    func setSessionTrottlerCallback() {
        guard TSCurrentUserInfo.share.isLogin == true else {
            return
        }
        sesssionCheckThrottler.callback = {
            userConfiguration?.checkUserSessionDuration()
        }
    }
    
    func delete() {
        do {
            guard let fileComponents = UserConfig.fileComponents else { return }
            _ = try File.delete(fileComponents)
        } catch let err {
            assert(false, err.localizedDescription)
        }
    }
    
    func save() {
        // check for log in state
        do {
            guard let fileComponents = UserConfig.fileComponents else { return }
            let data = try JSONEncoder().encode(self)
            _ = try File.write(data, to: fileComponents)
            
        } catch let err {
            assert(false, err.localizedDescription)
        }
    }
    
    static func get() -> UserConfig? {
        
        var session: UserConfig? = nil
        
        do {
            guard let fileComponents = fileComponents else { return nil }
            let data = try File.read(from: fileComponents)
            let obj = try? JSONDecoder().decode(UserConfig.self, from: data)
            session = obj
        } catch {
            session = UserConfig()
            guard let user = CurrentUserSessionInfo else { return nil }
            session?.avatarUrl = user.avatarUrl
            session?.certificateUrl = user.verificationIcon
            session?.displayname = user.name
            session?.username = user.username
        }
        
        if session?.feedcontentCountry?.isEmpty == true  {
           session?.feedcontentCountry = CurrentUserSessionInfo?.country ?? ""
        }
        
//        if (session?.discoverCountry.orEmpty) == "" {
//            session?.discoverCountry = CurrentUserSessionInfo?.country ?? ""
//        }
        // 当discoverCountry 为 "" 其实默认是查询全球的数据
        if session?.discoverCountry == nil {
            session?.discoverCountry = CurrentUserSessionInfo?.country ?? ""
        }
        
        if session?.starRankCountry == nil {
            session?.starRankCountry = CurrentUserSessionInfo?.country ?? ""
        }
        
        if session?.liveCountry == nil {
            session?.liveCountry = CurrentUserSessionInfo?.country ?? ""
        }

        if session?.miniVideoCountry == nil {
            session?.miniVideoCountry = CurrentUserSessionInfo?.country ?? ""
        }

        session?.setSessionTrottlerCallback()
        return session
    }
    
}
