//
//  TSUIView.swift
//  RewardsLink
//
//  Created by Kit Foong on 11/07/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import UIKit


class TSUIView: UIView {
    var eventStartTime : Int = 0
    var stayTimer : Timer?
    
    func viewStayEvent() {

    }
    
    func stopStayEvent(itemId: String = "") {

    }
    
    func getCurrentTime() -> Int {
        return Date().timeStamp.toInt()
    }
    
    func className(_ obj: AnyObject) -> String {
        return String(describing: type(of: obj))
    }
}

