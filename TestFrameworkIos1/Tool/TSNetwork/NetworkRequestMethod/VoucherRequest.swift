//
//  VoucherRequest.swift
//  RewardsLink
//
//  Created by Wong Jin Lun on 29/05/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import SwiftyJSON

public enum VoucherBannerType {
    case image
    case video
}

public enum VoucherButtonType {
    case getVoucher
    case isExpiring
    case expired
    case redeem
    case isRedeemed
}

// MARK: - VoucherRequest
struct VoucherRequest: RequestType {
    typealias ResponseType = [VoucherResponse]
    
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

// MARK: - PandaVoucherResponse
struct VoucherResponse: Codable {
    let categoryID: Int?
    let categoryName: String?
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case categoryName = "category_name"
        case imageURL = "image_url"
    }
}

// MARK: - VoucherSummaryRequest
struct VoucherSummaryRequest: RequestType {
    
    typealias ResponseType = [VoucherSummaryResponse]?
    
    let type: PandaProviderType
    let region: String
    let isSummary: Int
    
    var data: YPRequestData {
        var path = "/wallet/api/partner/panda/providers?type=\(type.rawValue)&country_code=\(region)&is_summary=\(isSummary)"
        return YPRequestData(path: path, method: .get, params: nil)
    }
}

// MARK: - VoucherSummaryResponse
struct VoucherSummaryResponse: Codable {
    let categoryID: Int
    let categoryName: String?
    let data: [VoucherSummaryData]
    
    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case categoryName = "category_name"
        case data
    }
}

// MARK: - VoucherSummaryData
struct VoucherSummaryData: Codable {
    let id: Int?
    let name, description: String?
    let imageURL: [String]?
    let logoURL: [String]?
    let videoURL: String?
    let type: ProviderType?
    let accountType: String?
    let validity: Int?
    let offsetPercentage, rebatePercentage: String?
    let maxQuantity: Int?
    let descriptionLong: String?
    
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
        case descriptionLong = "description_long"
    }
}

// MARK: - VoucherProductRequest
struct VoucherProductRequest: RequestType {
    
    typealias ResponseType = [VoucherSummaryResponse]
    
    let type: PandaProviderType
    let region: String
    let categoryId: Int
    
    var data: YPRequestData {
        var path = "/wallet/api/partner/panda/providers?type=\(type.rawValue)&country_code=\(region)&category_id=\(categoryId)"
        return YPRequestData(path: path, method: .get, params: nil)
    }
}


// MARK: - VoucherDetailsRequest
struct VoucherDetailsRequest: RequestType {
    typealias ResponseType = VoucherDetailsResponse
    
    let voucherId: String
    
    var data: YPRequestData {
        var path = "/wallet/api/partner/panda/providers/\(voucherId)/products"
        return YPRequestData(path: path, method: .get, params: nil)
    }
}

struct VoucherDetailsResponse: Decodable {
    let id, gatewayId: Int?
    let name, description, descriptionLong: String?
    let accountType, type : String?
    let imageURL, logoURL: [String]?
    let videoURL: String?
    let redemptionOnlineInstruction, redemptionInstoreInstruction, cardTerms: String?
    let packages: [VoucherPackage]?
    let transactionFee: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case gatewayId = "gateway_id"
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
        case transactionFee = "transaction_fee"
    }
}

struct VoucherPackage: Decodable {
    let productID, providerID: Int?
    let price: String?
    let minAmount, maxAmount, offsetCurrency: String?
    var title, description: String?
    var imageURL, logoURL: String?
    let sortOrder: Int?
    let offsetAmount, offsetYipps, offsetPercentage, rebatePercentage: String?
    var maxQuantity: Int?
    var quantity: Int = 0
    var selectedIndex: Int = 0
    var isDisable: Bool = false
    var isSelected: Bool = false
    
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
    }
}

class ExpandableContentSection: Codable {
    var title: String
    var content: String?
    var isExpanded: Bool
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
        self.isExpanded = true
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case content
        case isExpanded
    }
}

struct MyVoucherRequest: RequestType {
    typealias ResponseType = [MyVoucherModel]
    
    let after: Int
    let limit: Int
    
