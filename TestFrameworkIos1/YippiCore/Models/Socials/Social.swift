// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

public struct FeedResponse: Decodable {
    public let data: [Feed]

    enum CodingKeys: String, CodingKey {
        case data
    }
}

public struct Feed: Decodable {
    public let feed: FeedDetail
    
    enum CodingKeys: String, CodingKey {
        case feed
    }
}

public struct FeedDetail: Decodable {
    public let actionID: Int
    public let body: String
    public let feedObject: FeedObject
    public let attachment: [FeedAttachment]?
    public let feedTitle: String
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        actionID = try container.decode(Int.self, forKey: .actionID)
        feedObject = try container.decode(FeedObject.self, forKey: .feedObject)
        body = try container.decode(String.self, forKey: .body)
        attachment = try container.decodeIfPresent([FeedAttachment].self, forKey: .attachment)
        feedTitle = try container.decode(String.self, forKey: .feedTitle)
    }
    
    enum CodingKeys: String, CodingKey {
        case actionID = "action_id"
        case body
        case feedObject = "object"
        case attachment
        case feedTitle = "feed_title"
    }
}

public struct FeedAttachment: Decodable {
    public let imageMain: ImageMain?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        imageMain = FeedAttachment.parseImageMain(container, forKey: .imageMain)
    }
    
    private static func parseImageMain(_ container: KeyedDecodingContainer<CodingKeys>, forKey: KeyedDecodingContainer<CodingKeys>.Key) -> ImageMain? {
        
        if let value = try? container.decode(ImageMain.self, forKey: forKey) {
            return value
        } else if let stringValue = try? container.decode(String.self, forKey: forKey) {
            return ImageMain(src: stringValue, size: nil)
        }
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case imageMain = "image_main"
    }
}

public struct ImageMain: Decodable {
    public let src: String
    public let size: Size?
}

public struct Size: Codable {
    public let width, height: Int
}

public struct FeedObject: Codable {
    public let imageProfile: String
    
    enum CodingKeys: String, CodingKey {
        case imageProfile = "image_profile"
    }
}
