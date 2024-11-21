//
//  TSCommentsSimpelModel.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/27.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class TSCommentsSimpelModel: Mappable {
    /// 评论ID
    var id: Int!
    /// 评论用户 ID
    var userId: Int!
    /// 接收评论用户 ID
    var targetUserID: Int!
    /// 评论内容
    var body: String!
    /// 类型
    var type: String!
    var sourceID: Int!
    var createDate: Date!
    var hasReplay = false
    var sortId: String?
    var remark: String = ""
    // 消息总类型
    var sortType: String = ""
    
    //reject feed
    var rejectFeedCover: String?
    var rejectFeedContent: String?
    //系统消息的子类型
    var systemType: String = ""
    var systemContent: String = ""
    var systemState: String = ""
    var rewardAmount: CGFloat = 0.0
    var rewardUnit: String = ""
    var subject: String = ""
    
    init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        targetUserID <- map["target_user"]
        body <- map["body"]
        userId <- map["user_id"]
        type <- map["resourceable.type"]
        sourceID <- map["resourceable.id"]
        createDate <- (map["created_at"], DateTransformer)
    }
}
