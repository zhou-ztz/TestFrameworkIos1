//
//  SocialTokenPackage.swift
//  Yippi
//
//  Created by Jerry Ng on 07/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

struct SocialTokenPackageRequestType: RequestType {
    typealias ResponseType = [SocialTokenPackageModel.Data]
    var data: YPRequestData {
        return YPRequestData(
            path: "/api/v2/token-redeem/packages",
            method: .get, params: nil)
    }
}

struct SocialTokenPackageModel : Codable {

    struct Data : Codable {

        let packageId : Int
        let yipps : String
        let amount : String

        enum CodingKeys: String, CodingKey {
            case packageId = "package_id"
            case yipps = "yipps"
            case amount = "amount"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            packageId = try (values.decodeIfPresent(Int.self, forKey: .packageId) ?? 0)
            yipps = try (values.decodeIfPresent(String.self, forKey: .yipps) ?? "0")
            amount = try (values.decodeIfPresent(String.self, forKey: .amount) ?? "0")
        }

    }
}
