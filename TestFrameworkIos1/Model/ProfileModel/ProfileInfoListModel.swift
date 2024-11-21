//
//  ProfileInfoListModel.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2022/8/12.
//  Copyright © 2022 Toga Capital. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper

class ProfileInfoListModel: Mappable {
    var infoId: Int = 0
    var infoName: String = ""
    var infoKey: String = ""
    var child: Bool = false
    
    required init?(map: Map) {}

    func mapping(map: Map) {
        infoId <- map["id"]
        infoName <- map["name"]
        infoKey <- map["key"]
        child <- map["child"]
    }
    
}
