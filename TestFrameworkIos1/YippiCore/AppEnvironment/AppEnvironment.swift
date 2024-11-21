import Foundation
import SwiftyUserDefaults
import ObjectMapper

public enum BuildConfiguration {
    case debug
    case release
}

public enum ServerEnvironment{
    case production
    case preprod
    case staging
    case custom
}

public struct ServerConfig: Codable, DefaultsSerializable, Mappable{
    
    public var sobotGroupId: String = ""
    
    /// 是否隐藏游客开关
    public var isHiddenGuestLoginButtonInLaunch: Bool?
    /// Engage Lab推送的key
    public var engageKey: String = ""
    
    /// The base URL that is used to perform API network requests
    public var apiBaseURL: String = ""
    
    /// The base URL that is used to perform Biz API network requests
    public var bizApiBaseURL: String = ""
    
    /// 埋点接口 请求地址
    public var eventApiBaseURL: String = ""
    
    public var identifier: String = ""
    
    public var pushLiveHost: String = ""
    
    public var pullLiveHost: String = ""
    
    public var starQuestPusherKey: String = ""

    public var alipayProductID: String = ""

    public var alipayAppID: String = ""

    public var miniProgramKey: String = ""

    public var miniProgramSecret: String = ""

    public var miniProgramServer: String = ""

    public var eshopAppId: String = ""
    
    public var uploadFileURL: String = ""
    
    public var guestUsername: String = ""

    public var merchantAppId: String = ""
    
    public var togagoClientId: String = ""

    public var togagoUrl: String = ""
    
    public var merchantHost: String = ""
    
    public var charityAppId: String = ""
    
    public var creatorCenterAppId: String = ""
    
    public var mapMerchantAppId: String = ""
    
    /// 签到配置Key
    public var rlCheckInAppId: String = ""
    
    public var yippsHunterAppId: String = ""
   
    public var universalLinkApiSchema: String = ""
    
    public var universalLinkWebSchema: String = ""
    
    public var universalLinkRegisterSchema: String = ""

    public var deepLinkSchema: String = ""
    
    // MARK: AppsFlyers
    public var afAppID: String = ""
    
    public var afDevKey: String = ""
    
    public var afInviteOneLinkID: String = ""
    
    public var afBrandDomain: String = ""
    
    /// 易盾的key
    public var NTESVerifyCodeID: String = ""
    
    /// 环信配置Key
    public var imAppKey: String = ""
    /// 环信配置推送证书名称
    public var imApnsName: String = ""

    public var lokaliseProjectID: String = ""

    public var lokaliseSDKToken: String = ""
    
    /// scash
    public var scashURL: String = ""
    
    /// redpay download
    public var redpayURL: String = ""
    
    public static var production = ServerConfig(.production)
    public static var preproduction = ServerConfig(.preprod)
    public static var staging = ServerConfig(.staging)
    public static var custom = ServerConfig(.custom)
    
    public init?(map: ObjectMapper.Map) {
    }
    
