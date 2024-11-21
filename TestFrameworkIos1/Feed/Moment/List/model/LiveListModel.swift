//
//  LiveListModel.swift
//  Yippi
//
//  Created by Jerry Ng on 26/03/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper


class LiveListModel: LiveEntityModel {
    var coverImage:LiveListCoverImageModel?
    var viewCount:Int = 0
   // var liveEvent: LiveEventInfo?
    var language: String = ""
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        coverImage <- map["coverImage"]
        viewCount <- map["viewCount"]
    //    liveEvent <- map["liveEvent"]
        language <- map["language"]
    }
}

class LiveListCoverImageModel: Mappable {
    var url:String?
    var mine:String?
    var dimension:DimensionModel?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        url <- map["url"]
        mine <- map["mime"]
        dimension <- map["dimension"]
    }
}

class DimensionModel: Mappable {
    var width:CGFloat = 0
    var height:CGFloat = 0
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        width <- map["width"]
        height <- map["height"]
    }
}
