//
//  LiveTokenStatus.swift
//  Yippi
//
//  Created by Francis on 05/05/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation


struct LivePinhistoryRequestType: RequestType {
    typealias ResponseType = LivePinhistoryModel
    
    var limit: Int
    var offset: Int?
    
    var data: YPRequestData {
        let url: String
        if let offset = offset {
            url = "/api/v2/token/transactions?limit=\(limit)&offset=\(offset)"
        } else {
            url = "/api/v2/token/transactions?limit=\(limit)"
        }
        return YPRequestData(path: url, method: .get, params: nil)
    }
}

struct LivePinhistoryModel: Codable {
    
    struct Event: Codable {
        let slotStart, slotEnd: Date

        enum CodingKeys: String, CodingKey {
            case slotStart = "slot_start"
            case slotEnd = "slot_end"
        }
    }
    
    struct Data: Codable {
        let action : String
        let actionTime : Date
        let id : Int
        let quantity : Int
        let title : String?
        let tokenName : String?

        enum CodingKeys: String, CodingKey {
            case action = "action"
            case actionTime = "action_time"
            case id = "id"
            case quantity = "quantity"
            case title = "title"
            case tokenName = "token_name"
        }
    }

    let data: [Data]?
}

struct LivePinContinueRequestType: RequestType {
    typealias ResponseType = LivePinContinueModel
    
    var feedId: Int
    var pinKey: String
    
    var data: YPRequestData {
        let url = "/api/v2/token/live-pinned/continue"
        return YPRequestData(path: url, method: .post, params: [
            "feed_id": feedId,
            "live_pinned_type": pinKey
        ])
    }
}

struct LivePinContinueModel: Codable {
    let balances : [Balance]?
    let pinEndTime : Date?
    
    var masterTokenCount: Int {
        guard let balances = balances else { return 0 }
        let balance: Int? = (balances.filter { $0.id == 1 }.first?.id)
        return balance.orZero
        
    }

    struct Balance : Codable {

        let balance : Int
        let id : Int
        let tokenName : String


        enum CodingKeys: String, CodingKey {
            case balance = "balance"
            case id = "id"
            case tokenName = "token_name"
        }

    }
    
    enum CodingKeys: String, CodingKey {
        case balances = "balances"
        case pinEndTime = "live_pinned_endtime"
    }

}


struct LiveTokenStatusRequestType: RequestType {
    typealias ResponseType = LiveTokenStatusModel
    
    var data: YPRequestData {
        let url = "/api/v2/token/live-pinned/status"
        return YPRequestData(path: url, method: .get, params: nil)
    }
}


struct LiveTokenStatusModel: Codable {

    let livePinnedEndtime: Date?
    
    enum CodingKeys: String, CodingKey {
        case livePinnedEndtime = "live_pinned_endtime"
    }
    
}


struct LiveTokenTimeCostRequestType: RequestType  {
    typealias ResponseType = LiveTokenTimeCostModel
    
    var data: YPRequestData {
        let url = "/api/v2/token/live-pinned/price"
        return YPRequestData(path: url, method: .get, params: nil)
    }
}

struct LiveTokenTimeCostModel: Codable {
    
    let amount: Int
    var title: String? 
    let defaultExtendMinutes: TimeInterval
    let type: String

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case amount = "amount"
        case defaultExtendMinutes = "default_extend_minutes"
        case type = "type"
    }

}
