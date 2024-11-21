//
//  CallListModel.swift
//  Yippi
//
//  Created by Wong Jin Lun on 26/04/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

class CallListResponseModel: Mappable {
    
    var message: String?
    var data: [CallListModel]?
    
    required init?(map: Map){}

    func mapping(map: Map) {
        message <- map["message"]
        data <- map["data"]
    }
}

class CallListModel: Mappable {

    var filterId: String?
    var filterData: FilterDataModel?
    
    required init?(map: Map){}

    func mapping(map: Map) {
        filterId <- map["filter_id"]
        filterData <- map["filter_data"]
    }
}

class FilterDataModel: Mappable {
    
    var count: Int?
    var user: CallUserModel?
    var callStatus, groupType: String?
    var date: String?
  
    
    required init?(map: Map){}

    func mapping(map: Map) {
        count <- map["count"]
        user <- map["user"]
        date <- map["date_time"]
        callStatus <- map["call_status"]
        groupType <- map["group_type"]
      
    }
}

class CallUserModel: Mappable {
    
    var id: Int?
    var username: String?
    required init?(map: Map){}

    func mapping(map: Map) {
        id <- map["id"]
        username <- map["username"]
    }
}

