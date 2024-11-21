//
//  TSDatabaseMomentTask.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  数据库管理类 动态相关任务

import UIKit
import RealmSwift
import os.log

public func handleException(_ error: Error) {
//    os_log("%@", log: OSLog.deviceCycle, type: .error, error.localizedDescription)
}
// MARK: - 当动态详情页和动态发布页重写后，这个类就该删除了
class TSDatabaseMomentTask {

    fileprivate let realm: Realm = FeedIMSDKManager.shared.param.realm!

    /// 可以替换掉内部数据的初始化方法,用于测试
    ///
    /// - Parameter realm: 数据库
    init() { }

    // MARK: - 删除动态

    // MARK: 获取任务
    /// 获取失败的删除任务
    func getFaildDeleteList() -> [TSMomentDeleteTaskObject] {
        let faildDelete = realm.objects(TSMomentDeleteTaskObject.self).filter("taskState == 2")
        return Array(faildDelete)
    }

    /// 获取未完成的删除任务
    func getUnFinishDeleteList() -> [TSMomentDeleteTaskObject] {
        let unFinishedDigg = realm.objects(TSMomentDeleteTaskObject.self).filter("taskState != 1")
        return Array(unFinishedDigg)
    }

    /// 获取单个删除任务
    ///
    /// - Parameters:
    ///   - feedIdentity: 动态唯一标识
    /// - Returns: 任务
    func getDelete(_ feedIdentity: Int) -> TSMomentDeleteTaskObject? {
        let result = realm.objects(TSMomentDeleteTaskObject.self).filter("feedIdentity == \(feedIdentity)")
        if result.isEmpty {
            return nil
        }
        return result.first!
    }

    // MARK: 写入任务
    /// 写入删除任务
    func save(deleteTask feedIdentity: Int) {
        let result = realm.objects(TSMomentDeleteTaskObject.self).filter("feedIdentity == \(feedIdentity)")
        if !result.isEmpty {
            return
        }
        
        do {
            try realm.safeWrite {
                let newObject = TSMomentDeleteTaskObject()
                newObject.feedIdentity = feedIdentity
                newObject.taskState = 0
                realm.add(newObject, update: .all)
            }
        } catch let err { handleException(err) }
    }

    /// 设置删除任务为进行状态
    func changeToStartState(delete: TSMomentDeleteTaskObject) {
        do {
            try realm.safeWrite {
                delete.taskState = 0
            }
        } catch let err { handleException(err) }
    }

    // MARK: 结束任务

    /// 结束删除任务
    ///
    /// - Parameters:
    ///   - digg: 收藏任务
    ///   - success: 是否成功
    func end(delete task: TSMomentDeleteTaskObject, success: Bool) {
        do {
            try realm.safeWrite {
                task.taskState = success ? 1 : 2
                if task.taskState == 1 { // 如果成功，删除任务
                    realm.delete(task)
                }
            }
        } catch let err { handleException(err) }
    }

    // MARK: - 点赞

    // MARK: 获取任务
    /// 获取失败的点赞任务
    func getFaildDiggList() -> [TSMomentDiggTaskObject] {
        let failDigg = realm.objects(TSMomentDiggTaskObject.self).filter("taskState == 2")
        return Array(failDigg)
    }

    /// 获取未完成的点赞任务
    func getUnFinishedDiggList() -> [TSMomentDiggTaskObject] {
        let unFinishedDigg = realm.objects(TSMomentDiggTaskObject.self).filter("taskState != 1")
        return Array(unFinishedDigg)
    }

    /// 获取单个赞任务
    ///
    /// - Parameters:
    ///   - feedIdentity: 动态唯一标识
    /// - Returns: 任务
    func getDigg(_ feedIdentity: Int) -> TSMomentDiggTaskObject? {
        let result = realm.objects(TSMomentDiggTaskObject.self).filter("feedIdentity == \(feedIdentity)")
        if result.isEmpty {
            return nil
        }
        return result.first!
    }

    // MARK: 写入任务

    /// 写入赞任务
    ///
    /// - Parameters:
    ///   - newDigg: 0 取消赞，1 点赞
    ///   - feedIdentity: 动态唯一标识
    func save(diggTask newDigg: Int, feedIdentity: Int) {
        let result = realm.objects(TSMomentDiggTaskObject.self).filter("feedIdentity == \(feedIdentity)")
        var newObject = TSMomentDiggTaskObject()
        
        do {
            try realm.safeWrite {
                newObject.feedIdentity = feedIdentity
                if !result.isEmpty {
                    newObject = result.first!
                }
                
                newObject.taskState = 0
                newObject.diggState = newDigg
                realm.add(newObject, update: .all)
            }
        } catch let error as NSError {
            assert(false, "😡😡😡Fail to save digg task object, reason: \(error.localizedDescription)")
        }
    }

