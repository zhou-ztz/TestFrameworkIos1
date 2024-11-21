//
//    SocialTokenSlots.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

import RealmSwift

enum ScheduleListState {
    case event(applied: Bool)
//    case full(seats: Int, maximum: Int, cost: Int)
    case applying(seats: Int, maximum: Int, cost: Int)
    case ready(seats: Int, maximum: Int, cost: Int)
    case comingSoon(seats: Int, maximum: Int, cost: Int, isEvent: Bool)
    case history(seats: Int, maximum: Int, cost: Int, isEvent: Bool)
}

struct SocialTokenSlotsRequestType: RequestType {
    typealias ResponseType = SocialTokenSlotsModel
    
    let limit: Int
    let offset: Int?
    let onlyAvailable: Bool
    let startTime: Double
    let endTime: Double
    
    var data: YPRequestData {
        let url: String
        
        let urlComponents = URLComponents(string: "/api/v2/event-slot/getSlots")
        
        if offset == nil {
            url = "/api/v2/event-slot/getSlots?limit=\(limit)&only_available=\(onlyAvailable)&start_datetime=\(startTime)&end_datetime=\(endTime)"
        } else {
            url = "/api/v2/event-slot/getSlots?limit=\(limit)&offset=\(offset!)&only_available=\(onlyAvailable)&start_datetime=\(startTime)&end_datetime=\(endTime)"
        }
        
        return YPRequestData(
            path: url,
            method: .get, params: nil)
    }
}

struct SocialTokenSlotsModel: Codable {
    
    private static let formatCalender = Calendar.init(identifier: Calendar.Identifier.gregorian)

    struct Data: Codable {

        var applied : Bool
        var available : Int
        let country : String?
        var currentCount : Int
        var id : Int
        let maxCount : Int
        let slotEnd : Date
        let slotStart : Date
        let price: Int
        let slotType: String
        let slotTitle: String
        
        var locallyApplied = false
        
        var eventDate: String {
            let components = Calendar.init(identifier: Calendar.Identifier.gregorian).dateComponents(in: .current, from: slotStart)
            return String(format: "date_format_simplified".localized, components.year.orZero.stringValue, components.month.orZero.stringValue, components.day.orZero.stringValue)
        }
        
        var slotTimeRange: String {
            let start = slotStart.string(format: "HH:mm", timeZone: TimeZone.current)
            let end = slotEnd.string(format: "HH:mm", timeZone: TimeZone.current)
            
            return "\(start) - \(end)"
        }
        
        var state: ScheduleListState {
            switch slotType.uppercased() {
            case "EVENT":
                return ScheduleListState.event(applied: applied)
                
            default:
                if applied == true {
                    return ScheduleListState.applying(seats: currentCount, maximum: maxCount, cost: price)
                } else if locallyApplied == true {
                    return ScheduleListState.applying(seats: currentCount + 1, maximum: maxCount, cost: price)
                } else if available == 0 {
                    return ScheduleListState.ready(seats: currentCount, maximum: maxCount, cost: price)
                }
            }
            return ScheduleListState.ready(seats: currentCount, maximum: maxCount, cost: price)
        }
        
        enum CodingKeys: String, CodingKey {
            case applied = "applied"
            case available = "available"
            case country = "country"
            case currentCount = "current_count"
            case id = "id"
            case maxCount = "max_count"
            case slotEnd = "slot_end"
            case slotStart = "slot_start"
            case price = "price"
            case slotType = "slot_type"
            case slotTitle = "slot_title"
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
