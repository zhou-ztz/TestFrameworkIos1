//
//  RetrieveCallDetailModel.swift
//  Yippi
//
//  Created by Wong Jin Lun on 26/04/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

class CallDetailResponseModel : Mappable {
    var message : String?
    var data : [CallDetailData]?

    required init?(map: Map) {

    }

    func mapping(map: Map) {

        message <- map["message"]
        data <- map["data"]
    }

}

class CallDetailData : Mappable {
    var id : Int?
    var yunxin_id : String?
    var device : String?
    var from : Int?
    var to : Int?
    var group_type : String?
    var call_type : String?
    var call_status : String?
    var last_call_action : String?
    var start_call : String?
    var accept_call : String?
    var reject_call : String?
    var missed_call : String?
    var end_call : String?
    var created_at : String?
    var updated_at : String?
    var person : CallDetailPerson?
    var in_out : String?
    var call_req : [String]?

    required init?(map: Map) {

    }

    func mapping(map: Map) {

        id <- map["id"]
        yunxin_id <- map["yunxin_id"]
        device <- map["device"]
        from <- map["from"]
        to <- map["to"]
        group_type <- map["group_type"]
        call_type <- map["call_type"]
        call_status <- map["call_status"]
        last_call_action <- map["last_call_action"]
        start_call <- map["start_call"]
        accept_call <- map["accept_call"]
        reject_call <- map["reject_call"]
        missed_call <- map["missed_call"]
        end_call <- map["end_call"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        person <- map["person"]
        in_out <- map["in_out"]
        call_req <- map["call_req"]
    }

}

class CallDetailPerson : Mappable {
    var id : Int?
    var username : String?

    required init?(map: Map) {

    }

    func mapping(map: Map) {

        id <- map["id"]
        username <- map["username"]
    }

}

