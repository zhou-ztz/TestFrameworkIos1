//
//  TSNewsSelectedObject.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/30.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSNewsSelectedObject: Object {
    /// 资讯id
    @objc dynamic var newsID: Int = -1

    /// 设置主键
    override static func primaryKey() -> String? {
        return "newsID"
    }
}
