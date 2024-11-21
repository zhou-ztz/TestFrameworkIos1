//
//  CountriesStoreManager.swift
//  RewardsLink
//
//  Created by Kit Foong on 27/05/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import ObjectBox
import ObjectMapper

class CountryEntity: Entity, Mappable {
    var id: Id = 0
    var code: String = ""
    var name: String = ""
    
    required init() { }
    
    required init?(map: Map) { }

    func mapping(map: Map) {
        code <- map["code"]
        name <- map["title"]
    }

    convenience init(code: String, name: String) {
        self.init()
        self.code = code
        self.name = name
    }
}

class CountriesStoreManager {
    private let box = try! StoreManager.shared.store.box(for: CountryEntity.self)
    
    func fetch() -> [CountryEntity] {
        return try! box.all() ?? []
    }
    
    func add(list: [CountryEntity]) {
        try? box.put(list)
    }
    
    func removeAll() {
        try? box.removeAll()
    }
}
