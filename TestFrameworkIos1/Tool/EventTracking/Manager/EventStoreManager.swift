//
//  EventStoreManager.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2024/1/29.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit
import ObjectBox

/// 埋点事件的数据存储支持
class EventStoreManager: NSObject {
    
    private let box = try! StoreManager.shared.store.box(for: EventEntity.self)
    
    func fetch() -> [EventEntity] {
        do {
            return try box.all()
        } catch {
            print("fetching events error: \(error)")
            EventTrackingManager.instance.postEvents()
            return []
        }
    }
    
    func add(_ event: EventEntity) {
        do {
            try box.put(event)
        } catch {
            EventTrackingManager.instance.postEvents()
            print("add event error: \(error)")
        }
    }
    
    func clear() {
        do {
            try box.removeAll()
        } catch {
            EventTrackingManager.instance.postEvents()
            print("clear events error: \(error)")
        }
    }
    
}
