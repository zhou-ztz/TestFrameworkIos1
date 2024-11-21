//
//  HashTagStoreManager.swift
//  RewardsLink
//
//  Created by Kit Foong on 27/05/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import ObjectBox

class HashTagStoreManager {
    private let box = try! StoreManager.shared.store.box(for: HashtagModel.self)
    
    func fetch() -> [HashtagModel] {
        return try! box.all() ?? []
    }
    
    func add(list: [HashtagModel]) {
        try? box.put(list)
    }
    
    func removeAll() {
        try? box.removeAll()
    }
}
