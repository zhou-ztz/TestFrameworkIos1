//
//  TSDataBaseManager.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/14.
//  Copyright © 2017年 LeonFa. All rights reserved.
//
//  数据库管理类
import UIKit
/// 时间类型
@objc public enum DateType: Int {
    /// - simple: 个人主页
    /// - 1天内显示 今\n天，
    /// - 1天到2天显示 昨\n天，
    /// - 2天以上显示月日如 24\n12月、09\n2 月，当月份小于 10 时，数字和月份之间有个空格
    case simple = 0
    /// normal: 动态列表时间戳格式转换
    /// - 一分钟内显示一分钟
    /// - 一小时内显示几分钟前
    /// - 一天内显示几小时前
    /// - 1天到2天显示昨天
    /// - 2天到9天显示几天前
    /// - 9天以上显示月日如（05-21）
    case normal
    /// 动态详情
    /// - 一分钟内显示一分钟
    /// - 一小时内显示几分钟前，
    /// - 一天内显示几小时前，
    /// - 1天到2天显示如（昨天 20:36），
    /// - 2天到9天显示如（五天前 20：34），
    /// - 9天以上显示如（02-28 19:15）
    case detail
    /// 钱包明细列表
    /// - 今天显示 今天\n07.11
    /// - 昨天显示 昨天\n07.10
    /// - 其他显示 周几\n11.27
    case walletList
    /// 钱包详情
    /// - 2017-05-02 周几 14:37
    case walletDetail
    
    /// 时间详情
    /// 24 hour format
    case timeOnly
    
    /// Message Request time
    case messageRequestTime
    
    case tip
}

public class TSDate: NSObject {

    // MARK: - Lifecycle
    /// 日程表
    private let calendar = Calendar(identifier: .gregorian)
    /// 当前时间
    private var now: Date
    /// 当天零点
    private var today = Date()
    /// 昨天零点
    private var yesterday = Date()
    /// 9 天前
    private var nightday = Date()
    /// 一分钟前
    private var oneMinute = Date()
    /// 一小时前
    private var oneHour = Date()
    /// 一年前
    private var oneYear = Date()
    /// 格式转换器
    private let formatter = DateFormatter()

    /// 后台返回时间
    private var date = Date()

    // MARK: - Lifecycle
    public override convenience init() {
        self.init(now: Date())
    }

    /// 用于测试的初始化方法
    ///
    /// - Parameter now: 作为“现在”标准的时间
    public init(now: Date) {
        self.now = now
        today = calendar.startOfDay(for: now)
        yesterday = calendar.date(byAdding: Calendar.Component.hour, value: -1 * 24, to: today, wrappingComponents: false)!
        nightday = calendar.date(byAdding: Calendar.Component.hour, value: -9 * 24, to: today, wrappingComponents: false)!
        oneMinute = calendar.date(byAdding: Calendar.Component.minute, value: -1, to: now, wrappingComponents: false)!
        oneHour = calendar.date(byAdding: Calendar.Component.hour, value: -1, to: now, wrappingComponents: false)!
        oneYear = calendar.date(byAdding: Calendar.Component.year, value: -1, to: now, wrappingComponents: false)!
    }

    // MARK: - Public

    /// 转换成时间
    ///
    /// - Parameters:
    ///   - type: 转换类型
    ///   - timeStamp: 时间戳
    /// - Returns: 计算后的字符串
    @objc public func dateString(_ type: DateType, nsDate: NSDate) -> String {
        return dateString(type, nDate: convertToDate(nsDate))
    }

