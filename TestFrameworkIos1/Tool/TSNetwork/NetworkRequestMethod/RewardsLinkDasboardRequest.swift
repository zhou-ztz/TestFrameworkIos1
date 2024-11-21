//
//  RewardsLinkDasboardRequest.swift
//  Yippi
//
//  Created by Wong Jin Lun on 27/10/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation


struct RewardsLinkDasboardRequest: RequestType {
    
    typealias ResponseType = [RewardsLinkDashboardResponse]

    let limit: Int
    let offset: Int
    let type: Int
    let countryCode: String
    
    var data: YPRequestData {
        return YPRequestData(path: "/api/v2/module/rewards-dashboards?type=\(type)&limit=\(limit)&offset=\(offset)&country_code=\(countryCode)", method: .get, params: nil)
        
    }
}
//
//struct RewardsLinkDashboardResponse: Decodable {
//    let id: Int
//    let module: String
//    let status: Bool
//    let version: Int
//    let action: DashboardAction
//    let slug, translationKey: String
//    let imageURL: String
//    let backgroundImageURL, bgColour: String
//    let sort: Int
//
//    enum CodingKeys: String, CodingKey {
//        case id, module, status, version, action, slug
//        case translationKey = "translation_key"
//        case imageURL = "image_url"
//        case backgroundImageURL = "background_image_url"
//        case bgColour = "bg_colour"
//        case sort
//    }
//}
//
//struct DashboardAction: Decodable {
//    let type, extra, authMode: String
//
//    enum CodingKeys: String, CodingKey {
//        case type, extra
//        case authMode = "auth_mode"
//    }
//    
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        type = try values.decode(String.self, forKey: .type)
//        extra = try values.decode(String.self, forKey: .extra)
//        authMode = try values.decode(String.self, forKey: .authMode)
//    }
//}


// MARK: - WelcomeElement
struct RewardsLinkDashboardResponse: Codable {
    let id: Int
    let module: String?
    let status: Bool
    let version: Int
    let action: DashboardAction
    let slug, translationKey: String?
    let imageURL: String?
    let backgroundImageURL, bgColour: String?
    let sort: Int
    let countryCode: String?
    enum CodingKeys: String, CodingKey {
        case id, module, status, version, action, slug
        case translationKey = "translation_key"
        case imageURL = "image_url"
        case backgroundImageURL = "background_image_url"
        case bgColour = "bg_colour"
        case sort
        case countryCode = "country_code"
    }
}

// MARK: - Action
struct DashboardAction: Codable {
    let type: String?
    let extra: String?
    let authMode: String?

    enum CodingKeys: String, CodingKey {
        case type, extra
        case authMode = "auth_mode"
    }
}

