//
//  MeetSettingModel.swift
//  Yippi
//
//  Created by Francis on 19/05/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

struct MeetSettingRequestType: RequestType  {
    typealias ResponseType = MeetSettingModel
    var data: YPRequestData {
        return YPRequestData(
            path: "/api/v2/setting/random-ppl-chatroom-id/public_id",
            method: .get, params: nil)
    }
}


struct MeetSettingModel : Codable {

    let roomId: Int
    let countdown: Int

    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case countdown = "countdown"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        roomId = try (values.decodeIfPresent(Int.self, forKey: .roomId) ?? 0)
        countdown = try (values.decodeIfPresent(Int.self, forKey: .countdown) ?? 15)
    }

}

class YunXinResponse<T: Mappable>: Mappable {
    var code : Int?
    var desc : T?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        code <- map["code"]
        desc <- map["desc"]
        
    }
}

class YunXinChatRoomResponse<T: Mappable>: Mappable {
    var code : Int?
    var chatroom : T?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        code <- map["code"]
        chatroom <- map["chatroom"]
        
    }
}

class MeetQueryUserRoomIdsDescResponse: Mappable {

    var roomids : [String]?

    required init?(map: Map){}

    func mapping(map: Map) {
        roomids <- map["roomids"]
    }
}


class MeetCloseRoomResponse: Mappable {
    
    var announcement : String?
    var broadcasturl : String?
    var creator : String?
    var ext : String?
    var name : String?
    var roomid : Int?
    var valid : Bool?

    required init?(map: Map){}

    func mapping(map: Map) {
        announcement <- map["announcement"]
        broadcasturl <- map["broadcasturl"]
        creator <- map["creator"]
        ext <- map["ext"]
        name <- map["name"]
        roomid <- map["roomid"]
        valid <- map["valid"]
    }
}

class YunXinRoomNumberResponse: Mappable {
    var code : Int?
    var data : RoomNumbers?
    var msg: String?
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        code <- map["code"]
        data <- map["data"]
        msg <- map["msg"]
        
    }
}

class RoomNumbers: Mappable {
    var totalCount: Int = 0
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        totalCount <- map["totalCount"]
        
    }
}
