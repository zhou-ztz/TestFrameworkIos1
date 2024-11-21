//
//  TopicListObject.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/25.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TopicListObject: Object {

    @objc dynamic var topicId: Int = 0
    @objc dynamic var topicTitle: String = ""
    @objc dynamic var topicLogo: EntityNetFile?
    @objc dynamic var topicFollow = false
    /// 主键
    override static func primaryKey() -> String? {
        return "topicId"
    }
}
