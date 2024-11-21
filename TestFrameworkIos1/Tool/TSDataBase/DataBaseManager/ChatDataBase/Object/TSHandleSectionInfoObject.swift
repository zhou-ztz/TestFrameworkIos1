//
//  TSHandleSectionInfoObject.swift
//  ThinkSNS +
//
//  Created by lip on 2017/4/12.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  消息页面处理区域信息数据库模型

import RealmSwift

class TSHandleSectionInfoObject: Object {
    /// 接收信息的用户名
    @objc dynamic var incomingUserName = ""
    /// 接收信息的用户唯一标识
    @objc dynamic var incomingUserIdentity: Int = -1
    /// 会话唯一标识
    ///
    /// - Note: 用于查阅数据库
    @objc dynamic var identity: Int = -1
    /// 最新的会话信息内容
    @objc dynamic var latestMessage: String? = nil
    /// 最新消息的时间
    ///
    /// - Note: 由服务器提供
    @objc dynamic var latestMessageDate: NSDate? = nil
    /// 未读消息数量
    @objc dynamic var unreadCount: Int = 0
    /// 最新消息发送结果
    let isSendingLatestMessage = RealmOptional<Bool>()

    override class func primaryKey() -> String {
        return "identity"
    }
}
