//
//  WhiteboardChatroomRequest.swift
//  YippiCore
//
//  Created by Tinnolab on 17/06/2019.
//  Copyright © 2019 Chew. All rights reserved.
//

import Foundation

@objcMembers
public class WhiteboardCreateChatroomRequestType: NSObject, RequestType {
    public typealias ResponseType = CreateChatroomRequestResult
    
    public let roomName: String
    
    @objc public init(roomName: String) {
        self.roomName = roomName
    }
    
    public var data: YPRequestData {
        var params: [String: Any] = [:]
        
        params["room_name"] = roomName
        
        return YPRequestData(
            path: "/api/v2/user/createChatRoom",
            method: .post,
            params: params)
    }
    
    
    /// Objective C Bridge
    @objc
    public func toObjcRequest() -> URLRequest {
        var urlReq = JSONRequest
        urlReq.httpMethod = data.method.rawValue
        urlReq.httpBody = try? JSONSerialization.data(withJSONObject: data.params ?? [:], options: [])
        // the expected response is also JSON
        return urlReq
    }
    
}

@objcMembers
public class WhiteboardCloseChatroomRequestType: NSObject, RequestType {
    public typealias ResponseType = CloseChatroomRequestResult
    
    public let roomId: String
    
    @objc public init(roomId: String) {
        self.roomId = roomId
    }
    
    public var data: YPRequestData {
        var params: [String: Any] = [:]
        
        params["room_id"] = roomId
        
        return YPRequestData(
            path: "/api/v2/user/closeChatRoom",
            method: .post,
            params: params)
    }
    
    
    /// Objective C Bridge
    @objc
    public func toObjcRequest() -> URLRequest {
        var urlReq = JSONRequest
        urlReq.httpMethod = data.method.rawValue
        urlReq.httpBody = try? JSONSerialization.data(withJSONObject: data.params ?? [:], options: [])
        // the expected response is also JSON
        return urlReq
    }
    
}
