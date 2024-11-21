//
//  DatabaseTask.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  后台任务管理类

import UIKit
import RealmSwift

class DatabaseTask {
    private let realm: Realm! = FeedIMSDKManager.shared.param.realm!
    /// 可以替换掉内部数据的初始化方法,用于测试
    ///
    /// - Parameter realm: 数据库
    init() { }

    // MARK: - 获取

    /// 获取失败的任务
    func getFaildTask(idPrefix: String) -> [TaskObject] {
        let faild = realm.objects(TaskObject.self).filter("taskStatus == 2 AND id BEGINSWITH '\(idPrefix)'")
        return Array(faild)
    }

    /// 获取未完成的任务
    func getUnfinishedTask(idPrefix: String) -> [TaskObject] {
        let unFinished = realm.objects(TaskObject.self).filter("taskStatus != 1 AND id BEGINSWITH '\(idPrefix)'")
        return Array(unFinished)
    }

    /// 获取任务
    func getTask(id: String) -> TaskObject? {
        let tasks = realm.objects(TaskObject.self).filter("id = '\(id)'")
        return tasks.first
    }

    // MARK: - 写入

    /// 添加一个任务
    ///
    /// - Note: 如果任务已经存在，则只会更新 operation
    ///
    /// - Parameters:
    ///   - id: 任务唯一标识
    ///   - operation: 任务将要执行的操作，一般用于任务具有两种状态时。例如 1/0 ：收藏/取消收藏，点赞/取消点赞
    /// - Returns: 任务
    func addTask(id: String, operation: Int?) -> TaskObject? {
        // 1.检出有误旧任务已经存在，有旧任务存在，仅更新旧任务状态
        do {
            if let oldTask = realm.objects(TaskObject.self).filter("id = '\(id)'").first, let operation = operation {
                try realm.safeWrite {
                    oldTask.operation.value = operation
                    realm.add(oldTask, update: .all)
                }
            }
            // 2.如果没有旧任务，就创建一个新的任务
            let task = TaskObject()
            task.id = id
            task.operation.value = operation
            
            try realm.safeWrite {
                realm.add(task, update: .all)
            }

            return task
        } catch let err {
            handleException(err)
            return nil
        }
        
    }

    /// 结束任务
    func end(task: TaskObject, isSuccess: Bool) {
        do {
        try realm.safeWrite {
            task.taskStatus = isSuccess ? 1 : 2
        }
        } catch let err { handleException(err) }
    }

    /// 启动任务
    func start(task: TaskObject) {
        do {
            try realm.safeWrite {
                task.taskStatus = 0
            }
        } catch let err { handleException(err) }
    }

}
