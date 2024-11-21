//
//  TSFeedAnalogObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态模拟数据

import RealmSwift

class TSFeedAnalogObject: Object {

    /// 动态模拟数据 头像
    @objc dynamic var avatar: String = ""
    /// 动态模拟数据 用户名
    @objc dynamic var name: String = ""
    /// 动态模拟数据 内容
    @objc dynamic var content: String = ""
    /// 动态模拟数据 图片
    @objc dynamic var image: String = ""
    /// 动态模拟数据 时间
    @objc dynamic var time: NSDate = NSDate()
    /// 动态模拟数据 链接
    @objc dynamic var link: String = ""
    @objc dynamic var width: Int = 260
    @objc dynamic var height: Int = 130
}
