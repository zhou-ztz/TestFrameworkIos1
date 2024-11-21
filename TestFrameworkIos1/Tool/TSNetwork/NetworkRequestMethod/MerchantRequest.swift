//
//  MerchantRequest.swift
//  Yippi
//
//  Created by Wong Jin Lun on 29/10/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation

import ObjectMapper
import SwiftyJSON

struct MerchantRequest: RequestType {
    typealias ResponseType = [MerchantResponse] //[String: Merchant]
    
    let longitude, latitude: String
    let distance: String
    let offset, limit: String
    let countryCode: String
    
    var data: YPRequestData {
        return YPRequestData(path: "/api/v2/user/merchant/home?longitude=\(longitude)&latitude=\(latitude)&distance=\(distance)&offset=\(offset)&limit=\(limit)&countryCode=\(countryCode)", method: .get, params: nil)
    }
}

// MARK: Old Merchant Response
struct MerchantResponse: Codable {
    let sort: String?
    var data: [MerchantData]
    let listPath, title, type, titleLokalise: String?
    //let yippswanted: YippsWanted?
    let dealPath: String?

    enum CodingKeys: String, CodingKey {
        case sort, data
        case listPath = "list_path"
        case title, type
        case titleLokalise = "title_lokalise"
        //case yippswanted
        case dealPath = "deal_path"
    }
}

// MARK: - MerchantData
struct MerchantData: Codable {
    let id: Int?, mechantID: Int?
    let rating, rate, offset: String?
    let cate, merchantName, cateNamekey: String?
    let banners, logo: String?
    let status: String?
    let lat, lng: String?
    let city, province, country: String?
    let countryCode: CountryCode?
    let address1, address2, merchantAddress1, merchantAddress2: String?
    //外部商家List
    let externalMerchantChannels: [String]?
    let isExternalMerchant: Bool?
    var favorite: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case mechantID = "mechantId"
        case rating, rate, offset
        case cate, merchantName, cateNamekey
        case banners, logo
        case status
        case lat, lng
        case city, province, country
        case countryCode
        case address1, address2, merchantAddress1, merchantAddress2
        case externalMerchantChannels
        case isExternalMerchant
        case favorite      
    }
}

// MARK: - YippsWanted
struct YippsWanted: Codable {
    let module: String
    let status: Bool
    let action: YippsAction
    let id: Int
    let slug: String
    let imageURL, backgroundImageURL: String
    let bgColour: String
    let version, sort: Int
    let translationKey: String

    enum CodingKeys: String, CodingKey {
        case module, status, action, id, slug
        case imageURL = "image_url"
        case backgroundImageURL = "background_image_url"
        case bgColour = "bg_colour"
        case version, sort
        case translationKey = "translation_key"
    }
}

// MARK: - YippsAction
struct YippsAction: Codable {
    let type, extra: String
    let authMode: String?

    enum CodingKeys: String, CodingKey {
        case type, extra
        case authMode = "auth_mode"
    }
}

struct MerchantFavouriteRequest: RequestType {
    typealias ResponseType = MerchantFavouriteResponse
    
    let merchantId: String
    
    var data: YPRequestData {
        return YPRequestData(path: "/api/v2/user/merchant/favorite", method: .post, params: ["merchantId": merchantId])
    }
}

struct MerchantFavouriteResponse: Codable {
    let data: MerchantFavouriteData
}

// MARK: - DataClass
struct MerchantFavouriteData: Codable {
    let updatedAt: String
    let id, merchantID, yippiID: Int
    let yippiAccount: String
    let yippsWantedMerchantID: Int
    let yippsWantedBranchID: Int?
    let branchID: String
    let favorite: Bool
    let favoriteAt: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case updatedAt, id
        case merchantID = "merchantId"
        case yippiID = "yippiId"
        case yippiAccount
        case yippsWantedMerchantID = "yippsWantedMerchantId"
        case yippsWantedBranchID = "yippsWantedBranchId"
        case branchID = "branchId"
        case favorite, favoriteAt, createdAt
    }
}

// MARK: - Merchant Request Second Format
struct MerchantRequest2: RequestType {
    typealias ResponseType = MerchantOuterResponse
    
    let countryCode, longitude, latitude: String
    
    var data: YPRequestData {
        return YPRequestData(baseUrl: TSAppConfig.share.environment.bizServerAddress, path: "/api/rewardslink/old/merchant-blocks?countryCode=\(countryCode)&latitude=\(latitude)&longitude=\(longitude)", method: .get, params: nil)
    }
}

// MARK: - Merchant Response
struct MerchantOuterResponse: Codable {
    let data: [MerchantResponse]
}
