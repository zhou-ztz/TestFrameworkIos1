//
//  Chatroom.swift
//  YippiCore
//
//  Created by Tinnolab on 17/06/2019.
//  Copyright © 2019 Chew. All rights reserved.
//

import Foundation

//REMARK: - Create chatroom
@objcMembers
public class CreateChatroomRequestResult: NSObject, Decodable {
    public let data: CreateChatroomData
}

@objcMembers
public class CreateChatroomData: NSObject, Decodable {
    public let chatroom: ChatroomResponseModel
    public let code: Int
}

@objcMembers
public class ChatroomResponseModel:  NSObject, Decodable {
    public let roomid: Int
    public let valid: Bool
    public let announcement: String?
    public let queuelevel: Int
    public let muted: Bool
    public let name: String
    public let broadcasturl: String?
    public let ext, creator: String
}

//REMARK: - Create chatroom
@objcMembers
public class CloseChatroomRequestResult: NSObject, Decodable {
    public let data: CloseChatroomData
}

@objcMembers
public class CloseChatroomData: NSObject, Decodable {
    public let roomid: Int
    public let valid: Bool
    public let desc: CloseChatroomData?
    public let announcement: String?
    public let muted: Bool
    public let queuelevel: Int
    public let name: String
    public let code: Int?
    public let broadcasturl: String?
    public let ext, creator: String
}
