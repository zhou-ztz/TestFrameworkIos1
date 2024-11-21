//
//  VideoPlayerUtil.swift
//  Yippi
//
//  Created by CC Teoh on 18/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class VideoPlayerUtil: NSObject {
    
    func timeformat(fromSeconds seconds: Int) -> String? {
        var seconds = seconds
        //format of hour
        seconds = seconds / 1000
        let str_hour = String(format: "%02ld", seconds / 3600)
        //format of minute
        let str_minute = String(format: "%02ld", (seconds % 3600) / 60)
        //format of second
        let str_second = String(format: "%02ld", seconds % 60)
        //format of time
        var format_time: String? = nil
        if seconds / 3600 <= 0 {
            format_time = "00:\(str_minute):\(str_second)"
        } else {
            format_time = "\(str_hour):\(str_minute):\(str_second)"
        }
        return format_time
    }
    
    class func isInterfaceOrientationPortrait() -> Bool {
        let o = UIApplication.shared.statusBarOrientation
        return o == .portrait
    }
}

