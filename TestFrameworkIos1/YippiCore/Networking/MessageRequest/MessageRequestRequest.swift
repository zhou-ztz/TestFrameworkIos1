//
//  MessageRequestRequest.swift
//  Yippi
//
//  Created by Tinnolab on 27/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

struct MessageRequestRequest {
    
    let requestCount = Request<MessageRequestCountModel>(method: .get, path: "user/message/pendingRequestCount", replacers: [])
    
    let msgRequestList = Request<MessageRequestModel>(method: .get, path: "user/message/pendingRequest?limit=200", replacers: [])
    
    let deleteMessageRequest = Request<Empty>(method: .delete, path: "user/message/pendingRequest", replacers: [])
    
    let markRead = Request<Empty>(method: .patch, path: "user/message/markAsRead", replacers: [])
    
    let sendMessage = Request<MessageDetailModel>(method: .post, path: "user/message/pendingRequestChat", replacers: [])
    
    let chatHistory = Request<MessageDetailModel>(method: .get, path: "user/message/pendingRequestChat?user_id={userID}&limit={limit}", replacers: ["{userID}","{limit}"])
    
    let followFriend = Request<Empty>(method: .post, path: "user/message/addFriend", replacers: [])
    
    let blacklistFriend = Request<Empty>(method: .post, path: "user/black/{userID}", replacers: ["{userID}"])
}

// sourcery: RealmEntityConvertible
class MessageRequestCountModel: Mappable {
    var count: Int = 0
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        count <- map["count"]
    }
    
    /// 从数据库模型转换
    init(object: MessageRequestCountObject) {
        self.count = object.count
    }
    
    /// 转换为数据库对象
    func object() -> MessageRequestCountObject {
        let object = MessageRequestCountObject()
        object.count = self.count
        return object
    }
}

// sourcery: RealmEntityConvertible
class MessageRequestModel: Mappable {
    var requestID: Int = 0
    var fromUserID: Int = 0
    var toUserID: Int = 0
    var isBlock: Int = 0
    var total: Int = 0
    var createdAt = Date()
    var updatedAt = Date()
    var deletedAt = Date()
    var syncAt = Date()
    var after: Int = 0
    var user: UserInfoModel?
    var messageDetail: MessageDetailModel?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        fromUserID <- map["from_user_id"]
        toUserID <- map["to_user_id"]
        isBlock <- map["is_block"]
        total <- map["total"]
        createdAt <- (map["created_at"], DateTransformer)
        updatedAt <- (map["updated_at"], DateTransformer)
        deletedAt <- (map["deleted_at"], DateTransformer)
        syncAt <- (map["sync_at"], DateTransformer)
        requestID <- map["request_id"]
        after <- map["after"]
        user <- map["user"]
        messageDetail <- map["message_detail"]
    }
    
    
    /// 从数据库模型转换
    init(object: MessageRequestObject) {
        self.fromUserID = object.fromUserID
        self.toUserID = object.toUserID
        self.isBlock = object.isBlock ? 1 : 0
        self.total = object.total
        self.createdAt = object.createdAt
        self.updatedAt = object.updatedAt
        self.deletedAt = object.deletedAt
        self.syncAt = object.syncAt
        self.requestID = object.requestID
        self.after = object.after
        
        let userobj = UserInfoModel.retrieveUser(userId: object.userId.orEmpty.toInt())
        self.user = userobj
        
        if nil != object.messageDetail, object.isInvalidated == false {
            self.messageDetail = MessageDetailModel(previewMessageObject: object.messageDetail!)
        }
    }
    
    /// 转换为数据库对象
    func object() -> MessageRequestObject {
        let object = MessageRequestObject()
        object.requestID = self.requestID
        object.fromUserID = self.fromUserID
        object.toUserID = self.toUserID
        object.isBlock = (self.isBlock == 1)
        object.total = self.total
        object.createdAt = self.createdAt
        object.updatedAt = self.updatedAt
        object.deletedAt = self.deletedAt
        object.syncAt = self.syncAt
        object.after = self.after
        object.userId = (self.user?.userIdentity).orZero.stringValue
        object.messageDetail = self.messageDetail?.previewMsgObject()
        return object
    }
}

// MARK: - MessageDetailModel
// sourcery: RealmEntityConvertible
class MessageDetailModel: Mappable {
    var requestID: Int = 0
    var fromUserID: Int = 0
    var toUserID: Int = 0
    var id: Int = 0
    var content = ""
    var isRead = 0
    var createdAt = Date()
    var updatedAt = Date()
    var deletedAt = Date()
    var readAt = Date()
    var user: UserInfoModel?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        requestID <- map["request_id"]
        fromUserID <- map["from_user_id"]
        toUserID <- map["to_user_id"]
        content <- map["content"]
        isRead <- map["is_read"]
        createdAt <- (map["created_at"], DateTransformer)
        updatedAt <- (map["updated_at"], DateTransformer)
        deletedAt <- (map["deleted_at"], DateTransformer)
        readAt <- (map["read_at"], DateTransformer)
        user <- map["user"]
    }
    
    /// 从数据库模型转换
    init(object: MessageDetailObject) {
        self.id = object.id
        self.requestID = object.requestID
        self.fromUserID = object.fromUserID
        self.toUserID = object.toUserID
        self.content = object.content
        self.isRead = object.isRead ? 1 : 0
        self.createdAt = object.createdAt
        self.updatedAt = object.updatedAt
        self.deletedAt = object.deletedAt
        self.readAt = object.readAt
        
        
        let userobj = UserInfoModel.retrieveUser(username: object.username)
        self.user = userobj
    }
    
    /// 从数据库模型转换
    init(previewMessageObject: PreviewMessageObject) {
        self.id = previewMessageObject.id
        self.requestID = previewMessageObject.requestID
        self.fromUserID = previewMessageObject.fromUserID
        self.toUserID = previewMessageObject.toUserID
        self.content = previewMessageObject.content
        self.isRead = previewMessageObject.isRead ? 1 : 0
        self.createdAt = previewMessageObject.createdAt
        self.updatedAt = previewMessageObject.updatedAt
        self.deletedAt = previewMessageObject.deletedAt
        self.readAt = previewMessageObject.readAt
    }
    
    /// 转换为数据库对象
    func object() -> MessageDetailObject {
        let object = MessageDetailObject()
        object.id = self.id
        object.requestID = self.requestID
        object.fromUserID = self.fromUserID
        object.toUserID = self.toUserID
        object.content = self.content
        object.isRead = (self.isRead == 1)
        object.createdAt = self.createdAt
        object.updatedAt = self.updatedAt
        object.deletedAt = self.deletedAt
        object.readAt = self.readAt
        object.username = self.user?.username
        return object
    }
    
    /// 转换为数据库对象
    func previewMsgObject() -> PreviewMessageObject {
        let object = PreviewMessageObject()
        object.id = self.id
        object.requestID = self.requestID
        object.fromUserID = self.fromUserID
        object.toUserID = self.toUserID
        object.content = self.content
        object.isRead = (self.isRead == 1)
        object.createdAt = self.createdAt
        object.updatedAt = self.updatedAt
        object.deletedAt = self.deletedAt
        object.readAt = self.readAt
        return object
    }
}