    var data: YPRequestData {
        let path = "/wallet/api/partner/panda/purchase/history?my_voucher=1&after=\(after)&limit=\(limit)"
        return YPRequestData(path: path, method: .get, params: nil)
    }
}

// MARK: - MyVoucherModel
struct MyVoucherModel: Codable {
    let myVoucherId: Int?
    let orderID: Int?
    let credits: String?
    let status: Int?
    let targetAmount, offsetAmount, offsetYipps, targetCurrency: String?
    let offsetCurrency: String?
    let provider: MyVoucherProvider?
    let phone: String?
    let cardname, createdAt, updatedAt, type: String?
    let orderNo: String?
    let paymentMethod, billReference: String?
    let quantity: Int?
    let failedReason: String?
    let expiryDate, activationTokenURL: String?
    let softpins: [Softpin]
    let displayStatus: String?
    let expiringSoon, expired: Int?
    let description: String?
    let descriptionLong: String?
    let isRedeemed: Int?

    enum CodingKeys: String, CodingKey {
        case myVoucherId = "id"
        case orderID = "order_id"
        case credits, status
        case targetAmount = "target_amount"
        case offsetAmount = "offset_amount"
        case offsetYipps = "offset_yipps"
        case targetCurrency = "target_currency"
        case offsetCurrency = "offset_currency"
        case provider, phone, cardname
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case type
        case orderNo = "order_no"
        case paymentMethod = "payment_method"
        case billReference = "bill_reference"
        case quantity
        case failedReason = "failed_reason"
        case expiryDate = "expiry_date"
        case activationTokenURL = "activation_token_url"
        case softpins
        case displayStatus = "display_status"
        case expiringSoon = "expiring_soon"
        case expired
        case description
        case descriptionLong = "description_long"
        case isRedeemed = "is_redeemed"
    }
}

// MARK: - MyVoucherProvider
struct MyVoucherProvider: Codable {
    let id: Int?
    let gatewayId: Int?
    let name, introduction, description: String?
    let descriptionLong: String?
    let accountType: String?
    let imageURL, logoURL: [String]?
    let videoURL, type, transactionFee, transactionPercentage: String?
    let redemptionOnlineInstruction, redemptionInstoreInstruction, cardTerms: String?
    let sortOrder, isActive: Int?
    let createdAt, updatedAt, deletedAt, country, serviceCountry: String?
    let categoryId: Int?
    let channel: String?
    let channelRefId : String?
    let offsetPercentage, rebatePercentage: String?
    let package: MyVoucherPackage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case gatewayId = "gateway_id"
        case name, introduction, description
        case descriptionLong = "description_long"
        case accountType = "account_type"
        case imageURL = "image_url"
        case logoURL = "logo_url"
        case videoURL = "video_url"
        case type
        case transactionFee = "transaction_fee"
        case transactionPercentage = "transaction_percentage"
        case redemptionOnlineInstruction = "redemption_online_instruction"
        case redemptionInstoreInstruction = "redemption_instore_instruction"
        case cardTerms = "card_terms"
        case sortOrder = "sort_order"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case country
        case serviceCountry = "service_country"
        case categoryId = "category_id"
        case channel
        case channelRefId = "channel_ref_id"
        case offsetPercentage = "offset_percentage"
        case rebatePercentage = "rebate_percentage"
        case package
    }
}

// MARK: - MyVoucherPackage
struct MyVoucherPackage: Codable {
    let id, providerID: Int?
    let gatewayID: Int?
    let price, title, description, descriptiveName: String?
    let validity: Int?
    let imageURL: String?
    let sortOrder: Int?
    let createdAt, updatedAt, deletedAt: String?
    let productID, minAmount, maxAmount, currency: String?
    let accountType: [String]?
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
        case accountType = "account_type"
        case offsetAmount = "offset_amount"
        case offsetYipps = "offset_yipps"
        case offsetPercentage = "offset_percentage"
        case rebatePercentage = "rebate_percentage"
        case maxQuantity = "max_quantity"
    }
}

enum ProviderType: String, Codable {
    case prepaid = "prepaid"
    case softpins = "softpins"
    case utilities = "utilities"
    case voucher = "voucher"
}

struct MyVoucherExpiredRequest: RequestType {
    typealias ResponseType = [MyVoucherModel]
    
    let after: Int
    let limit: Int
    let expired: Int
    
