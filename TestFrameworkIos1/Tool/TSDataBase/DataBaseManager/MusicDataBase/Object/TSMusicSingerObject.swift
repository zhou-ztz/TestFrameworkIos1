//
//  TSMusicSingerObject.swift
//  ThinkSNS +
//
//  Created by 小唐 on 01/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//

import Foundation
import RealmSwift

class TSMusicSingerObject: Object {
    // 歌手id
    @objc dynamic var id: Int = 0
    @objc dynamic var createDate: String = ""
    @objc dynamic var updateDate: String = ""
    // 歌手名称
    @objc dynamic var name: String = ""
    // 歌手图片
    @objc dynamic var cover: TSMusicImageObject?

    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
}
