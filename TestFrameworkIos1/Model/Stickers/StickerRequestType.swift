//
//  StickerRequestType.swift
//  Yippi
//
//  Created by Khoo on 20/11/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation

struct StickerRequestType: RequestType {
    typealias ResponseType = StickerResponse
    
    let bundleId: String
    
    var data: YPRequestData {
        return YPRequestData(
            path: "/api/v2/stickerTotal/\(bundleId)",
            method: .get,
            params: nil)
    }
}
struct StickerResponse: Codable {
    let data: Item?
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
    struct Item: Codable {
        let bundle_id: String
        let total_downloads, total_tips: Int
        
        enum CodingKeys: String, CodingKey {
            case bundle_id = "bundle_id"
            case total_downloads = "total_downloads"
            case total_tips = "total_tips"
        }
    }
    
    enum TargetType: String, Codable {
        case bundleId = "bundle_id"
        case totalDownlonds = "total_downloads"
        case total_tips = "total_tips"
    }

}


// MARK: - Yippi 6

struct GetLandingPageStickers: RequestType {
    typealias ResponseType = StickerLandingResponse
    
    var data: YPRequestData {
        return YPRequestData(path: "/api/v2/getlandingPageStickers", method: .get, params: nil)
    }
}

struct GetStickerByType: RequestType {
    typealias ResponseType = StickerListModel
    
    let type: StickerType
    let limit: Int
    let offset: Int
    let catId: Int?

    var data: YPRequestData {
        var url: String = ""
        switch type {
        case .featured_category:
            url = "api/v2/getStickerCategories"
        case .hot_stickers:
            url = "/api/v2/getHotStickers"
        case .recomended_artist:
            url = "/api/v2/getRecomendedArtist"
        case .new_artist:
            url = "/api/v2/getNewArtist"
        case .new_sticker:
            url = "/api/v2/getNewSticker"
        case .stickers_of_the_day:
            url = "/api/v2/getStickersOfTheDay"
        case .stickerByCategory:
            url = "/api/v2/getStickerByCategory"
        default:
            fatalError("Others are using another request.")
            break
        }
        
        url.append("?limit=\(limit)&offset=\(offset)")
        
        if let id = catId {
            url.append("&cat_id=\(id)")
        }
        
        return YPRequestData(path: url, method: .get, params: nil)
    }
}
