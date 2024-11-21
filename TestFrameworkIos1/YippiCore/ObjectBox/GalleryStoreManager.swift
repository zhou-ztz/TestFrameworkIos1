//
//  GalleryStoreManager.swift
//  Yippi
//
//  Created by CC Teoh on 29/07/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import ObjectBox

class GalleryStoreManager {
    
    private let galleryBox = try! StoreManager.shared.store.box(for: TrendingPhotoModel.self)
    
    func get(for type: TrendingPhotoType) -> [TrendingPhotoModel] {
        return try! galleryBox.query { TrendingPhotoModel.type.isEqual(to: type.toString()) }.ordered(by: TrendingPhotoModel.feedId, flags: .descending).build().find()
    }
    
    func deleteAll() {
        try? galleryBox.removeAll()
    }
    
    func save(gallery objects: [TrendingPhotoModel], for type: TrendingPhotoType) {
        objects.forEach { object in
            object.type = type
        }
        try? galleryBox.put(objects)
    }
    
    func reset(objects: [TrendingPhotoModel], for type: TrendingPhotoType) {
        try? galleryBox.query { TrendingPhotoModel.type.isEqual(to: type.toString() )}.build().remove()
        save(gallery: objects, for: type)
    }
}
