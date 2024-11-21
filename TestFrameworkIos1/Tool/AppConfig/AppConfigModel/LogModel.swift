//
//  LogModel.swift
//  Yippi
//
//  Created by Kit Foong on 24/10/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

class LogRequestCheckModel: Codable, Mappable {
    var requestId: Int = 0
    var startDate: String = ""
    var endDate: String = ""
    var type: String = ""

    init () {}

    required init?(map: Map){}

    func mapping(map: Map) {
        requestId <- map["data.request_id"]
        startDate <- map["data.start_date"]
        endDate <- map["data.end_date"]
        type <- map["data.type"]
    }

    enum CodingKeys: String, CodingKey {
        case requestId
        case startDate
        case endDate
        case type
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        requestId = try values.decode(Int.self, forKey: .requestId)
        startDate = try values.decode(String.self, forKey: .startDate)
        endDate = try values.decode(String.self, forKey: .endDate)
        type = try values.decode(String.self, forKey: .type)
    }
}
