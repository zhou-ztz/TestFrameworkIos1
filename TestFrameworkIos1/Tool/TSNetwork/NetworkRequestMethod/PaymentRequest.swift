//
//  MerchantPaymentRequest.swift
//  Yippi
//
//  Created by Wong Jin Lun on 29/11/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation


struct MerchantInfoRequest: RequestType {
    
    typealias ResponseType = MerchantInfoResponse

    let branchHashId: String
   
    var data: YPRequestData {
        return YPRequestData(path: "/wallet/api/merchant/payment/merchant-info?branch_hash_id=\(branchHashId)", method: .get, params: nil)
    }
}

struct MerchantInfoResponse {
    let branchName, branchID, merchantRebate, offsetPercentage: String?
    let country: String?
    let currencyCode: String?
    let merchantID: Int?
    let merchantName: String?
    let merchantImage: String?
    var minAmount: Float? = 5.0

    enum MerchantInfoResponseCodingKeys: String, CodingKey {
        case branchName = "branch_name"
        case branchID = "branch_id"
        case merchantRebate = "merchant_rebate"
        case country
        case currencyCode = "currency_code"
        case merchantID = "merchant_id"
        case merchantName = "merchant_name"
        case merchantImage = "merchant_image"
        case minAmount = "min_amount"
        case offsetPercentage = "offset_percentage"
    }
    
}

extension MerchantInfoResponse: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: MerchantInfoResponseCodingKeys.self)
        do {
            let intMinAmount = try values.decode(Int.self, forKey: .minAmount)
            minAmount = Float(intMinAmount)
        } catch {
            do {
                let floatMinAmount = try try values.decode(Float.self, forKey: .minAmount)
                minAmount = floatMinAmount
            } catch DecodingError.typeMismatch {
               //throw DecodingError.typeMismatch(MetadataType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
            }
        }
        
        branchName = try? values.decode(String.self, forKey: .branchName)
        branchID = try values.decode(String.self, forKey: .branchID)
        merchantRebate = try? values.decode(String.self, forKey: .merchantRebate)
        country = try? values.decode(String.self, forKey: .country)
        currencyCode = try? values.decode(String.self, forKey: .currencyCode)
        merchantID = try values.decode(Int.self, forKey: .merchantID)
        merchantName = try? values.decode(String.self, forKey: .merchantName)
        merchantImage = try? values.decode(String.self, forKey: .merchantImage)
        offsetPercentage = try? values.decode(String.self, forKey: .offsetPercentage)
    }
}

