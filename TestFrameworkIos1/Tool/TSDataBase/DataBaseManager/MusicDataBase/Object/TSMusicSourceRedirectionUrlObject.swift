//
//  TSMusicSourceRedirecationUrlObject.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSMusicSourceRedirectionUrlObject: Object {
    /// 音乐资源id
    @objc dynamic var musicStorage: Int = 0
    ///重定向地址
    @objc dynamic var redirectionPath: String? = nil

    /// 设置主键
    override static func primaryKey() -> String? {
        return "musicStorage"
    }
}
