//
//  UserInfoModel.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/15.
//  Copyright © 2017年 LeonFa. All rights reserved.
//
//  用户信息数据模型
//  全局使用

import UIKit
import SwiftyJSON
import ObjectMapper
import ObjectBox

struct UserInfoModel: UserInfoType, Mappable, Entity {

    // objectbox: id = { "assignable": true }
    var id: Id = 0
    var userIdentity: Int = 0
    
    // objectbox: transient
    var name: String {
        get {
            return LocalRemarkName.getRemarkName(userId: userIdentity.stringValue, username: username, originalName: displayName, label: nil)
        }
        set {
            displayName = newValue
        }
    }
    var displayName: String = ""

    
    var username: String = ""

    // objectbox: transient
    var remarkName: String? {
        return LocalRemarkName.getRemarkName(userId: "\(self.userIdentity)", username: self.username, originalName: self.name, label: nil)
    }

    var phone: String?
    var mobi: String?

    var email: String?
    var sex: Int = 0 /// The user's gender, 0 - Unknown, 1 - Man, 2 - Woman.
    var bio: String?
    var location: String?
    var createDate: Date?
    var updateDate: Date?
    var avatarUrl: String?
    var avatarMime: String?
    var coverUrl: String?
    var coverMime: String?
    var following: Bool = false
    var follower: Bool = false
    var friendsCount: Int = 0
    var otpDevice: Bool = false

    // verification
    var verificationIcon: String?
    var verificationType: String?

    // extra
    var likesCount: Int = 0
    var commentsCount: Int = 0
    var followersCount: Int = 0
    var followingsCount: Int = 0
    var feedCount: Int = 0
    var checkInCount: Int = 0
    var canSubscribe: Bool = false
    var isRewardAcceptEnabled: Bool = false
    var activitiesCount: Int = 0

    var isBlacked: Bool = false
    var deleteDate: String = ""

    var whiteListType: String?

    var stickerArtistId: Int = 0
    var stickerArtistName: String?

    var enableExternalRtmp: Bool = false
    var badgeCount: Int = 0
    var latestBadges: String? = nil
    var country: String = ""

    var subscribing: Bool = false
    var subsInfluenceScore: String?
    var rankingInfluenceScore: String?

    var miniProgramShopUrl: String?
    // objectbox: uid = 1954115900950405632
    var miniProgramShopId: Int?

    // certification
    var birthdate : String = ""
    
    var monthlyLiveScore: String?

    var profileFrameIcon: String?
    var profileFrameColorHex: String?
    var liveFeedId: Int?
    
    var subscriptionEnable: Int = 0
    var subscriptionDisabledMsg: String?
    //V6.21.0新增属性
    var website: String = ""
    
    var workIndustryID: Int = 0

    var workIndustryName: String = ""
    
    var workIndustryKey: String = ""
    
    var relationshipID: Int = 0
    
    var relationshipName: String = ""
    
    var relationshipKey: String = ""

    var countryKey: String = ""
    
    var countryID: Int = 0
    
    var cityKey: String = ""
    
    var cityID: Int = 0
    ///用户是否是商家的信息
    var miniProgramShow: Bool = false
    var merchantId: Int?
    var merchantRoute: String?
    
    /// 用户签到显示状态 true 显示签到 false 隐藏签到
    var checkinStatus: Bool = false
    /// 用户签到显示积分相关内容 true=显示积分，false=隐藏积分
    var checkinShowPoint: Bool = false
    init() { }
    init?(map: Map) { }

