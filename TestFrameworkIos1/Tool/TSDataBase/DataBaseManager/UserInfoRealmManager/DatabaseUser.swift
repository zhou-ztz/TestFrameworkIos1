//
//  TSDatabaseUser.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  数据库 - 用户相关
//  提供各种获取用户信息的相关的方法

import UIKit
import RealmSwift

class DatabaseUser {
    fileprivate let realm: Realm = FeedIMSDKManager.shared.param.realm!

    init() { }
}
//
//// MARK: - 当前用户信息
//extension DatabaseUser {
//
//    // MARK: 用户信息
//
//    /// 从数据库中获取当前用户的信息
//    func getCurrentUser() -> UserSessionInfo? {
//        let user = ((Defaults[.currentUser]?.uid)?.toInt()).orInvalidateInt
//
//        if let object = realm.objects(UserInfoModel.self).filter("userIdentity = \(user)").first {
//            return UserSessionInfo(object: object)
//        }
//        return nil
//    }
//
//    /// 保存当前用户信息
//    func saveCurrentUser(_ userModel: UserSessionInfo?) {
//        guard let userModel = userModel else { return }
//        do {
//            try saveCurrentUser(userModel.object())
//        } catch let err {
//            LogManager.Log("Failed to save - not current user: \(err)", loggingType: .exception)
//        }
//    }
//    /// 重载保存当前用户信息
//    func saveCurrentUser(_ userObject: UserInfoModel) throws {
//        guard userObject.userIdentity == Int((Defaults[.currentUser]?.uid).orEmpty) else {
//            throw DatabaseExceptionType.notCurrentUser
//        }
//        // 当前用户信息是唯一的，即使primarykey不一样
//        let savedUsers = realm.objects(UserInfoModel.self)
//
//        do {
//            try realm.safeWrite {
//                realm.delete(savedUsers)
//                realm.add(userObject, update: .all)
//            }
//        } catch {
//            assert(false, "Couldn't save current user, reason: \(error.localizedDescription)")
//        }
//    }
//    /// 删除当前用户信息
//    func deleteCurrentUser() -> Void {
//        let user = (Defaults[.currentUser]?.uid.toInt()).orInvalidateInt
//        do {
//            try realm.safeWrite {
//                let objects = realm.objects(UserInfoModel.self).filter("userIdentity = \(user)")
//                realm.delete(objects)
//            }
//        } catch let error {
//            LogManager.Log("Couldn't delete current user, reason: \(error.localizedDescription)", loggingType: .exception)
//        }
//
//    }
//
//    /// 修改当前用户信息
//    func updateCurrentUser() -> Void {
//        guard let model = CurrentUserSessionInfo else {
//            return
//        }
//        do {
//            try realm.safeWrite {
//                realm.add(model.object(), update: .all)
//            }
//        } catch let error {
//            LogManager.Log("failed to update current user, reason: \(error.localizedDescription)", loggingType: .exception)
//        }
//    }
//
//    // MARK: 用户认证
//
//    /// 删除用户认证信息
//    func deleteCurrentUserCertificate() {
//        let objects = realm.objects(TSUserCertificateObject.self)
//        do {
//            try realm.safeWrite {
//                realm.delete(objects)
//            }
//        } catch let error {
//            LogManager.Log("failed to delete user ceritificate, reason: \(error.localizedDescription)", loggingType: .exception)
//        }
//    }
//
//    /// 保存用户认证信息
//    func saveCurrentUser(certificate: EntityCertification) {
//        do {
//            try realm.safeWrite { realm.add(certificate, update: .all) }
//        } catch let error {
//            LogManager.Log("failed to save current user, reason: \(error.localizedDescription)", loggingType: .exception)
//        }
//    }
//    /// 获取用户认证信息
//    func getCurrentUserCertificate() -> EntityCertification? {
//        guard let currentUserId = getCurrentUser()?.userIdentity else { return nil }
//        return realm.objects(EntityCertification.self).filter("userId = \(currentUserId)").first
//    }
//    /// 监听用户认证信息
//    func notificationForUserCertificate(block: @escaping (RealmCollectionChange<Results<TSUserCertificateObject>>) -> Void) -> NotificationToken {
//        let userCertificate = realm.objects(TSUserCertificateObject.self)
//        return userCertificate.observe(block)
//    }
//}

// MARK: - 点赞榜
extension DatabaseUser {
    /// 获取用户中心点赞榜的列表
    func getDiggRank(userId: Int) -> TSUserDiggsrankListObject? {
        let diggRankList = realm.objects(TSUserDiggsrankListObject.self).filter("userId == \(userId)")
        if diggRankList.isEmpty {
            return nil
        }
        return Array(diggRankList).first
    }

    func delete(diggrankUserId: Int) {
        do {
            try realm.safeWrite {
                let relation = realm.objects(TSUserDiggsrankListObject.self).filter("userId == \(diggrankUserId)")
                realm.delete(relation)
            }
        } catch let error {
            assert(false, "failed to delete user digg rank, reason: \(error.localizedDescription)")
        }
    }

    /// 储存点赞榜列表
    func save(diggRank: TSUserDiggsrankListObject) {
        do {
            try realm.safeWrite {
                realm.add(diggRank, update: .all)
            }
        } catch let error {
            assert(false, "failed to save user digg rank, reason: \(error.localizedDescription)")
        }
    }

    /// 检测点赞
    ///
    /// - Parameters:
    ///   - userIdentity: 用户 userIdentity
    ///   - completed: 结果
    /// - Returns: 通知口令，要接收通知请保持对口令的强引用
    func setDiggrankNotification(userId: Int, completed: @escaping (_ changes: RealmCollectionChange<Results<TSUserDiggsrankListObject>>) -> Void) -> NotificationToken {
        let results = realm.objects(TSUserDiggsrankListObject.self).filter("userId == \(userId)")
        let token = results.observe { (changes) in
            completed(changes)
        }
        return token
    }
}
