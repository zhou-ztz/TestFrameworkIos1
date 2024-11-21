//
//  MessageRequestCount.swift
//  Yippi
//
//  Created by Tinnolab on 04/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import RealmSwift

class MessageRequestCountObject: Object {
    /// 标识
    // sourcery: primarykey
    let id = RealmOptional<Int>()
    
    @objc dynamic var count: Int = 0
    
    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
}
