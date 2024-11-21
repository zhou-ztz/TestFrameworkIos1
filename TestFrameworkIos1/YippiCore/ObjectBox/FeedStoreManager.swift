//
//  FeedStoreManager.swift
//  RewardsLink
//
//  Created by Kit Foong on 27/05/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import ObjectBox

class FeedsStoreManager {
    private let box = try! StoreManager.shared.store.box(for: FeedListModel.self)
    
    func fetch(by type: FeedListType) -> [FeedListModel]? {
        return try? box.query { FeedListModel.feedType.isEqual(to: type.boxFilterType)}.build().find()
    }
    
    func fetchById(id: Int) -> TSRepostModel? {
        do {
            if let result = try box.query({
                FeedListModel.id.isEqual(to: id)
            }).build().findFirst() {
                return TSRepostModel(feed: result)
            } else {
                return TSRepostModel(type: .delete)
            }
        } catch let err {
            return nil
        }
    }
    
    func delete(by type: FeedListType) {
        try? box.query { FeedListModel.feedType.isEqual(to: type.boxFilterType)}.build().remove()
    }
    
    func save(_ models: [FeedListModel], for type: FeedListType) {
        models.forEach { model in
            model.feedType = type.boxFilterType
        }
        try? box.put(models)
    }
    
    func add(list: [FeedListModel]) {
        try? box.put(list)
    }
    
    func reset(_ models: [FeedListModel], for type: FeedListType) {
        self.delete(by: type)
        self.save(models, for: type)
    }
}
