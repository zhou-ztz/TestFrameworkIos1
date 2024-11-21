// 
// Copyright © 2018 Toga Capital. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

@objcMembers
public final class TSUser: NSObject, Codable, DefaultsSerializable {
    public let uid: String
    public let phone: String
    public let username: String
    public let nickname: String
    
    public var token: String {
        return UserDefaults.standard.string(forKey: "TSAccountTokenSaveKey").orEmpty
    }
//    public let remark: String
//    public let headsmall: String
//    public let headlarge: String
//    public let sign: String        // 个性签名
//    public let gender: String      // 性别 0-男 1-女 2-未填写
//    public let province: String
//    public let city: String
//    public let isvip: Bool
    
    // REMARKS: This is for Friend, most likely no used, can be removed in future
    // public private(set) var getmsg: Bool        // 是否接受用户的新消息
    // public private(set) var isstar: Bool        // 是否星标朋友
    // public private(set) var isfriend: Bool      // 0 没关系 1 好友
    // public private(set) var verify: Bool        // 0-不验证 1-验证 （加好友）
    // public private(set) var sort: String        // 排序位置
    // public private(set) var isblack: Bool       // 是否在黑名单
    // public private(set) var waitforadd: Bool    // 存在好友申请
    // public private(set) var type: Int           // type 0-等待自己同意 1-等待验证 2-已添加
    // public private(set) var fauth1: Int         // 0-看 1-不看 当前用户是否看另个用户的朋友圈
    // public private(set) var fauth2: Int         // 0-看 1-不看 当前用户不让另个用户查看我的朋友圈
    // public private(set) var cover: String       // 朋友圈相册封面
    // public private(set) var picture1: String    // 最新照片
    // public private(set) var picture2: String    // 最新照片
    // public private(set) var picture3: String    // 最新照片
    
    // REMARKS: Social User, hopefully will be combined in future
//    public let email: String?
//    public let createtime: String
//    public let socialID: Int
//    public let token: String
//    public let secret: String
    public let displayname: String
//    public let photoID: Int
//    public let status: String?
//    public let statusDate: Date?
//    public let locale: String
//    public let language: String
//    public let timezone: String
//    public let search: Bool
//    public let showProfileviewers: Bool
//    public let levelID: Int
//    public let invitesUsed: Int
//    public let extraInvites: Int
//    public let enabled: Bool
//    public let verified: Bool
//    public let approved: Bool
//    public let creationDate: Date?
//    public let creationIP: String?
//    public let modifiedDate: Date?
//    public let lastloginDate: Date?
//    public let lastloginIP: String?
//    public let updateDate: Date?
//    public let memberCount: Int
//    public let viewCount: Int
//    public let commentCount: Int
//    public let likeCount: Int
//    public let seaoLocationid: Int
//    public let location: String
//    public let followCount: Int
//    public let userCover: String
    
    enum CodingKeys: String, CodingKey {
        case uid = "uid"
        case username = "username"
        case phone = "phone"
//        case email = "email"
        case nickname = "nickname"
//        case isvip = "isvip"
//        case headsmall = "headsmall"
//        case headlarge = "headlarge"
//        case gender = "gender"
//        case sign = "sign"
//        case province = "province"
//        case city = "city"
//        case remark = "remark"
//        case createtime = "createtime"
//        case socialID = "social_id"
//        case token = "token"
//        case secret = "secret"
        case displayname = "displayname"
//        case photoID = "photo_id"
//        case status = "status"
//        case statusDate = "status_date"
//        case locale = "locale"
//        case language = "language"
//        case timezone = "timezone"
//        case search = "search"
//        case showProfileviewers = "show_profileviewers"
//        case levelID = "level_id"
//        case invitesUsed = "invites_used"
//        case extraInvites = "extra_invites"
//        case enabled = "enabled"
//        case verified = "verified"
//        case approved = "approved"
//        case creationDate = "creation_date"
//        case creationIP = "creation_ip"
//        case modifiedDate = "modified_date"
//        case lastloginDate = "lastlogin_date"
//        case lastloginIP = "lastlogin_ip"
//        case updateDate = "update_date"
//        case memberCount = "member_count"
//        case viewCount = "view_count"
//        case commentCount = "comment_count"
//        case likeCount = "like_count"
//        case seaoLocationid = "seao_locationid"
//        case location = "location"
//        case followCount = "follow_count"
//        case userCover = "user_cover"
    }
    