    @objc public func dateString(_ type: DateType, nDate: Date, dateFormat: String = "MM-dd") -> String {
        date = nDate
        var dateString = ""
        switch type {
        case .simple:
            dateString = simpleDate()
        case .normal:
            dateString = normalDate(dateFormat: dateFormat)
        case .detail:
            dateString = detailDate()
        case .walletList:
            dateString = walletListDate()
        case .walletDetail:
            dateString = walletDetailDate()
        case .timeOnly:
            dateString = timeOnly()
        case .messageRequestTime:
            dateString = messageRequestTime()
        case .tip:
            dateString = tipSimpleDate()
        }
        return dateString
    }
    /// 转换成时间
    ///
    /// - Parameters:
    ///   - type: 转换类型
    ///   - timeStamp: 时间戳
    /// - Returns: 计算后的字符串
    //    func dateString(_ type: DateType, time: NSDate) -> String {
    //        let timeStampInt = Int(time.timeIntervalSince1970)
    //        return dateString(type, timeStamp: timeStampInt)
    //    }

    // MARK: - Private

    /// simple 类型的时间
    /// - Note:
    /// 个人主页
    /// 1天内显示 今\n天，
    /// 1天到2天显示 昨\n天，
    /// 2天以上显示月日如 24\n12月、09\n2 月，当月份小于 10 时，数字和月份之间有个空格
    ///
    private func simpleDate() -> String {
        if isLate(than: today) {
            return "today".localized
        }
        if isLate(than: yesterday) && isEarly(than: today) {
            return "yesterday".localized
        }
        formatter.dateFormat = "MM"
        let month = Int(formatter.string(from: date))!
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        if month < 10 {
            return day + "\n\(month) 月"
        }
        return day + "\n\(month)月"
    }

    /// normal 类型的时间
    ///
    /// - Note:
    /// 动态列表时间戳格式转换
    /// 一分钟内显示一分钟内
    /// 一小时内显示几分钟前
    /// 一天内显示几小时前
    /// 1天到2天显示昨天
    /// 2天到9天显示几天前
    /// 9天以上显示月日如（05-21）
    private func normalDate(dateFormat: String = "MM-dd") -> String {
        let comphoent = calendar.dateComponents([.day, .hour, .minute], from: date, to: now)
        if isLate(than: oneMinute) {
            return "one_min".localized
        }
        if isLate(than: oneHour) && isEarly(than: oneMinute) {
            return "\((comphoent.minute)!)" + "minutes_ago".localized
        }
        if isLate(than: today) && isEarly(than: oneHour) {
            return "\((comphoent.hour)!)" + "hours_ago".localized
        }
        if isLate(than: yesterday) && isEarly(than: today) {
            return "yesterday".localized
        }
        if isLate(than: nightday) && isEarly(than: yesterday) {
            return "\(comphoent.day! + 1)" + "days_ago".localized
        }
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }

    /// detail 类型的时间
    ///
    /// - Note:
    /// 一分钟内显示一分钟内
    /// 一小时内显示几分钟前，
    /// 一天内显示几小时前，
    /// 1天到2天显示如（昨天 20:36），
    /// 2天到9天显示如（五天前 20：34），
    /// 9天以上显示如（02-28 19:15）
    private func detailDate() -> String {
        let comphoent = calendar.dateComponents([.day, .hour, .minute], from: date, to: now)
        if isLate(than: oneMinute) {
            return "one_min".localized
        }
        if isLate(than: oneHour) && isEarly(than: oneMinute) {
            return "\((comphoent.minute)!)" + "minutes_ago".localized
        }
        if isLate(than: today) && isEarly(than: oneHour) {
            return "\((comphoent.hour)!)" + "hours_ago".localized
        }
        if isLate(than: yesterday) && isEarly(than: today) {
            formatter.dateFormat = "HH:mm"
            return "yesterday".localized + " \(formatter.string(from: date))"
        }
        if isLate(than: nightday) && isEarly(than: yesterday) {
            formatter.dateFormat = "HH:mm"
            return "\(comphoent.day! + 1)" + "days_ago".localized + " \(formatter.string(from: date))"
        }
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: date)
    }

    /// walletList 类型时间
    ///
    /// - Note:
    /// 今天显示 今天\n07.11
    /// 昨天显示 昨天\n07.10
    /// 其他显示 周几\n11.27
    func walletListDate() -> String {
        formatter.dateFormat = "MM.dd"
        let day = formatter.string(from: date)

        if isLate(than: today) {
            return "today".localized + "\n" + day
        }
        if isLate(than: yesterday) && isEarly(than: today) {
            formatter.dateFormat = "HH:mm"
            return "yesterday".localized + "\n" + day
        }
        formatter.dateFormat = "e"
        let week = Int(formatter.string(from: date))!

        return "\(weakSting(week))\n" + day
    }
    
    /// 钱包详情
    ///
    /// - Note:
    /// - 2017-05-02 周几 14:37
    func walletDetailDate() -> String {
        formatter.dateFormat = "yyyy-MM-dd"
        let year = formatter.string(from: date)
        formatter.dateFormat = "HH:mm"
        let time = formatter.string(from: date)
        
        formatter.dateFormat = "e"
        let week = Int(formatter.string(from: date))!
        return year + " \(weakSting(week)) " + time
    }
    
    /// 时间详情
    ///
    /// - Note:
    /// - 02:37 PM
    private func timeOnly() -> String {
        formatter.dateFormat = "HH:mm"
        let time = formatter.string(from: date)
        return time
    }
    
    /// Message Request time
    ///
    /// - Note:
    /// - 02:37 PM
    private func messageRequestTime() -> String {
        if isLate(than: today) {
            return "chatroom_text_today".localized
        }
        if isLate(than: yesterday) && isEarly(than: today) {
            return "yesterday".localized
        }
        if isLate(than: oneYear) && isEarly(than: yesterday) {
            formatter.dateFormat = "LLL"
            let month = formatter.string(from: date)
            formatter.dateFormat = "d"
            let day = formatter.string(from: date)

            return String(format: "chatroom_same_year_format".localized, month, day.toInt())
        }
        formatter.dateFormat = "y"
        let year = formatter.string(from: date)
        formatter.dateFormat = "LLL"
        let month = formatter.string(from: date)
        formatter.dateFormat = "d"
        let day = formatter.string(from: date)

        return String(format: "chatroom_different_year_format".localized, year.toInt(), month, day.toInt())
    }
    
    private func tipSimpleDate() -> String {
        if isLate(than: today) {
            return "today".localized
        }
        if isLate(than: yesterday) && isEarly(than: today) {
            return "yesterday".localized
        }
        formatter.dateFormat = "MMM"
        let month = formatter.string(from: date)
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        return "\(day) \(month)"
    }

    // MARK: - Tool

    /// 将 Int 转换成周几
    func weakSting(_ week: Int) -> String {
        switch week {
        case 2:
            return "mon".localized
        case 3:
            return "tues".localized
        case 4:
            return "wed".localized
        case 5:
            return "thurs".localized
        case 6:
            return "fri".localized
        case 7:
            return "sat".localized
        case 1:
            return "sun".localized
        default:
            return ""
        }
    }

    /// 是否早于某个时间
    private func isEarly(than compareDate: Date) -> Bool {
        return date < compareDate
    }

    /// 是否晚于某个时间
    private func isLate(than compareDate: Date) -> Bool {
        return date >= compareDate
    }

    /// 将 NSDate 转换成 Date
    private func convertToDate(_ nsDate: NSDate) -> Date {
        return Date(timeIntervalSince1970: nsDate.timeIntervalSince1970)
    }

}


extension Date {
    func toSimplifiedFormat() -> String {
        let components = Calendar.init(identifier: Calendar.Identifier.gregorian).dateComponents(in: .current, from: self)
        return String(format: "date_format_simplified".localized, components.year.orZero.stringValue, components.month.orZero.stringValue, components.day.orZero.stringValue)
    }
    
    func toHourFormat() {
        
    }
    
//    func isBetween(_ date1: Date, and date2: Date) -> Bool {
//        return (min(date1, date2) ... max(date1, date2)).contains(self)
//    }
}
