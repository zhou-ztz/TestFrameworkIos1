//
//  TSUserVerifiedModel.swift
//  Yippi
//
//  Created by Francis on 23/03/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

/// 用户验证数据模型
//sourcery: RealmEntityConvertible
class TSUserVerifiedModel: Mappable {
    /// Verified type.
    var type: String = ""
    /// Verified icon.
    var icon: String = ""
    /// 认证描述
    var description: String = ""

    init?(type: String?, icon: String?) {
        guard let type = type else {
            return nil
        }
        self.type = type
        self.icon = icon ?? ""
    }

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        type <- map["type"]
        icon <- map["icon"]
        description <- map["description"]
    }

    /// 从数据库模型转换
    init?(object: EntityUserVerified?) {
        guard let object = object else { return nil }
        self.type = object.type
        self.icon = object.icon
        self.description = object.desc
    }
    /// 转换为数据库对象
    func object() -> EntityUserVerified {
        let object = EntityUserVerified()
        object.type = self.type
        object.icon = self.icon
        object.desc = self.description
        return object
    }
}