    public init(uid: String, username: String, phone: String, nickname: String, displayname: String
//                , remark: String, email: String?, isvip: Bool, headsmall: String, headlarge: String, gender: String, sign: String, province: String, city: String, createtime: String, socialID: Int, token: String, secret: String, displayname: String, photoID: Int, status: String?, statusDate: Date?, locale: String, language: String, timezone: String, search: Bool, showProfileviewers: Bool, levelID: Int, invitesUsed: Int, extraInvites: Int, enabled: Bool, verified: Bool, approved: Bool, creationDate: Date?, creationIP: String?, modifiedDate: Date?, lastloginDate: Date?, lastloginIP: String?, updateDate: Date?, memberCount: Int, viewCount: Int, commentCount: Int, likeCount: Int, seaoLocationid: Int, location: String, followCount: Int, userCover: String
    ) {
        self.uid = uid
        self.username = username
        self.phone = phone
        self.nickname = nickname
//        self.remark = remark
//        self.email = email
//        self.isvip = isvip
//        self.headsmall = headsmall
//        self.headlarge = headlarge
//        self.gender = gender
//        self.sign = sign
//        self.province = province
//        self.city = city
//        self.createtime = createtime
//        self.socialID = socialID
//        self.token = token
//        self.secret = secret
        self.displayname = displayname
//        self.photoID = photoID
//        self.status = status
//        self.statusDate = statusDate
//        self.locale = locale
//        self.language = language
//        self.timezone = timezone
//        self.search = search
//        self.showProfileviewers = showProfileviewers
//        self.levelID = levelID
//        self.invitesUsed = invitesUsed
//        self.extraInvites = extraInvites
//        self.enabled = enabled
//        self.verified = verified
//        self.approved = approved
//        self.creationDate = creationDate
//        self.creationIP = creationIP
//        self.modifiedDate = modifiedDate
//        self.lastloginDate = lastloginDate
//        self.lastloginIP = lastloginIP
//        self.updateDate = updateDate
//        self.memberCount = memberCount
//        self.viewCount = viewCount
//        self.commentCount = commentCount
//        self.likeCount = likeCount
//        self.seaoLocationid = seaoLocationid
//        self.location = location
//        self.followCount = followCount
//        self.userCover = userCover
    }
}

extension TSUser {
    private static func parseBool(_ container: KeyedDecodingContainer<CodingKeys>, forKey: KeyedDecodingContainer<CodingKeys>.Key) -> Bool {
        if let boolValue = try? container.decode(Bool.self, forKey: forKey) {
            return boolValue
        } else if let stringValue = try? container.decode(String.self, forKey: forKey) {
            return Bool(value: stringValue)
        }
        
        return false
    }
    
    private static func parseInt(_ container: KeyedDecodingContainer<CodingKeys>, forKey: KeyedDecodingContainer<CodingKeys>.Key) -> Int? {
        if let intValue = try? container.decode(Int.self, forKey: forKey) {
            return intValue
        } else if let stringValue = try? container.decode(String.self, forKey: forKey) {
            return Int(stringValue)
        }
        
        return nil
    }
    
    private static func parseDate(_ container: KeyedDecodingContainer<CodingKeys>, forKey: KeyedDecodingContainer<CodingKeys>.Key) -> Date? {
        if !container.contains(forKey) {
            return nil
        }
        
        do {
            if try container.decodeNil(forKey: forKey) {
                return nil
            }
        } catch {
            return nil
        }
        
        if let dateValue = try? container.decode(Date.self, forKey: forKey) {
            return dateValue
        } else if let stringValue = try? container.decode(String.self, forKey: forKey) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            return dateFormatter.date(from: stringValue)
        }
        
