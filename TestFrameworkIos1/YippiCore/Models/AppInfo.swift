import SwiftyUserDefaults

public struct AppInfo: Codable, DefaultsSerializable {
    public let featureGame: [FeatureGame]?
    public let annoucement: Annoucement?
    public let needUpdate: Bool
    public let modules: [AppModule]
    public let waveUrl: String
    
    enum CodingKeys: String, CodingKey {
        case featureGame = "featureGame"
        case annoucement = "annoucement"
        case needUpdate = "needUpdate"
        case modules = "modules"
        case waveUrl = "waveUrl"
    }
}

public struct Annoucement: Codable {
    public let showAnnoucement: Int
    public let annoucementImage: String
    public let annoucementInstruction: String
    public let annoucementType: String
    public let annoucementData: String
    
    enum CodingKeys: String, CodingKey {
        case showAnnoucement = "show_annoucement"
        case annoucementImage = "annoucement_image"
        case annoucementInstruction = "annoucement_instruction"
        case annoucementType = "annoucement_type"
        case annoucementData = "annoucement_data"
    }
}

public struct FeatureGame: Codable {
    public let gameID: String
    public let gameIcon: String
    public let gameName: String
    public let description: String
    public let isOfficial: String
    public let addedTimestamp: String
    public let gameURL: String
    public let androidStatus: String
    public let iosStatus: String
    public let gameSequence: String
    
    enum CodingKeys: String, CodingKey {
        case gameID = "game_id"
        case gameIcon = "game_icon"
        case gameName = "game_name"
        case description = "description"
        case isOfficial = "isOfficial"
        case addedTimestamp = "added_timestamp"
        case gameURL = "game_url"
        case androidStatus = "android_status"
        case iosStatus = "ios_status"
        case gameSequence = "game_sequence"
    }
}

public enum AppModuleId: Int {
    case News = 1
    case Games = 2
    case PeopleNearby = 3
    case Sticker = 4
    case Eostrewave = 5
    case YippiEvent = 6
    case RewardsLink = 7
    case TAMall = 8
    case Shopping = 9
    case Education = 10
    case PaidSticker = 11
    case FaceUnity = 12
    case ScanTransfer = 13
    case VIPSubscribe = 14
    case HotelFlight = 15
    case Report = 17
    case Live = 18
    case CustomerSupport = 19
    case IAP = 20
    case HallOfFame = 21
    case GamificationLeveling = 22
    case Gintell = 23
    case MobileTopUp = 24
    case FeedBlockButton = 25
    case MiniProgram = 26
    case UtilitiesBill = 27
    case Incubator = 37
    case Wallet = 39
    case YippsHunter = 41
    case ReferAndEarn = 43
}

public struct AppModule: Codable {
    public let id: String
    public let module: String
    public let status: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case module = "module"
        case status = "status"
    }
}
