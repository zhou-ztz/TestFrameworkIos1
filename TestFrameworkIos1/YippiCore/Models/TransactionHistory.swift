// 
// Copyright © 2018 Toga Capital. All rights reserved.
//

import UIKit

public struct TransactionHistory: Decodable {
    public let history: [HistoryModel]
    public let username: String
}

public struct HistoryModel: Decodable {
    public let created: String
    public let type: String
    public let amount: String
    public let description: String
    public let balance: String
    
    public var amountValue: String {
        return "\(type.uppercased() == "IN" ? "+" : "-") \(amount)"
    }
    
    public var textColor: UIColor {
        return type.uppercased() == "IN" ? UIColor(red: 0, green: 138, blue: 14) : UIColor(red: 255, green: 51, blue: 76)
    }
}

public struct WalletBalance: Decodable {
    public let uid, username, phone: String
    public let tc, tp, yPoint, yipps, cPoint: Float
    public let numOfWallet: Int

    enum CodingKeys: String, CodingKey {
        case uid, username, phone
        case numOfWallet = "num_of_wallet"
        case tc = "TC"
        case tp = "TP"
        case yPoint = "Y-Point"
        case yipps = "Yipps"
        case cPoint = "CPoint"
    }
    
    private static func parseFloat(_ container: KeyedDecodingContainer<CodingKeys>, forKey: KeyedDecodingContainer<CodingKeys>.Key) -> Float? {
        if let floatValue = try? container.decode(Float.self, forKey: forKey) {
            return floatValue
        } else if let stringValue = try? container.decode(String.self, forKey: forKey) {
            return Float(stringValue)
        }
        
        return nil
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        username = try container.decode(String.self, forKey: .username)
        phone = try container.decode(String.self, forKey: .phone)
        tc = WalletBalance.parseFloat(container, forKey: .tc) ?? 0
        tp = WalletBalance.parseFloat(container, forKey: .tp) ?? 0
        yPoint = WalletBalance.parseFloat(container, forKey: .yPoint) ?? 0
        yipps = WalletBalance.parseFloat(container, forKey: .yipps) ?? 0
        cPoint = WalletBalance.parseFloat(container, forKey: .cPoint) ?? 0
        numOfWallet = try container.decode(Int.self, forKey: .numOfWallet)
    }
}
