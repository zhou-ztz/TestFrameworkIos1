//
//  SocialTokenPurchase.swift
//  Yippi
//
//  Created by Jerry Ng on 07/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation


struct SocialTokenPurchaseRequestType: RequestType {
    typealias ResponseType = SocialTokenPurchaseModel.Data
    
    var packageId: Int
    var pin: String
    
    var data: YPRequestData {
        return YPRequestData(
            path: "/api/v2/token-redeem/purchase",
            method: .post, params: [
                    "package_id": packageId.stringValue,
                    "pin": pin
            ])
    }
}

struct SocialTokenPurchaseModel : Codable {

    struct Data : Codable {

        let balances: [SocialTokenBalanceModel.Data]
        let redeemTokenQuantity : String
        let transactionId : String
        let redeemTime : Date

        enum CodingKeys: String, CodingKey {
            case balances = "balances"
            case redeemTokenQuantity = "redeem_token_quantity"
            case transactionId = "transaction_id"
            case redeemTime = "redeem_time"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            balances = try (values.decodeIfPresent([SocialTokenBalanceModel.Data].self, forKey: .balances) ?? [])
            redeemTokenQuantity = try (values.decodeIfPresent(String.self, forKey: .redeemTokenQuantity) ?? "0")
            transactionId = try (values.decodeIfPresent(String.self, forKey: .transactionId) ?? "0")
            redeemTime = SocialTokenPurchaseModel.Data.parseDate(values, forKey: .redeemTime) ?? Date()
        }

        private static func parseDate(_ container: KeyedDecodingContainer<CodingKeys>, forKey: KeyedDecodingContainer<CodingKeys>.Key) -> Date? {
            if !container.contains(forKey) {
                return nil
            }
            
            do {
                if try container.decodeNil(forKey: forKey) {
                    return nil
                }
            } catch {
                return nil
            }
            
            if let dateValue = try? container.decode(Date.self, forKey: forKey) {
                return dateValue
            } else if let stringValue = try? container.decode(String.self, forKey: forKey) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                return dateFormatter.date(from: stringValue)
            }
            
            return nil
        }
    }
}
