//
//  ServicesStoreManager.swift
//  Yippi
//
//  Created by Yong Tze Ling on 29/07/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation

class ServicesStoreManager {
    
//    private let box = try! StoreManager.shared.store.box(for: YippsWantedService.self)
//    
//    func fetch() -> [YippsWantedService] {
//        return try! box.all()
//    }
//    
//    func add(_ service: YippsWantedService) {
//        let all = fetch()
//        if let last = all.last, all.count == 10 && all.contains(where: { $0.id == service.id }) == false {
//            try? box.remove(last.id)
//        }
//        try? box.put(service)
//    }
//    
//    func clear() {
//        try? box.removeAll()
//    }
}

class HomedashBoardFeedStoreManager {
    
    private let box = try! StoreManager.shared.store.box(for: FeedStoreModel.self)
    
    func fetch() -> [FeedStoreModel]? {
        return try! box.all()
    }
    
    func add(_ service: FeedStoreModel) {
        clear()
        try? box.put(service)
    }
    
    func clear() {
        try? box.removeAll()
    }
}

