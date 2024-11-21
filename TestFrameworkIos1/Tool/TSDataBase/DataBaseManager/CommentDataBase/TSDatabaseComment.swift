//
//  TSCommentDatabase.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/9.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  数据库评论相关

import UIKit
import RealmSwift

class TSDatabaseComment: NSObject {

    // MARK: - SAVE
    /// 储存发送的评论
    ///
    /// - Parameter comment: 评论对象
    func save(comment: TSSendCommentObject) {
        do {
            let realm = FeedIMSDKManager.shared.param.realm!
            try realm.safeWrite {
                realm.add(comment, update: .all)
            }
        } catch let err { handleException(err) }
        
    }

    /// 储存删除的评论
    ///
    /// - Parameter delete: 删除的object
    func save(delete: TSDeleteCommentObject) {
        do {
            let realm = FeedIMSDKManager.shared.param.realm!
            try realm.safeWrite {
                realm.add(delete, update: .all)
            }
        } catch let err { handleException(err) }
    }

    // MARK: - DELETE
    /// 删除发送成功的评论
    ///
    /// - Parameter commentIdentity: 评论唯一id
    func delete(commentMark: Int64) {
        do {
            let realm = FeedIMSDKManager.shared.param.realm!
            try realm.safeWrite {
                let comment = realm.objects(TSSendCommentObject.self).filter("commentMark == \(commentMark)")
                guard let commentObject = comment.first else {
                    return
                }
                realm.delete(commentObject)
            }
        } catch let err { handleException(err) }
    }

    /// 删除删除的评论
    ///
    /// - Parameter deleteCommentMark: 删除唯一标识
    func delete(deleteCommentMark: Int64) {
        do {
            let realm = FeedIMSDKManager.shared.param.realm!
            try realm.safeWrite {
                let comment = realm.objects(TSDeleteCommentObject.self).filter("commentMark == \(deleteCommentMark)")
                if comment.isEmpty {
                    return
                }
                realm.delete(comment)
            }
        } catch let err { handleException(err) }
    }

    /// 删除数据库的评论
    func delete(mommentCommentMark: Int64) {
        do {
            let realm = FeedIMSDKManager.shared.param.realm!
            try realm.safeWrite {
                let comment = realm.objects(TSMomentCommnetObject.self).filter("commentMark == \(mommentCommentMark)")
                if comment.isEmpty {
                    return
                }
                realm.delete(comment)
            }
        } catch let err { handleException(err) }
    }

    /// 删除所有评论数据
    func deleteAll() {
        do {
            let realm = FeedIMSDKManager.shared.param.realm!
            let comments = realm.objects(TSMomentCommnetObject.self)
            let sendComments = realm.objects(TSSendCommentObject.self)
            try realm.safeWrite {
                realm.delete(comments)
                realm.delete(sendComments)
            }
        } catch let err { handleException(err) }
    }

    // MARK: - GET
    /// 获取还没发送成功的Id
    ///
    /// - Parameter feedId: 动态的id
    /// - Returns: 返回评论对象数组
    func get(feedId: Int) -> [TSSendCommentObject]? {
        let realm = FeedIMSDKManager.shared.param.realm!
        
        do {
            let result = realm.objects(TSSendCommentObject.self).filter("feedId = \(feedId)")
            if result.isEmpty {
                return nil
            }
            return Array(result)
        } catch let err {
            handleException(err)
            return nil
        }
    }

    /// 获取还没发送成功的评论
    ///
    /// - Returns: 返回没有成功的评论
    func getSendTask() -> [TSSendCommentObject]? {
        let realm = FeedIMSDKManager.shared.param.realm!
        
        do {
            let result = realm.objects(TSSendCommentObject.self)
            return Array(result)
        } catch let err {
            handleException(err)
            return nil
        }
    }

    /// 改变所有评论状态
    ///
    /// - Parameter failComments: 失败的评论任务
    func replace(failComments: [TSSendCommentObject]) {
        let realm = FeedIMSDKManager.shared.param.realm!
        
        do {
            try realm.safeWrite {
                for item in failComments {
                    item.status = 1
                    realm.add(item, update: .all)
                }
            }
        } catch let err { handleException(err) }
    }

    /// 获取还未删除的评论
    ///
    /// - Returns: 待删除的评论
    func getDeleteTask() -> [TSDeleteCommentObject]? {
        do {
            let realm = FeedIMSDKManager.shared.param.realm!
            let result = realm.objects(TSDeleteCommentObject.self)
            if result.isEmpty {
                return nil
            }
            return Array(result)
        } catch let err {
            handleException(err)
            return nil
        }
    }
}
