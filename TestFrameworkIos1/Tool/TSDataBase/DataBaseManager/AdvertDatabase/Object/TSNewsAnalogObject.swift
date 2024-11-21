//
//  TSNewsAnalogObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  咨询模拟数据

import RealmSwift

class TSNewsAnalogObject: Object {

    /// 资讯模拟数据 标题
    @objc dynamic var title: String?
    /// 资讯模拟数据 图片
    @objc dynamic var image: String?
    /// 资讯模拟数据 来源
    @objc dynamic var from: String?
    /// 资讯模拟数据 时间
    @objc dynamic var time: NSDate?
    /// 资讯模拟数据 链接
    @objc dynamic var link: String?

}
