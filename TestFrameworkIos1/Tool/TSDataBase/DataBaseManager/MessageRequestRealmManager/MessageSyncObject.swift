//
//  MessageSyncObject.swift
//  Yippi
//
//  Created by Tinnolab on 16/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import RealmSwift

class MessageSyncObject: Object {
    @objc dynamic var toUserID: Int = 0
    @objc dynamic var requestID: Int = 0
    @objc dynamic var id: Int = 0
    @objc dynamic var syncAt = Date()
    
    /// 设置主键
    override static func primaryKey() -> String? {
        return "toUserID"
    }
}
