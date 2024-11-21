// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import UIKit

struct GetFeeds: APIRequest {
    typealias Response = FeedResponse
    
    var resourceName: String {
        return "rest/advancedactivity/feeds"
    }
    
    var requestMethod: RequestMethod {
        return .get
    }
    
    let getImageDimention: Bool
    let limit: Int
    let feedFilter: Int
    let objectInfo: Int
    let filterType: String?
    
    init(limit: Int,
         getImageDimention: Bool,
         feedFilter: Int,
         objectInfo: Int,
         filterType: String? = nil) {
        
        self.getImageDimention = getImageDimention
        self.limit = limit
        self.feedFilter = feedFilter
        self.objectInfo = objectInfo
        self.filterType = filterType
    }
    
    enum CodingKeys: String, CodingKey {
        case feedFilter = "feed_filter"
        case objectInfo = "object_info"
        case getImageDimention = "getAttachedImageDimention"
        case limit
        case filterType = "filter_type"
    }
    
}

struct GetVideos: APIRequest {
    typealias Response = SocialVideoResponse
    
    var resourceName: String {
        return "rest/advancedvideos/browse"
    }
    
    var requestMethod: RequestMethod {
        return .get
    }
    
    let limit: Int
    let page: Int
    let orderby: String
    
    init(limit: Int, page: Int, orderby: String) {
        self.limit = limit
        self.page = page
        self.orderby = orderby
    }
}

enum FanPageUserType: String {
    case all
    case official
}

// struct GetFanPage: APIRequest {
//     typealias Response = FanpageResponse
//    
//     var resourceName: String {
//        return "rest/user/fanpage"
//    }
//    
//     var requestMethod: RequestMethod {
//        return .get
//    }
//    
//     let userType: String
//    
//     init(userType: FanPageUserType) {
//        self.userType = userType.rawValue
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case userType = "user_type"
//    }
//}

struct ShareStickerToSocial: APIRequest {
    typealias Response = Int
    
    var resourceName: String {
        return "rest/advancedactivity/feeds/post"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let type: String
    let stickerId: String
    
    init(type: String,
         stickerId: String) {
        self.type = type
        self.stickerId = stickerId
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case stickerId = "sticker_id"
    }
}


// struct FollowOfficialPage: APIRequest {
//     typealias Response = FollowResponse
//     var resourceName: String {
//        return "rest/user/add"
//    }
//     var requestMethod: RequestMethod {
//        return .post
//    }
//     let userId: Int
//    
//     init(userId: Int) {
//        self.userId = userId
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case userId = "user_id"
//    }
//}
//
// struct UnfollowOfficialPage: APIRequest {
//     typealias Response = FollowResponse
//     var resourceName: String {
//        return "rest/user/remove"
//    }
//     var requestMethod: RequestMethod {
//        return .post
//    }
//     let userId: Int
//    
//     init(userId: Int) {
//        self.userId = userId
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case userId = "user_id"
//    }
//}
