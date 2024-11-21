//
//  RewardModel.swift
//  Yippi
//
//  Created by Yong Tze Ling on 21/10/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import ObjectMapper

public struct RewardModel: Mappable {
    var id: Int = -1
    var imageUrl: String = ""
    var amount: String = ""
    var sort: Int = 0
    
    public init?(map: Map) {
    }
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        imageUrl <- map["image_url"]
        amount <- map["amount"]
        sort <- map["sort"]
    }
}
