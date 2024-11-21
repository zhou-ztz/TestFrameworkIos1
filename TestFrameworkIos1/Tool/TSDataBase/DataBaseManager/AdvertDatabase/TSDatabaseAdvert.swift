//
//  TSDatabaseAdvert.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import RealmSwift

class TSDatabaseAdvert {
    
    fileprivate let realm: Realm = FeedIMSDKManager.shared.param.realm!
    /// 可以替换掉内部数据的初始化方法,用于测试
    ///
    /// - Parameter realm: 数据库
    init() { }

    // MARK: - 删除
    func deleteAll() {
        let spaceObjects = realm.objects(TSAdSpaceObject.self)
        let advertObjects = realm.objects(TSAdvertObject.self)
        let analogFeedObject = realm.objects(TSFeedAnalogObject.self)
        let analogNewsObject = realm.objects(TSNewsAnalogObject.self)
        
        do {
            try realm.safeWrite {
                realm.delete(spaceObjects)
                realm.delete(advertObjects)
                realm.delete(analogFeedObject)
                realm.delete(analogNewsObject)
            }
        } catch {
            assert(false, "failed to delete all database advert, reason: \(error.localizedDescription)")
        }
    }

    // MARK: - 写入
    
    /// 写入广告数据
    ///
    /// - Parameters:
    ///   - objects: 新数据
    ///   - update: 是否清空旧数据
    func save(objects: [TSAdvertObject], update: Bool) {
        do {
            try realm.safeWrite {
                if update {
                    let oldObjects = realm.objects(TSAdvertObject.self)
                    let analogFeedObject = realm.objects(TSFeedAnalogObject.self)
                    let analogNewsObject = realm.objects(TSNewsAnalogObject.self)
                    realm.delete(oldObjects)
                    realm.delete(analogFeedObject)
                    realm.delete(analogNewsObject)
                }
                realm.add(objects, update: .all)
            }
        } catch {
            assert(false, "failed to save advert object, reason: \(error.localizedDescription)")
        }
    }
    
    /// 写入广告位数据
    ///
    /// - Parameters:
    ///   - objects: 新数据
    ///   - update: 是否清空旧数据
    func save(spaceObjects objects: [TSAdSpaceObject], update: Bool) {
        do {
            try realm.safeWrite {
                if update {
                    let oldObjects = realm.objects(TSAdSpaceObject.self)
                    realm.delete(oldObjects)
                }
                realm.add(objects, update: .all)
            }
        } catch {
            assert(false, "failed to save space object, reason: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 获取
    
    /// 通过类型查询 id 
//    func getSpaceId(with type: AdvertSpaceType) -> Int? {
//        let result = realm.objects(TSAdSpaceObject.self).filter("space = '\(type.rawValue)'")
//        return result.first?.id
//    }

    /// 通过广告位 id 获取数据
//    func getObjects(spaceId: Int) -> [TSAdvertObject] {
//        let result = realm.objects(TSAdvertObject.self).filter("spaceId == \(spaceId)").sorted(byKeyPath: "order", ascending: true)
//        return Array(result)
//    }

//    /// 通过类型查询广告数据
//    func getObjects(type: AdvertSpaceType) -> [TSAdvertObject] {
//        guard let spaceId = getSpaceId(with: type) else {
//            return []
//        }
//        let advertObjects = getObjects(spaceId: spaceId)
//        return advertObjects
//    }
}
