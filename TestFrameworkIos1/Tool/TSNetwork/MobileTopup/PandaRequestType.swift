//
//  PandaRequestType.swift
//  Yippi
//
//  Created by Wong Jin Lun on 02/02/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Get Transactions
struct PandaProviderRequest: RequestType {
    
    typealias ResponseType = [PandaProviderResponse]

    let type: PandaProviderType?
    let region: String?
    
    var data: YPRequestData {
        var path = "/wallet/api/partner/panda/providers"
        if let type = type, let region = region {
            path += "?type=" + type.rawValue + "&country_code=" + region
        }
        return YPRequestData(path: path, method: .get, params: nil)
    }
}

enum PandaProviderType: String {
    case bills = "bills"
    case mobile = "mobile_topup"
    case voucher = "voucher"
}

// MARK: - PandaProviderResponse
struct PandaProviderResponse: Codable {
    let type: String
    let data: [PandaProviderModel]
}

// MARK: - PandaProviderModel
struct PandaProviderModel: Codable {
    let id: Int?
    let name: String?
    let description: String?
    let imageURL, logoURL: String?
    let videoURL: String?
    let type, accountType: String?
    let validity: Int?
    let offsetPercentage, rebatePercentage: String?
    let maxQuantity: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case imageURL = "image_url"
        case logoURL = "logo_url"
        case videoURL = "video_url"
        case type
        case accountType = "account_type"
        case validity
        case offsetPercentage = "offset_percentage"
        case rebatePercentage = "rebate_percentage"
        case maxQuantity = "max_quantity"
    }
}

struct PandaProductRequest: RequestType {
    
    typealias ResponseType = PandaProductResponse
    
    let providerId: Int
    
    var data: YPRequestData {
        let url = "/wallet/api/partner/panda/providers/\(providerId)/products"
        return YPRequestData(path: url, method: .get, params: nil)
    }
}

// MARK: - PandaProductResponse
struct PandaProductResponse: Codable {
    let id: Int
    let gatewayID: String?
    let name: String
    let description, descriptionLong: String?
    let accountType, type: String
    let imageURL, logoURL: String?
    let videoURL, redemptionOnlineInstruction, redemptionInstoreInstruction, cardTerms: String?
    let packages: [PandaPackageModel]

    enum CodingKeys: String, CodingKey {
        case id
        case gatewayID = "gateway_id"
        case name, description
        case descriptionLong = "description_long"
        case accountType = "account_type"
        case type
        case imageURL = "image_url"
        case logoURL = "logo_url"
        case videoURL = "video_url"
        case redemptionOnlineInstruction = "redemption_online_instruction"
        case redemptionInstoreInstruction = "redemption_instore_instruction"
        case cardTerms = "card_terms"
        case packages
    }
}

// MARK: - PandaPackageModel
struct PandaPackageModel: Codable {
    let productID, providerID: Int?
    let price: String?
    let minAmount, maxAmount, offsetCurrency, title: String?
    let description: String?
    let imageURL: String?
    let sortOrder: Int?
    let offsetAmount, offsetYipps, offsetPercentage, rebatePercentage: String?
    let maxQuantity: Int?
    let accountType: [String]?

    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case providerID = "provider_id"
        case price
        case minAmount = "min_amount"
        case maxAmount = "max_amount"
        case offsetCurrency = "offset_currency"
        case title, description
        case imageURL = "image_url"
        case sortOrder = "sort_order"
        case offsetAmount = "offset_amount"
        case offsetYipps = "offset_yipps"
        case offsetPercentage = "offset_percentage"
        case rebatePercentage = "rebate_percentage"
        case maxQuantity = "max_quantity"
        case accountType = "account_type"
    }
}

struct PandaPurchaseRequest: RequestType {
    
    typealias ResponseType = PaymentMethodResponse
    
    //prepaid
    let accountNo: String
    let productId: String
    let payChannelId: String
    let payType: String
    let pin: String
    let remark: String
    
    //softpin
    let quantity: Int
    
    //utilities
    let billReference: String
    let amount: Double
    let accountType: String?
    
    //vouchers
    let offsetRate: Double

    var data: YPRequestData {
        return YPRequestData(path: "/wallet/api/partner/panda/purchase", method: .post, params: ["account_no": accountNo, "product_id": productId, "pay_channel_id": payChannelId, "pay_type": payType, "pin": pin, "quantity": quantity, "bill_reference": billReference, "amount": amount, "offset_rate": offsetRate, "remark": remark, "account_type": accountType])
    }
}

struct PandaPurchaseAliPayRequest: RequestType {
    
    typealias ResponseType = PaymentMethodAliPayResponse
    
    //prepaid
    let accountNo: String
    let productId: String
    let payChannelId: String
    let payType: String
    let pin: String
    let remark: String

    
    //vouchers
    let offsetRate: Double

