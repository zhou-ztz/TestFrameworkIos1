//
//  TSWebEditorRealmManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 05/02/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  web编辑器的数据库管理，主要用来管理编辑器中的缓存图片节点

import Foundation
import RealmSwift

class TSWebEditorRealmManager {
    fileprivate let realm: Realm = FeedIMSDKManager.shared.param.realm!

    // MARK: - Lifecycle
    init() { }

    /// 删除整个表
    func deleteAll() {
        self.deleteAllEditorCacheImage()
    }
}

// MARK: - 图片缓存节点信息管理

extension TSWebEditorRealmManager {

    // MARK: - 估测的功能分析

    /// 获取指定的图片缓存节点
    /// 获取指定列表的图片缓存节点列表

    /// 增加图片缓存节点

    /// 修改图片缓存节点
    /// 图片缓存节点的引用修改
    /// 图片缓存节点的批量处理

    /// 删除指定的图片缓存节点
    /// 删除指定的图片缓存节点列表
    /// 删除所有的图片缓存节点

    // MARK: - 暂时先完成部分需要的功能接口

    /// 判断指定的图片节点是否存在
    func isExistEditorCacheImage(md5: String) -> Bool {
        let objects = realm.objects(TSEditorCacheImageNodeObject.self).filter("md5 == '\(md5)'")
        return !objects.isEmpty
    }
    func isExistEditorCacheImage(fileId: Int) -> Bool {
        let objects = realm.objects(TSEditorCacheImageNodeObject.self)
        var existFlag: Bool = false
        for object in objects {
            for currentFileId in object.fileIdList {
                if currentFileId == fileId {
                    existFlag = true
                    return existFlag
                }
            }
        }
        return existFlag
    }

    /// 获取指定的图片缓存节点
    func getEditorCacheImage(name: String) -> TSEditorCacheImageNode? {
        let object = realm.object(ofType: TSEditorCacheImageNodeObject.self, forPrimaryKey: name)
        if let object = object {
            return TSEditorCacheImageNode(object: object)
        } else {
            return nil
        }
    }
    func getEditorCacheImage(md5: String) -> TSEditorCacheImageNode? {
        let objects = realm.objects(TSEditorCacheImageNodeObject.self).filter("md5 == '\(md5)'")
        if let object = objects.first {
            return TSEditorCacheImageNode(object: object)
        } else {
            return nil
        }
    }
    func getEditorCacheImage(fileId: Int) -> TSEditorCacheImageNode? {
        let objects = realm.objects(TSEditorCacheImageNodeObject.self)
        for object in objects {
            for currentFileId in object.fileIdList {
                if currentFileId == fileId {
                    return TSEditorCacheImageNode(object: object)
                }
            }
        }
        return nil
    }

    /// 增加图片缓存节点
    func addEditorCacheImage(_ model: TSEditorCacheImageNode) -> Void {
        do {
            try realm.safeWrite {
                realm.add(model.object(), update: .all)
            }
        } catch let err { handleException(err) }
    }
    /// 修正图片缓存节点(引用计数、文件id、)
    func updateEditorCacheImage(_ model: TSEditorCacheImageNode) -> Void {
        do {
            realm.add(model.object(), update: .all)
        } catch let err { handleException(err) }
    }

    /// 删除指定的图片缓存节点
    func deleteEditorCacheImage(imageNode: TSEditorCacheImageNode) -> Void {
        self.deleteEditorCacheImage(name: imageNode.name)
    }
    func deleteEditorCacheImage(name: String) -> Void {
        do {
            if let object = realm.object(ofType: TSEditorCacheImageNodeObject.self, forPrimaryKey: name) {
                try realm.safeWrite {
                    realm.delete(object)
                }
            }
        } catch let err { handleException(err) }
    }
    func deleteEditorCacheImage(md5: String) -> Void {
        do {
            let objects = realm.objects(TSEditorCacheImageNodeObject.self).filter("md5 == '\(md5)'")
            if !objects.isEmpty {
                try realm.safeWrite {
                    realm.delete(objects)
                }
            }
        } catch let err { handleException(err) }
    }
    func deleteEditorCacheImage(fileId: Int) -> Void {
        do {
            let objects = realm.objects(TSEditorCacheImageNodeObject.self)
            for object in objects {
                for currentFileId in object.fileIdList {
                    if currentFileId == fileId {
                        try realm.safeWrite {
                            realm.delete(object)
                        }
                        return
                    }
                }
            }
        } catch let err { handleException(err) }
    }
    /// 删除所有的图片缓存节点
    func deleteAllEditorCacheImage() -> Void {
        do {
            let objects = realm.objects(TSEditorCacheImageNodeObject.self)
            try realm.safeWrite {
                realm.delete(objects)
            }
        } catch let err { handleException(err) }
    }

}
