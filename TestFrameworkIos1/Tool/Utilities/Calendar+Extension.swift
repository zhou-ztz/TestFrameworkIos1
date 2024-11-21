//
//  Calendar+Extension.swift
//  Yippi
//
//  Created by Francis on 01/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

private let gregorianCalendar = Calendar(identifier: .gregorian)

public extension Calendar {
    
    static func startDayOfMonth(in month: Int, year: Int) -> Int {
        let dateComponents = DateComponents(calendar: gregorianCalendar,
                                            year: year,
                                            month: month,
                                            day: 1)
        var adjustedWeekday = gregorianCalendar.component(.weekday, from: dateComponents.date!)
        
        if adjustedWeekday == 0 {
            return 7
        }
        
        return adjustedWeekday - 1
    }

    static func numberOfDays(in month: Int, year: Int) -> Int {
        let dateComponents = DateComponents(calendar: gregorianCalendar,
                                            year: year,
                                            month: month)
        
        guard let date = dateComponents.date else { return 0 }
        
        return gregorianCalendar.component(.day,
                                  from: gregorianCalendar.date(byAdding: DateComponents(month: 1, day: -1),
                                                               to: date)!)
    }
    
}

private let dateFormatter = DateFormatter()

extension Date {
    func timeAgoDisplay(dateFormat: String = "MM-dd") -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo < minute {
            return "\(secondsAgo) \("secondsago".localized)"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute) \("minutes_ago".localized)"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour) \("hours_ago".localized)"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) \("days_ago".localized)"
        }
        
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
}
