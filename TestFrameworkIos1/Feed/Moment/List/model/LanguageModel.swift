//
//  LanguageModel.swift
//  Yippi
//
//  Created by ChuenWai on 03/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class LanguageModel: Mappable {
    var languages: [LanguageEntity] = []

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        languages <- map["languages"]
    }
}

