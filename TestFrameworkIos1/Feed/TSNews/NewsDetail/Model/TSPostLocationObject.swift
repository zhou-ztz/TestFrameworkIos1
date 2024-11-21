//
//  TSPostLocationObject.swift
//  Yippi
//
//  Created by Khoo on 08/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//


import UIKit
import RealmSwift
import ObjectMapper
// TL: to be removed
class TSPostLocationObject: Object, Mappable {
    
    @objc dynamic var locationID: String = ""
    @objc dynamic var locationName: String = ""
    @objc dynamic var locationLatitude: Float = 0
    @objc dynamic var locationLongtitude: Float = 0
    @objc dynamic var address: String?

    /// 主键
    override static func primaryKey() -> String? {
        return "locationID"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        locationID <- map["lid"]
        locationName <- map["name"]
        locationLatitude <- map["lat"]
        locationLongtitude <- map["lng"]
        address <- map["address"]
    }
    
}
