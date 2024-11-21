// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

@objc enum claimType: Int {
    case personal = 0
    case group
    case live
}

struct openEgg: APIRequest {
    
    typealias Response = ClaimEggResponse
    
    var requestMethod: RequestMethod {
        return .patch
    }
    
    var resourceName: String {
        switch type {
        case .personal: return "/wallet/api/eggs/personal"
        case .group: return "/wallet/api/eggs/group"
        case .live: return "/wallet/api/eggs/live/v1"
        }
    }
    
    let eggId: Int?
    let type: claimType
    let feedId: Int?
    
    init(eggId: Int? = nil, feedId: Int? = nil, type: claimType) {
        self.eggId = eggId
        self.type = type
        self.feedId = feedId
    }
    
    enum CodingKeys: String, CodingKey {
        case eggId = "red_packet_id"
        case feedId = "feed_id"
    }
    
}

struct openPersonalEgg: APIRequest {
    typealias Response = EggResponseModel
    
    var resourceName: String {
        return "api/v2/user/redpackets"
    }
    
    var requestMethod: RequestMethod {
        return .patch
    }
    
    let eggId: Int
    
    init(eggId: Int) {
        self.eggId = eggId
    }
    
    enum CodingKeys: String, CodingKey {
        case eggId = "redpacket_id"
    }
}

struct openGroupEgg: APIRequest {
    typealias Response = EggResponseModel
    
    var resourceName: String {
        return "api/v2/user/redpackets"
    }
    
    var requestMethod: RequestMethod {
        return .patch
    }
    
    let eggId: Int?
    let groupId: String?
    let feedId: Int?
    
    init(eggId: Int? = nil, groupId: String? = nil, feedId: Int? = nil) {
        self.eggId = eggId
        self.groupId = groupId
        self.feedId = feedId
    }
    
    enum CodingKeys: String, CodingKey {
        case eggId = "redpacket_id"
        case groupId = "group_id"
        case feedId = "feed_id"
    }
}

struct sendPersonalEgg: APIRequest {
    typealias Response = SendEggResult
    
    var resourceName: String {
        return "reward/api/sendEgg"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let password: String
    let amount: String
    let receiver: String
    let message: String
    
    init(password: String, amount: String, receiver: String, message: String) {
        self.password = password
        self.amount = amount
        self.receiver = receiver
        self.message = message
    }
    
    enum CodingKeys: String, CodingKey {
        case password
        case amount
        case receiver
        case message
    }
}

struct sendGroupEgg: APIRequest {
    typealias Response = SendEggResult
    
    var resourceName: String {
        return "reward/api/sendGroupEgg"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let password: String
    let amount: String
    let groupId: String
    let message: String
    let quantity: Int
    let random: Int
    
    init(password: String, amount: String, groupId: String, message: String, quantity:Int, random:Int) {
        self.password = password
        self.amount = amount
        self.groupId = groupId
        self.message = message
        self.quantity = quantity
        self.random = random
    }
    
    enum CodingKeys: String, CodingKey {
        case password
        case amount
        case groupId = "group_id"
        case message
        case quantity
        case random
    }
}
