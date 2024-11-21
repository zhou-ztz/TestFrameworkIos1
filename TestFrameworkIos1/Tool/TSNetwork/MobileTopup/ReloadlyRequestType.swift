//
//  SRSReloadlyRequestType.swift
//  Yippi
//
//  Created by ChuenWai on 05/08/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

struct ReloadlyProviderRequest: RequestType {
    typealias ResponseType = [SRSProviderModel]

    let countryISO: String

    var data: YPRequestData {
        let path = "/wallet/api/partner/reloadly/providers/countries/" + countryISO.trimmingCharacters(in: .whitespacesAndNewlines)
        return YPRequestData(path: path, method: .get, params: nil)
    }
}

struct ReloadlyPackagesRequest: RequestType {
    typealias ResponseType = [ReloadlyPackageModel]

    let productID: Int

    var data: YPRequestData {
        let url = "wallet/api/partner/reloadly/v2/providers/\(productID)/products"
        return YPRequestData(
            path: url,
            method: .get,
            params: nil
        )
    }
}

struct ReloadlyPackageModel: Decodable {
    let productID: Double
    let yipps, amount: Double
    let currency: String

    enum CodingKeys: String, CodingKey {
        case productID = "amount"
        case yipps
        case amount = "target_amount"
        case currency = "target_currency"
    }
}

struct ReloadlyPurchaseRequest: RequestType {
    typealias ResponseType = ReloadlyPurchaseResponse

    let providerID: Int
    let amount: String
    let countryISO: String
    let pin: String
    let phoneNo: String

    var data: YPRequestData {
        let params: [String: Any] = [
            "provider_id": providerID,
            "amount": amount,
            "country_code": countryISO,
            "pin": pin,
            "phone": phoneNo
        ]
        return YPRequestData(path: "/wallet/api/partner/reloadly/v2", method: .post, params: params)
    }
}

struct ReloadlyPurchaseResponse: Decodable {
    let model: ReloadlyTransactionModel
    let messages: String?

    enum CodingKeys: String, CodingKey {
        case model = "data"
        case messages
    }
}

struct ReloadlyHistoryRequest: RequestType {

    typealias ResponseType = [ReloadlyTransactionModel]

    let after: Int
    let limit: Int
    let region: String

    var data: YPRequestData {
        let path = "/wallet/api/partner/reloadly/" + region + "?after=\(after)&limit=\(limit)"
        return YPRequestData(path: path, method: .get, params: nil)
    }
}

struct ReloadlyTransactionModel: Decodable {
    let id, orderID, status: Int
    let displayStatus, phoneNo, provider: String
    let currency, amount, yipps: String?
    let redeemTime, image, title: String
    let offsetYipps, offsetAmount, offsetCurrency: String

    enum CodingKeys: String, CodingKey {
        case id, status, currency, amount, yipps, provider, image, title
        case displayStatus = "status_display"
        case phoneNo = "phone_no"
        case redeemTime = "redeem_time"
        case orderID = "order_id"
        case offsetYipps = "offset_yipps"
        case offsetAmount = "offset_amount"
        case offsetCurrency = "offset_currency"
    }

}

struct ReloadlyV3PackagesRequest: RequestType {
    typealias ResponseType = [ReloadlyV3PackageModel]

    let productID: Int

    var data: YPRequestData {
        let url = "wallet/api/partner/reloadly/v3/providers/\(productID)/products"
        
        return YPRequestData(
            path: url,
            method: .get,
            params: nil
        )
    }
}

struct ReloadlyV3PackageModel: Decodable {
    let productID: Double
    let amount, offsetAmount, offsetYipps: Double
    let currency, offsetCurrency: String

    enum CodingKeys: String, CodingKey {
        case productID = "amount"
        case amount = "target_amount"
        case currency = "target_currency"
        case offsetAmount = "offset_amount"
        case offsetYipps = "offset_yipps"
        case offsetCurrency = "offset_currency"
    }
}

struct ReloadlyV3PurchaseRequest: RequestType {
    typealias ResponseType = ReloadlyV3PurchaseResponse

    let providerID: String
    let amount: String
    let countryISO: String
    let pin: String
    let phoneNo: String

    var data: YPRequestData {
        let params: [String: Any] = [
            "provider_id": providerID,
            "amount": amount,
            "country_code": countryISO,
            "pin": pin,
            "phone": phoneNo
        ]
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
        return YPRequestData(apiPaymentBaseURL: domainUrl, path: "/wallet/api/partner/reloadly/v3", method: .post, params: params)

    }
}

struct ReloadlyV3PurchaseResponse: Decodable {
    let paymentUrl: String?
    let body: ReloadlyPaymentData?
    

    enum CodingKeys: String, CodingKey {
        case paymentUrl = "payment_gateway_url"
        case body = "body"
    }
   
}

struct ReloadlyPaymentData: Decodable {
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

