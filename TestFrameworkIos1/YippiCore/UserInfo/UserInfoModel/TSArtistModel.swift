//
//  TSNetFileModel.swift
//  Yippi
//
//  Created by Francis on 23/03/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

//sourcery: RealmEntityConvertible
class TSArtistModel: Mappable {
    var artist_id: Int = 0
    var artist_name: String = ""
    var description: String = ""
    var icon: String = ""
    var banner: String = ""
    var uid: Int = 0
    var created_at: String = ""
    var updated_at: String = ""
    var hide_view_moment: Bool = false

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        artist_id <- map["artist_id"]
        artist_name <- map["artist_name"]
        description <- map["description"]
        icon <- map["icon"]
        banner <- map["banner"]
        uid <- map["uid"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        hide_view_moment <- map["hide_view_moment"]
    }
}
