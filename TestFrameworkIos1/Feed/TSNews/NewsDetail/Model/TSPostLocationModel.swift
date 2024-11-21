//
//  TSLocationModel.swift
//  Yippi
//
//  Created by Khoo on 05/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

class TSPostLocationModel: Mappable {
    
    var locationID:String = ""
    var locationName: String = ""
    var locationLatitude:Float = 0
    var locationLongtitude:Float = 0
    var address:String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        locationID <- map["lid"]
        locationName <- map["name"]
        locationLatitude <- map["lat"]
        locationLongtitude <- map["lng"]
        address <- map["address"]
    }

//    init(object: TSPostLocationObject) {
//        self.locationID = object.locationID
//        self.locationName = object.locationName
//        self.locationLatitude = object.locationLatitude
//        self.locationLongtitude = object.locationLongtitude
//        self.address = object.address
//
//    }
//
//    func object() -> TSPostLocationObject {
//        let object = TSPostLocationObject()
//        object.locationID = self.locationID
//        object.locationName = self.locationName
//        object.locationLatitude = self.locationLatitude
//        object.locationLongtitude = self.locationLongtitude
//        object.address = self.address
//
//        return object
//    }
    
    static func convert(_ object: TSPostLocationModel?) -> String? {
        guard let object = object else { return nil }
        return object.toJSONString()
    }
    
    static func convert(_ json: String?) -> TSPostLocationModel? {
        guard let json = json else { return nil }
        return TSPostLocationModel(JSONString: json)
    }
}
