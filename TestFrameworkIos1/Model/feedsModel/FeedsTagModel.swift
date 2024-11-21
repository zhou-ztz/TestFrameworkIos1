//
//  FeedsTagModel.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2022/8/17.
//  Copyright © 2022 Toga Capital. All rights reserved.
//

import UIKit
import ObjectMapper

class FeedsTagModel: Mappable {
    var tagId: Int = 0
    var tagName: String = ""
    var tagCategoryId: Int = 0
    var tagWeight: Int = 0
    var tagKey: String = ""
    
    required init?(map: Map) {}

    func mapping(map: Map) {
        tagId <- map["id"]
        tagName <- map["name"]
        tagCategoryId <- map["tag_category_id"]
        tagWeight <- map["weight"]
        tagKey <- map["key"]
    }
    
    
}
