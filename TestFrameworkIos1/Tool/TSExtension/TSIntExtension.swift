//
//  TSIntExtension.swift
//  ThinkSNS +
//
//  Created by lip on 2017/5/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

extension Int {
    /// 判断一个整数是否为 0 (为空)
    public var isEqualZero: Bool {
        return self == 0
    }

    /// 将时间戳转换成 date
    func convertToDate() -> NSDate {
        return NSDate(timeIntervalSince1970: TimeInterval(self))
    }
}

extension Double {

    /// 将 Double 转换成 String 类型
    ///
    /// - Parameter decimal: 小数位数
    func tostring(decimal: Int = 2, grouping: Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = grouping
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = decimal
        formatter.minimumFractionDigits = decimal

        return formatter.string(from: NSNumber(value: self)) ?? String(format: "%.\(decimal)f", self)
    }
    
    ///
    ///
    func formatDistance() -> String {
        if self >= 1000 {
            let distanceInKilometers = self / 1000
            return String(format: "%.2f km", distanceInKilometers)
        } else {
            return String(format: "%.0f m", self)
        }
    }
}
