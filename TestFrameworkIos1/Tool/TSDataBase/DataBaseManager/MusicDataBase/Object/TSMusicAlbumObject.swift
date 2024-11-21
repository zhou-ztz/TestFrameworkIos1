////
////  TSMusicAlbumObject.swift
////  Thinksns Plus
////
////  Created by LiuYu on 2017/3/20.
////  Copyright © 2017年 ZhiYiCX. All rights reserved.
////
//
//import UIKit
//import RealmSwift
//
//class TSMusicAlbumObject: Object {
//
//    /// 专辑id
//    @objc dynamic var albumID: Int = -1
//    /// 创建时间
//    @objc dynamic var created_at: String = ""
//    /// 上传时间
//    @objc dynamic var updated_at: String = ""
//    /// 专辑名称
//    @objc dynamic var title: String = ""
//    /// 专辑简介
//    @objc dynamic var intro: String = ""
//    
//    /// 封面附件id
//    @objc dynamic var storage_id: Int = -1
//    /// 封面的size
//    @objc dynamic var storageSize: String = ""
//    
//    /// 收听数
//    @objc dynamic var taste_count: Int = 0
//    /// 分享数
//    @objc dynamic var share_count: Int = 0
//    /// 评论数
//    @objc dynamic var comment_count: Int = 0
//    /// 收藏数
//    @objc dynamic var collect_count: Int = 0
//    /// 是否收藏
//    @objc dynamic var isConllected: Int = 0
//
//    /// 设置索引
//    override static func indexedProperties() -> [String] {
//        return ["albumID"]
//    }
//    /// 设置主键
//    override static func primaryKey() -> String? {
//        return "albumID"
//    }
//}

typealias TSMusicAlbumObject = TSAlbumListObject
