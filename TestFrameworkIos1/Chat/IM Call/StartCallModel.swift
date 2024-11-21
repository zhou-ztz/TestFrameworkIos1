//
//  StartCallModel.swift
//  Yippi
//
//  Created by Wong Jin Lun on 26/04/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

class StartCallResponseModel : Mappable {
    var message : String?
    var data : StartCallData?

    required init?(map: Map) {

    }

    func mapping(map: Map) {

        message <- map["message"]
        data <- map["data"]
    }

}

class StartCallData : Mappable {
    var yunxin_id : String?
    var from : String?
    var to : String?
    var call_type : String?
    var group_type : String?
    var start_call : String?
    var device : String?
    var last_call_action : String?
    var updated_at : String?
    var created_at : String?
    var id : Int?

    required init?(map: Map) {

    }

    func mapping(map: Map) {

        yunxin_id <- map["yunxin_id"]
        from <- map["from"]
        to <- map["to"]
        call_type <- map["call_type"]
        group_type <- map["group_type"]
        start_call <- map["start_call"]
        device <- map["device"]
        last_call_action <- map["last_call_action"]
        updated_at <- map["updated_at"]
        created_at <- map["created_at"]
        id <- map["id"]
    }

}
