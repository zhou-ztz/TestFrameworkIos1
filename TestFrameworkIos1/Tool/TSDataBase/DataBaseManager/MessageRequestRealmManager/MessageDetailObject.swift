//
//  MessageDetailObject.swift
//  Yippi
//
//  Created by Tinnolab on 04/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import RealmSwift

class MessageDetailObject: Object {
    @objc dynamic var requestID: Int = 0
    @objc dynamic var fromUserID: Int = 0
    @objc dynamic var toUserID: Int = 0
    @objc dynamic var id: Int = 0
    @objc dynamic var content: String = ""
    @objc dynamic var isRead: Bool = false
    @objc dynamic var createdAt = Date()
    @objc dynamic var updatedAt = Date()
    @objc dynamic var deletedAt = Date()
    @objc dynamic var readAt = Date()
    @objc dynamic var username: String?
    
    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func messageItem() -> MessageItem {
        var toUserId = self.fromUserID
        var type: MessageType = .incoming
        if self.fromUserID == CurrentUserSessionInfo?.userIdentity {
            type = .outgoing
            toUserId = self.toUserID
        }
        var item = MessageItem.init(id: self.id, toUserId: toUserId, type: type, content: self.content, time: self.createdAt, status: .normal)
        if let username = self.username {
            item = MessageItem.init(id: self.id, toUserId: toUserId, type: type, content: self.content, time: self.createdAt, status: .normal, username: username)
        }
        return item
    }
}
