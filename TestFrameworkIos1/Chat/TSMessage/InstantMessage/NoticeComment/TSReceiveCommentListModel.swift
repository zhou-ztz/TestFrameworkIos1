//
//  TSReceiveCommentListModel.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2019/3/15.
//  Copyright © 2019年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class TSReceiveCommentListModel: Mappable {
    /// 评论 ID
    var id: String!
    /// 评论时间
    var createDate: Date?
    /// 日志类型 目前用来区分 FeedReject 和 Comment
    var type: String = ""
    
    var contents: String = ""
    /// 评论用户
    var commentUserId: Int = 0
    /// 所属资源类型(动态)
    var sourceType: String = ""
    var sourceId: Int = 0
    var remark: String = ""
    /// 其他类型的所属资源 评论、拒绝帖子
    var otherTypeSourceType: String = ""
    var otherTypeSourceId: Int = 0
    var hasReplay = false

    //reject feed
    var rejectFeedCover: String = ""
    var rejectFeedContent: String = ""
    
    //system系统消息所属下面的类型
    var systemSourceType: String = ""
    var systemContent: String = ""
    var systemState: String = ""
    var rewardAmount: CGFloat = 0.0
    var rewardUnit: String = ""
    var subject: String = ""
    
    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        createDate <- (map["created_at"], DateTransformer)
        contents <- map["data.contents"]
        commentUserId <- map["data.sender.id"]
        type <- map["type"]
        sourceType <- map["data.resource.type"]
        sourceId <- map["data.resource.id"]
        remark <- map["data.resource.remark"]
        otherTypeSourceType <- map["data.commentable.type"]
        otherTypeSourceId <- map["data.commentable.id"]
        hasReplay <- map["data.hasReply"]
        
        rejectFeedCover <- map["data.commentable.cover"]
        rejectFeedContent <- map["data.commentable.feed_content"]
        
        systemSourceType <- map["data.type"]
        systemContent <- map["data.contents"]
        systemState <- map["data.state"]
        rewardAmount <- map["data.amount"]
        rewardUnit <- map["data.unit"]
        subject <- map["data.subject"]
        
    }
}
