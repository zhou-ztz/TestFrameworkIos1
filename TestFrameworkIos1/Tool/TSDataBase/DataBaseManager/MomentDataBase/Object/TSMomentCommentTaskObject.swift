//
//  TSMomentCommentTaskObject.swift
//  Yippi
//
//  Created by Charlie-iOS on 20/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//
import UIKit
import RealmSwift

class TSMomentCommentTaskObject: Object {
    
    /// 动态 Id
    @objc dynamic var feedIdentity = -1
    /// 收藏的状态
    @objc dynamic var commentState = -1
    
    /// 任务的完成状态，0 进行中，1 已完成，2 未完成
    @objc dynamic var taskState = 0
    
    /// 设置主键
    override static func primaryKey() -> String? {
        return "feedIdentity"
    }
}
