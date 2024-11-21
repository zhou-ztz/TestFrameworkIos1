//
//  UserWalletRequest.swift
//  Yippi
//
//  Created by Yong Tze Ling on 29/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

struct UserWalletRequestType: RequestType {
    typealias ResponseType = UserWalletResponse
    
    let limit: Int
    
    var data: YPRequestData {
        return YPRequestData(path: "/wallet/api/me?limit=\(limit)", method: .get, params: nil)
    }
}


struct UserWalletResponse: Decodable {
    let currency: UserCurrencyModel?
    let transaction: [WalletTransactionModel]?
    
    enum CodingKeys: String, CodingKey {
        case currency, transaction
    }
}

struct UserCurrencyModel: Decodable {
    let yipps: YippsResponse?
    let cpoint: YippsResponse?
    let rebate: YippsResponse?
    
    enum CodingKeys: String, CodingKey {
        case yipps = "Yipps"
        case cpoint = "CPoint"
        case rebate = "Rebate"
    }
}

struct WalletTransactionModel: Decodable {
    let id: Int
    let title: String?
    let body: String?
    let type: Int
    let currency: Int
    let amount: String
    let state: Int
    let createdAt, updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, body, type, currency, amount, state
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
