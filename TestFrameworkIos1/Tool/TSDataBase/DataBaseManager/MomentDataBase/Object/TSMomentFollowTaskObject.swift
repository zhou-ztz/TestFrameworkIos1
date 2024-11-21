//
//  TSMomentFollowTaskObject.swift
//  Yippi
//
//  Created by TinnoLab on 26/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import RealmSwift

class TSMomentFollowTaskObject: Object {

    /// 用户ID
    @objc dynamic var userId = -1
    /// 关注状态
    @objc dynamic var followState = -1
    /// 任务的完成状态，0 进行中，1 已完成，2 未完成
    @objc dynamic var taskState = 0
    /// 设置主键
    override static func primaryKey() -> String? {
        return "userId"
    }
}