    private init(_ serverEnv : ServerEnvironment){
        if let bundlePath = Bundle.main.path(forResource: "AppEnvironment", ofType: "plist") {
            let dicData = NSDictionary(contentsOfFile: bundlePath) as! Dictionary<String, Any>
            let map = Map(mappingType: .fromJSON, JSON: dicData)
            
            lokaliseProjectID <- map["LokaliseProjectID"]
            lokaliseSDKToken <- map["LokaliseSDKToken"]
            isHiddenGuestLoginButtonInLaunch <- map["isHiddenGuestLoginButtonInLaunch"]
            sobotGroupId <- map["sobotGroupId"]
            NTESVerifyCodeID <- map["NTESVerifyCodeID"]
            
            switch(serverEnv){
            case .production:
                apiBaseURL <- map["serverAddress.production.address"]
                bizApiBaseURL <- map["serverAddress.production.merchantBizAddress"]
                eventApiBaseURL <- map["serverAddress.production.eventAddress"]
                identifier <- map["serverAddress.production.identifier"]
                pushLiveHost <- map["serverAddress.production.pushLiveHost"]
                pullLiveHost <- map["serverAddress.production.pullLiveHost"]
                starQuestPusherKey <- map["serverAddress.production.starQuestPusherKey"]
                alipayProductID <- map["serverAddress.production.alipayProductID"]
                alipayAppID <- map["serverAddress.production.alipayAppID"]
                miniProgramKey <- map["serverAddress.production.miniProgramKey"]
                miniProgramSecret <- map["serverAddress.production.miniProgramSecret"]
                miniProgramServer <- map["serverAddress.production.miniProgramServer"]
                eshopAppId <- map["serverAddress.production.eshopAppId"]
                uploadFileURL <- map["serverAddress.production.uploadFileURL"]
                guestUsername <- map["serverAddress.production.guestUsername"]
                merchantAppId <- map["serverAddress.production.merchantAppId"]
                mapMerchantAppId <- map["serverAddress.production.mapMerchantAppId"]
                togagoClientId <- map["serverAddress.production.togagoClientId"]
                togagoUrl <- map["serverAddress.production.togagoUrl"]
                merchantHost <- map["serverAddress.production.merchantHost"]
                charityAppId <- map["serverAddress.production.charityAppId"]
                creatorCenterAppId <- map["serverAddress.production.creatorCenterAppId"]
                rlCheckInAppId <- map["serverAddress.production.rlCheckInAppId"]
                yippsHunterAppId <- map["serverAddress.production.yippsHunterAppId"]
                universalLinkApiSchema <- map["serverAddress.production.universalLinkApiSchema"]
                universalLinkWebSchema <- map["serverAddress.production.universalLinkWebSchema"]
                universalLinkRegisterSchema <- map["serverAddress.production.universalLinkRegisterSchema"]
                deepLinkSchema <- map["serverAddress.production.deepLinkSchema"]
                imAppKey <- map["serverAddress.production.imAppKey"]
                imApnsName <- map["serverAddress.production.imApnsName"]
                engageKey <- map["serverAddress.production.engageKey"]
                afAppID <- map["serverAddress.production.afAppID"]
                afDevKey <- map["serverAddress.production.afDevKey"]
                afInviteOneLinkID <- map["serverAddress.production.afInviteOneLinkID"]
                afBrandDomain <- map["serverAddress.production.afBrandDomain"]
                scashURL <- map["serverAddress.production.scashURL"]
                redpayURL <- map["serverAddress.production.redpayURL"]
            case .preprod:
                apiBaseURL <- map["serverAddress.preproduction.address"]
                bizApiBaseURL <- map["serverAddress.preproduction.merchantBizAddress"]
                eventApiBaseURL <- map["serverAddress.preproduction.eventAddress"]
                identifier <- map["serverAddress.preproduction.identifier"]
                pushLiveHost <- map["serverAddress.preproduction.pushLiveHost"]
                pullLiveHost <- map["serverAddress.preproduction.pullLiveHost"]
                starQuestPusherKey <- map["serverAddress.preproduction.starQuestPusherKey"]
                alipayProductID <- map["serverAddress.preproduction.alipayProductID"]
                alipayAppID <- map["serverAddress.preproduction.alipayAppID"]
                miniProgramKey <- map["serverAddress.preproduction.miniProgramKey"]
                miniProgramSecret <- map["serverAddress.preproduction.miniProgramSecret"]
                miniProgramServer <- map["serverAddress.preproduction.miniProgramServer"]
                eshopAppId <- map["serverAddress.preproduction.eshopAppId"]
                uploadFileURL <- map["serverAddress.preproduction.uploadFileURL"]
                guestUsername <- map["serverAddress.preproduction.guestUsername"]
                merchantAppId <- map["serverAddress.preproduction.merchantAppId"]
                mapMerchantAppId <- map["serverAddress.preproduction.mapMerchantAppId"]
                togagoClientId <- map["serverAddress.preproduction.togagoClientId"]
                togagoUrl <- map["serverAddress.preproduction.togagoUrl"]
                merchantHost <- map["serverAddress.preproduction.togagoUrl"]
                charityAppId <- map["serverAddress.preproduction.charityAppId"]
                creatorCenterAppId <- map["serverAddress.preproduction.creatorCenterAppId"]
                rlCheckInAppId <- map["serverAddress.preproduction.rlCheckInAppId"]
                yippsHunterAppId <- map["serverAddress.preproduction.yippsHunterAppId"]
                universalLinkApiSchema <- map["serverAddress.preproduction.universalLinkApiSchema"]
                universalLinkWebSchema <- map["serverAddress.preproduction.universalLinkWebSchema"]
                universalLinkRegisterSchema <- map["serverAddress.preproduction.universalLinkRegisterSchema"]
                deepLinkSchema <- map["serverAddress.preproduction.deepLinkSchema"]
                imAppKey <- map["serverAddress.preproduction.imAppKey"]
                imApnsName <- map["serverAddress.preproduction.imApnsName"]
                engageKey <- map["serverAddress.preproduction.engageKey"]
                afAppID <- map["serverAddress.preproduction.afAppID"]
                afDevKey <- map["serverAddress.preproduction.afDevKey"]
                afInviteOneLinkID <- map["serverAddress.preproduction.afInviteOneLinkID"]
                afBrandDomain <- map["serverAddress.preproduction.afBrandDomain"]
                scashURL <- map["serverAddress.preproduction.scashURL"]
                redpayURL <- map["serverAddress.preproduction.redpayURL"]
            case .staging:
                apiBaseURL <- map["serverAddress.staging.address"]
                bizApiBaseURL <- map["serverAddress.staging.merchantBizAddress"]
                eventApiBaseURL <- map["serverAddress.staging.eventAddress"]
                identifier <- map["serverAddress.staging.identifier"]
                pushLiveHost <- map["serverAddress.staging.pushLiveHost"]
                pullLiveHost <- map["serverAddress.staging.pullLiveHost"]
                starQuestPusherKey <- map["serverAddress.staging.starQuestPusherKey"]
                alipayProductID <- map["serverAddress.staging.alipayProductID"]
                alipayAppID <- map["serverAddress.staging.alipayAppID"]
                miniProgramKey <- map["serverAddress.staging.miniProgramKey"]
                miniProgramSecret <- map["serverAddress.staging.miniProgramSecret"]
                miniProgramServer <- map["serverAddress.staging.miniProgramServer"]
                eshopAppId <- map["serverAddress.staging.eshopAppId"]
                uploadFileURL <- map["serverAddress.staging.uploadFileURL"]
                guestUsername <- map["serverAddress.staging.guestUsername"]
                merchantAppId <- map["serverAddress.staging.merchantAppId"]
                mapMerchantAppId <- map["serverAddress.staging.mapMerchantAppId"]
                togagoClientId <- map["serverAddress.staging.togagoClientId"]
                togagoUrl <- map["serverAddress.staging.togagoUrl"]
                merchantHost <- map["serverAddress.staging.merchantHost"]
                charityAppId <- map["serverAddress.staging.charityAppId"]
                creatorCenterAppId <- map["serverAddress.staging.creatorCenterAppId"]
                rlCheckInAppId <- map["serverAddress.staging.rlCheckInAppId"]
                yippsHunterAppId <- map["serverAddress.staging.yippsHunterAppId"]
                universalLinkApiSchema <- map["serverAddress.staging.universalLinkApiSchema"]
                universalLinkWebSchema <- map["serverAddress.staging.universalLinkWebSchema"]
                universalLinkRegisterSchema <- map["serverAddress.staging.universalLinkRegisterSchema"]
                deepLinkSchema <- map["serverAddress.staging.deepLinkSchema"]
                imAppKey <- map["serverAddress.staging.imAppKey"]
                imApnsName <- map["serverAddress.staging.imApnsName"]
                engageKey <- map["serverAddress.staging.engageKey"]
                afAppID <- map["serverAddress.staging.afAppID"]
                afDevKey <- map["serverAddress.staging.afDevKey"]
                afInviteOneLinkID <- map["serverAddress.staging.afInviteOneLinkID"]
                afBrandDomain <- map["serverAddress.staging.afBrandDomain"]
                scashURL <- map["serverAddress.staging.scashURL"]
                redpayURL <- map["serverAddress.staging.redpayURL"]
            case .custom:
                apiBaseURL <- map["serverAddress.custom.address"]
                bizApiBaseURL <- map["serverAddress.custom.merchantBizAddress"]
                eventApiBaseURL <- map["serverAddress.custom.eventAddress"]
                identifier <- map["serverAddress.custom.identifier"]
                pushLiveHost <- map["serverAddress.custom.pushLiveHost"]
                pullLiveHost <- map["serverAddress.custom.pullLiveHost"]
                starQuestPusherKey <- map["serverAddress.custom.starQuestPusherKey"]
                alipayProductID <- map["serverAddress.custom.alipayProductID"]
                alipayAppID <- map["serverAddress.custom.alipayAppID"]
                miniProgramKey <- map["serverAddress.custom.miniProgramKey"]
                miniProgramSecret <- map["serverAddress.custom.miniProgramSecret"]
                miniProgramServer <- map["serverAddress.custom.miniProgramServer"]
                eshopAppId <- map["serverAddress.custom.eshopAppId"]
                uploadFileURL <- map["serverAddress.custom.uploadFileURL"]
                guestUsername <- map["serverAddress.custom.guestUsername"]
                merchantAppId <- map["serverAddress.custom.merchantAppId"]
                mapMerchantAppId <- map["serverAddress.custom.mapMerchantAppId"]
                togagoClientId <- map["serverAddress.custom.togagoClientId"]
                togagoUrl <- map["serverAddress.custom.togagoUrl"]
                merchantHost <- map["serverAddress.custom.merchantHost"]
                charityAppId <- map["serverAddress.custom.charityAppId"]
                creatorCenterAppId <- map["serverAddress.custom.creatorCenterAppId"]
                rlCheckInAppId <- map["serverAddress.custom.rlCheckInAppId"]
                yippsHunterAppId <- map["serverAddress.custom.yippsHunterAppId"]
                universalLinkApiSchema <- map["serverAddress.custom.universalLinkApiSchema"]
                universalLinkWebSchema <- map["serverAddress.custom.universalLinkWebSchema"]
                universalLinkRegisterSchema <- map["serverAddress.custom.universalLinkRegisterSchema"]
                deepLinkSchema <- map["serverAddress.custom.deepLinkSchema"]
                imAppKey <- map["serverAddress.custom.imAppKey"]
                imApnsName <- map["serverAddress.custom.imApnsName"]
                engageKey <- map["serverAddress.custom.engageKey"]
                afAppID <- map["serverAddress.custom.afAppID"]
                afDevKey <- map["serverAddress.custom.afDevKey"]
                afInviteOneLinkID <- map["serverAddress.custom.afInviteOneLinkID"]
                afBrandDomain <- map["serverAddress.custom.afBrandDomain"]
                scashURL <- map["serverAddress.custom.scashURL"]
                redpayURL <- map["serverAddress.custom.redpayURL"]
            }
        } else {
            fatalError("默认环境配置文件格式错误,查看文档 ./Thinksns Plus Document/应用配置说明.md")
        }
    }
    
