//
//  SRSRequestType.swift
//  Yippi
//
//  Created by Yong Tze Ling on 20/05/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Get Transactions

struct SRSTransactionRequest: RequestType {
    typealias ResponseType = SRSTransactionResponse
    
    let limit: Int
    let offset: Int
    let type: SRSBillType
    
    var data: YPRequestData {
        let url = "/wallet/api/partner/srs/transactions?offset=\(offset)&limit=\(limit)&type=\(type.paramName)"
        return YPRequestData(path: url, method: .get, params: nil)
    }
}

struct SRSTransactionResponse: Decodable {
    let data: [SRSTransactionModel]?
}

struct SRSTransactionModel: Decodable {
    
    let orderID: Int
    let statusText: String
    let status: Int
    let yipps, amount, providerName: String
    let accountNo, phone: String?
    let imageURL: String?
    let redeemTime: String
    let title: String
    let offsetYipps, offsetAmount, offsetCurrency: String
    
    var isSuccess: Bool {
        return status == 2
    }

    enum CodingKeys: String, CodingKey {
        case orderID = "order_id"
        case statusText = "status_text"
        case status, yipps, amount
        case providerName = "provider_name"
        case phone
        case accountNo = "account_no"
        case imageURL = "image_url"
        case redeemTime = "redeem_time"
        case title
        case offsetYipps = "offset_yipps"
        case offsetAmount = "offset_amount"
        case offsetCurrency = "offset_currency"
    }
}

// MARK: - Get Providers

enum SRSBillType: String {
    case all = "bills"
    case loans = "loans"
    case internet = "internet"
    case tv = "tv"
    case water = "water"
    case electricity = "electricity"
    case mobile = "topup"

    var displayTitles: String {
        switch self {
            case .all: return "srs_utilities_bills_all".localized
            case .loans: return "srs_utilities_loans_saving_bills".localized
            case .internet: return "srs_utilities_bill_internet".localized
            case .tv: return "srs_utilities_tv_radio_bills".localized
            case .water: return "srs_utilities_water_bills".localized
            case .electricity: return "srs_utilities_bill_electricity".localized
            default: return self.rawValue
        }
    }

    var paramName: String {
        switch self {
            case .all: return "bills"
            case .mobile: return "mobile_topup"
            default: return self.rawValue
        }
    }
}

enum SRSAccountType: String {
    case icNo = "IC no."
    case accNo = "account no."
    case phoneNo = "phone no."
    case notSpecified = "Error"

    var displayTitle: String {
        switch self {
            case .icNo: return "srs_utilities_placeholder_ic_no".localized
            case .accNo: return "mobile_top_up_payment_history_provider_account_id".localized
            default: return ""
        }
    }
}

struct SRSProviderRequest: RequestType {
    
    typealias ResponseType = SRSProviderResponse

    let type: SRSBillType?
    
    var data: YPRequestData {
        var path = "/wallet/api/partner/srs/providers"
        if let type = type {
            path += "?type=" + type.paramName
        }
        return YPRequestData(path: path, method: .get, params: nil)
    }
}

struct SRSProviderResponse: Decodable {
    let data: [SRSProviderModel]
    let postpaid: [SRSProviderModel]?
}

struct SRSProviderModel: Decodable {
    var id: Int
    var name: String
    var imageURL: String?
    var type: SRSBillType?
    var accountType: SRSAccountType?
    var minLength: Int?
    var maxLength: Int?
    var rebatePercentage: String?
    var offsetPercentage: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case imageURL = "image_url"
        case type = "type"
        case accountType = "account_type"
        case minLength = "account_length_min"
        case maxLength = "account_length_max"
        case rebatePercentage = "rebate_percentage"
        case offsetPercentage = "offset_percentage"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        imageURL = try values.decodeIfPresent(String.self, forKey: .imageURL)
        type = SRSBillType(rawValue: try (values.decodeIfPresent(String.self, forKey: .type) ?? "")) ?? .all
        accountType = SRSAccountType(rawValue: try (values.decodeIfPresent(String.self, forKey: .accountType) ?? "")) ?? .notSpecified
        minLength = try values.decodeIfPresent(Int.self, forKey: .minLength)
        maxLength = try values.decodeIfPresent(Int.self, forKey: .maxLength)
        rebatePercentage = try values.decodeIfPresent(String.self, forKey: .rebatePercentage)
        offsetPercentage = try values.decodeIfPresent(String.self, forKey: .offsetPercentage)
    }
}

// MARK: - Get Products

struct SRSProductRequest: RequestType {
    
    typealias ResponseType = SRSProductResponse
    
    let providerId: Int
    
    var data: YPRequestData {
        let url = "/wallet/api/partner/srs/products?provider_id=\(providerId)"
        return YPRequestData(path: url, method: .get, params: nil)
    }
}

