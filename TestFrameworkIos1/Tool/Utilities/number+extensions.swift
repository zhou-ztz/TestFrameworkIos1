//
//  number+extensions.swift
//  Yippi
//
//  Created by Francis Yeap on 5/14/19.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation

extension Int {
    var stringValue: String { return String(self)}
    var uint64: UInt64 { return UInt64(self) }
    var boolValue: Bool { return self > 0 }
    var abbreviated: String { return Double(self).abbreviated }
    var abbStartFrom5Digit: String { return Double(self).abbStartFrom5Digit }
    var byteSize: String { return ByteCountFormatter().string(fromByteCount: Int64(self)) }
}

extension UInt64 {
    var intValue: Int { return Int(self) }
}

extension Float {
    var cleanValue: String {
        return self.remainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension Double {
    var stringValue: String { return String(self) }
    var cleanValue: String {
        return self.remainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
    
    var abbreviated: String {
        let numFormatter = NumberFormatter()
        numFormatter.roundingMode = .floor
        numFormatter.locale = Locale(identifier: "en")
        numFormatter.usesGroupingSeparator = true
        numFormatter.groupingSeparator = ","

        typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
        let abbreviations:[Abbrevation] = [(0, 1, ""),
                                           (1000.0, 1000.0, "K"),
                                           (1_000_000.0, 1_000_000.0, "M"),
                                           (100_000_000.0, 100_000_000.0, "B")]
                                           // you can add more !
        let startValue = Double (abs(self))
        let abbreviation:Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if (startValue < tmpAbbreviation.threshold) {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        } ()

        let value = self / abbreviation.divisor
        numFormatter.positiveSuffix = abbreviation.suffix
        numFormatter.negativeSuffix = abbreviation.suffix
        numFormatter.allowsFloats = true
        numFormatter.minimumIntegerDigits = 1
        numFormatter.minimumFractionDigits = 0
        numFormatter.maximumFractionDigits = 1

        return numFormatter.string(from: NSNumber (value:value))!
    }

    var yippsAbbreviate: String {
        let numFormatter = NumberFormatter()
        numFormatter.roundingMode = .floor

        typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
        let abbreviations:[Abbrevation] = [(0, 1, ""),
                                           (1000.0, 1000.0, "K"),
                                           (1_000_000.0, 1_000_000.0, "M"),
                                           (100_000_000.0, 100_000_000.0, "B")]
        // you can add more !
        let startValue = Double (abs(self))
        let abbreviation:Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if (startValue < tmpAbbreviation.threshold) {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        } ()

        let value = self / abbreviation.divisor
        let remainder = self.remainder(dividingBy: abbreviation.divisor)
        numFormatter.positiveSuffix = abbreviation.suffix
        numFormatter.negativeSuffix = abbreviation.suffix
        numFormatter.minimumIntegerDigits = 1
        if remainder != 0 {
            numFormatter.allowsFloats = true
            numFormatter.minimumFractionDigits = 2
            numFormatter.maximumFractionDigits = 2
        } else {
            numFormatter.allowsFloats = false
            numFormatter.minimumFractionDigits = 0
            numFormatter.maximumFractionDigits = 0
        }

        return numFormatter.string(from: NSNumber (value:value))!
    }

    /// For Star of the day score results
    var abbStartFrom5Digit: String {
        guard self >= 10000 else {
            return self.tostring(decimal: 0)
        }
        
        return self.abbreviated
    }
    
    func toCurrencyString(currencyIndicator: String) -> String? {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencySymbol = currencyIndicator
        currencyFormatter.currencyCode = currencyIndicator
        currencyFormatter.negativeFormat = "-¤#,##0.00"
        return currencyFormatter.string(from: NSNumber(value: self))
    }
}
 