    public mutating func fetchEntitlement(){
        if let bundlePath = Bundle.main.path(forResource: "AppEnvironment", ofType: "plist") {
            let dicData = NSDictionary(contentsOfFile: bundlePath) as! Dictionary<String, Any>
            if let model = Mapper<ServerConfig>().map(JSON: dicData) {
                self = model
                return
            }
            fatalError("默认环境配置文件格式错误,查看文档 ./Thinksns Plus Document/应用配置说明.md")
        } else {
            fatalError("默认环境配置文件格式错误,查看文档 ./Thinksns Plus Document/应用配置说明.md")
        }
    }
     
    public mutating func mapping(map: ObjectMapper.Map) {
        
    }
}

/**
 A collection of **all** global variables and singletons that the app wants access to.
 */
public struct Environment {
    /// The configuration for which the app was built
    ///
    /*
    #if DEBUG
    public let buildConfiguration: BuildConfiguration = .debug
    #else
    public let buildConfiguration: BuildConfiguration = .release
    #endif
    */
    public let bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "com.togl.rewardslink"
    
    /// The base URL that is used to perform network requests
    public var config: ServerConfig
    
    /// The currently logged in user.
    public let currentUser: TSUser?
    
    public let appInfo: AppInfo?
    
    public let featureFlags: FeatureFlags
    
