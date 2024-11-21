//
//  Debouncer.swift
//  Yippi
//
//  Created by francis on 25/06/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation

public class Debouncer: NSObject {
    var handler: (() -> ())?
    private(set) var delay: Double
    private(set) weak var timer: Timer?
    
    public init(delay: Double) {
        self.delay = delay
    }
    
    public func execute() {
        timer?.invalidate()
        let nextTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(Debouncer.fireNow), userInfo: nil, repeats: false)
        timer = nextTimer
    }
    
    @objc private func fireNow() {
        self.handler?()
    }
}