        return nil
    }


    public func update(headsmall: String, headlarge: String) -> TSUser {
        return TSUser(uid: self.uid, username: self.username, phone: self.phone, nickname: self.nickname, displayname: self.displayname
//            , remark: self.remark, email: self.email, isvip: self.isvip, headsmall: headsmall , headlarge: headlarge, gender: self.gender, sign: self.sign, province: self.province, city: self.city, createtime: self.createtime, socialID: self.socialID, token: self.token, secret: self.secret, displayname: self.displayname, photoID: self.photoID, status: self.status, statusDate: self.statusDate, locale: self.locale, language: self.language, timezone: self.timezone, search: self.search, showProfileviewers: self.showProfileviewers, levelID: self.levelID, invitesUsed: self.invitesUsed, extraInvites: self.extraInvites, enabled: self.enabled, verified: self.verified, approved: self.approved, creationDate: self.creationDate, creationIP: self.creationIP, modifiedDate: self.modifiedDate, lastloginDate: self.lastloginDate, lastloginIP: self.lastloginIP, updateDate: self.updateDate, memberCount: self.memberCount, viewCount: self.viewCount, commentCount: self.commentCount, likeCount: self.likeCount, seaoLocationid: self.seaoLocationid, location: self.location, followCount: self.followCount, userCover: self.userCover
        )
    }
    
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let uid = try container.decode(String.self, forKey: .uid)
        let username = try container.decode(String.self, forKey: .username)
        let phone = try container.decode(String.self, forKey: .phone)
        let nickname = try container.decode(String.self, forKey: .nickname)
//        let remark = try container.decode(String.self, forKey: .remark)
//        let email = try container.decodeIfPresent(String.self, forKey: .email)
//        let isvip = User.parseBool(container, forKey: .isvip)
//        let headsmall = try container.decodeIfPresent(String.self, forKey: .headsmall) ?? ""
//        let headlarge = try container.decode(String.self, forKey: .headlarge)
//        let gender = try container.decode(String.self, forKey: .gender)
//        let sign = try container.decode(String.self, forKey: .sign)
//        let province = try container.decode(String.self, forKey: .province)
//        let city = try container.decode(String.self, forKey: .city)
//        let createtime = try container.decode(String.self, forKey: .createtime)
//        let socialID = User.parseInt(container, forKey: .socialID)!
//        let token = try container.decode(String.self, forKey: .token)
//        let secret = try container.decode(String.self, forKey: .secret)
        let displayname = try container.decode(String.self, forKey: .displayname)