    var data: YPRequestData {
        let path = "/wallet/api/partner/panda/purchase/history?my_voucher=1after=\(after)&limit=\(limit)&expired=\(expired)"
        return YPRequestData(path: path, method: .get, params: nil)
    }
}

struct VoucherSearchRequest: RequestType {
    typealias ResponseType = VoucherSearchResponse
    
    let countryCode: String
    let keyword: String
    
    var data: YPRequestData {
        let path = "/wallet/api/partner/panda/providers/search?country_code=\(countryCode)&keyword=\(keyword)"
        return YPRequestData(path: path, method: .get, params: nil)
    }
}

// MARK: - VoucherSearchResponse
struct VoucherSearchResponse: Codable {
    let data: [VoucherSearchData]?
    let count: Int?
}

// MARK: - VoucherSearchData
struct VoucherSearchData: Codable {
    let id, gatewayID: Int?
    let name, description, descriptionLong: String?
    let accountType: String?
    let imageURL, logoURL: [String]?
    let videoURL: String?
    let type: String?
    let transactionFee: String?
    let redemptionOnlineInstruction, redemptionInstoreInstruction, cardTerms: String?
    let sortOrder, isActive: Int?
    let createdAt, updatedAt: String?
    let deletedAt: String?
    let country: String?
    let categoryID: Int?
    let packages: [VoucherSearchPackage]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case gatewayID = "gateway_id"
        case name, description
        case descriptionLong = "description_long"
        case accountType = "account_type"
        case imageURL = "image_url"
        case logoURL = "logo_url"
        case videoURL = "video_url"
        case type
        case transactionFee = "transaction_fee"
        case redemptionOnlineInstruction = "redemption_online_instruction"
        case redemptionInstoreInstruction = "redemption_instore_instruction"
        case cardTerms = "card_terms"
        case sortOrder = "sort_order"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case country
        case categoryID = "category_id"
        case packages
    }
}

// MARK: - VoucherSearchPackage
struct VoucherSearchPackage: Codable {
    let id, providerID, gatewayID: Int?
    let price: String?
    let title, description, descriptiveName: String?
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

class VoucherBannerContent {
    var type: VoucherBannerType
    var url: String?
    
    init(type: VoucherBannerType = .image, url: String?) {
        self.type = type
        self.url = url
    }
}

class RedeemVoucherModel {
    var index: Int
    var content: [RedeemVoucherContent]
    
    init(index: Int, content: [RedeemVoucherContent]) {
        self.index = index
        self.content = content
    }
}

class RedeemVoucherContent {
    var title: String?
    var content: String?
    
    init(title: String?, content: String?) {
        self.title = title
        self.content = content
    }
}

struct VoucherRandomSearch: RequestType {
    typealias ResponseType = VoucherSearchResponse
    
    let countryCode: String
    let keyword: String
    let feedSearch: Int
    
    var data: YPRequestData {
        var path: String = ""
        if feedSearch == 1 {
            path = "/wallet/api/partner/panda/providers/search?country_code=\(countryCode)&feed_search=\(feedSearch)"
        } else {
            path = "/wallet/api/partner/panda/providers/search?country_code=\(countryCode)&feed_search=\(feedSearch)&keyword=\(keyword)"
        }
        return YPRequestData(path: path, method: .get, params: nil)
    }
}

struct PandaHistoriesVoucherRequest: RequestType {
    typealias ResponseType = [MyVoucherModel]
    
    let serviceTransId: Int
    
    var data: YPRequestData {
        let path = "/wallet/api/partner/panda/purchase/history?id=\(serviceTransId)&my_voucher=1"
        return YPRequestData(path: path, method: .get, params: nil)
    }
}

struct VoucherMarkAsRedeemRequest: RequestType {
    typealias ResponseType = MarkAsRedeemResponse
    
    let id: Int

    var data: YPRequestData {
        let path = "/wallet/api/partner/panda/voucher/update-redeemed"
        return YPRequestData(path: path, method: .post, params: ["id": id])
    }
}

// MARK: - MarkAsRedeemResponse
struct MarkAsRedeemResponse: Codable {
    let id: Int?

    // Coding keys to map JSON keys to Swift properties
    private enum CodingKeys: String, CodingKey {
        case id
    }
}
