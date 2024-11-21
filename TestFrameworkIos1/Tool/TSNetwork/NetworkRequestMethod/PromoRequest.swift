//
//  PromoRequest.swift
//  RewardsLink
//
//  Created by Kit Foong on 29/08/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation

import SwiftyJSON

class RedeemPromoModel {
    var title: String
    var desc: String
    
    init(title: String, desc: String) {
        self.title = title
        self.desc = desc
    }
}

enum PromoDetailType {
    case rewardPoints, voucher, both, none
}

class PromoDetailModel {
    var rewardsPoints: PromoRewardPoints?
    var voucher: PromoVoucher?
    var type: PromoDetailType
    
    init(rewardsPoints: PromoRewardPoints? = nil, voucher: PromoVoucher? = nil, type: PromoDetailType) {
        self.rewardsPoints = rewardsPoints
        self.voucher = voucher
        self.type = type
    }
}

struct RedeemPromoRequest: RequestType {
    typealias ResponseType = RedeemPromoResponse
    
    let promoCode: String
    
    var data: YPRequestData {
        return YPRequestData(path: "/wallet/api/promo-code/redeem", method: .post, params: ["code": promoCode])
    }
}

struct RedeemPromoResponse: Codable {
    let rewardPoints: [PromoRewardPoints]?
    let vouchers: [PromoVoucher]?
    
    enum CodingKeys: String, CodingKey {
        case rewardPoints = "reward_points"
        case vouchers
    }
}

struct PromoRewardPoints: Codable {
    let id, ownerId: Int?
    let title, body: String?
    let type: Int?
    let targetType, targetId: String
    let currency: Int?
    let amount: String?
    let state: Int?
    let createdAt, updatedAt: String?
    let redpacketId: String?
    let amountRemaining: String?
    let quantity, isRandomAmount, quantityRemaining: Int?
    let groupId: String?
    let isRefund, stickerBundleId, referId, platform: Int?
    let topupRefId, liveEggStartTime, liveEggEndTime: String?
    let feedId: Int?
    let channel: String?

    enum CodingKeys: String, CodingKey {
        case id
        case ownerId = "owner_id"
        case title, body, type
        case targetType = "target_type"
        case targetId = "target_id"
        case currency, amount, state
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case redpacketId = "redpacket_id"
        case amountRemaining = "amount_remaining"
        case quantity
        case isRandomAmount = "is_random_amount"
        case quantityRemaining = "quantity_remaining"
        case groupId = "group_id"
        case isRefund = "is_refund"
        case stickerBundleId = "sticker_bundle_id"
        case referId = "refer_id"
        case platform
        case topupRefId = "topup_ref_id"
        case liveEggStartTime = "live_egg_start_time"
        case liveEggEndTime = "live_egg_end_time"
        case feedId = "feed_id"
        case channel
    }
}

struct PromoVoucher: Codable {
    let id, providerId, packageId: Int?
    let amount: String?
    let softpins: [Softpin]
    let displayStatus: String?
    let expiringSoon, expired: Int?
    let productImage: [String]
    let provider: MyVoucherProvider?
    let package: MyVoucherPackage?

    enum CodingKeys: String, CodingKey {
        case id
        case providerId = "provider_id"
        case packageId = "package_id"
        case amount
        case softpins
        case displayStatus = "display_status"
        case expiringSoon = "expiring_soon"
        case expired
        case productImage = "product_image"
        case provider
        case package
    }
}

struct PromoHistoryRequest: RequestType {
    typealias ResponseType = [PromoHistory]
        
    let after: Int
    let limit: Int
    
    var data: YPRequestData {
        return YPRequestData(path: "/wallet/api/promo-code/history?limit=\(limit)&after=\(after)", method: .get)
    }
}

struct PromoHistory: Codable {
    let id, userId, promoCodeId, currencyOrderId: Int?
    let pandaPurchaseIds, createdAt, updatedAt, deletedAt: String?
    let promoCode: PromoCode?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case promoCodeId = "promo_code_id"
        case currencyOrderId = "currency_order_id"
        case pandaPurchaseIds = "panda_purchase_ids"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case promoCode = "promo_code"
    }
}

struct PromoCode: Codable {
    let id: Int?
    let code: String?
    let isActive: Int?
    let rewardsPackage: String?
    let quantity: Int?
    let startDate, endDate: String?
    let title, message: String?
    let createdAt, updatedAt, deletedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, code
        case isActive = "is_active"
        case rewardsPackage = "rewards_package"
        case quantity
        case startDate = "start_date"
        case endDate = "end_date"
        case title, message
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct PromoDetailRequest: RequestType {
    typealias ResponseType = RedeemPromoResponse
        
    let promoCodeId: Int
    
    var data: YPRequestData {
        return YPRequestData(path: "/wallet/api/promo-code/history?id=\(promoCodeId)", method: .get)
    }
}