struct SRSProductResponse: Decodable {
    let moreInfo: [String]
    let packages: [SRSPackageModel]

    enum CodingKeys: String, CodingKey {
        case moreInfo = "more_info"
        case packages
    }
}

struct SRSPackageModel: Decodable {
    let productID, price, yipps, title: String
    let packageDescription: String?
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case price, yipps, title
        case packageDescription = "description"
        case imageURL = "image_url"
    }
}

// MARK: - Purchase package
struct SRSPurchaseRequest: RequestType {
    
    typealias ResponseType = SRSPurchaseResponse
    
    let productId: String
    let pin: String
    let mobileNo: String?
    let accountNo: String?
    
    var data: YPRequestData {
        var params: [String: Any] = ["product_id": productId, "pin": pin]
        if let mobileNo = mobileNo {
            params["mobile_number"] = mobileNo
        } else if let accountNo = accountNo {
            params["account_no"] = accountNo
        }
        return YPRequestData(path: "/wallet/api/partner/srs/purchase", method: .post, params: params)
    }
}

struct SRSPurchaseResponse: Decodable {
    let model: SRSTransactionModel
    let message: String?

    enum CodingKeys: String, CodingKey {
        case model = "transaction"
        case message
    }
}

struct SRSV2ProductRequest: RequestType {
    
    typealias ResponseType = SRSV2ProductResponse
    
    let providerId: Int
    
    var data: YPRequestData {
        let url = "/wallet/api/partner/srs/v2/products?provider_id=\(providerId)"
        return YPRequestData(path: url, method: .get, params: nil)
    }
}

struct SRSV2ProductResponse: Decodable {
    let moreInfo: [String?]
    let packages: [SRSV2PackageModel]

    enum CodingKeys: String, CodingKey {
        case moreInfo = "more_info"
        case packages
    }
}

struct SRSV2PackageModel: Decodable {
    let productID, price, title, offsetAmount, offsetYipps, offsetCurrency: String
    let packageDescription: String?
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case price, title
        case packageDescription = "description"
        case imageURL = "image_url"
        case offsetAmount = "offset_amount"
        case offsetYipps = "offset_yipps"
        case offsetCurrency = "offset_currency"
    }
}

// MARK: - Purchase package
struct SRSV2PurchaseRequest: RequestType {
    
    typealias ResponseType = SRSV2PurchaseResponse
    
    let productId: String
    let pin: String
    let mobileNo: String?
    let accountNo: String?
    
    var data: YPRequestData {
        var params: [String: Any] = ["product_id": productId, "pin": pin]
        if let mobileNo = mobileNo {
            params["mobile_number"] = mobileNo
        } else if let accountNo = accountNo {
            params["account_no"] = accountNo
        }
        
        let domainUrl: String
        let envConfigId = TSAppConfig.share.environment.identifier
        switch envConfigId {
        case "Stg":
            domainUrl = ServerConfig.staging.apiBaseURL
        case "Preprod":
            domainUrl = ServerConfig.preproduction.apiBaseURL
        case "Prod":
            domainUrl = "services_module_payment_custom_domain".localized
        default:
            domainUrl = "services_module_payment_custom_domain".localized
        }
        return YPRequestData(apiPaymentBaseURL: domainUrl ,path: "/wallet/api/partner/srs/v2/purchase", method: .post, params: params)

    }
}

struct SRSV2PurchaseResponse: Decodable {
    let paymentUrl: String?
    let paymentData: SRSPaymentData?
    

    enum CodingKeys: String, CodingKey {
        case paymentUrl = "payment_gateway_url"
        case paymentData = "payment_data"
    }
    
//    init(from decoder:Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        paymentUrl = try? container.decodeIfPresent(String.self, forKey: .paymentUrl)
//        paymentData = try? container.decodeIfPresent([String: Any].self, forKey: .paymentData)
//    }
   
}

struct SRSPaymentData: Decodable {
    let address, city, country, currencyText, email, firstName, lastName, phone, isSamesAsBilling,
        state, zip, transactionReturnURL, customerPaymentPageText, orderDescription, orderDetail,
        purchaseAmount, signature: String

    enum CodingKeys: String, CodingKey {
        case address = "address"
        case city = "city"
        case country = "country"
        case currencyText = "currencyText"
        case email = "email"
        case firstName = "firstName"
        case lastName = "lastName"
        case phone = "phone"
        case isSamesAsBilling = "IsSameAsBilling"
        case state = "state"
        case zip = "zip"
        case transactionReturnURL = "transactionReturnURL"
        case customerPaymentPageText = "customerPaymentPageText"
        case orderDescription = "orderDescription"
        case orderDetail = "orderDetail"
        case purchaseAmount = "purchaseAmount"
        case signature = "signature"
    }
}
