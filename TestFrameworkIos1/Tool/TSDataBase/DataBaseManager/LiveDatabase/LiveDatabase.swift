//
//  LiveDatabase.swift
//  Yippi
//
//  Created by Francis Yeap on 06/03/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import RealmSwift

//class LiveDatabase {
//    
//    fileprivate let realm: Realm = FeedIMSDKManager.shared.param.realm!
//    
//    init() { }
//    
//    func deleteAll() {
//        let liveObjs = realm.objects(LiveObject.self)
//        do {
//            try realm.safeWrite {
//                realm.delete(liveObjs)
//            }
//        } catch {
//            assert(false, "Couldn't not delete from database, reason: \(error.localizedDescription)")
//        }
//    }
//    
//    func save(objects: [LiveObject], shouldDeleteAll:Bool = true) {
//        if shouldDeleteAll {
//            deleteAll()
//        }
//        
//        do {
//            try realm.safeWrite {
//                realm.add(objects, update: .all)
//            }
//        } catch {
//            assert(false, "Failed to save live objects, reason: \(error.localizedDescription)")
//        }
//    }
//    
//    func fetchLiveObject(with feedId: Int) -> LiveObject? {
//        let result = realm.objects(LiveObject.self).filter("feedId = '\(feedId)'").first
//        return result
//    }
//    
//}
