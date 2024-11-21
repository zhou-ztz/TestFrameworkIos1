//
//  ReceiveLikeModel.swift
//  ThinkSNS +
//
//  Created by lip on 2017/9/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  用户收到的赞 数据模型

import UIKit
import ObjectMapper

class ReceiveLikeModel: Mappable {
    // 点赞标识
    var id: Int = -1
    // 点赞用户
    var userId: Int = -1
    // 接收用户（你能收到就是因为这个ID就是你）
    var targetUserId: Int = -1
    /// 所属资源类型
    var sourceType: ReceiveInfoSourceType = .feed
    // 赞时间
    var createDate: Date!
    // 更新时间
    var updateDate: Date?
    /// 附属信息
    var exten: ReceiveExtenModel?
    // 点赞用户信息
    var userInfo: UserInfoModel?
    var sortId: String?

    required init?(map: Map) {
    }
    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        targetUserId <- map["target_user"]
        sourceType <- (map["likeable_type"], ReceiveInfoSourceTypeTransform())
        createDate <- (map["created_at"], DateTransformer)
        updateDate <- (map["updated_at"], DateTransformer)
        let tempExten = ReceiveExtenModel()
        var contentType = ""
        switch sourceType {
        case .feed:
            contentType = "title_post".localized
            tempExten.content <- map["likeable.feed_content"]
            tempExten.coverId <- map["likeable.images.0.id"]
            tempExten.targetId <- map["likeable.id"]
            // 先判断是否是图片动态，然后尝试读取视频封面图
            if tempExten.coverId == nil {
                tempExten.coverId <- map["likeable.video.cover_id"]
                tempExten.isVieo = true
            }
        case .song, .musicAlbum:
            contentType = "Music".localized
            tempExten.targetId <- map["likeable.id"]
            tempExten.content <- map["likeable.title"]
            tempExten.coverId <- map["likeable.storage"]
        case .reject:
            break
        default:
            break
        }
        exten = tempExten
        if tempExten.targetId == nil {
            // 点赞的资源被删除时，仍然展示，不过只展示内容 且为 "该动态/帖子/回答/文章... 已被删除"
            exten?.content = String(format: "resource_deleted_format".localized, contentType)
        }
    }

    func convert() -> NoticePendingCellLayoutConfig {
        var titleInfo: String?
        switch sourceType {
        case .feed:
            titleInfo = "liked_feed_moment".localized
        case .musicAlbum:
            titleInfo = "like_your_album".localized
        case .song:
            titleInfo = "like_your_song".localized
        case .reject:
            break
        default:
            break
        }

        let isHiddenExtenRegin = exten == nil
        
        if let userInfo = userInfo {
            let coverUrl = TSURLPath.imageV2URLPath(storageIdentity: exten?.coverId, compressionRatio: 100, cgSize: CGSize(width: 27 * 3, height: 27 * 3))
            let config = NoticePendingCellLayoutConfig(pendingReginStatus: .heart, isHiddenExtenRegin: isHiddenExtenRegin, isHiddenContent: true, avatarUrl: userInfo.avatarUrl.orEmpty, verifyType: userInfo.verificationType, verifyIcon: userInfo.verificationIcon.orEmpty, userId: userId, title: userInfo.name, titleInfo: titleInfo, subTitle: nil, date: createDate, content: nil, hightLightInContent: nil, extenContent: exten?.content, extenCover: coverUrl, isVideo: exten?.isVieo, pendingContent: nil, amount: nil, day: nil)
            return config
        }
        
        let config = NoticePendingCellLayoutConfig(pendingReginStatus: .heart, isHiddenExtenRegin: isHiddenExtenRegin, isHiddenContent: false, avatarUrl: "", verifyType: "", verifyIcon: "", userId: 0, title: "", titleInfo: titleInfo, subTitle: nil, date: createDate, content: nil, hightLightInContent: nil, extenContent: "", extenCover: nil, isVideo: false, pendingContent: nil, amount: 0, day: 0)
        return config
    }
}
