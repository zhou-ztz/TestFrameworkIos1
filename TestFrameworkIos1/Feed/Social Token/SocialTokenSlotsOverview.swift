//
//  SocialTokenSlotsOverview.swift
//  Yippi
//
//  Created by Francis on 07/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import RealmSwift


struct SocialTokenSlotsOverviewRequestType: RequestType {
    typealias ResponseType = SocialTokenSlotsOverviewModel
    
    var data: YPRequestData {
        let url = "/api/v2/event-slot/overviews"
        return YPRequestData(path: url, method: .get, params: nil)
    }
}


struct SocialTokenSlotsOverviewModel: Codable {
    struct Data: Codable {
        var date : Date
        var isBooked : Int

        enum CodingKeys: String, CodingKey  {
            case date = "date"
            case isBooked =  "is_booked"
        }
    }

    var data : [Data]?
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}