public enum MinAmount: Codable {
    case int(Int)
    case float(Float)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = try .int(container.decode(Int.self))
        } catch DecodingError.typeMismatch {
            do {
                self = try .float(container.decode(Float.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(MetadataType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let int):
            try container.encode(int)
        case .float(let float):
            try container.encode(float)
        }
    }
}

public enum OffsetPercentage: Codable {
    case int(Int)
    case string(Float)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = try .int(container.decode(Int.self))
        } catch DecodingError.typeMismatch {
            do {
                self = try .string(container.decode(Float.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(MetadataType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let int):
            try container.encode(int)
        case .string(let string):
            try container.encode(string)
        }
    }
}

struct PaymentMethodRequest: RequestType {
    
    typealias ResponseType = [PaymentMethodResponse]
    
    let countryCode: String
    
    var data: YPRequestData {
        let typeParam = countryCode == "CN" ? "&type=voucher" : ""
        let path = "/wallet/api/merchant/payment/payment-method?country=\(countryCode)\(typeParam)"
        return YPRequestData(path: path, method: .get, params: nil)
    }
}


// MARK: - PaymentMethodResponse
struct PaymentMethodResponse: Codable {
    let image: String
    let value, channelID: String
    let label: String

    enum CodingKeys: String, CodingKey {
        case image, value
        case channelID = "channel_id"
        case label = "label"
    }
}

// MARK: - PaymentMethodAliPayResponse
struct PaymentMethodAliPayResponse: Codable {
    let orderStr: String?

    enum CodingKeys: String, CodingKey {
        case orderStr = "orderstr"
    }
}

struct OffsetSummaryRequest: RequestType {
    
    typealias ResponseType = OffsetSummaryResponse

    let branchHashId: String
    let amount: Double
   
    var data: YPRequestData {
        return YPRequestData(path: "/wallet/api/merchant/payment/offset-summary?branch_hash_id=\(branchHashId)&amount=\(amount)", method: .get, params: nil)
    }
}

struct OffsetSummaryResponse: Codable {
    let amount, offsetAmount, offsetPoints: Double
    let offsetPercentage: Double
    let conversionRate: Double
    let payAmount: Double
    let remainingPointsBalance: Double
    let currencyCode: String
    let currentPointsBalance: Double

    enum CodingKeys: String, CodingKey {
        case amount
        case offsetAmount = "offset_amount"
        case offsetPoints = "offset_points"
        case offsetPercentage = "offset_percentage"
        case conversionRate = "conversion_rate"
        case payAmount = "pay_amount"
        case remainingPointsBalance = "remaining_points_balance"
        case currencyCode = "currency_code"
        case currentPointsBalance = "current_points_balance"
    }
}

struct PandaOffsetSummaryRequest: RequestType {
    
    typealias ResponseType = PandaOffsetSummaryResponse

    let type: String
    let amount: Double
   
    var data: YPRequestData {
        return YPRequestData(path: "/wallet/api/merchant/payment/offset-summary?type=\(type)&amount=\(amount)", method: .get, params: nil)
    }
}

// MARK: - PandaOffsetSummaryResponse
struct PandaOffsetSummaryResponse {
    var amount: Float? = 0.0
    let offsetAmount, offsetPoints: Double
    let offsetPercentage: Int
    let conversionRate, payAmount, remainingPointsBalance: Double
    let currencyCode: String
    let currentPointsBalance: Double

    enum PandaOffsetSummaryResponseCodingKeys: String, CodingKey {
        case amount
        case offsetAmount = "offset_amount"
        case offsetPoints = "offset_points"
        case offsetPercentage = "offset_percentage"
        case conversionRate = "conversion_rate"
        case payAmount = "pay_amount"
        case remainingPointsBalance = "remaining_points_balance"
        case currencyCode = "currency_code"
        case currentPointsBalance = "current_points_balance"
    }
}

extension PandaOffsetSummaryResponse: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: PandaOffsetSummaryResponseCodingKeys.self)
        do {
            let intAmount = try values.decode(Int.self, forKey: .amount)
            amount = Float(intAmount)
        } catch {
            do {
                let floatAmount = try try values.decode(Float.self, forKey: .amount)
                amount = floatAmount
            } catch DecodingError.typeMismatch {
                //throw DecodingError.typeMismatch(MetadataType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
            }
        }
        
        offsetAmount = try values.decode(Double.self, forKey: .offsetAmount)
        offsetPoints = try values.decode(Double.self, forKey: .offsetPoints)
        offsetPercentage = try values.decode(Int.self, forKey: .offsetPercentage)
        conversionRate = try values.decode(Double.self, forKey: .conversionRate)
        payAmount = try values.decode(Double.self, forKey: .payAmount)
        remainingPointsBalance = try values.decode(Double.self, forKey: .remainingPointsBalance)
        currencyCode = try values.decode(String.self, forKey: .currencyCode)
        currentPointsBalance = try values.decode(Double.self, forKey: .currentPointsBalance)
    }
    
}

struct CreatePaymentRequest: RequestType {
    
    typealias ResponseType = PaymentMethodResponse
    
    let branchHashId: String
    let amount: Double
    let paymentChannelId: String
    let paymentType: String
    let remark: String
    let pin: String
    let isOffset: String
    let provideroOrderNo: String
    let offsetRate: Double

