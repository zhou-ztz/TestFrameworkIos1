//
//  TSNetFileModel.swift
//  Yippi
//
//  Created by Francis on 23/03/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

/// 网络文件数据模型
// sourcery: RealmEntityConvertible
class TSNetFileModel: Mappable {
     /// 厂商名称
     var vendor: String = "local"
     /// 文件请求地址，GET 方式
     var url: String = ""
     /// 文件 MIME
     var mime: String = ""
     /// 文件尺寸
     var size: Int = 0
     /// 文件宽
     var width: Int = 0
     /// 文件高
     var height: Int = 0

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        vendor <- map["vendor"]
        url <- map["url"]
        mime <- map["mime"]
        size <- map["size"]
        width <- map["dimension.width"]
        height <- map["dimension.height"]
    }

    /// 从数据库模型转换
    init(object: EntityNetFile) {
        self.vendor = object.vendor
        self.url = object.url
        self.mime = object.mime
        self.size = object.size
        self.width = object.width
        self.height = object.height
    }
    /// 转换为数据库对象
    func object() -> EntityNetFile {
        let object = EntityNetFile()
        object.vendor = self.vendor
        object.url = self.url
        object.mime = self.mime
        object.size = self.size
        object.width = self.width
        object.height = self.height
        return object
    }
}
