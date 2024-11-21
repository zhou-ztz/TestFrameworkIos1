//
//  TSSendCommentObject.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSSendCommentObject: Object {

    /// 动态的ID
    @objc dynamic var feedId = 0
    /// 评论标识
    @objc dynamic var commentIdentity = 0
    /// 圈子ID
    @objc dynamic var groupId = -1
    /// 创建时间
    @objc dynamic var create: NSDate? = nil
    /// 内容
    @objc dynamic var content = ""
    /// 评论者id
    @objc dynamic var userIdentity = 0
    /// 动态作者id
    @objc dynamic var toUserIdentity = 0
    /// 被回复者id
    @objc dynamic var replayToUserIdentity = 0
    /// 发送状态 0为成功或者发送中， 1为失败
    @objc dynamic var status = 0
    /// 唯一的id
    @objc dynamic var commentMark: Int64 = 0

    @objc dynamic var contentType = ""
    
    /// 设置主键
    override static func primaryKey() -> String? {
        return "commentMark"
    }

}