    var data: YPRequestData {
        return YPRequestData(path: "/wallet/api/merchant/payment", method: .post, params: ["branch_hash_id": branchHashId, "amount": amount, "pay_channel_id": paymentChannelId, "pay_type": paymentType, "remark": remark, "pin": pin, "is_offset": isOffset, "provider_order_no": provideroOrderNo, "offset_rate": offsetRate])
    }
}


struct PaymentHistoriesRequest: RequestType {
    
    typealias ResponseType = PaymentHistoriesResponse
    
    let trxId: String

    var data: YPRequestData {
        return YPRequestData(path: "/wallet/api/merchant/payment/histories?trx_id=\(trxId)", method: .get, params: nil)
    }
}

// MARK: - PaymentHistoriesResponse
struct PaymentHistoriesResponse: Codable {
    let balance: HistoryBalance
    let transaction: [HistoryTransaction]
}

// MARK: - HistoryBalance
struct HistoryBalance: Codable {
    let ownerID, type: Int?
    let sum, createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case ownerID = "owner_id"
        case type, sum
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - HistoryTransaction
struct HistoryTransaction: Codable {
    let id: Int?
    let body: String?
    let targetUser, orderID: Int?
    let transactionDate, targetType: String?
    let status: Int?
    let merchantName, title, currency, amount: String?
    let type: Int?
    let offsetPercentage, offsetAmount, offsetPoints, paymentMethod: String?
    let payAmount: String?
    let remark: String?
    let createdAt, statusLabel: String?
    let deepLink: String?
    let showDetail: Int?
    let extras: HistoryExtras?
    let rewardPointsEarn: String?

    enum CodingKeys: String, CodingKey {
        case id, body
        case targetUser = "target_user"
        case orderID = "order_id"
        case transactionDate = "transaction_date"
        case targetType = "target_type"
        case status
        case merchantName = "merchant_name"
        case title, currency, amount, type
        case offsetPercentage = "offset_percentage"
        case offsetAmount = "offset_amount"
        case offsetPoints = "offset_points"
        case paymentMethod = "payment_method"
        case payAmount = "pay_amount"
        case remark
        case createdAt = "created_at"
        case statusLabel = "status_label"
        case deepLink = "deep_link"
        case showDetail = "show_detail"
        case extras
        case rewardPointsEarn = "reward_points_earn"
    }
}

// MARK: - HistoryExtras
struct HistoryExtras: Codable {
    let type: String?
    let phoneNo: String?
    let accountNo: String?
    let package: String?
    let provider: String?
    let quantity: Int?
    let billReference: String?
    let status: String?
    let failedReason: String?
    let serviceTransactionId: Int?
    let providerId: Int?
    let providerImage: [String]?
    let packagePrice: String?
    let statusCode: Int?
    let providerType: String?
    
    let softpins: [Softpin]?
    let topup: [Topup]?
    let utilities: [Utility]?
    
    enum CodingKeys: String, CodingKey {
        case phoneNo = "phone_no"
        case accountNo = "account_no"
        case billReference = "bill_reference"
        case package, provider, quantity, status, type, softpins, topup, utilities
        case failedReason = "failed_reason"
        case serviceTransactionId = "service_transaction_id"
        case providerId = "provider_id"
        case providerImage = "provider_image"
        case packagePrice = "package_price"
        case statusCode = "status_code"
        case providerType = "provider_type"
    }
}

// MARK: - Softpin
struct Softpin: Codable {
    let orderDate, dealerNumber, referenceID, topupCode: String?
    let topupSerial, topupExpiry, denomName2, topupCode2: String?
    let topupSerial2, voucherLink: String?
    let amount: String?
    let payeeCode: String?
    
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
        case amount = "Amount"
        case payeeCode = "PayeeCode"
    }
}

