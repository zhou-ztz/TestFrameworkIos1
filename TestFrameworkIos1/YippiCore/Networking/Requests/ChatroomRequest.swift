//
//  ChatroomRequest.swift
//  YippiCore
//
//  Created by Tinnolab on 17/06/2019.
//  Copyright © 2019 Chew. All rights reserved.
//

import Foundation

struct CreateChatroomRequest: APIRequest {
    typealias Response = CreateChatroomRequestResult
    
    var resourceName: String {
        return "/api/v2/user/createChatRoom"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let roomName: String
    
    init(roomName: String) {
        self.roomName = roomName
    }
    
    enum CodingKeys: String, CodingKey {
        case roomName = "room_name"
    }
}

struct CloseChatroomRequest: APIRequest {
    typealias Response = CloseChatroomRequestResult
    
    var resourceName: String {
        return "/api/v2/user/closeChatRoom"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let roomId: String
    
    init(roomId: String) {
        self.roomId = roomId
    }
    
    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
    }
}
