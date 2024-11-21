//
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

public extension Double {
    var toFloat: Float {
        return Float(self)
    }
    
    func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = style
        guard let formattedString = formatter.string(from: self) else { return "" }
        return formattedString
    }
}

public enum CountType {
    case auto
    case short
    case full
}

public extension TimeInterval {
    func toCountDown(_ handleType: CountType) -> String {
        var result =  ""
        
        let formatShort = { () -> String in
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            return formatter.string(from: self) ?? "00:00"
        }
        
        let formatLong = { () -> String in
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            return formatter.string(from: self) ?? "00:00"
        }
        
        let formatFull = { () -> String in
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            return formatter.string(from: self) ?? "00:00:00"
        }
        
        switch handleType {
        case .auto:
            if self > 0 {
                switch self {
                case ..<(60*60): result = formatShort()
                default:  result = formatLong()
                }
                return result
                
            } else {
                return "00:00"
            }
            
        case .full: return formatFull()
        case .short: return formatShort()
        }
        
        
    }
}
