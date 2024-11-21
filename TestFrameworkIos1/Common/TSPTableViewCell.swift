//
//  TSTableViewCell.swift
//  RewardsLink
//
//  Created by Kit Foong on 16/07/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class TSPTableViewCell: UITableViewCell, BaseCellProtocol {
    var indexPath: IndexPath?
    static var timerDictionary: [IndexPath: DataCollectionDict] = [:]
    
    func getCurrentTime() -> Int {
        return Date().timeStamp.toInt()
    }
    
    func viewStayEvent(indexPath: IndexPath, itemId: Int) {

    }
    
    func stopStayEvent(indexPath: IndexPath) {
        
    }
}
