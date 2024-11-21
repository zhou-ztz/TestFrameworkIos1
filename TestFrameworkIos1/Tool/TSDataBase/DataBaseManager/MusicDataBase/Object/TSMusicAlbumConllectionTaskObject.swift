//
//  TSMusicAlbumConllectionTaskObject.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSMusicAlbumConllectionTaskObject: Object {

    /// 任务标识，格式 userIdentity + "#" + "albumIdentity"
    @objc dynamic var id = ""
    /// 专辑 Id
    @objc dynamic var albumIdentity = -1
    /// 当前用户标识
    @objc dynamic var userIdentity = -1
    /// 收藏的状态
    @objc dynamic var collectionState = -1

    /// 任务的完成状态，0 进行中，1 已完成，2 未完成
    @objc dynamic var taskState = 0

    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
}
