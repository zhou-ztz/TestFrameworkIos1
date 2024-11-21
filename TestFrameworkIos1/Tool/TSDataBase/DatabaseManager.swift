//
//  TSDataBaseManager.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/14.
//  Copyright © 2017年 LeonFa. All rights reserved.
//
//  数据库管理类

import UIKit
import RealmSwift

enum DatabaseExceptionType: Error {
    case notCurrentUser
}

class DatabaseManager: NSObject {
    /// 用户相关
    var user = DatabaseUser()
    /// 动态相关
//    var moment = TSDatabaseMoment()
    /// 数据库相关
    var chat = TSChatDatabaseManager()
    /// 评论相关
    var comment = TSDatabaseComment()
    /// 广告相关
    var advert = TSDatabaseAdvert()
    /// 后台任务
    var task = DatabaseTask()
    /// 动态任务相关
    var momentTask = TSDatabaseMomentTask()
    /// 音乐
   // var music = TSDatabaseMusic()
    /// 评论相关
    /// 之后应统一评论，并使用TSCommentRealmManager代替TSDatabaseComment
    var commentManager = TSCommentRealmManager()
    let messageRequest = MessageRequestRealmManager()
    
    /// 编辑器的图片缓存
    let editor = TSWebEditorRealmManager()

    override init() {
        super.init()
    }

    // MARK: - Pucblic
    /// 退出登录时清空数据库信息
    func deleteAll() {
        // 删除点赞任务
        momentTask.deleteAll()
        // 删除动态列表
//        moment.deleteAll()
        // 删除聊天信息
        chat.deleteAll()
        /// 删除所有动态评论
        comment.deleteAll()
        /// 删除所有音乐评论
       // music.deleteAll()
        /// 删除Gallery列表
        GalleryStoreManager().deleteAll()
        /// 删除所有的缓存
        messageRequest.deleteAll()

//        languageFilter.deleteAll()
    }
}
