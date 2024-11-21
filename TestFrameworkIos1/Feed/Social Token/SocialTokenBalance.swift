//
//  SocialTokenBalance.swift
//  Yippi
//
//  Created by Francis Yeap on 11/02/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

import RealmSwift

struct SocialTokenBalanceRequestType: RequestType {
    typealias ResponseType = SocialTokenBalanceModel
    var data: YPRequestData {
        return YPRequestData(
            path: "/api/v2/token/balances",
            method: .get, params: nil)
    }
}

struct SocialTokenBalanceModel : Codable {

    struct Data : Codable {

        let balances : Int
        let id : Int

        enum CodingKeys: String, CodingKey {
            case balances = "balance"
            case id = "id"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            balances = try (values.decodeIfPresent(Int.self, forKey: .balances) ?? 0)
            id = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        }

    }

    let data : [Data]?


    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([SocialTokenBalanceModel.Data].self, forKey: .data)
    }

}