//        let photoID = User.parseInt(container, forKey: .photoID) ?? 0
//        let status = try container.decodeIfPresent(String.self, forKey: .status)
//        let statusDate = User.parseDate(container, forKey: .statusDate)
//        let locale = try container.decode(String.self, forKey: .locale)
//        let language = try container.decode(String.self, forKey: .language)
//        let timezone = try container.decode(String.self, forKey: .timezone)
//        let search = User.parseBool(container, forKey: .search)
//        let showProfileviewers = User.parseBool(container,  forKey: .showProfileviewers)
//        let levelID = User.parseInt(container, forKey: .levelID) ?? 0
//        let invitesUsed = User.parseInt(container, forKey: .invitesUsed) ?? 0
//        let extraInvites = User.parseInt(container, forKey: .extraInvites) ?? 0
//        let enabled = User.parseBool(container, forKey: .enabled)
//        let verified = User.parseBool(container, forKey: .verified)
//        let approved = User.parseBool(container, forKey: .approved)
//        let creationDate = User.parseDate(container, forKey: .creationDate)
//        let creationIP = try container.decodeIfPresent(String.self, forKey: .creationIP)
//        let lastloginDate = User.parseDate(container, forKey: .lastloginDate)
//        let modifiedDate = User.parseDate(container, forKey: .modifiedDate)
//        let lastloginIP = try container.decodeIfPresent(String.self, forKey: .lastloginIP)
//        let updateDate = User.parseDate(container, forKey: .updateDate)
//        let memberCount = User.parseInt(container, forKey: .memberCount) ?? 0
//        let viewCount = User.parseInt(container, forKey: .viewCount) ?? 0
//        let commentCount = User.parseInt(container, forKey: .commentCount) ?? 0
//        let likeCount = User.parseInt(container, forKey: .likeCount) ?? 0
//        let seaoLocationid = User.parseInt(container, forKey: .seaoLocationid) ?? 0
//        let location = try container.decode(String.self, forKey: .location)
//        let followCount = User.parseInt(container, forKey: .followCount) ?? 0
//        let userCover = try container.decode(String.self, forKey: .userCover)
        
        self.init(uid: uid, username: username, phone: phone, nickname: nickname, displayname: displayname
//                  , remark: remark, email: email, isvip: isvip, headsmall: headsmall, headlarge: headlarge, gender: gender, sign: sign, province: province, city: city, createtime: createtime, socialID: socialID, token: token, secret: secret, displayname: displayname, photoID: photoID, status: status, statusDate: statusDate, locale: locale, language: language, timezone: timezone, search: search, showProfileviewers: showProfileviewers, levelID: levelID, invitesUsed: invitesUsed, extraInvites: extraInvites, enabled: enabled, verified: verified, approved: approved, creationDate: creationDate, creationIP: creationIP, modifiedDate: modifiedDate, lastloginDate: lastloginDate, lastloginIP: lastloginIP, updateDate: updateDate, memberCount: memberCount, viewCount: viewCount, commentCount: commentCount, likeCount: likeCount, seaoLocationid: seaoLocationid, location: location, followCount: followCount, userCover: userCover
        )
    }
}


public struct ProfileSetting: Decodable {
    public let uid, sort, username, phone: String
    public let email, password, nickname, isvip: String
    public let headlarge: String
    public let headsmall: String?
    public let gender, sign, province, city: String
    public let isfriend: Int
    public let isblack, verify, isstar, remark: String
    public let getmsg, fauth1, fauth2: String
    public let picture1, picture2, picture3, cover, createtime: String
    
    public func update(_ oldUser: TSUser) -> TSUser {
        let newUser = TSUser(uid: oldUser.uid, username: oldUser.username, phone: oldUser.phone, nickname: self.nickname, displayname: ""

//            , remark: oldUser.remark, email: self.email, isvip: oldUser.isvip, headsmall: self.headsmall ?? "", headlarge: self.headlarge, gender: self.gender, sign: self.sign, province: oldUser.province, city: oldUser.city, createtime: oldUser.createtime, socialID: oldUser.socialID, token: oldUser.token, secret: oldUser.secret, displayname: oldUser.displayname, photoID: oldUser.photoID, status: oldUser.status, statusDate: oldUser.statusDate, locale: oldUser.locale, language: oldUser.language, timezone: oldUser.timezone, search: oldUser.search, showProfileviewers: oldUser.showProfileviewers, levelID: oldUser.levelID, invitesUsed: oldUser.invitesUsed, extraInvites: oldUser.extraInvites, enabled: oldUser.enabled, verified: oldUser.verified, approved: oldUser.approved, creationDate: oldUser.creationDate, creationIP: oldUser.creationIP, modifiedDate: oldUser.modifiedDate, lastloginDate: oldUser.lastloginDate, lastloginIP: oldUser.lastloginIP, updateDate: oldUser.updateDate, memberCount: oldUser.memberCount, viewCount: oldUser.viewCount, commentCount: oldUser.commentCount, likeCount: oldUser.likeCount, seaoLocationid: oldUser.seaoLocationid, location: oldUser.location, followCount: oldUser.followCount, userCover: oldUser.userCover
        )
        return newUser
    }
}
