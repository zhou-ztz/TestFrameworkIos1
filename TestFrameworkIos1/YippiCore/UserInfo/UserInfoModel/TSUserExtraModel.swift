//
//  TSUserExtraModel.swift
//  Yippi
//
//  Created by Francis on 23/03/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

/// 用户附加信息
//sourcery: RealmEntityConvertible
class TSUserExtraModel: Mappable {
    var userId: Int = 0
    /// The number of users who received the number of statistics.
    var likesCount: Int = 0
    /// The comments made by this user.
    var commentsCount: Int = 0
    /// Follow this user's statistics.
    var followersCount: Int = 0
    /// This user follows the statistics.
    var followingsCount: Int = 0
    /// This user friends the statistics.
    var feedsCount: Int = 0
    /// Secondary data update time.
    var updateDate: String = ""
    /// 当前用户签到总天数
    var checkinCount: Int = 0
    /// 当前用户连续签到天数
    var lastCheckinCount: Int = 0
    /// 问题数
    var qustionsCount = 0
    /// 回答数
    var answersCount = 0
    /// 粉丝/问答点赞/回答/动态点赞/资讯点赞数（请求哪个接口，返回的就是哪个排行的数量）
    var count = 0
    /// 粉丝/财富/收入/专家/问答达人/解答/动态/资讯排行（请求哪个接口，返回的就是哪个排行）
    var rank = 0
    /// Can accept tipping
    var canAcceptReward = 0
    
    var isMiniVideoEnabled = 0
    
    var isSubscribable: Int = 0
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        userId <- map["user_id"]
        likesCount <- map["likes_count"]
        commentsCount <- map["comments_count"]
        followersCount <- map["followers_count"]
        followingsCount <- map["followings_count"]
        feedsCount <- map["feeds_count"]
        updateDate <- map["updated_at"]
        checkinCount <- map["checkin_count"]
        lastCheckinCount <- map["last_checkin_count"]
        qustionsCount <- map["questions_count"]
        answersCount <- map["answers_count"]
        count <- map["count"]
        rank <- map["rank"]
        canAcceptReward <- map["can_accept_reward"]
        isMiniVideoEnabled <- map["is_enabled_mini_video"]
        isSubscribable <- map["is_subscribable"]
    }

    /// 从数据库模型转换
    init(object: EntityUserExtra) {
        self.userId = object.userId
        self.likesCount = object.likesCount
        self.commentsCount = object.commentsCount
        self.followersCount = object.followersCount
        self.followingsCount = object.followingsCount
        self.feedsCount = object.feedsCount
        self.updateDate = object.updateDate
        self.qustionsCount = object.qustionsCount
        self.answersCount = object.answersCount
        self.canAcceptReward = object.canAcceptReward
        self.isMiniVideoEnabled = object.isMiniVideoEnabled
    }
    /// 转换为数据库对象
    func object() -> EntityUserExtra {
        let object = EntityUserExtra()
        object.userId = self.userId
        object.likesCount = self.likesCount
        object.commentsCount = self.commentsCount
        object.followersCount = self.followersCount
        object.followingsCount = self.followingsCount
        object.feedsCount = self.feedsCount
        object.updateDate = self.updateDate
        object.qustionsCount = self.qustionsCount
        object.answersCount = self.answersCount
        object.canAcceptReward = self.canAcceptReward
        object.isMiniVideoEnabled = self.isMiniVideoEnabled
        return object
    }
}