    var data: YPRequestData {
        return YPRequestData(path: "/wallet/api/partner/panda/purchase", method: .post, params: ["account_no": accountNo, "product_id": productId, "pay_channel_id": payChannelId, "pay_type": payType, "pin": pin, "offset_rate": offsetRate, "remark": remark])
    }
}


struct PandaHistoryRequest: RequestType {

    typealias ResponseType = [PandaTransactionModel]

    let after: Int
    let limit: Int

    var data: YPRequestData {
        let path = "/wallet/api/partner/panda/purchase/history" + "?after=\(after)&limit=\(limit)"
        return YPRequestData(path: path, method: .get, params: nil)
    }
}

struct PandaTransactionModel: Codable {
    let id: Int?
    let credits, phone, cardname: String?
    let provider: PandaProvider?
    let targetCurrency, createdAt, displayStatus: String?
    let orderID: Int?
    let type, offsetAmount, offsetCurrency: String?
    let softpins: [Softpin]?
    let targetAmount, offsetYipps, updatedAt: String?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case id, credits, provider, phone, cardname
        case targetCurrency = "target_currency"
        case createdAt = "created_at"
        case displayStatus = "display_status"
        case orderID = "order_id"
        case type
        case offsetAmount = "offset_amount"
        case offsetCurrency = "offset_currency"
        case softpins
        case targetAmount = "target_amount"
        case offsetYipps = "offset_yipps"
        case updatedAt = "updated_at"
        case status
    }
}

struct PandaProvider: Codable {
    let id: Int?
    let name, description: String?
    let imageURL, logoURL: [String?]
    let package: PandaPackage?
    let accountType: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case imageURL = "image_url"
        case logoURL = "logo_url"
        case package
        case accountType = "account_type"
    }
}

struct PandaPackage: Codable {
    let id, providerID, gatewayID: Int?
    let price: String?
    let title: String?
    let description, descriptiveName: String?
    let validity: Int?
    let imageURL: String?
    let sortOrder: Int?
    let createdAt, updatedAt: String?
    let deletedAt: String?
    let productID, minAmount, maxAmount, currency: String?
    let offsetAmount, offsetYipps, offsetPercentage, rebatePercentage: String?
    let maxQuantity: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case providerID = "provider_id"
        case gatewayID = "gateway_id"
        case price, title, description
        case descriptiveName = "descriptive_name"
        case validity
        case imageURL = "image_url"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case productID = "product_id"
        case minAmount = "min_amount"
        case maxAmount = "max_amount"
        case currency
        case offsetAmount = "offset_amount"
        case offsetYipps = "offset_yipps"
        case offsetPercentage = "offset_percentage"
        case rebatePercentage = "rebate_percentage"
        case maxQuantity = "max_quantity"
    }
}

struct PandaHistoriesRequest: RequestType {
    
    typealias ResponseType = [PandaHistoriesResponse]
    
    let id: Int
    let myVoucher: Int

    var data: YPRequestData {
        return YPRequestData(path: "/wallet/api/partner/panda/purchase/history?id=\(id)&my_voucher=\(myVoucher)", method: .get, params: nil)
    }
}

struct PandaHistoriesResponse: Codable {
    let id: Int?
    let credits, phone, cardname: String?
    let targetCurrency, createdAt, displayStatus: String
    let orderID: Int?
    let type, offsetAmount, offsetCurrency: String?
    let provider: PandaProvider
    let softpins: [PandaSoftpin]?
    let targetAmount, offsetYipps, updatedAt: String?
    let status: Int?
    let paymentMethod, orderNo: String?
    let quantity: Int?
    let billReference: String?
    let failedReason: String?
    let accountType: String?
    
    enum CodingKeys: String, CodingKey {
        case id, credits, provider, phone, cardname
        case targetCurrency = "target_currency"
        case createdAt = "created_at"
        case displayStatus = "display_status"
        case orderID = "order_id"
        case type
        case offsetAmount = "offset_amount"
        case offsetCurrency = "offset_currency"
        case softpins
        case targetAmount = "target_amount"
        case offsetYipps = "offset_yipps"
        case updatedAt = "updated_at"
        case status
        case paymentMethod = "payment_method"
        case orderNo = "order_no"
        case quantity = "quantity"
        case billReference = "bill_reference"
        case failedReason = "failed_reason"
        case accountType = "account_type"
    }
}

// MARK: - PandaSoftpin
struct PandaSoftpin: Codable {
    let orderDate, dealerNumber, referenceID, topupCode: String
    let topupSerial, topupExpiry, denomName2, topupCode2: String
    let topupSerial2, voucherLink: String

    enum CodingKeys: String, CodingKey {
        case orderDate = "OrderDate"
        case dealerNumber = "DealerNumber"
        case referenceID = "ReferenceID"
        case topupCode = "TopupCode"
        case topupSerial = "TopupSerial"
        case topupExpiry = "TopupExpiry"
        case denomName2 = "DenomName2"
        case topupCode2 = "TopupCode2"
        case topupSerial2 = "TopupSerial2"
        case voucherLink = "VoucherLink"
    }
}
