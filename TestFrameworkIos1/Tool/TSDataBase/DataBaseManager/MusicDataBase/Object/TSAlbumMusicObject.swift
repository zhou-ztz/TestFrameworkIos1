//
//  TSAlbumMusicObject.swift
//  ThinkSNS +
//
//  Created by 小唐 on 01/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  专辑详情中音乐数据库模型

import Foundation
import RealmSwift

class TSAlbumMusicObject: Object {
    // 音乐id
    @objc dynamic var id: Int = 0
    @objc dynamic var createDate: String = ""
    @objc dynamic var updateDate: String = ""
    @objc dynamic var deleteDate: String?
    // 音乐标题
    @objc dynamic var title: String = ""
    // 歌手信息
    @objc dynamic var singer: TSMusicSingerObject?
    // 音乐附件信息
    @objc dynamic var storage: TSMusicStorageObject?
    // 歌曲时间(app暂时自行下载解析时间)
    @objc dynamic var lastTime: Int = 0
    // 歌词
    // 别的界面中总使用强制解析，故这里不适用可选
//    @objc dynamic var lyric: String?
    @objc dynamic var lyric: String = "music_lyric".localized
    // 播放数
    @objc dynamic var tasteCount: Int = 0
    // 分享数
    @objc dynamic var shareCount: Int = 0
    // 评论数
    @objc dynamic var commentCount: Int = 0
    // 是否已赞
    @objc dynamic var isLiked: Bool = false

    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }

}

/// 音乐附件
class TSMusicStorageObject: Object {
    // 附件id
    @objc dynamic var id: Int = 0
    // 付费金额 音乐免费时该字段不存在
    var amount = RealmOptional<Float>()
    // 付费类型  音乐免费时该字段不存在
    @objc dynamic var type: String?
    // 是否已付费 音乐免费时 该字段不存在
    var paid = RealmOptional<Bool>()
    // 付费节点  音乐免费时 该字段不存在
    var paidNode = RealmOptional<Int>()

    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
}
