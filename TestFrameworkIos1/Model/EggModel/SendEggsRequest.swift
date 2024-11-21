//
//  SendEggsRequest.swift
//  Yippi
//
//  Created by Francis Yeap on 5/23/19.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "Use SendEggRequest instead.")
struct SendEggRequestType: RequestType {
    typealias ResponseType = SendEggsResponseType
    
    enum SendType {
        case user(name: String)
        case group(id: String, quantity: Int, isRandomAmount: Bool)
        case live(id: Int, packageId: Int)
    }
    
    let sendType: SendType
    let amount: Double
    let message: String?
    let password: String
    
    var data: YPRequestData {
        var params: [String: Any]
    
        params =  [
            "amount": amount
        ]
        
        if password.isEmpty == false {
            params["password"] = password
        }
        
        switch sendType {
        case .user(let name):
            params["receiver_name"]  = name
        case let .group(id, quantity, isRandom):
            params["group_id"] = id
            params["quantity"] = quantity
            params["is_random_amount"] = isRandom == true ? 1 : 0
        case let .live(id, packageId):
            params["feed_id"] = id
            params["treasurebox_package_id"] = packageId
        }
        
        if let message = message {
            params["message"] = message
        }
        
        if let user = CurrentUserSessionInfo {
            params["request_id"] = user.requestKey
        }
        
        return YPRequestData(
            path: "/api/v2/user/redpackets",
            method: .post,
            params: params)
    }
}


struct SendEggRequest: RequestType {
    typealias ResponseType = SendEggResponse
    
    enum SendType {
        case personal(receiver: String)
        case group(groupId: String, isRandom: Bool, quantity: Int, specificUser: [String] = [])
        case live(id: Int, packageId: Int, subscriberOnly: Bool = false)
        
        var path: String {
            switch self {
            case .personal: return "/wallet/api/eggs/personal"
            case .group: return "/wallet/api/eggs/group"
            case .live: return "/wallet/api/eggs/live"
            }
        }
    }
    
    let amount: Double
    let message: String?
    let pin: String
    let type: SendType
    
    var data: YPRequestData {
        var params: [String: Any] = [:]
        switch type {
        case .personal(let receiver):
            params["receiver"] = receiver
        case let .group(groupId, isRandom, quantity, specificUser):
            params["group_id"] = groupId
            params["is_random"] = isRandom
            params["quantity"] = quantity
            if specificUser.isEmpty == false {
                params["specific_user"] = specificUser
            }
        case let .live(id, packageId, subscriberOnly):
            params["feed_id"] = id
            params["treasurebox_package_id"] = packageId
            params["subscriber_only"] = subscriberOnly ? 1 : 0
        }
        params["pin"] = pin
        params["amount"] = amount
        params["message"] = message.orEmpty
        return YPRequestData(path: type.path, method: .post, params: params)
    }
}

struct ClaimEggRequest: RequestType {
    typealias ResponseType = SendEggResponse
    
    enum ClaimType: String {
        case personal = "/wallet/api/eggs/personal"
        case group = "/wallet/api/eggs/group"
    }
    
    let eggId: String
    let type: ClaimType
    
    var data: YPRequestData {
        let params: [String: Any] = ["red_packet_id": eggId]
        return YPRequestData(path: type.rawValue, method: .patch, params: params)
    }
}
