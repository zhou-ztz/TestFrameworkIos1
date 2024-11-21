// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

public struct Package: Codable {
    public let id, uid: String?
    public let code, packageID: String
    public let trialID: String?
    public let periodDay: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, uid
        case packageID = "package_id"
        case code
        case trialID = "trial_id"
        case periodDay = "period_day"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        uid = try values.decodeIfPresent(String.self, forKey: .uid)
        packageID = try values.decode(String.self, forKey: .packageID)
        code = Package.parseInt(values, forKey: .code) ?? "0"
        trialID = try values.decodeIfPresent(String.self, forKey: .trialID)
        periodDay = try values.decodeIfPresent(Int.self, forKey: .periodDay)
    }
    
    private static func parseInt(_ container: KeyedDecodingContainer<CodingKeys>, forKey: KeyedDecodingContainer<CodingKeys>.Key) -> String? {
        if let intValue = try? container.decode(Int.self, forKey: forKey) {
            return String(intValue)
        } else if let stringValue = try? container.decode(String.self, forKey: forKey) {
            return stringValue
        }
        return nil
    }
}

public struct PeriodDay: Decodable {
    public let periodDay: Int
    
    enum CodingKeys: String, CodingKey {
        case periodDay = "period_day"
    }
}

public struct EostreState: Decodable {
    public let success: Int
    public let memberPackagePin: String?
    public let message: String?
    
    enum CodingKeys: String, CodingKey {
        case memberPackagePin = "member_package_pin"
        case success
        case message
    }
}

public struct EostreTrialCode: Decodable {
    public let code: String
}
