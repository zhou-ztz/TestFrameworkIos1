import UIKit

@objcMembers
public class StickerList: NSObject, Decodable {
    public let items: [Sticker]?
    public let totalSize: Int

    enum CodingKeys: String, CodingKey {
        case items
        case totalSize
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decode([Sticker]?.self , forKey: .items) {
            items = value
        } else {
            items = nil
        }
        totalSize = Int(try container.decodeIfPresent(String.self , forKey: .totalSize) ?? "0") ?? 0
    }
}
public enum MetadataType: Codable {
    case int(Int)
    case string(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = try .int(container.decode(Int.self))
        } catch DecodingError.typeMismatch {
            do {
                self = try .string(container.decode(String.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(MetadataType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let int):
            try container.encode(int)
        case .string(let string):
            try container.encode(string)
        }
    }
}

public struct Sticker: Decodable {
    public let bundleIDType: MetadataType?
    public let bundleIcon: String?
    public let bundleName, description: String?
    public let isOfficial, status, isGIF: Int?
    public let isEvent: Int?
    public let addedTimestamp: String?
    public let downloadCount: Int?
    public let bannerURL: String?
    public let price: String?
    public let slug: String?
    public let voteCount: Int?
    public let artist: Artist?
    public let stickerList: [StickerList]?
    public let stickers: [Sticker]?
    public let todayStats: SOTDStats?
    public let tipsCount: Int?
    public let coverSize, bannerSize, stickerSize, backgroundColor: String?
    public let stickerCreatedBy: String?
    // new artist
    public let uid: Int?
    public let hideViewMoment: Int?
    // recommend artist
    public let artistID: Int?
    public let artistName: String?
    public let icon, banner: String?
    public let stickerSet, totalPoints: Int?
    // category
    public let id: Int?
    public let name: String?
    public let catID: Int?
    public let image: String?
    
    public var bundleID: Int? {
        guard let bundleid = bundleIDType else { return nil }
        switch bundleid {
        case .int(let val):
            return val
        case .string(let val):
            return Int(val)!
        }
    }
    
    public struct SOTDStats: Codable {
        public let bundleID, downloadCount, tipsCount, downloadPoints: Int
        public let tipsAmount, amountPoints, totalPoints: Int

        enum CodingKeys: String, CodingKey {
            case bundleID = "bundle_id"
            case downloadCount = "download_count"
            case tipsCount = "tips_count"
            case downloadPoints = "download_points"
            case tipsAmount = "tips_amount"
            case amountPoints = "amount_points"
            case totalPoints = "total_points"
        }
    }
    
    public struct StickerList: Codable {
        public let stickerID, bundleID: Int
        public let stickerIcon: String
        public let stickerName: String
        public let position: Int
        
        enum CodingKeys: String, CodingKey {
            case stickerID = "sticker_id"
            case bundleID = "bundle_id"
            case stickerIcon = "sticker_icon"
            case stickerName = "sticker_name"
            case position
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case bundleIDType = "bundle_id"
        case bundleIcon = "bundle_icon"
        case bundleName = "bundle_name"
        case description = "description"
        case isOfficial, status, isEvent
        case isGIF = "isGif"
        case catID = "cat_id"
        case addedTimestamp = "added_timestamp"
        case downloadCount = "download_count"
        case bannerURL = "banner_url"
        case price
        case artistID = "artist_id"
        case slug
        case voteCount = "vote_count"
        case tipsCount = "tips_count"
        case coverSize, bannerSize, stickerSize, backgroundColor
        case stickerCreatedBy = "sticker_created_by"
        case artist
        case todayStats = "today_statistics"
        case artistName = "artist_name"
        case icon, banner
        case stickerSet = "sticker_set"
        case totalPoints = "total_points"
        case uid
        case hideViewMoment = "hide_view_moment"
        case stickerList, stickers, id, name, image
    }
}

public struct StickerLandingResponse: Decodable {
    public var data: StickerHome?
}

public struct StickerHome: Decodable {
    public var stickers: [StickerCollectionSection]
    public var banner: StickerHomeBannerSection?
}

public enum StickerListingType: String, Codable {
    case grid, list, featured, unknown
    public init(from decoder: Decoder) throws {
        self = try StickerListingType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum StickerType: String, Codable {
    case hot_stickers, stickers_of_the_day, new_sticker, recomended_artist, new_artist, featured_category, stickerByCategory, unknown
    public init(from decoder: Decoder) throws {
        self = try StickerType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}


public struct StickerCollectionSection: Decodable {
    public let title: String
    public let listingType: StickerListingType
    public let type: StickerType
    public let row: Int?
    public let bgColor: String?
    public var data: [Sticker]
    public let titleStyle : String?
    public let showScore: Bool
    public let hasMoreData: Bool
    
    enum CodingKeys: String, CodingKey {
        case title, type
        case listingType = "listing_type"
        case data, row
        case bgColor = "bg_color"
        case titleStyle = "title_style"
        case showScore = "show_score"
        case hasMoreData = "load_more"
    }
}

public struct StickerHomeBannerSection: Decodable {
    public let title: String?
    public let bannerList: [StickerBanner]?
    public let delayMillisecond: Int

    enum CodingKeys: String, CodingKey {
        case bannerList = "banner_list"
        case delayMillisecond = "delay_milis"
        case title
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bannerList = try container.decodeIfPresent([StickerBanner].self, forKey: .bannerList)
        do {
            delayMillisecond = try container.decodeIfPresent(Int.self, forKey: .delayMillisecond) ?? 3000
        } catch {
            let delay = try container.decodeIfPresent(String.self, forKey: .delayMillisecond) ?? "3000"
            delayMillisecond = Int(delay)!
        }
        title = try container.decodeIfPresent(String.self, forKey: .title)
    }
}

public enum StickerBannerActionType: String, Codable {
    case url, sticker, unknown
    public init(from decoder: Decoder) throws {
        self = try StickerBannerActionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public struct StickerBanner: Decodable {
    public let bannerName: String
    public let bundleId: Int?
    public let bannerSequence: Int
    public let bannerUrl: String?
    public let actionType: StickerBannerActionType?
    public let actionValue: String?

    enum CodingKeys: String, CodingKey {
        case bannerName = "banner_name"
        case bannerSequence = "banner_sequence"
        case bundleId = "bundle_id"
        case bannerUrl = "banner_url"
        case actionType = "action_type"
        case actionValue = "action_value"
    }
}

public struct StickerListModel: Decodable {
    public let data: StickerCollectionSection
}

public struct StickerRankSection: Decodable {
    public let title: String
    public let data: [Sticker]
    
    enum CodingKeys: String, CodingKey {
        case title
        case data
    }
}

public struct StickerPaidSection: Decodable {
    public let title, listingType: String
    public let type: StickerType
    public let data: [Sticker]
    
    enum CodingKeys: String, CodingKey {
        case title
        case listingType = "listing_type"
        case type = "type"
        case data
    }
}

public struct StickerDetail: Decodable {
    public let bundle: Sticker
    public let artist: Artist
    public let stickers: [StickerItem]
    public let isDownloaded: Bool

    enum CodingKeys: String, CodingKey {
        case bundle = "bundle"
        case artist = "artist"
        case stickers = "stickers"
        case isDownloaded = "is_downloaded"
    }
}

public struct Artist: Codable {
    public let artistIDType: MetadataType
    public let artistName, description: String?
    public let icon, banner: String?
    public let uid: Int?
    
    public var artistID: Int {
        switch artistIDType  {
        case .int(let val):
            return val
        case .string(let val):
            return Int(val)!
        }
    }
    
    
    enum CodingKeys: String, CodingKey {
        case artistIDType = "artist_id"
        case artistName = "artist_name"
        case description, icon, banner
        case uid
    }
}

@objcMembers
public class StickerItem: NSObject, Decodable {
    public let stickerID, bundleID: String
    public let stickerIcon: String
    public let stickerName, position: String
    
    enum CodingKeys: String, CodingKey {
        case stickerID = "sticker_id"
        case bundleID = "bundle_id"
        case stickerIcon = "sticker_icon"
        case stickerName = "sticker_name"
        case position
    }
    
    public init(id: String, bundleId: String, icon: String, name: String, position: String) {
        self.stickerID = id
        self.bundleID = bundleId
        self.stickerIcon = icon
        self.position = position
        self.stickerName = name
    }
}

public struct ArtistDetail: Decodable {
    public var bundle: ArtistBundle
    public let artist: [Artist]
}

public struct ArtistBundle: Decodable {
    public let title: String
    public var data: [Sticker]
}

@objcMembers
public class UserBundle: NSObject, Codable {
    public let uid, userID: String
    public let bundleID: Int
    public let bundleIcon: String
    public let bundleName: String
    
    enum CodingKeys: String, CodingKey {
        case uid
        case userID = "user_id"
        case bundleID = "bundle_id"
        case bundleIcon = "bundle_icon"
        case bundleName = "bundle_name"
    }
    @objc public func asJSON()->String?{
        do{
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)
        }catch{
            return nil
        }
    }
    
    required public init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
            userID = try container.decode(String.self, forKey: .userID)
            bundleID = try container.decode(Int.self, forKey: .bundleID)
            bundleIcon = try container.decode(String.self, forKey: .bundleIcon)
            bundleName = try container.decode(String.self, forKey: .bundleName)
            uid = (try container.decodeIfPresent(String.self, forKey: .uid)) ?? "Unknown"
    }
    
}

@objcMembers
public class CustomerStickerItem: NSObject, Decodable {
    public let Typename: String?
    public let customStickerId: String?
    public let stickerUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case Typename = "__typename"
        case customStickerId = "custom_sticker_id"
        case stickerUrl = "sticker_url"
      
    }
    
    public init(customStickerId: String, Typename: String, stickerUrl: String) {
        self.customStickerId = customStickerId
        self.Typename = Typename
        self.stickerUrl = stickerUrl
     
    }
}

@objcMembers
public class CreateCustomerStickerItem: NSObject, Decodable {
    public let data: CreateStickerItem
 
    enum CodingKeys: String, CodingKey {
        case data = "data"
   
    }
    
    public init(data: CreateStickerItem) {
        self.data = data

    }
    
    public class CreateStickerItem: NSObject, Decodable {
        public let uploadCustomSticker: CustomerStickerItem
      
        enum CodingKeys: String, CodingKey {
            case uploadCustomSticker = "uploadCustomSticker"
          
          
        }
        
        public init(uploadCustomSticker: CustomerStickerItem) {
            self.uploadCustomSticker = uploadCustomSticker
            
         
        }
    }
}

@objcMembers
public class CreateCustomerMaxError: NSObject, Decodable {
    public let errors: [ErrorItem]
 
    enum CodingKeys: String, CodingKey {
        case errors = "errors"
   
    }
    
    public init(errors: [ErrorItem]) {
        self.errors = errors

    }
    
    public class ErrorItem: NSObject, Decodable {
        public let message: String
      
        enum CodingKeys: String, CodingKey {
            case message = "message"
          
        }
        
        public init(message: String) {
            self.message = message
            
        }
    }
}


@objcMembers
public class FetchCustomStickersItem: NSObject, Decodable {
    public let __typename: String
    public let cursor: String
    public let node: CustomerStickerItem
    enum CodingKeys: String, CodingKey {
        case __typename = "__typename"
        case cursor = "cursor"
        case node = "node"
    }
    public init(__typename: String, cursor: String, node: CustomerStickerItem) {
        self.__typename = __typename
        self.cursor = cursor
        self.node = node
        
     
    }
}
