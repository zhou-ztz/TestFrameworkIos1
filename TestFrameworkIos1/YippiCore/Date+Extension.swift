// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

private let calendar1 = Calendar(identifier: .gregorian)

public extension Date {
    
    func compareDates(_ components: Calendar.Component..., as date: Date, using calendar: Calendar = .current) -> Bool {
             return components.filter { calendar.component($0, from: date) != calendar.component($0, from: self) }.isEmpty
    }
    
    func toFormat(_ format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        df.timeZone = TimeZone(identifier: "UTC")
        return df.string(from: self)
    }

    
    static func endOfDay(for date: Date) -> Date {
        let startOfDay = calendar1.startOfDay(for: date)
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return calendar1.date(byAdding: components, to: startOfDay)!
    }
    
    var epochTime: Double {
        return self.timeIntervalSince1970 
    }
    
    var day: Int {
        return calendar.component(.day, from: self)
    }
    
    var month: Int {
        return calendar.component(.month, from: self)
    }
    
    var year: Int {
        return calendar.component(.year, from: self)
    }
    
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
    /// 获取yyyyMMdd格式时间
    var classicTimeFormat : String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
//        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        return formattedDate
    }
    
    var utcTimeStamp: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let utcDateString = dateFormatter.string(from: self)
        guard let utcDate = dateFormatter.date(from: utcDateString) else {
            return ""
        }
        let timeInterval = utcDate.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
}

