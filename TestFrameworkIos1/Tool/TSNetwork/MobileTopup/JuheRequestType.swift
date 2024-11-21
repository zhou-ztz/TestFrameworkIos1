//
//  JuheRequestType.swift
//  Yippi
//
//  Created by Wong Jin Lun on 12/07/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

struct JuhePackagesRequest: RequestType {
    typealias ResponseType = [JuhePackageModel]

    let productID: Int

    var data: YPRequestData {
        let url =  "wallet/api/partner/juhe/mobile-topup/v2/providers/\(productID)/products"
        
        return YPRequestData(
            path: url,
            method: .get,
            params: nil
        )
    }
}

struct JuhePackageModel: Decodable {
    let amount: Int
    let offsetYipps, offsetAmount, processFees: Double
    let offsetCurrency, packageName, targetCurrency, targetAmount, productID: String
  
    enum CodingKeys: String, CodingKey {
        case amount
        case targetAmount = "target_amount"
        case targetCurrency = "target_currency"
        case offsetAmount = "offset_amount"
        case offsetYipps = "offset_yipps"
        case offsetCurrency = "offset_currency"
        case packageName = "package_name"
        case productID = "product_id"
        case processFees = "process_fees"
    }
}

struct JuhePurchaseRequest: RequestType {
    typealias ResponseType = JuhePurchaseResponse

    let providerID: Int
    let productID: String
    let pin: String
    let phoneNo: String

    var data: YPRequestData {
        let params: [String: Any] = [
            "provider_id": providerID,
            "product_id": productID,
            "pin": pin,
            "phone": phoneNo
        ]
        return YPRequestData(path: "/wallet/api/partner/juhe/mobile-topup/v2/order", method: .post, params: params)
    }
  
}

struct JuhePurchaseResponse: Codable {
    let app_id: String?
    let created_time: String?
    let description: String?
    let id: String?
    let pay_amt: String?
    let expend: PurchaseOrderExpend?
    let query_url: String?
    let prod_mode: String?
    let object: String?
    let pay_channel: String?
    let order_no: String?
    let party_order_id: String?
    let status: String?
    let orderStr: String?
    
    enum CodingKeys: String, CodingKey {
        case app_id = "app_id"
        case created_time = "created_time"
        case description = "description"
        case id = "id"
        case pay_amt = "pay_amt"
        case expend = "expend"
        case query_url = "query_url"
        case prod_mode = "prod_mode"
        case object = "object"
        case pay_channel = "pay_channel"
        case order_no = "order_no"
        case party_order_id = "party_order_id"
        case status = "status"
        case orderStr = "orderstr"
        
    }
}

struct PurchaseOrderExpend: Codable {
    let pay_info: String

    enum CodingKeys: String, CodingKey {
        case pay_info = "pay_info"
      
    }
}

struct JuheVerifyRequest: RequestType {
    typealias ResponseType = [JuheVerifyResponseModel]

    let adapayId: String

    var data: YPRequestData {
        let params: [String: Any] = [
            "adapay_id": adapayId,
        ]
        return YPRequestData(path: "/wallet/api/partner/juhe/mobile-topup/v2/verify", method: .post, params: params)
    }
    
}

struct JuheVerifyResponseModel: Decodable {
    let id, credits, orderId, status: Int
    let provider, phone, cardName, createdAt, targetCurrency, displayStatus, offsetCurrency, updatedAt: String
    let processFees, offsetAmount, targetAmount, offsetYipps: Double
  
    enum CodingKeys: String, CodingKey {
        case id, credits, status, provider, phone
        case orderId = "order_id"
        case cardName = "cardname"
        case createdAt = "created_at"
        case targetCurrency = "target_currency"
        case displayStatus = "display_status"
        case offsetCurrency  = "offset_currency"
        case updatedAt = "updated_at"
        case processFees = "process_fees"
        case offsetAmount = "offset_amount"
        case targetAmount = "target_amount"
        case offsetYipps = "offset_yipps"
    }
}

struct JuheHistoryRequest: RequestType {

    typealias ResponseType = [JuheTransactionModel]

    let after: Int
    let limit: Int
    let region: String

    var data: YPRequestData {
        let path = "/wallet/api/partner/juhe/mobile-topup/v2/histories" + "?after=\(after)&limit=\(limit)"
        return YPRequestData(path: path, method: .get, params: nil)
    }
}

struct JuheTransactionModel: Decodable {
    let id, credits, orderId, status: Int
    let provider, phone, cardName, createdAt, displayStatus, updatedAt: String
    let offsetCurrency, targetCurrency: String?
    let offsetAmount, offsetYipps, targetAmount, processFees: Double?

    enum CodingKeys: String, CodingKey {
        case id, credits, status, provider, phone
        case orderId = "order_id"
        case cardName = "cardname"
        case createdAt = "created_at"
        case displayStatus = "display_status"
        case offsetCurrency = "offset_currency"
        case updatedAt = "updated_at"
        case offsetAmount = "offset_amount"
        case offsetYipps = "offset_yipps"
        case targetAmount = "target_amount"
        case targetCurrency = "target_currency"
        case processFees = "process_fees"
    }

}