    /// 设置赞任务为进行状态
    func changeToStartState(digg: TSMomentDiggTaskObject) {
        do {
            try realm.safeWrite {
                digg.taskState = 0
            }
        } catch let err { handleException(err) }
    }

    // MARK: 结束任务

    /// 结束赞任务
    ///
    /// - Parameters:
    ///   - digg: 赞任务
    ///   - success: 是否成功
    func end(digg task: TSMomentDiggTaskObject, success: Bool) {
        do {
            try realm.safeWrite {
                task.taskState = success ? 1 : 2
            }
        } catch let err { handleException(err) }
    }

    // MARK: - 收藏

    // MARK: 获取任务
    /// 获取失败的收藏任务
    func getFaildCollectList() -> [TSMomentCollectTaskObject] {
        let failCollect = realm.objects(TSMomentCollectTaskObject.self).filter("taskState == 2")
        return Array(failCollect)
    }
    
    /// 获取失败的comment disable任务
    func getFaildCommentList() -> [TSMomentCommentTaskObject] {
        let failCollect = realm.objects(TSMomentCommentTaskObject.self).filter("taskState == 2")
        return Array(failCollect)
    }

    /// 获取未完成的收藏任务
    func getUnFinishedCollectList() -> [TSMomentCollectTaskObject] {
        let unFinishedCollect = realm.objects(TSMomentCollectTaskObject.self).filter("taskState != 1")
        return Array(unFinishedCollect)
    }
    
    /// 获取未完成的comment disable任务
    func getUnFinishedCommentList() -> [TSMomentCommentTaskObject] {
        let unFinishedCollect = realm.objects(TSMomentCommentTaskObject.self).filter("taskState != 1")
        return Array(unFinishedCollect)
    }

    /// 获取单个收藏任务
    ///
    /// - Parameters:
    ///   - feedIdentity: 动态唯一标识
    /// - Returns: 任务
    func getCollect(_ feedIdentity: Int) -> TSMomentCollectTaskObject? {
        let result = realm.objects(TSMomentCollectTaskObject.self).filter("feedIdentity == \(feedIdentity)")
        if result.isEmpty {
            return nil
        }
        return result.first!
    }
    
    /// 获取单个comment disable任务
    ///
    /// - Parameters:
    ///   - feedIdentity: 动态唯一标识
    /// - Returns: 任务
    func getComment(_ feedIdentity: Int) -> TSMomentCommentTaskObject? {
        let result = realm.objects(TSMomentCommentTaskObject.self).filter("feedIdentity == \(feedIdentity)")
        if result.isEmpty {
            return nil
        }
        return result.first!
    }

    // MARK: 写入任务

    /// 写入收藏任务
    ///
    /// - Parameters:
    ///   - newCollect: 0 取消收藏，1 收藏
    ///   - feedIdentity: 动态唯一标识
    func save(collectTask newCollect: Int, feedIdentity: Int) {
        let result = realm.objects(TSMomentCollectTaskObject.self).filter("feedIdentity == \(feedIdentity)")
        var newObject = TSMomentCollectTaskObject()
        newObject.feedIdentity = feedIdentity
        if !result.isEmpty {
            newObject = result.first!
        }
        
        do {
            try realm.safeWrite {
                newObject.taskState = 0
                newObject.collectState = newCollect
                realm.add(newObject, update: .all)
            }
        } catch let err { handleException(err) }
    }
    
    /// 写入comment disable任务
    ///
    /// - Parameters:
    ///   - newComment: 0 default/enable comment，1 disable comment
    ///   - feedIdentity: 动态唯一标识
    func saveComment(commentTask newComment: Int, feedIdentity: Int) {
        let result = realm.objects(TSMomentCommentTaskObject.self).filter("feedIdentity == \(feedIdentity)")
        var newObject = TSMomentCommentTaskObject()
        newObject.feedIdentity = feedIdentity
        if !result.isEmpty {
            newObject = result.first!
        }
        
        do {
            try realm.safeWrite {
                newObject.taskState = 0
                newObject.commentState = newComment
                realm.add(newObject, update: .all)
            }
        } catch let err { handleException(err) }
    }

