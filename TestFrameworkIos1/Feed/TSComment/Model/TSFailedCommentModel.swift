//
//  TSFailedCommentModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 19/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  发送失败的评论数据模型

import Foundation
import SwiftyJSON
import ObjectMapper
import RealmSwift

/// 发送失败的评论数据模型
class TSFailedCommentModel {
    var id: Int = 0
    var commentTableType: String = ""
    var commentTableId: Int = 0
    var userId: Int = 0
    var targetUserId: Int = 0
    var replyUserId: Int?
    var createDate: Date?
    var updateDate: Date?
    var body: String = ""
    var type: TSCommentType?
    var contentType: CommentContentType
    var user: UserInfoModel?
    var targetUser: UserInfoModel?
    var replyUser: UserInfoModel?

    // 构造方法
    init(type: TSCommentType, sourceId: Int, content: String, targetUserId: Int, replyUserId: Int?, contentType: CommentContentType) {
        // id的自增
        self.id = TSFailedCommentObject.incrementaID()
        self.type = type
        self.commentTableType = type.rawValue
        self.commentTableId = sourceId
        self.userId = CurrentUserSessionInfo?.userIdentity ?? 0
        self.targetUserId = targetUserId
        self.replyUserId = replyUserId
        self.createDate = Date()
        self.updateDate = Date()
        self.body = content
        self.contentType = contentType
    }

    // MARK: - DB
    init(object: TSFailedCommentObject) {
        self.id = object.id
        self.commentTableType = object.commentTableType
        self.commentTableId = object.commentTableId
        self.userId = object.userId
        self.targetUserId = object.targetUserId
        self.replyUserId = object.replyUserId.value
        self.createDate = object.createDate
        self.updateDate = object.updateDate
        self.body = object.body
        self.type = TSCommentType(rawValue: object.commentTableType)
        self.contentType = CommentContentType(rawValue: object.contentType) ?? .text
    }
    func object() -> TSFailedCommentObject {
        let object = TSFailedCommentObject()
        object.id = self.id
        object.commentTableType = self.commentTableType
        object.commentTableId = self.commentTableId
        object.userId = self.userId
        object.targetUserId = self.targetUserId
        object.replyUserId = RealmOptional<Int>(self.replyUserId)
        object.createDate = self.createDate
        object.updateDate = self.updateDate
        object.body = self.body
        object.contentType = self.contentType.rawValue
        return object
    }
}

// MARK: - 构建TSSimpleCommentModel

extension TSFailedCommentModel {
    func simpleModel() -> TSSimpleCommentModel {
        var simpleModel = TSSimpleCommentModel()
        simpleModel.content = self.body
        if let date = self.createDate {
            simpleModel.createdAt = NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
        }
        simpleModel.status = 1
        simpleModel.isTop = false
        simpleModel.id = self.id
        simpleModel.commentMark = Int64(self.id)
        simpleModel.userInfo = self.user
        simpleModel.replyUserInfo = self.replyUser
        simpleModel.contentType = self.contentType
        return simpleModel
    }
}

// MARK: - 构建TSCommentViewModel

extension TSFailedCommentModel {
    func viewModel() -> TSCommentViewModel? {
        guard let type = self.type else {
            return nil
        }
        let viewModel = TSCommentViewModel(id: self.id, userId: self.userId, type: type, user: self.user, replyUser: self.replyUser, content: self.body, createDate: self.createDate, status: .faild, isTop: false, contentType: self.contentType)
        return viewModel
    }
}