// MARK: - Topup
struct Topup: Codable {
    let dealerNumber, id, time, amount: String?
    let number, status, status2, topupOperator: String?
    let operatorCode, denomName, denomType, processed: String?
    let reference, errorMessage: String?
    let isInternational: Bool?

    enum CodingKeys: String, CodingKey {
        case dealerNumber = "DealerNumber"
        case id = "ID"
        case time = "Time"
        case amount = "Amount"
        case number = "Number"
        case status = "Status"
        case status2 = "Status2"
        case topupOperator = "Operator"
        case operatorCode = "OperatorCode"
        case denomName = "DenomName"
        case denomType = "DenomType"
        case processed = "Processed"
        case reference = "Reference"
        case errorMessage = "ErrorMessage"
        case isInternational = "IsInternational"
    }
}

// MARK: - Utility
struct Utility: Codable {
    let billID, time, amount, reference: String?
    let reference1, reference2, status, notifyNumber: String?
    let dealerNumber, payeeCode, payeeName, remark: String?
    let reason: String?
    let image: String?
    let processed: String?

    enum CodingKeys: String, CodingKey {
        case billID = "BillID"
        case time = "Time"
        case amount = "Amount"
        case reference = "Reference"
        case reference1 = "Reference1"
        case reference2 = "Reference2"
        case status = "Status"
        case notifyNumber = "NotifyNumber"
        case dealerNumber = "DealerNumber"
        case payeeCode = "PayeeCode"
        case payeeName = "PayeeName"
        case remark = "Remark"
        case reason = "Reason"
        case image = "Image"
        case processed = "Processed"
    }
}

struct VoucherOffsetSummaryRequest: RequestType {
    
    typealias ResponseType = VoucherOffsetSummaryResponse

    let branchHashId: String
    let amount: Double
    let flexibleOffset: String
    let flexibleOffsetPoint: Double
    let type: String
    let quantity: String
    let productId: String
    let isOffset: String
    
    var data: YPRequestData {
        return YPRequestData(path: "/wallet/api/merchant/payment/offset-summary?branch_hash_id=\(branchHashId)&amount=\(amount)&flexible_offset=\(flexibleOffset)&flexible_offset_point=\(flexibleOffsetPoint)&type=\(type)&qty=\(quantity)&product_id=\(productId)&is_offset=\(isOffset)", method: .get, params: nil)
    }
}

struct VoucherOffsetSummaryResponse: Codable {
    let amount, offsetAmount, offsetPoints: Double
    let offsetPercentage: Double
    let conversionRate: Double
    let payAmount: Double
    let remainingPointsBalance: Double
    let currencyCode: String
    let currentPointsBalance: Double
    let minOffsetPoint, maxOffsetPoint: Double?
    let serviceFee: Double
    
    enum CodingKeys: String, CodingKey {
        case amount
        case offsetAmount = "offset_amount"
        case offsetPoints = "offset_points"
        case offsetPercentage = "offset_percentage"
        case conversionRate = "conversion_rate"
        case payAmount = "pay_amount"
        case remainingPointsBalance = "remaining_points_balance"
        case currencyCode = "currency_code"
        case currentPointsBalance = "current_points_balance"
        case minOffsetPoint = "min_offset_point"
        case maxOffsetPoint = "max_offset_point"
        case serviceFee = "service_fee"
    }
}

struct AlipaySDKCheckRequest: RequestType {
    
    typealias ResponseType = AlipaySDKCheckResponse

    let type: String
  
    var data: YPRequestData {
        return YPRequestData(path: "/wallet/api/payment/check/alipay-sdk?type=\(type)", method: .get, params: nil)
    }
}

struct AlipaySDKCheckResponse: Codable {
    
    //结果返回true代表支持支付宝sdk; false代表不支持支付宝SDK
    let isAlipaySDKSupported: Bool
    
    enum CodingKeys: String, CodingKey {
    
        case isAlipaySDKSupported = "alipay-sdk"
    }
}
