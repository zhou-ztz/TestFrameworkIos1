//
//  FeedTagListModel.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2022/8/17.
//  Copyright © 2022 Toga Capital. All rights reserved.
//

import UIKit
import ObjectMapper
class FeedTagListModel: Mappable {

    var Id: Int = 0
    var name: String = ""
    var weight: Int = 0
    var key: String = ""
    var tags: [FeedsTagModel]?
    
    required init?(map: Map) {}

    func mapping(map: Map) {
        Id <- map["id"]
        name <- map["name"]
        weight <- map["weight"]
        key <- map["key"]
        tags <- map["tags"]
    }
}
