//
//  TSComment.swift
//  Yippi
//
//  Created by Francis Yeap on 15/06/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

/// 评论应用场景/评论类型
typealias TSCommentSituation = TSCommentType
enum TSCommentType: String {
    case momment = "feeds"
    case album = "music_specials"
    case song = "musics"
    case post = "group-posts"
    case news = "news"

    init(type: ReceiveInfoSourceType) {
        self.init(rawValue: type.rawValue)!
    }
}

/// 评论通用模型
class TSCommentModel: Mappable {

    var id: Int = 0
    var userId: Int = 0
    var targetUserId: Int = 0
    var replyUserId: Int?
    var body: String = ""
    var commentTableId: Int = 0
    var commentTableType: String = ""
    var updateDate: Date?
    var createDate: Date?

    var contentType: String = ""
    var subscribing: Bool = false
    var isTop: Bool = false

    var type: TSCommentType? {
        return TSCommentType(rawValue: self.commentTableType)
    }
    
    var user: UserInfoModel?
    var targetUser: UserInfoModel?
    var replyUser: UserInfoModel?

    // MARK: - Mappable
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        targetUserId <- map["target_user"]
        replyUserId <- map["reply_user"]
        body <- map["body"]
        commentTableId <- map["commentable_id"]
        commentTableType <- map["commentable_type"]
        updateDate <- (map["updated_at"], DateTransformer)
        createDate <- (map["updated_at"], DateTransformer)
        contentType <- map["content_type"]
        subscribing <- map["subscribing"]
    }

    // MARK: - DB
    init(object: TSCommentObject) {
        self.id = object.id
        self.userId = object.userId
        self.targetUserId = object.targetUserId
        self.replyUserId = object.replyUserId.value
        self.body = object.body
        self.commentTableId = object.commentTableId
        self.commentTableType = object.commentTableType
        self.updateDate = object.updateDate
        self.createDate = object.createDate
        self.isTop = object.isTop
        self.contentType = object.contentType
    }

    func object() -> TSCommentObject {
        let object = TSCommentObject()
        object.id = self.id
        object.userId = self.userId
        object.targetUserId = self.targetUserId
        object.replyUserId = RealmOptional<Int>(self.replyUserId)
        object.body = self.body
        object.commentTableId = self.commentTableId
        object.commentTableType = self.commentTableType
        object.updateDate = self.updateDate
        object.createDate = self.createDate
        object.isTop = self.isTop
        object.contentType = self.contentType
        return object
    }

}

// MARK: - 构建TSSimpleCommentModel

extension TSCommentModel {
    func simpleModel() -> TSSimpleCommentModel {
        var simpleModel = TSSimpleCommentModel()
        simpleModel.content = self.body
        if let date = self.createDate {
            simpleModel.createdAt = NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
        }
        simpleModel.status = 0
        simpleModel.isTop = false
        simpleModel.id = self.id
        simpleModel.commentMark = Int64(self.id)
        simpleModel.userInfo = self.user
        simpleModel.replyUserInfo = self.replyUser
        simpleModel.isTop = self.isTop
        simpleModel.contentType = CommentContentType(rawValue: self.contentType) ?? .text
        return simpleModel
    }
}

// MARK: - 构建TSCommentViewModel

extension TSCommentModel {
    func viewModel() -> TSCommentViewModel? {
        guard let type = self.type else {
            return nil
        }
        let viewModel = TSCommentViewModel(id: self.id, userId: self.userId, type: type, user: self.user, replyUser: self.replyUser, content: self.body, createDate: self.createDate, status: .normal, isTop: self.isTop, contentType: CommentContentType(rawValue: self.contentType) ?? .text)
        return viewModel
    }
}

