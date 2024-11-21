//
//  TSImageObject.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  图片数据表模型

import UIKit
import RealmSwift

class TSImageObject: Object {
    // 缓存标示
    @objc dynamic var cacheKey: String = ""
    var locCacheKey: String = ""
    @objc dynamic var storageIdentity: Int = 0
    @objc dynamic var netImageUrl: String = ""
    @objc dynamic var width: Double = 0
    @objc dynamic var height: Double = 0
    @objc dynamic var mimeType: String = ""

     // MARK: - V2 数据

    /// 是否在加载时清除缓存
    @objc dynamic var shouldCleanCache = false

    /// 收费方式
    @objc dynamic var type: String?

    /// 当前用户是否已经付费
    let paid = RealmOptional<Bool>()
    /// 付费节点
    let node = RealmOptional<Int>()
    /// 付费金额
    let amount = RealmOptional<Int>()
    // 发布时，图片的付费方式 0 表示发布时不付费，2 表示查看收费， 1 表示下载收费
    @objc dynamic var payType = -1
    // 发布时，图片的付费价格
    @objc dynamic var price = 0
    /// 厂商名称
    @objc dynamic var vendor: String = "local"

    /// 设置主键
    override static func primaryKey() -> String? {
        return "storageIdentity"
    }


    /// 判断图片是否为长图
    func isLongPic() -> Bool {
        let screenRatio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
        let picRatio = height / width
        return picRatio / Double(screenRatio) > 3
    }
}

extension TSImageObject {
    func set(shouldChangeCache shouldChange: Bool) {
        do {
            let realm = FeedIMSDKManager.shared.param.realm!
            try realm.safeWrite {
                self.shouldCleanCache = shouldChange
                realm.add(self, update: .all)
            }
        
        } catch let err { handleException(err) }
    }
}