    /// 设置收藏任务为进行状态
    func changeToStartState(collect: TSMomentCollectTaskObject) {
        do {
            try realm.safeWrite {
                collect.taskState = 0
            }
        } catch let err { handleException(err) }
    }
    
    /// 设置comment disable任务为进行状态
    func changeToStartCommentState(comment: TSMomentCommentTaskObject) {
        do {
            try realm.safeWrite {
                comment.taskState = 0
            }
        } catch let err { handleException(err) }
    }

    // MARK: 结束任务

    /// 结束收藏任务
    ///
    /// - Parameters:
    ///   - digg: 收藏任务
    ///   - success: 是否成功
    func end(collect task: TSMomentCollectTaskObject, success: Bool) {
        do {
            try realm.safeWrite {
                task.taskState = success ? 1 : 2
            }
        } catch let err { handleException(err) }
    }
    
    /// - Parameters:
    ///   - comment: comment disable任务
    ///   - success: 是否成功
    func endComment(comment task: TSMomentCommentTaskObject, success: Bool) {
        do {
            try realm.safeWrite {
                task.taskState = success ? 1 : 2
            }
        } catch let err { handleException(err) }
    }

    // MARK: - 关注

    // MARK: 获取任务
    /// 获取失败的关注任务
    func getFaildFollowList() -> [TSMomentFollowTaskObject] {
        let failFollow = realm.objects(TSMomentFollowTaskObject.self).filter("taskState == 2")
        return Array(failFollow)
    }

    /// 获取未完成的关注任务
    func getUnFinishedFollowList() -> [TSMomentFollowTaskObject] {
        let unFinishedFollow = realm.objects(TSMomentFollowTaskObject.self).filter("taskState != 1")
        return Array(unFinishedFollow)
    }

    /// 获取单个关注任务
    ///
    /// - Parameters:
    ///   - userId: 用户ID
    /// - Returns: 任务
    func getFollow(_ userId: Int) -> TSMomentFollowTaskObject? {
        let result = realm.objects(TSMomentFollowTaskObject.self).filter("userId == \(userId)")
        if result.isEmpty {
            return nil
        }
        return result.first!
    }

    // MARK: 写入任务

    /// 写入关注任务
    ///
    /// - Parameters:
    ///   - newFollow: 0 取消关注，1 关注
    ///   - userId: 用户ID
    func save(followTask newFollow: Int, userId: Int) {
        let result = realm.objects(TSMomentFollowTaskObject.self).filter("userId == \(userId)")
        var newObject = TSMomentFollowTaskObject()
        newObject.userId = userId
        if !result.isEmpty {
            newObject = result.first!
        }
        
        do {
            try realm.safeWrite {
                newObject.taskState = 0
                newObject.followState = newFollow
                realm.add(newObject, update: .all)
            }
        } catch let err { handleException(err) }
    }

    /// 设置关注任务为进行状态
    func changeToStartState(follow: TSMomentFollowTaskObject) {
        do {
            try realm.safeWrite {
                follow.taskState = 0
            }
        } catch let err { handleException(err) }
    }

    // MARK: 结束任务

    /// 结束关注任务
    ///
    /// - Parameters:
    ///   - follow: 关注任务
    ///   - success: 是否成功
    func end(follow task: TSMomentFollowTaskObject, success: Bool) {
        do {
            try realm.safeWrite {
                task.taskState = success ? 1 : 2
            }
        } catch let err { handleException(err) }
    }

    // MARK: - 删除任务
    func deleteAll() {
        deleteDiggTask()
        deletCollectionTask()
        deleteDeleteTask()
        deleteFollowTask()
    }

    /// 删除收藏任务
    func deletCollectionTask() {
        let tasks = realm.objects(TSMomentCollectTaskObject.self)
        do {
            try realm.safeWrite {
                realm.delete(tasks)
            }
        } catch let err { handleException(err) }
    }

    /// 删除赞任务
    func deleteDiggTask() {
        let tasks = realm.objects(TSMomentDiggTaskObject.self)
        do {
            try realm.safeWrite {
                realm.delete(tasks)
            }
        } catch let err { handleException(err) }
    }

    /// 删除删除任务
    func deleteDeleteTask() {
        let tasks = realm.objects(TSMomentDeleteTaskObject.self)
        do {
            try realm.safeWrite {
                realm.delete(tasks)
            }
        } catch let err { handleException(err) }
    }

    /// 删除关注任务
    func deleteFollowTask() {
        let tasks = realm.objects(TSMomentFollowTaskObject.self)
        do {
            try realm.safeWrite {
                realm.delete(tasks)
            }
        } catch let err { handleException(err) }
    }
}
