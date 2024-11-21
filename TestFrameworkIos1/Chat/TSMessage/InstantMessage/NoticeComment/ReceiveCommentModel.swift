//
//  ReceiveCommentModel.swift
//  ThinkSNS +
//
//  Created by lip on 2017/9/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  收到的评论数据模型

import UIKit
import ObjectMapper

/// 评论类型
///
/// - commentToMe: 评论我的
/// - replyToMe: 回复我的
/// - replyToOther: 回复别人的
enum ReceiveCommentType {
    case commentToMe
    case replyToMe
    case replyToOther
}

class ReceiveCommentModel: Mappable {
    /// 评论 ID
    var id: Int!
    /// 评论发送用户
    var userId: Int!
    /// 目标用户
    var targetUserId: Int!
    /// 被回复用户
    var replyUserId: Int?
    /// 评论时间
    var createDate: Date?
    /// 更新时间
    var updateDate: Date?
    /// 评论内容
    var content: String!
    /// 所属资源类型
    var sourceType: ReceiveInfoSourceType = .feed
    /// 附属信息
    var exten: ReceiveExtenModel?
    /// 圈子标识
    ///
    /// - Note: 该条评论来自圈子将单独使用该字段,同时 self.exten.targetId 是post id
    var groupId: Int?
    /// 置顶积分
    var amount: Int?
    /// 置顶天数
    var day: Int?
    /// 是否是at类型的内容（现在只有动态）
    var isAtContent: Bool = false
    /// 对应at类型的ID
    var atMessageID: Int = 0
    var hasReplay = false
    var sortID: String?
    var remark: String = ""
    // 消息总类型
    var sortType: ReceiveNotificationsType = .comment
    var sourceTypeNew: String = "" //资源类型
    //系统消息的子类型
    var systemType: String = ""
    var systemContent: String = ""
    var systemState: String = ""
    var rewardAmount: CGFloat = 0.0
    var rewardUnit: String = ""
    var subject: String = ""
    // 发送评论用户
    var user: UserInfoModel?
    // 被回复用户
    var replyUser: UserInfoModel?
    /// 评论信息状态
    /**
    if let reply = replyUserId, reply != 0 {
    if let current = CurrentUserSessionInfo?.userIdentity {
    if reply == current {
    return ReceiveCommentType.replyToMe
    }
    }
    return ReceiveCommentType.replyToOther
    }
    return ReceiveCommentType.commentToMe
    */
    var type: ReceiveCommentType {
        return hasReplay ? ReceiveCommentType.replyToMe : ReceiveCommentType.commentToMe
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        targetUserId <- map["target_user"]
        replyUserId <- map["reply_user"]
        createDate <- (map["created_at"], DateTransformer)
        updateDate <- (map["updated_at"], DateTransformer)
        content <- map["body"]
        sourceType <- (map["commentable_type"], ReceiveInfoSourceTypeTransform())
        amount <- map["amount"]
        day <- map["day"]
        let tempExten = ReceiveExtenModel()
        tempExten.isVieo = false
        switch sourceType {
        case .feed:
            tempExten.content <- map["commentable.feed_content"]
            tempExten.coverId <- map["commentable.images.0.id"]
            // 先判断是否是图片动态，然后尝试读取视频封面图
            if tempExten.coverId == nil {
                tempExten.coverId <- map["commentable.video.cover_id"]
                tempExten.isVieo = true
            }
            tempExten.targetId <- map["commentable.id"]
        case .song, .musicAlbum:
            tempExten.targetId <- map["commentable.id"]
            tempExten.content <- map["commentable.title"]
            tempExten.coverId <- map["commentable.storage"]
        case .reject:
            break
        default:
            break
        }
        exten = tempExten
        if tempExten.targetId == nil {
            exten = nil
        }
        groupId <- map["commentable.group_id"]
    }

    func convert() -> NoticePendingCellLayoutConfig {
        var titleInfo: String?
        var subTitle: String? = replyUser?.name
        switch type {
        case .commentToMe:
            switch sourceType {
            case .feed:
                titleInfo = "rw_comment_format_feed".localized
            case .musicAlbum:
                titleInfo = "comment_your_album".localized
            case .song:
                titleInfo = "comment_your_song".localized
            case .reject:
                break
            default:
                break
            }
        case .replyToMe:
            titleInfo = "rw_has_replied".localized
            subTitle = nil
        case .replyToOther:
            titleInfo = "reply".localized
        default:
            break
        }

        let isHiddenExtenRegin = exten == nil
        var pendingReginStatus: NoticePendingCellPendingReginStatus = .report
//        var pendingContent: String?
//        if isHiddenExtenRegin == true {
//            pendingReginStatus = .warning
//            switch sourceType {
//            case .feed:
//                pendingContent = "status_is_delete".localized
//            case .musicAlbum:
//                pendingContent = "album_is_delete".localized
//            case .song:
//                pendingContent = "song_is_delete".localized
//            }
//        }

        if let user = user {
            let coverUrl = TSURLPath.imageV2URLPath(storageIdentity: exten?.coverId, compressionRatio: 100, cgSize: CGSize(width: 27 * 3, height: 27 * 3))
            let config = NoticePendingCellLayoutConfig(pendingReginStatus: pendingReginStatus, isHiddenExtenRegin: isHiddenExtenRegin, isHiddenContent: false, avatarUrl: user.avatarUrl, verifyType: user.verificationType, verifyIcon: user.verificationIcon, userId: userId, title: user.name, titleInfo: titleInfo, subTitle: subTitle, date: createDate, content: content, hightLightInContent: nil, extenContent: exten?.content, extenCover: coverUrl, isVideo: exten?.isVieo, pendingContent: nil, amount: amount, day: day)
            return config
        }
        
        let config = NoticePendingCellLayoutConfig(pendingReginStatus: pendingReginStatus, isHiddenExtenRegin: isHiddenExtenRegin, isHiddenContent: false, avatarUrl: "", verifyType: "", verifyIcon: "", userId: 0, title: "", titleInfo: titleInfo, subTitle: subTitle, date: createDate, content: content, hightLightInContent: nil, extenContent: "", extenCover: nil, isVideo: false, pendingContent: nil, amount: 0, day: 0)
        return config
    }
}

class ReceiveExtenModel {
    /// 目标id, 点击跳转等操作的目标
    var targetId: Int?
    /// 内容
    var content: String!
    /// 封面
    var coverId: Int?
    /// 封面URL地址
    var coverPath: String?
    /// 视频 只有动态才有
    var isVieo: Bool?

    /// 圈子id
    ///
    /// Note: - 只有在有圈子的时候才有这个值
    var groupId: Int?
}
