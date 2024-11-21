//
//  TSCollectionViewCell.swift
//  RewardsLink
//
//  Created by Kit Foong on 11/07/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import UIKit


typealias DataCollectionDict = (timer: Timer, indexPath: IndexPath, itemId: Int, startTime: Int)

class TSCollectionViewCell: UICollectionViewCell, BaseCellProtocol {
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

protocol BaseCellProtocol {
    static var cellIdentifier: String { get }
    static func nib() -> UINib
}

extension BaseCellProtocol {
    static var cellIdentifier: String {
        return String(describing: Self.self)
    }
    
    static func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
}
