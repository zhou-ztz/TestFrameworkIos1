//
//  TimeInterval+Extension.swift
//  feedIMSDKDemo
//
//  Created by dong on 2024/10/17.
//

import Foundation

extension TimeInterval {
    
    func stringFromTimeInterval() -> String {
        let time = NSInteger(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)

    }
    
    func toFormat(units: NSCalendar.Unit = [.minute, .second]) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = units
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self)
    }
}
