// 
// Copyright © 2018 Toga Capital. All rights reserved.
//

import Foundation

public struct SocialVideoResponse: Decodable {
    public let response: [Video]
    public let canCreate, totalItemCount: Int
    public let filter: Filter
}

public struct Filter: Decodable {
    public let type, name, label: String
    public let multiOptions: MultiOptions
}

public struct MultiOptions: Decodable {
    public let empty, creationDate, modifiedDate, viewCount: String
    public let likeCount, commentCount, rating, favouriteCount: String
    public let featured, bestVideo, bestChannel, sponsored: String
    public let title, titleReverse: String
    
    enum CodingKeys: String, CodingKey {
        case empty = ""
        case creationDate = "creation_date"
        case modifiedDate = "modified_date"
        case viewCount = "view_count"
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case rating
        case favouriteCount = "favourite_count"
        case featured
        case bestVideo = "best_video"
        case bestChannel = "best_channel"
        case sponsored, title
        case titleReverse = "title_reverse"
    }
}

public struct Video: Decodable {
    public let videoID: Int
    public let title, description: String
    public let search: Int
    public let ownerType: String
    public let ownerID: Int
    public let parentType, parentID: String?
    public let creationDate, modifiedDate: String
    public let viewCount, commentCount, type: Int
    public let code: String
    public let categoryID, status: Int
    public let rating: Float
    public let fileID, duration, rotation, mainChannelID: Int
    public let subcategoryID, subsubcategoryID, photoID: Int?
    public let profileType, featured, favouriteCount, sponsored: Int
    public let seaoLocationid: Int
    public let location: String
    public let networksPrivacy: String?
    public let likeCount, synchronized: Int
    public let image, imageNormal, imageProfile, imageIcon: String
    public let contentURL: String
    public let ownerImage, ownerImageNormal, ownerImageProfile, ownerImageIcon: String
    public let ownerTitle: String
    public let allowToView, ratingCount: Int
    public let videoURL: String
    public let isPassword: Int
    public let authView, authComment: String
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        videoID = try container.decode(Int.self, forKey: .videoID)
        search = try container.decode(Int.self, forKey: .search)
        title = try container.decode(String.self, forKey: .title)
        description = Video.parseString(container, forKey: .description)
        ownerType = try container.decode(String.self, forKey: .ownerType)
        ownerID = try container.decode(Int.self, forKey: .ownerID)
        parentType = try container.decodeIfPresent(String.self, forKey: .parentType)
        parentID = try container.decodeIfPresent(String.self, forKey: .parentID)
        creationDate = try container.decode(String.self, forKey: .creationDate)
        modifiedDate = try container.decode(String.self, forKey: .modifiedDate)
        viewCount = try container.decode(Int.self, forKey: .viewCount)
        commentCount = try container.decode(Int.self, forKey: .commentCount)
        type = try container.decode(Int.self, forKey: .type)
        code = try container.decode(String.self, forKey: .code)
        rating = try container.decode(Float.self, forKey: .rating)
        categoryID = try container.decode(Int.self, forKey: .categoryID)
        status = try container.decode(Int.self, forKey: .status)
        fileID = try container.decode(Int.self, forKey: .fileID)
        duration = try container.decode(Int.self, forKey: .duration)
        rotation = try container.decode(Int.self, forKey: .rotation)
        mainChannelID = try container.decode(Int.self, forKey: .mainChannelID)
        subcategoryID = try container.decodeIfPresent(Int.self, forKey: .subcategoryID)
        subsubcategoryID = try container.decodeIfPresent(Int.self, forKey: .subsubcategoryID)
        photoID = try container.decodeIfPresent(Int.self, forKey: .photoID)
        profileType = try container.decode(Int.self, forKey: .profileType)
        featured = try container.decode(Int.self, forKey: .featured)
        favouriteCount = try container.decode(Int.self, forKey: .favouriteCount)
        sponsored = try container.decode(Int.self, forKey: .sponsored)
        seaoLocationid = try container.decode(Int.self, forKey: .seaoLocationid)
        location = try container.decode(String.self, forKey: .location)
        networksPrivacy = try container.decodeIfPresent(String.self, forKey: .networksPrivacy)
        likeCount = try container.decode(Int.self, forKey: .likeCount)
        synchronized = try container.decode(Int.self, forKey: .synchronized)
        image = try container.decode(String.self, forKey: .image)
        imageNormal = try container.decode(String.self, forKey: .imageNormal)
        imageProfile = try container.decode(String.self, forKey: .imageProfile)
        imageIcon = try container.decode(String.self, forKey: .imageIcon)
        contentURL = try container.decode(String.self, forKey: .contentURL)
        ownerImage = try container.decode(String.self, forKey: .ownerImage)
        ownerImageNormal = try container.decode(String.self, forKey: .ownerImageNormal)
        ownerImageProfile = try container.decode(String.self, forKey: .ownerImageProfile)
        ownerImageIcon = try container.decode(String.self, forKey: .ownerImageIcon)
        ownerTitle = Video.parseString(container, forKey: .ownerTitle)
        allowToView = try container.decode(Int.self, forKey: .allowToView)
        ratingCount = try container.decode(Int.self, forKey: .ratingCount)
        isPassword = try container.decode(Int.self, forKey: .isPassword)
        videoURL = try container.decode(String.self, forKey: .videoURL)
        authView = try container.decode(String.self, forKey: .authView)
        authComment = try container.decode(String.self, forKey: .authComment)
    }
    
    private static func parseString(_ container: KeyedDecodingContainer<CodingKeys>, forKey: KeyedDecodingContainer<CodingKeys>.Key) -> String {
        
        if let value = try? container.decode(String.self, forKey: forKey) {
            return value
        } else if let intValue = try? container.decode(Int.self, forKey: forKey) {
            return String(intValue)
        }
        return ""
    }
    
    
    enum CodingKeys: String, CodingKey {
        case videoID = "video_id"
        case title, description, search
        case ownerType = "owner_type"
        case ownerID = "owner_id"
        case parentType = "parent_type"
        case parentID = "parent_id"
        case creationDate = "creation_date"
        case modifiedDate = "modified_date"
        case viewCount = "view_count"
        case commentCount = "comment_count"
        case type, code
        case photoID = "photo_id"
        case rating
        case categoryID = "category_id"
        case status
        case fileID = "file_id"
        case duration, rotation
        case mainChannelID = "main_channel_id"
        case subcategoryID = "subcategory_id"
        case subsubcategoryID = "subsubcategory_id"
        case profileType = "profile_type"
        case featured
        case favouriteCount = "favourite_count"
        case sponsored
        case seaoLocationid = "seao_locationid"
        case location
        case networksPrivacy = "networks_privacy"
        case likeCount = "like_count"
        case synchronized, image
        case imageNormal = "image_normal"
        case imageProfile = "image_profile"
        case imageIcon = "image_icon"
        case contentURL = "content_url"
        case ownerImage = "owner_image"
        case ownerImageNormal = "owner_image_normal"
        case ownerImageProfile = "owner_image_profile"
        case ownerImageIcon = "owner_image_icon"
        case ownerTitle = "owner_title"
        case allowToView = "allow_to_view"
        case ratingCount = "rating_count"
        case videoURL = "video_url"
        case isPassword = "is_password"
        case authView = "auth_view"
        case authComment = "auth_comment"
    }
}
