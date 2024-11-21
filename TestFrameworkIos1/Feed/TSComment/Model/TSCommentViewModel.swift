//
//  TSCommentViewModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/10/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  评论视图模型
//  之后的评论相关视图都加载该模型
//  如：动态中评论列表的某一条评论、其他详情页或列表页中的评论列表中的一条评论

import Foundation

/// 评论发送状态
enum TSCommentSendtatus: Int {
    /// 发送成功
    case normal = 0
    /// 发送失败
    case faild
    /// 发送中
    case sending
}

class TSCommentViewModel {
    var id: Int = 0
    var userId: Int = 0
    var user: UserInfoModel?
    var replyUser: UserInfoModel?
    var content: String = ""
    var createDate: Date?
    var isTop = false
    var status: TSCommentSendtatus = .normal
    var type: TSCommentType

    var contentType: CommentContentType = .text
    
    init(type: TSCommentType) {
        self.type = type
        self.userId = CurrentUserSessionInfo?.userIdentity ?? 0
    }
    init(type: TSCommentType, content: String, replyUserId: Int?, status: TSCommentSendtatus, contentType: CommentContentType) {
        self.type = type
        self.content = content
        self.userId = (CurrentUserSessionInfo?.userIdentity).orZero
        self.user = CurrentUser
        if let replyUserId = replyUserId {
            self.replyUser = UserInfoModel.retrieveUser(userId: replyUserId)
        }
        self.status = status
        self.contentType = contentType
    }
    init(id: Int, userId: Int, type: TSCommentType, user: UserInfoModel?, replyUser: UserInfoModel?, content: String, createDate: Date?, status: TSCommentSendtatus, isTop: Bool = false, contentType: CommentContentType) {
        self.id = id
        self.userId = userId
        self.type = type
        self.user = user
        self.replyUser = replyUser
        self.content = content
        self.createDate = createDate
        self.status = status
        self.isTop = isTop
        self.contentType = contentType
    }

}
