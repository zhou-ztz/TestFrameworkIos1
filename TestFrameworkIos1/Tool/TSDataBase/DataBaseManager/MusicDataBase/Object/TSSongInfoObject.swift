////
////  TSSongInfoObject.swift
////  Thinksns Plus
////
////  Created by LiuYu on 2017/3/22.
////  Copyright © 2017年 ZhiYiCX. All rights reserved.
////
//
//import UIKit
//import RealmSwift
//
//class TSSongInfoObject: Object {
//
//    /// id
//    @objc dynamic var infoID: Int = 0
//    /// 创建时间
//    @objc dynamic var created_at: String = ""
//    /// 上传时间
//    @objc dynamic var updated_at: String = ""
//    /// 歌曲名
//    @objc dynamic var title: String = ""
//    /// 歌手
////    let singer = List<TSSingerObject>()
//    @objc dynamic var singerId: Int = 0
//    /// 歌手信息
//    @objc dynamic var singer: TSSingerObject?
//    /// 歌曲封面附件ID
//    @objc dynamic var storage: Int = 0
//    /// 时长
//    @objc dynamic var last_time: Int = 0
//    /// 歌词
//    @objc dynamic var lyric: String = ""
//    /// 播放数
//    @objc dynamic var taste_count: Int = 0
//    /// 分享数
//    @objc dynamic var share_count: Int = 0
//    /// 评论数
//    @objc dynamic var comment_count: Int = 0
//    /// 是否点赞/收藏
//    @objc dynamic var isdiggmusic: Int = 0
//
//    /// 设置索引
//    override static func indexedProperties() -> [String] {
//        return ["infoID", "title", "singerId"]
//    }
//    /// 设置主键
//    override static func primaryKey() -> String? {
//        return "infoID"
//    }
//}
