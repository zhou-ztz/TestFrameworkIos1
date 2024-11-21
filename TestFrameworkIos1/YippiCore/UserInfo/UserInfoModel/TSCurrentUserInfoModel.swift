//
//  UserSessionInfo.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/07/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  当前用户的数据模型
//  含有wallet数据模型

import Foundation
import ObjectBox
import ObjectMapper
import UIKit


struct UserSessionInfo: Entity, Mappable, UserInfoType {

    // objectbox: id = { "assignable": true }
    var id: Id = 0

    // objectbox: transient
    var requestKey: String {
        return userIdentity.stringValue + "\(Int64(Date().timeIntervalSince1970))"
    }

    var userIdentity: Int = 0
    var name: String = ""
    var phone: String?
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
    
    // certification
    var certificationStatus: Int = 0
    
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
    var isRewardAcceptEnabled: Bool = false
    var canSubscribe: Bool = false
    var activitiesCount: Int = 0
    
    // wallet
    var yippsTotal: Double = 0.0
    var rewardsTotal: Double = 0.0
    var rebates: Double = 0.0
    
    var whiteListType: String? = nil
    var country: String = ""
    var freeHotPost: Int = 0
    var isLiveEnabled: Bool = false
    var isMiniVideoEnabled: Bool = false //*
    var enableExternalRTMP: Bool = false
    var hasPin: Bool = false //*
    var birthdate: String = ""
    var username: String = ""
    var haslevelUpgraded: Bool = false
    
    var subscribingBadge: String?
    
    var profileFrameIcon: String?
    var profileFrameColorHex: String?
    var liveFeedId: Int?
    
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
    //国家下面是否还有州省
    var countryHasChild: Bool = false
    
    var provinceKey: String = ""
    
    var provinceID: Int = 0
    //州省下面是否还有城市
    var provinceHasChild: Bool = false
    
    var cityKey: String = ""
    
    var cityID: Int = 0

    // objectbox: transient
    var shortDesc: String {
        return bio == nil ? "rw_intro_default".localized : bio!
    }
    
    /// 用户签到显示状态 true 显示签到 false 隐藏签到
    var checkinStatus: Bool = false
    /// 用户签到显示积分相关内容 true=显示积分，false=隐藏积分
    var checkinShowPoint: Bool = false
    
    init(id: Id,
         userIdentity: Int,
         name: String,
         phone: String?,
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
         certificationStatus: Int,
         verificationIcon: String?,
         verificationType: String?,
         likesCount: Int,
         commentsCount: Int,
         followersCount: Int,
         followingsCount: Int,
         feedCount: Int,
         checkInCount: Int,
         isRewardAcceptEnabled: Bool,
         canSubscribe: Bool,
         activitiesCount: Int,
         yippsTotal: Double,
         rewardsTotal: Double,
         rebates: Double,
         whiteListType: String?,
         country: String,
         freeHotPost: Int,
         isLiveEnabled: Bool,
         isMiniVideoEnabled: Bool,
         enableExternalRTMP: Bool,
         hasPin: Bool,
         birthdate: String,
         username: String,
         haslevelUpgraded: Bool,
         subscribingBadge: String?,
         profileFrameIcon: String?,
         profileFrameColorHex: String?,
         liveFeedId: Int?,
         website: String,
         workIndustryID: Int,
         workIndustryName: String,
         workIndustryKey: String,
         relationshipID: Int,
         relationshipName: String,
         relationshipKey: String,
         countryKey: String,
         countryID: Int,
         countryHasChild: Bool,
         provinceKey: String,
         provinceID: Int,
         provinceHasChild: Bool,
         cityKey: String,
         cityID: Int,
         checkinStatus: Bool,
         checkinShowPoint: Bool
    ) {
        self.id = UInt64(userIdentity)
        self.userIdentity = userIdentity
        self.name = name
        self.email = email
        self.phone = phone
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
        self.certificationStatus = certificationStatus
        self.verificationIcon = verificationIcon
        self.verificationType = verificationType
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.followersCount = followersCount
        self.feedCount = feedCount
        self.checkInCount = checkInCount
        self.isRewardAcceptEnabled = isRewardAcceptEnabled
        self.canSubscribe = canSubscribe
        self.activitiesCount = activitiesCount
        self.yippsTotal = yippsTotal
        self.rewardsTotal = rewardsTotal
        self.whiteListType = whiteListType
        self.country = country
        self.freeHotPost = freeHotPost
        self.isLiveEnabled = isLiveEnabled
        self.isMiniVideoEnabled = isMiniVideoEnabled
        self.enableExternalRTMP = enableExternalRTMP
        self.hasPin = hasPin
        self.birthdate = birthdate
        self.username = username
        self.haslevelUpgraded = haslevelUpgraded
        self.subscribingBadge = subscribingBadge
        self.profileFrameIcon = profileFrameIcon
        self.profileFrameColorHex = profileFrameColorHex
        self.liveFeedId = liveFeedId
        self.website = website
        self.workIndustryID = workIndustryID
        self.workIndustryName = workIndustryName
        self.workIndustryKey = workIndustryKey
        self.relationshipID = relationshipID
        self.relationshipName = relationshipName
        self.relationshipKey = relationshipKey
        self.countryKey = countryKey
        self.countryID = countryID
        self.countryHasChild = countryHasChild
        self.provinceKey = provinceKey
        self.provinceID = provinceID
        self.provinceHasChild = provinceHasChild
        self.cityKey = cityKey
        self.cityID = cityID
        self.checkinStatus = checkinStatus
        self.checkinShowPoint = checkinShowPoint
    }
    
