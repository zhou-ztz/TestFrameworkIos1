//
//  SocialTokenDataHandler.swift
//  Yippi
//
//  Created by Francis on 10/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation


enum SocialTokenType: Int {
    case master = 1
    case hot = 2
    case pinpost = 3
    case notrecorded = -1
    
    func initialize(with tokenType: Int) -> SocialTokenType {
        switch tokenType {
        case 1, 2, 3:
            return SocialTokenType(rawValue: tokenType)!
            
        default:
            return .notrecorded
        }
    }
}

class SocialTokenDataSourceHandler {
    
    var datasource: [SocialTokenSlotsModel.Data] = []
    
    var adjustedDataSource: [SocialTokenSlotsModel.Data] = []
    
   // let cacheManager: CacheManager = CacheManager()

    var appliedData: [Int: Bool] = [:] // [slot_id : Bool]
    
    init() {
      //  cacheManager.wipe()
    }
    
    func refreshData() {
        /*
         assumptions :
             - applied slots cannot be undone
            - every slots can be applied no more than once
         */
        saveAppliedData()
        refreshDatasourceWithLocalCache()
    }
    
    private func saveAppliedData() {
        for item in datasource {
            if item.applied == false { continue }
            appliedData[item.id] = true
        }
    }
    
    private func refreshDatasourceWithLocalCache()  {
        for (index, item) in datasource.enumerated() {
            if item.applied  == false, appliedData[item.id] == true {
                datasource[index].locallyApplied = true
            }
        }
    }
    
    func setAppliedFor(slotId: Int) {
        appliedData[slotId] = true
    }
    
}
