//
//  MessageRequestItemObject.swift
//  Yippi
//
//  Created by Tinnolab on 04/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import RealmSwift

class MessageRequestObject: Object {
    
    @objc dynamic var requestID: Int = 0
    @objc dynamic var fromUserID: Int = 0
    @objc dynamic var toUserID: Int = 0
    @objc dynamic var isBlock: Bool = false
    @objc dynamic var total: Int = 0
    @objc dynamic var createdAt = Date()
    @objc dynamic var updatedAt = Date()
    @objc dynamic var deletedAt = Date()
    @objc dynamic var syncAt = Date()
    @objc dynamic var after: Int = 0
    @objc dynamic var userId: String?
    @objc dynamic var messageDetail: PreviewMessageObject?
    
    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["requestID"]
    }
    
    /// 设置主键
    override static func primaryKey() -> String? {
        return "requestID"
    }
}