    init(id: Id,
         userIdentity: Int,
         displayName: String,
         username: String,
         phone: String?,
         mobi: String?,
         email: String?,
         sex: Int,
         bio: String?,
         location: String?,
         createDate: Date? = nil,
         updateDate: Date? = nil,
         avatarUrl: String?,
         avatarMime: String?,
         coverUrl: String?,
         coverMime: String?,
         following: Bool,
         follower: Bool,
         friendsCount: Int,
         otpDevice: Bool,
         verificationIcon: String?,
         verificationType: String?,
         likesCount: Int,
         commentsCount: Int,
         followersCount: Int,
         followingsCount: Int,
         feedCount: Int,
         checkInCount: Int,
         canSubscribe: Bool,
         isRewardAcceptEnabled: Bool,
         activitiesCount: Int,
         isBlacked: Bool,
         deleteDate: String,
         whiteListType: String?,
         stickerArtistId: Int,
         stickerArtistName: String?,
         enableExternalRtmp: Bool,
         badgeCount: Int,
         latestBadges: String?,
         country: String,
         subscribing: Bool,
         subsInfluenceScore: String?,
         rankingInfluenceScore: String?,
         miniProgramShopUrl: String?,
         miniProgramShopId: Int?,
         birthdate: String,
         monthlyLiveScore: String?,
         profileFrameIcon: String?,
         profileFrameColorHex: String?,
         liveFeedId: Int?,
         subscriptionEnable: Int,
         subscriptionDisabledMsg: String?,
         website: String,
         workIndustryID: Int,
         workIndustryName: String,
         workIndustryKey: String,
         relationshipID: Int,
         relationshipName: String,
         relationshipKey: String,
         countryKey: String,
         countryID: Int,
         cityKey: String,
         cityID: Int,
         miniProgramShow: Bool,
         merchantId: Int?,
         merchantRoute: String?,
         checkinStatus: Bool,
         checkinShowPoint: Bool) {
        self.id = id
        self.userIdentity = userIdentity
        self.displayName = displayName
        self.name = displayName
        self.username = username
        self.phone = phone
        self.mobi = mobi
        self.email = email
        self.sex = sex
        self.bio = bio
        self.location = location
        self.createDate = createDate
        self.updateDate = updateDate
        self.avatarUrl = avatarUrl
        self.avatarMime = avatarMime
        self.coverUrl = coverUrl
        self.coverMime = coverMime
        self.following = following
        self.follower = follower
        self.friendsCount = friendsCount
        self.otpDevice = otpDevice
        self.verificationIcon = verificationIcon
        self.verificationType = verificationType
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.followersCount = followersCount
        self.followingsCount = followingsCount
        self.feedCount = feedCount
        self.checkInCount = checkInCount
        self.canSubscribe = canSubscribe
        self.isRewardAcceptEnabled = isRewardAcceptEnabled
        self.activitiesCount = activitiesCount
        self.isBlacked = isBlacked
        self.deleteDate = deleteDate
        self.whiteListType = whiteListType
        self.stickerArtistId = stickerArtistId
        self.stickerArtistName = stickerArtistName
        self.enableExternalRtmp = enableExternalRtmp
        self.badgeCount = badgeCount
        self.latestBadges = latestBadges
        self.country = country
        self.subscribing = subscribing
        self.subsInfluenceScore = subsInfluenceScore
        self.rankingInfluenceScore = rankingInfluenceScore
        self.miniProgramShopUrl = miniProgramShopUrl
        self.miniProgramShopId = miniProgramShopId
        self.birthdate = birthdate
        self.monthlyLiveScore = monthlyLiveScore
        self.profileFrameIcon = profileFrameIcon
        self.profileFrameColorHex = profileFrameColorHex
        self.liveFeedId = liveFeedId
        self.subscriptionEnable = subscriptionEnable
        self.subscriptionDisabledMsg = subscriptionDisabledMsg
        self.website = website
        self.workIndustryID = workIndustryID
        self.workIndustryName = workIndustryName
        self.workIndustryKey = workIndustryKey
        self.relationshipID = relationshipID
        self.relationshipName = relationshipName
        self.relationshipKey = relationshipKey
        self.countryKey = countryKey
        self.countryID = countryID
        self.cityKey = cityKey
        self.cityID = cityID
        self.miniProgramShow = miniProgramShow
        self.merchantId = merchantId
        self.merchantRoute = merchantRoute
        self.checkinStatus = checkinStatus
        self.checkinShowPoint = checkinShowPoint
    }

    mutating func mapping(map: Map) {
        userIdentity <- map["id"]
        if map["user_id"].isKeyPresent {
            userIdentity <- map["user_id"]
        }
        id = UInt64(userIdentity)
        name <- map["name"]
        username <- map["username"]
        phone <- map["phone"]
        mobi <- map["mobi"]
        email <- map["email"]
        bio <- map["bio"]
        sex <- map["sex"]
        location <- map["location"]
        createDate <- map["created_at"]
        updateDate <- map["updated_at"]
        createDate <- (map["created_at"], using: DateTransformer)
        updateDate <- (map["updated_at"], using: DateTransformer)
        avatarUrl <- map["avatar.url"]
        coverUrl <- map["bg.url"]
        coverMime <- map["bg.mime"]
        follower <- map["follower"]
        following <- map["following"]
        friendsCount <- map["friends_count"]
        otpDevice <- map["otp_device"]

        verificationIcon <- map["verified.icon"]
        verificationType <- map["verified.type"]

        // extra
        likesCount <- map["extra.likes_count"]
        commentsCount <- map["extra.comments_count"]
        followersCount <- map["extra.followers_count"]
        followingsCount <- map["extra.followings_count"]
        feedCount <- map["extra.feeds_count"]
        checkInCount <- map["extra.checkin_count"]
        checkInCount <- map["extra.last_checkin_count"]
        isRewardAcceptEnabled <- map["extra.can_accept_reward"]
        canSubscribe <- map["extra.is_subscribable"]
        activitiesCount <- map["extra.count"]

        isBlacked <- map["blacked"]
        deleteDate <- map["deleted_at"]

        whiteListType <- (map["whitelist_type"], using: StringArrayTransformer)

        stickerArtistId <- map["stickers_artist.0.artist_id"]
        stickerArtistName <- map["stickers_artist.0.artist_name"]

        miniProgramShopUrl <- map["eshop_miniprogram.shopUrl"]
        miniProgramShopId <- map["eshop_miniprogram.shop_id"]

        badgeCount <- map["badges_count"]
        latestBadges <- (map["latest_badges"], using: StringArrayTransformer)
        country <- map["country"]
        subscribing <- map["subscribing"]
        subsInfluenceScore <- map["subs_influence_score"]
        rankingInfluenceScore <- map["influence_score"]
        subscriptionEnable <- map["subscription_enable"]
        subscriptionDisabledMsg <- map["subscription_disabled_msg"]

        // certification
        birthdate <- map["certification.data.birthdate"]
        
        monthlyLiveScore <- map["monthly_live_score"]
        
        profileFrameIcon <- map["profile_frame.frame.icon_url"]
        profileFrameColorHex <- map["profile_frame.frame.color_code"]
        liveFeedId <- map["profile_frame.feed_id"]
        
        website <- map["website"]
        workIndustryID <- map["work_industry.id"]
        workIndustryName <- map["work_industry.name"]
        workIndustryKey <- map["work_industry.key"]
        relationshipID <- map["relationship_status.id"]
        relationshipName <- map["relationship_status.name"]
        relationshipKey <- map["relationship_status.key"]
        
        countryID <- map["location.country.id"]
        countryKey <- map["location.country.key"]
        cityID <- map["location.city.id"]
        cityKey <- map["location.city.key"]
        
        miniProgramShow <- map["merchant_info.miniShow"]
        merchantId <- map["merchant_info.data.merchant.id"]
        merchantRoute <- map["merchant_info.data.path"]
        
        checkinStatus <- map["checkin_status"]
        checkinShowPoint <- map["show_point"]
        
    }
    static func convert(_ object: [UserInfoModel]?) -> String? {
        guard let object = object else { return nil }
        return object.toJSONString()
    }
    
