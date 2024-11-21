//
//  UserWalletIntegrationModel.swift
//  Yippi
//
//  Created by Francis Yeap on 14/06/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper


struct UserWalletIntegrationModel: Mappable {

    var ownerId = 0
    var type = 0
    var sum: String = ""
    var create = Date()
    var update = Date()

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        ownerId <- map["owner_id"]
        type <- map["type"]
        sum <- map["sum"]
        create <- (map["created_at"], DateTransformer)
        update <- (map["updated_at"], DateTransformer)
    }
}
