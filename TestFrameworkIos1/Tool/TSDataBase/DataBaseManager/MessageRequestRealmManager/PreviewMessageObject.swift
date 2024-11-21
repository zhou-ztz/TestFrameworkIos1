//
//  PreviewMessageObject.swift
//  Yippi
//
//  Created by Tinnolab on 11/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import RealmSwift

class PreviewMessageObject: Object {
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
    
    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
}
