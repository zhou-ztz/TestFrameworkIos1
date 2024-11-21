//
//  MessageItemObject.swift
//  Yippi
//
//  Created by Tinnolab on 05/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import RealmSwift

class MessageItemObject: Object {
    @objc dynamic var id: Int = -1
    @objc dynamic var toUserId: Int = 0
    @objc dynamic var content: String = ""
    @objc dynamic var time: Date = Date()
    
    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func messageItem() -> MessageItem {
        let item = MessageItem.init(id: self.id, toUserId: self.toUserId, type: .outgoing, content: self.content, time: self.time, status: .failed)
        return item
    }
}
