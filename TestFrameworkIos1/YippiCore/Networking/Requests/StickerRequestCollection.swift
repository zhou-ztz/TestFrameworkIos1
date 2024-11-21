import Foundation

enum StickerPageType {
    case home, rank, paid, sotd
}

struct GetStickerRequest: APIRequest {
    typealias Response = StickerHome
    
    var resourceName: String = ""
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    init(pageType: StickerPageType) {
        switch pageType {
        case .home:
            resourceName = "sticker/api/StickerShopHomePage"
        case .rank:
            resourceName = "sticker/api/stickerRankPage"
        case .paid:
            resourceName = "sticker/api/stickerPaidPage"
        default:
            break
        }
    }
}

struct GetStickerList: APIRequest {
    typealias Response = StickerList
    
    var resourceName: String {
        return "sticker/api/StickerList"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let page: Int
    let pageSize: Int
    let type: String
    
    init(type: String,
         page: Int = 1,
         pageSize: Int = 10) {
        self.type = type
        self.page = page
        self.pageSize = pageSize
    }
    
    enum CodingKeys: String, CodingKey {
        case pageSize = "page_size"
        case page
        case type
    }
}

struct GetStickerDetail: APIRequest {
    typealias Response = StickerDetail
    var resourceName: String {
        return "sticker/api/viewBundleSet"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let id: String
    
    init(id: String) {
        self.id = id
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "bundle_id"
    }
}

struct GetArtistDetail: APIRequest {
    typealias Response = ArtistDetail
    
    var resourceName: String {
        return "sticker/api/ViewStickerSet"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let id: String
    let type: String
    
    init(id: String) {
        self.id = id
        self.type = "artist"
    }
}

struct GetMyStickers: APIRequest {
    typealias Response = [UserBundle]
    
    var resourceName: String {
        return "sticker/api/UserStickerList"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    init() {
        
    }
}

struct GetMyStickersV2: APIRequest {
    typealias Response = Dictionary<String, [UserBundle]>
    
    var resourceName: String {
        return "api/v2/user-sticker-list"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let userId: String
    
    init(userId:String) {
        self.userId = userId
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
    }
}

struct UninstallStickers: APIRequest {
    typealias Response = [String: String]
    
    var resourceName: String {
        return "sticker/api/UninstallSticker"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let bundleId: String
    
    init(bundleId: String) {
        self.bundleId = bundleId
    }
    
    enum CodingKeys: String, CodingKey {
        case bundleId = "bundle_id"
    }
}

struct DownloadSticker: APIRequest {
    typealias Response = [StickerItem]
    
    var resourceName: String {
        return "sticker/api/DownloadSticker"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let bundleId: String
    
    init(bundleId: String) {
        self.bundleId = bundleId
    }
    
    enum CodingKeys: String, CodingKey {
        case bundleId = "bundle_id"
    }
}

struct PurchaseSticker: APIRequest {
    typealias Response = [StickerItem]
    
    var resourceName: String {
        return "sticker/api/DownloadSticker"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let bundleId: String
    let username: String
    let password: String
    
    init(bundleId: String, username: String, password: String) {
        self.bundleId = bundleId
        self.username = username
        self.password = password.md5
    }
    
    enum CodingKeys: String, CodingKey {
        case bundleId = "bundle_id"
        case username
        case password
    }
}

struct SearchSticker: APIRequest {
    typealias Response = [Sticker]
    
    var resourceName: String {
        return "sticker/api/search"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let name: String
    let type: String
    
    init(name: String, type: String = "sticker") {
        self.name = name
        self.type = type
    }
}