    static func convert(_ json: String?) -> [UserInfoModel]? {
        guard let json = json else { return nil }
        return Mapper<UserInfoModel>().mapArray(JSONString: json)
    }
}

extension UserInfoModel {
    // objectbox: transient
    var isBannedUser: Bool {
        return deleteDate.isEmpty == false
    }

    // objectbox: transient
    var shortDesc: String {
        if let bio = bio, !bio.isEmpty {
            return bio
        }
        return "rw_intro_default".localized
    }

    // objectbox: transient
    var relationshipWithCurrentUser: (status: FollowStatus, texts: FollowStatustext)? {
        if TSCurrentUserInfo.share.isLogin == false {
            return nil
        }
        guard let currentUser = CurrentUser else {
            return nil
        }
        if currentUser.userIdentity == self.userIdentity {
            return (status: .oneself, texts: .oneself)
        }
        if following == true && follower == true {
            return (status: .eachOther, texts: .eachOther)
        }
        if follower == true {
            return (status: .follow, texts: .follow)
        }
        return (status: .unfollow, texts: .unfollow)
    }

    // objectbox: transient
    var isMe: Bool {
        guard let currentUser = CurrentUser else {
            return false
        }
        return self.userIdentity == currentUser.userIdentity || self.username == currentUser.username
    }

    // objectbox: transient
    var sexTitle: String {
        var title = "unknown".localized
        if 1 == self.sex {
            title =  "male".localized
        } else if 2 == self.sex {
            title =  "female".localized
        }
        return title
    }

    // objectbox: transient
    var followStatus: FollowStatus {
        guard userIdentity != CurrentUser?.userIdentity else {
            return .oneself
        }
        if follower && following {
            return .eachOther
        }
        if follower {
            return .follow
        }
        return .unfollow
    }

    // objectbox: transient
    var isOfficial: Bool {
        return verificationType == "official"
    }

    mutating func updateFollow(completion: ((Bool) -> Void)? = nil) {
        self.follower = !self.follower
        let followType: FollowStatus = self.follower == true ? .follow : .unfollow
        let userIdentity = self.userIdentity
        
        self.save()
        
        TSUserNetworkingManager().operateWithClosure(followType, userID: userIdentity) { (success) in
            if success {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil, userInfo: ["follow": followType, "userid": "\(userIdentity)"])
            } else {
                UIViewController.topMostController?.showError(message: "network_is_not_available".localized)
            }

            // Remove from remark name list
            // TODO: need to refine the logic
            if success && followType == .unfollow {
                if let userRemarkName =  UserDefaults.standard.array(forKey: "UserRemarkName") {
                    var remarkNameArray = userRemarkName as! [[String:String]]
                    remarkNameArray.removeAll { $0["userID"] == "\(userIdentity)"}

                    UserDefaults.standard.set(remarkNameArray, forKey: "UserRemarkName")
                }
               // RemarkNameManager.shared.removeRemarkName(for: userIdentity)
            }
            completion?(success)
        }
    }
}


extension UserInfoModel {
    func save() {
        UserInfoStoreManager().add(list: [self])
    }
    
    static func retrieveUser(username: String?) -> UserInfoModel? {
        guard let username = username else { return nil }
        return UserInfoStoreManager().fetchByUsername(username: username)
    }
    
    static func retrieveUser(userId: Int?) -> UserInfoModel? {
        guard let userId = userId else { return nil }
        return UserInfoStoreManager().fetchById(id: userId)
    }
    
    static func retrieveUser(nickname: String?) -> UserInfoModel? {
        guard let nickname = nickname else { return nil }
        return UserInfoStoreManager().fetchByNickname(nickname: nickname)
    }
}