    init?(map: Map) { }

    mutating func mapping(map: Map) {
        userIdentity <- map["id"]
        id = UInt64(userIdentity)
        name <- map["name"]
        phone <- map["phone"]
        email <- map["email"]
        bio <- map["bio"]
        sex <- map["sex"]
        username <- map["username"]
        location <- map["location"]
        country <- map["country"]
        createDate <- (map["created_at"], using: DateTransformer)
        updateDate <- (map["updated_at"], using: DateTransformer)
        avatarUrl <- map["avatar.url"]
        avatarMime <- map["avatar.mime"]
        coverUrl <- map["bg.url"]
        coverMime <- map["bg.mime"]
        follower <- map["follower"]
        following <- map["following"]
        friendsCount <- map["friends_count"]
        otpDevice <- map["otp_device"]
        
        certificationStatus <- map["certification.status"]
        
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
        isMiniVideoEnabled <- map["extra.is_enabled_mini_video"]
        isLiveEnabled <- map["extra.is_live_enable"]
        enableExternalRTMP <- map["extra.enable_external_rtmp"]
        canSubscribe <- map["extra.is_subscribable"]
        activitiesCount <- map["extra.count"]
        
        // wallet
        mapWallet(map: map)

        whiteListType <- (map["whitelist_type"], using: StringArrayTransformer)
        hasPin <- map["has_pin"]
        
        // certification
        birthdate <- map["birthdate"]
        haslevelUpgraded <- map["certification.auto_upgrade_dialog"]
        freeHotPost <- map["certification.category.free_hot_post"]

        subscribingBadge <- map["subscribing_badge"]
        
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
        countryHasChild <- map["location.country.child"]
        
        provinceID <- map["location.state.id"]
        provinceKey <- map["location.state.key"]
        provinceHasChild <- map["location.state.child"]
        
        cityID <- map["location.city.id"]
        cityKey <- map["location.city.key"]
        
        checkinStatus <- map["checkin_status"]
        checkinShowPoint <- map["show_point"]
        
    }
        
    mutating func updateYipps(with amount: Double) {
        self.yippsTotal = amount
    }
}



extension UserSessionInfo {
    mutating func mapWallet(map: Map) {
        var wallets : [UserWalletIntegrationModel]?
        wallets <- map["currency"]
        if let _wallets = wallets {
            updateWallet(_wallets)
        }
    }
    
    mutating func updateWallet(_ model: UserCurrencyModel) {
        self.yippsTotal = (model.yipps?.sum).orEmpty.toDouble()
        self.rewardsTotal = (model.cpoint?.sum).orEmpty.toDouble()
        self.rebates = (model.rebate?.sum).orEmpty.toDouble()
        
        save()
    }
    
    mutating func updateWallet(_ data: [UserWalletIntegrationModel]) {
        self.yippsTotal = (data.filter({ $0.type == 1}).first?.sum).orEmpty.toDouble()
        self.rewardsTotal = (data.filter({ $0.type == 2}).first?.sum).orEmpty.toDouble()
        self.rebates = (data.filter({ $0.type == 3 }).first?.sum).orEmpty.toDouble()
        
        save()
    }
    
    func save() {
        UserSessionStoreManager().add(list: [self])
    }
}

