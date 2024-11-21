//
//  UserStoreManager.swift
//  RewardsLink
//
//  Created by Kit Foong on 27/05/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import ObjectBox

class UserSessionStoreManager {
    private let box = try! StoreManager.shared.store.box(for: UserSessionInfo.self)
    
    func fetch() -> [UserSessionInfo] {
        return try! box.all() ?? []
    }
    
    func add(list: [UserSessionInfo]) {
        try? box.put(list)
    }
    
    func removeAll() {
        try? box.removeAll()
    }
}

class UserInfoStoreManager {
    private let box = try! StoreManager.shared.store.box(for: UserInfoModel.self)
    
    func fetch() -> [UserInfoModel] {
        return try! box.all() ?? []
    }
    
    func fetchById(id: Int) -> UserInfoModel? {
        do {
            let result = try box.query({
                UserInfoModel.userIdentity.isEqual(to: id)
            }).build().findFirst()
            return result
        } catch let err {
            return nil
        }
    }
    
    func fetchByUsername(username: String) -> UserInfoModel? {
        do {
            let result = try box.query({
                UserInfoModel.username.isEqual(to: username)
            }).build().findFirst()
            return result
        } catch let err {
            return nil
        }
    }
    
    func fetchByNickname(nickname: String) -> UserInfoModel? {
        do {
            let result = try box.query({
                UserInfoModel.displayName.isEqual(to: nickname)
            }).build().findFirst()
            return result
        } catch let err {
            return nil
        }
    }
    
    func add(list: [UserInfoModel]) {
        try? box.put(list)
    }
    
    func removeAll() {
        try? box.removeAll()
    }
}

