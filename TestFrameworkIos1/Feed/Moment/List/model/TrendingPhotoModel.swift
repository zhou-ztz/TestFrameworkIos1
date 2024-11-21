//
//  TrendingPhotoModel.swift
//  Yippi
//
//  Created by CC Teoh on 26/07/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper
import ObjectBox

enum TrendingPhotoType {
    case discover
    case user(id: Int)
    case hashtag(id: Int)
    
    func toString() -> String {
        switch self {
        case .discover: return "discover"
        case .user(let id): return "user:\(id)"
        case .hashtag(let id): return "hashtag:\(id)"
        }
    }
    
    static func convert(_ object: TrendingPhotoType?) -> String? {
        guard let object = object else { return nil }
        return object.toString()
    }
    
    static func convert(_ json: String?) -> TrendingPhotoType? {
        guard let json = json else { return nil }
        if json.contains("user") {
            let id = json.components(separatedBy: ":").last?.toInt()
            return .user(id: id.orZero)
        } else if json.contains("hashtag") {
            let id = json.components(separatedBy: ":").last?.toInt()
            return .hashtag(id: id.orZero)
        } else {
            return .discover
        }
    }
}

class TrendingPhotoModel: Mappable, Entity {
    var id: Id = 0
    var feedId: Int = 0
    var imageId: Int = 0
    var isVideo: Bool = false
    // objectbox: convert = { "dbType": "String", "converter": "TrendingPhotoType" }
    var type: TrendingPhotoType?
    
    init(){}
    convenience init(feedId: Int, imageId: Int, isVideo: Bool = false) {
        self.init()
        self.feedId = feedId
        self.imageId = imageId
        self.isVideo = isVideo
    }
    required init?(map: Map) { }

    func mapping(map: Map) {
        feedId <- map["feed_id"]
        imageId <- map["images.0.file"]
        isVideo <- map["images.0.is_video"]
    }

    // objectbox: transient
    var imageURL: String? {
        return imageId.imageUrlThumbnail()
    }
}
