//
//  TSConversationUtilDataObject.swift
//  ThinkSNS +
//
//  Created by lip on 2017/4/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  会话杂项数据库数据模型

import UIKit
import RealmSwift

/// 存储会话点赞数据库的主键
public let kConversationUtilDataDiggsObjectKey = "kConversationUtilDataDiggsObjectKey"
/// 存储会话评论数据库的主键
public let kConversationUtilDataCommentsObjectKey = "kConversationUtilDataCommentsObjectKey"
/// 存储会话评论置顶数据库的主键
public let kConversationUtilDataPinnedsObjectKey  = "kConversationUtilDataPinnedsObjectKey"

class TSConversationUtilDataObject: Object {
    /// 副标题
    @objc dynamic var detailTitle: String? = nil
    /// 用户组
    /// 通过,符号分开的字符串数组
    /// 例如: [1, 2, 3] 存储为 "1,2,3"
    @objc dynamic var uids: String? = nil
    /// 未读数
    @objc dynamic var unreadCount: Int = 0
    /// 时间
    @objc dynamic var date: NSDate? = nil
    /// 主键
    @objc dynamic var identity: String = ""
    /// 类型
    @objc dynamic var type: String = ""

    override class func primaryKey() -> String {
        return "identity"
    }
}
