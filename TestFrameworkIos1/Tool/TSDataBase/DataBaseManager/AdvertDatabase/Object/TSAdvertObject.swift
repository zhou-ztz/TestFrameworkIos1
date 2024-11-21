//
//  TSAdvertLaunchObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  广告 数据模型

import RealmSwift

class TSAdvertObject: Object {
    /// 广告数据类型
    public enum DataType: String {
        /// 图片数据
        case image
        /// 动态模拟数据
        case feedAnalog = "feed:analog"
        /// 资讯模拟数据
        case newsAnalog = "news:analog"
    }

    /// 唯一标识
    @objc dynamic var id = -1
    /// 排序
    @objc dynamic var order = -1
    /// 广告位 id
    @objc dynamic var spaceId = -1
    /// 广告数据类型，当前支持的数据类型参见 TSAdvertObject.DataType
    @objc dynamic var type: String = ""
    /// 标题
    @objc dynamic var title = ""
    /// 图片展示时间，默认给5s
    @objc dynamic var imageDuration: Int = 5

    // MARK: - 基础数据类型

    /// 图片数据
    @objc dynamic var normalImage: TSAdvertImageObject?

    // MARK: - Analog 模拟数据

    // 动态模拟数据
    @objc dynamic var analogFeed: TSFeedAnalogObject?

    // 咨询模拟数据
    @objc dynamic var analogNews: TSNewsAnalogObject?

    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }

    /// 从服务器提供的图片链接中提取图片的唯一标识
    class func getAnalogImageIdentity(imageURLString: String?) -> Int? {
        if let imgID = imageURLString?.components(separatedBy: "/").last {
            return Int(imgID)
        }
        return nil
    }
 
}