    public init(
        config: ServerConfig = .production,
        appInfo: AppInfo? = nil,
        currentUser: TSUser? = nil
    ) {
        self.config = config
        self.currentUser = currentUser
        self.appInfo = appInfo
        self.featureFlags = FeatureFlags.load()
    }
    
    public var appVersion: String {
        get {
            return Device.appVersion()
        }
    }
    
    public var buildVersion: String {
        get {
            return Device.appBuildNumber()
        }
    }
}

@objc public class AppEnvironment: NSObject {
    public static let AppEnvinronmentIdentifier: String = "com.toga.app.environment"
    fileprivate static var env_stack: [Environment] = [Environment()]
    
    public static var current: Environment! {
        return env_stack.last
    }
    
    override init(
        // TODO properties here
    ) {
    }
    
    public static func pushEnvironment(_ env: Environment) {
        saveEnvironment(env)
        env_stack.append(env)
    }
    
    // Replace the current environment with a new environment.
    public static func replaceCurrentEnvironment(_ env: Environment) {
        pushEnvironment(env)
        env_stack.remove(at: env_stack.count - 2)
    }

    public static func setup(completionHandler: @escaping() -> Void) {
        let env = fromStorage()
        replaceCurrentEnvironment(env)
        completionHandler()
    }
    
    // Saves some key data for the current environment
    internal static func saveEnvironment(_ env: Environment = AppEnvironment.current) {
        Defaults.serverConfig = env.config
        
        if let currentUser = env.currentUser {
            Defaults.currentUser = currentUser
        }
        
        if let appInfo = env.appInfo {
            Defaults.appInfo = appInfo
        }
        
        Defaults.featureFlags = env.featureFlags
    }
    
    internal static func fromStorage() -> Environment {
        #if DEBUG
        var config: ServerConfig  = ServerConfig.preproduction
        
        if let identifier = UserDefaults.standard.string(forKey: AppEnvinronmentIdentifier) {
            switch identifier {
            case "Prod":
                config = ServerConfig.production
            case "Stg":
                config = ServerConfig.staging
            case "Preprod":
                config = ServerConfig.preproduction
            case "Cus":
                config = ServerConfig.custom
            default:
                break
            }
        }
        #else
        let config: ServerConfig = ServerConfig.production
        #endif
        
        return Environment(config: config, appInfo: Defaults.appInfo, currentUser: Defaults.currentUser)
    }
}
