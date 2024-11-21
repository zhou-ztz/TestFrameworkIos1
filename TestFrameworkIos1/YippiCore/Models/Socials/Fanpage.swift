// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

//public struct FanpageResponse: Decodable {
//    public let response: FPResponse
//}
//
//public struct FPResponse: Decodable {
//    public let fanpageOwners: [FanpageOwner]
//    
//    enum CodingKeys: String, CodingKey {
//        case fanpageOwners = "fanpage_owners"
//    }
//}
//
//public struct FanpageOwner: Decodable {
//    public let userID: Int
//    public let username, displayname, creationDate: String
//    public let friendCount: Int
//    public let profilePhoto: String
//    public let photoID: Int
//    public let fanpageVerified: Int
//    public let followButton: FollowButton
//    
//    public var isFollowing: Bool {
//        return followButton.name == "remove_follow"
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case userID = "user_id"
//        case username, displayname
//        case creationDate = "creation_date"
//        case friendCount = "friend_count"
//        case profilePhoto = "profile_photo"
//        case photoID = "photo_id"
//        case fanpageVerified = "fanpage_verified"
//        case followButton = "follow_button"
//    }
//}
//
//public struct FollowButton: Codable {
//    public let label, name, url: String
//    public let urlParams: URLParams
//}
//
//public struct URLParams: Codable {
//    public let userID: Int
//    
//    enum CodingKeys: String, CodingKey {
//        case userID = "user_id"
//    }
//}
//
//public struct FollowResponse: Decodable {
//    public let statusCode: Int
//    
//    enum CodingKeys: String, CodingKey {
//        case statusCode = "status_code"
//    }
//}
