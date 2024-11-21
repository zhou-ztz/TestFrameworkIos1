//
//  FeedReactionsModel.swift
//  Yippi
//
//  Created by Francis Yeap on 11/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

class FeedReactionsModel : NSObject, Mappable {
    
    class Stat : NSObject, Mappable {

        var count : Int = 0
        var reaction : String = ""

        required init?(map: Map){}
        private override init(){}

        func mapping(map: Map) {
            count <- map["count"]
            reaction <- map["reaction"]
            
        }
    }


    class Data : NSObject, Mappable {

        var id: Int = 0
        var reaction : String = ""
        var userAvatar : String? = ""
        var userBio : String? = ""
        var userId : Int = 0
        var userName : String = ""
        var verifiedIcon: String? = ""
        var subscribing: Bool = false
        var subscribingBadge: String?
        
        required init?(map: Map){}
        private override init(){}

        func mapping(map: Map) {
            id <- map["id"]
            reaction <- map["reaction"]
            userAvatar <- map["user_avatar"]
            userBio <- map["user_bio"]
            userId <- map["user_id"]
            userName <- map["user_name"]
            verifiedIcon <- map["verified_icon"]
            subscribing <- map["subscribing"]
            subscribingBadge <- map["subscribing_badge"]
        }
    }


    var data : [Data]?
    var stats : [Stat]?

    required init?(map: Map){}
    func mapping(map: Map) {
        data <- map["data"]
        stats <- map["stats"]
        
    }
}

