//
//  TimerHolder.swift
//  Yippi
//
//  Created by Khoo on 17/06/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

protocol TimerHolderDelegate {
    func onTimerFired(holder: TimerHolder)
}

class TimerHolder: NSObject {
    var delegate: TimerHolderDelegate?
    var timer : Timer?
    var repeats: Bool?
    
    func startTimer(seconds: TimeInterval, delegate: TimerHolderDelegate, repeats:Bool) {
        self.delegate = delegate
        self.repeats = repeats
        
        if self.timer != nil {
            timer?.invalidate()
            timer = nil
        }
        
        timer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(onTimer(timer:)), userInfo: nil, repeats: repeats)
    }
    
    func stopTimer () {
        timer?.invalidate()
        timer = nil
        delegate = nil
    }
    
    @objc func onTimer (timer: Timer) {
        if let repeats = repeats {
            if !repeats {
                self.timer = nil
            }
            if delegate != nil {
                delegate?.onTimerFired(holder: self)
            }
        }
    }
}
