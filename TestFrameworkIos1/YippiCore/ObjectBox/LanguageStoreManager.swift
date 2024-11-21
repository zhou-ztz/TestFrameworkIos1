//
//  LanguageStoreManager.swift
//  RewardsLink
//
//  Created by Kit Foong on 27/05/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import ObjectBox
import ObjectMapper

class LanguageEntity: Entity, Mappable, Hashable {
    
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(code)
        hasher.combine(name)
    }
    
    static func == (lhs: LanguageEntity, rhs: LanguageEntity) -> Bool {
        return lhs.code == rhs.code && lhs.name == rhs.name && lhs.id == rhs.id
    }
}

class LanguageStoreManager {
    private let box = try! StoreManager.shared.store.box(for: LanguageEntity.self)
    
    func fetch() -> [LanguageEntity] {
        return try! box.all() ?? []
    }
    
    func add(list: [LanguageEntity]) {
        try? box.put(list)
    }
    
    func removeAll() {
        try? box.removeAll()
    }
}

