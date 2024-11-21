//
//  LiveStarSlotModel.swift
//  Yippi
//
//  Created by Francis Yeap on 16/06/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftUI

class LiveStarSlotModel: Mappable {
    
    var broadcastSubscription: Bool = false
    var slotList: [StarSlotModel]?
    var slotStartTime: Date = Date()
    var slotEndTime: Date = Date()
    var slotUnrank: SlotRankModel?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        slotList <- map["slot_views_list"]
        slotStartTime <- (map["slot_info.slot_start"], DateTransformer)
        slotEndTime <- (map["slot_info.slot_end"], DateTransformer)
        slotUnrank <- map["user_rank"]
        broadcastSubscription <- map["broadcast_subscription"]
    }
    
    var slotTimeRange: String {
        let start = slotStartTime.string(format: "HH:mm", timeZone: TimeZone.current)
        let end = slotEndTime.string(format: "HH:mm", timeZone: TimeZone.current)
        
        var eventDate = slotStartTime.string(format: "MMM dd", timeZone: TimeZone.current)
        if Calendar.current.compare(slotStartTime, to: slotEndTime, toGranularity: .day) != .orderedSame {
            let endDate = slotEndTime.string(format: "MMM dd", timeZone: TimeZone.current)
            eventDate.append(" - \(endDate)")
        }
        
        return "\(eventDate), \(start) - \(end)"
    }
    
    var slotStartDate: String {
        return slotStartTime.string(format: "MMM dd, HH:mm", timeZone: TimeZone.current)
    }
    
    var slotStartDayAndMonth: String {
        return slotStartTime.string(format: "MMM dd", timeZone: TimeZone.current)
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
        return today.compareDates(.year, .day, .month, as: slotStartTime)
    }

    var slotEndDate: Date {
        let userCalendar = Calendar.current
        var endDateComponents = userCalendar.dateComponents([.hour, .minute, .month, .year, .day, .second], from: slotEndTime)
        endDateComponents.timeZone = TimeZone.current
        let endDate = userCalendar.date(from: endDateComponents)!
        return endDate
    }
}


class SlotRankModel: Mappable, Equatable, ObservableObject {
    var views: Int = 0
    var tips: Double = 0.0
    var score: Double = 0.0
    var level: Int = 0
    var previousLevel: Int = 0
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        views <- map["views"]
        tips <- map["tips"]
        score <- map["score"]
        level <- map["level"]
        previousLevel <- map["previous_level"]
    }
}


func == (lhs: SlotRankModel, rhs: SlotRankModel) -> Bool {
     return (
        lhs.views == rhs.views &&
        lhs.tips == rhs.tips &&
        lhs.score == rhs.score &&
        lhs.level == rhs.level
    )
}

