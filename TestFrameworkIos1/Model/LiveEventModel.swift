//
//  LiveEventModel.swift
//  Yippi
//
//  Created by Francis Yeap on 16/06/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

class LiveEventModel: Mappable {
    var rankingList: [StarSlotModel]?
    var imgUrl : String?
    var link : String?
    var slotStartTime: Date?
    var slotEndTime: Date?
    var slotUnrank: SlotRankModel?
    var broadcastSubscription: Bool = false
    var periodStartTime: Date?
    var periodEndTime: Date?
    
    var slotTimeRange: String {
        let start = (slotStartTime ?? Date()).string(format: "HH:mm", timeZone: TimeZone.current)
        let end = (slotEndTime ?? Date()).string(format: "HH:mm", timeZone: TimeZone.current)
        
        var eventDate = (slotStartTime ?? Date()).string(format: "MMM dd", timeZone: TimeZone.current)
        if Calendar.current.compare((slotStartTime ?? Date()), to: (slotEndTime ?? Date()), toGranularity: .day) != .orderedSame {
            let endDate = (slotEndTime ?? Date()).string(format: "MMM dd", timeZone: TimeZone.current)
            eventDate.append(" - \(endDate)")
        }
        
        return "\(eventDate), \(start) - \(end)"
    }
    
    var slotStartDate: String {
        return (slotStartTime ?? Date()).string(format: "MMM dd, HH:mm", timeZone: TimeZone.current)
    }
    
    var slotStartDayAndMonth: String {
        return (slotStartTime ?? Date()).string(format: "MMM dd", timeZone: TimeZone.current)
    }

    var currentDate: Date {
        let userCalendar = Calendar.current
        let date = Date()
        let components = userCalendar.dateComponents([.hour, .minute, .month, .year, .day, .second], from: date)
        let currentDate = userCalendar.date(from: components)!
        return currentDate
    }
    
    var isSameDate: Bool {
        let today = Date()
        return today.compareDates(.year, .day, .month, as: (slotStartTime ?? Date()))
    }

    var slotEndDate: Date {
        let userCalendar = Calendar.current
        var endDateComponents = userCalendar.dateComponents([.hour, .minute, .month, .year, .day, .second], from: (slotEndTime ?? Date()))
        endDateComponents.timeZone = TimeZone.current
        let endDate = userCalendar.date(from: endDateComponents)!
        return endDate
    }

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        rankingList <- map["ranking_list"]
        imgUrl <- map["banner.img_url"]
        link <- map["banner.link"]
        slotStartTime <- (map["slot_info.slot_start"], DateTransformer)
        slotEndTime <- (map["slot_info.slot_end"], DateTransformer)
        slotUnrank <- map["user_rank"]
        broadcastSubscription <- map["broadcast_subscription"]
        periodStartTime <- (map["period_range.start"], DateTransformer)
        periodEndTime <- (map["period_range.end"], DateTransformer)
    }
    
    var streamerSlot: String {
        if let startTime = slotStartTime, let endTime = slotEndTime {
            let startDate = startTime.string(format: "MMM dd", timeZone: TimeZone.current)
            let start = startTime.string(format: "HH:mm", timeZone: TimeZone.current)
            let end = endTime.string(format: "HH:mm", timeZone: TimeZone.current)
            return "\(startDate), \(start) - \(end)"
        }
        return "-"
    }
}
