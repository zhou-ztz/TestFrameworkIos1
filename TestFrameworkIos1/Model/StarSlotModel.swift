//
//  StarSlotModel.swift
//  Yippi
//
//  Created by Francis Yeap on 28/01/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper
import DeepDiff
import SwiftUI

func == (lhs: StarSlotModel, rhs: StarSlotModel) -> Bool {
     return (
        lhs.username == rhs.username &&
        lhs.userIdentity == rhs.userIdentity &&
        lhs.rank?.score == rhs.rank?.score &&
        lhs.status == rhs.status &&
        lhs.feedId == rhs.feedId
    )
}


struct StarSlotModel: UserInfoType, Equatable, Hashable, Mappable, Identifiable {
    var id: String { return "\(userIdentity)_\(rank?.level ?? 0)_\(rank?.score ?? 0)" }
    var userIdentity: Int = 0
    var name: String = ""
    var phone: String?
    var email: String?
    var sex: Int = 0 // The user's gender, 0 - Unknown, 1 - Man, 2 - Woman.
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
    var isRewardAcceptEnabled: Bool = false
    var canSubscribe: Bool = false
    var activitiesCount: Int = 0
    
    var whiteListType: String? = nil
    var country: String = ""
    
    // certification
    var hasPin: Bool = false //*
    var birthdate: String = ""
    var username: String = ""
    var haslevelUpgraded: Bool = false
    
    // objectbox: transient
    var shortDesc: String {
        return bio == nil ? "more_profile_view_or_edit".localized : bio!
    }
    
    static var LiveStarSharedTimeFormatter = DateFormatter().configure { (formatter) in
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
    }

    static var LiveStarSharedDateFormatter = DateFormatter().configure { (formatter) in
        formatter.dateFormat = "MMM dd"
        formatter.timeZone = TimeZone.current
    }
    
    var rank: SlotRankModel?
    var feedId: Int = -1
    var status: Int = -1
    var liveEventStartTime: Date?
    var liveEventEndTime: Date?
    var slotTimePeriod: String {
        if let startTime = liveEventStartTime, let endTime =     liveEventEndTime {
            let startDate = StarSlotModel.LiveStarSharedDateFormatter.string(from: startTime)
            let start = StarSlotModel.LiveStarSharedTimeFormatter.string(from: startTime)
            let end = StarSlotModel.LiveStarSharedTimeFormatter.string(from: endTime)
            return "\(startDate), \(start) - \(end)"
        }
        return "-"
    }
    var profileFrameIcon: String?
    var profileFrameColorHex: String?
    var liveFeedId: Int?
    
    init?(map: Map) { }

    func hash(into hasher: inout Hasher) {
        switch self {
        default: break
        }
    }
    
    mutating func mapping(map: Map) {
        userIdentity <- map["id"]
        name <- map["name"]
        phone <- map["phone"]
        email <- map["email"]
        bio <- map["bio"]
        sex <- map["sex"]
        location <- map["location"]
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
        
        // certification
        birthdate <- map["certification.data.birthdate"]
        haslevelUpgraded <- map["certification.auto_upgrade_dialog"]
        
        username <- map["username"]
        whiteListType <- map["whitelist_type"]
        country <- map["country"]
        hasPin <- map["has_pin"]
        
        
        feedId <- map["live.feed_id"]
        status <- map["live.status"]
        rank <- map["slot_rank"]
        liveEventStartTime <- (map["slot_period.slot_start"], DateTransformer)
        liveEventEndTime <- (map["slot_period.slot_end"], DateTransformer)
        
        profileFrameIcon <- map["profile_frame.frame.icon_url"]
        profileFrameColorHex <- map["profile_frame.frame.color_code"]
        liveFeedId <- map["profile_frame.feed_id"]
    }
    
}

extension StarSlotModel: DiffAware {
    var diffId: StarSlotModel {
        return self
    }

    static func compareContent(_ a: StarSlotModel, _ b: StarSlotModel) -> Bool {
        return a == b
    }
}
