//
//  TSAccountDataBase.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/7/27.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSAccountDataBase {
    fileprivate let realm: Realm = FeedIMSDKManager.shared.param.realm!

    /// 可以替换掉内部数据的初始化方 法,用于测试
    ///
    /// - Parameter realm: 数据库
    init() { }
}

extension TSAccountDataBase {

    func saveName(_ name: TSAccountNameObject) -> Void {
        do {
            try realm.safeWrite {
                realm.add(name, update: .all)
            }
            let objects = realm.objects(TSAccountNameObject.self)
            if objects.count > 20 {
                try realm.safeWrite {
                    realm.delete(objects.first!)
                }
            }
        } catch let err { handleException(err) }
    }
    
}
