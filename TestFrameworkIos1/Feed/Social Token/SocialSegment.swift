//
//  SocialHistory.swift
//  Yippi
//
//  Created by Francis Yeap on 19/02/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//


import Foundation

struct SocialSegmentRequestType: RequestType {
    typealias ResponseType = SocialSegmentModel
    
    var history: Bool = false
    var limit: Int = 0
    var offset: Int?
    var userId: Int?
    
    var data: YPRequestData {
        var userId = self.userId
        if userId == nil {
            userId = (CurrentUserSessionInfo?.userIdentity).orZero
        } else {
            userId = self.userId!
        }
        let url: String
        if offset == nil {
            url = "/api/v2/token/livePinnedHistory/\(userId!)?history=\(history)&limit=\(limit)"
        } else {
            url = "/api/v2/token/livePinnedHistory/\(userId!)?history=\(history)&limit=\(limit)&offset=\(offset!)"
        }
        
        
        return YPRequestData(
            path: url,
            method: .get, params: nil)
    }
}



struct SocialSegmentModel : Codable {
    struct Data : Codable {
        let available : Int
        let country : String
        let currentCount : Int
        let id : Int
        let maxCount : Int
        let slotEnd : Date
        let slotStart : Date
        let price: Int
        let slotType: String
        let slotTitle: String
        
        var isEvent: Bool {
            switch slotType.lowercased() {
            case "event" : return true
            default: return false
            }
        }
        
        var slotTimeRange: String {
            let start = slotStart.string(format: "HH:mm", timeZone: TimeZone.current)
            let end = slotEnd.string(format: "HH:mm", timeZone: TimeZone.current)
            
            return "\(start) - \(end)"
        }        
        
        var eventDate: String {
            let components = Calendar.init(identifier: Calendar.Identifier.gregorian).dateComponents(in: .current, from: slotStart)
            return String(format: "date_format_simplified".localized, components.year.orZero.stringValue, components.month.orZero.stringValue, components.day.orZero.stringValue)
        }
        

        enum CodingKeys: String, CodingKey {
            case available = "available"
            case country = "country"
            case currentCount = "current_count"
            case id = "id"
            case maxCount = "max_count"
            case slotEnd = "slot_end"
            case slotStart = "slot_start"
            case price =  "price"
            case slotType = "slot_type"
            case slotTitle = "slot_title"
        }
        
        static func toSocialTokenSlotsModelDataType(from model: SocialSegmentModel.Data) -> SocialTokenSlotsModel.Data {
            let result = SocialTokenSlotsModel.Data(applied: true,
                                                    available: model.available,
                                                    country: model.country,
                                                    currentCount: model.currentCount,
                                                    id: model.id,
                                                    maxCount: model.maxCount,
                                                    slotEnd: model.slotEnd,
                                                    slotStart: model.slotStart,
                                                    price: 0,
                                                    slotType: "",
                                                    slotTitle: "")
            return result
        }
    }
    
    let data : [Data]?

    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([Data].self, forKey: .data)
    }
    
}
