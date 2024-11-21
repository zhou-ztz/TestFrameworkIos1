//
//  MiniProgramShareModel.swift
//  Yippi
//
//  Created by ChuenWai on 26/11/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

class MiniProgramShareModel: Mappable {
    var title: String?
    var desc: String?
    var thumbnail: String?
    var appId: String?
    var path: String?

    init?( ) { }

    required init?(map: Map) { }

    func mapping(map: Map) {
        title <- map["params.title"]
        desc <- map["params.desc"]
        thumbnail <- map["params.imageUrl"]
        appId <- map["appId"]
        path <- map["params.path"]

        if title == nil {
            title <- map["appTitle"]
        }
        if desc == nil {
            desc <- map["appDescription"]
        }
        if thumbnail == nil {
            thumbnail <- map["appAvatar"]
        }
        if appId == nil {
            appId <- map["appId"]
        }

    }
}
