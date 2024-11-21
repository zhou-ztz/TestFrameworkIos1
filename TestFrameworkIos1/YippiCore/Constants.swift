import UIKit

@objcMembers
public class Constants: NSObject {
    
    public static let watermarkSize: CGFloat = 70.0
     
    /// Determines best fit for given an video/image or 1080x1920(1080p) quality
    public static var bestPixelRatio: CGFloat {
        let zoomRatio1 = 1920.0 / UIScreen.main.bounds.height
        let zoomRatio2 = 1080.0 / UIScreen.main.bounds.width
        
        let bestZoom = max(zoomRatio1, zoomRatio2)
        
        return bestZoom
    }
    
    public static let kmd5Key: String = "yVku6GD&nbyG@GVfV"
    public static let NIMKey: String = "43cf17ab859f4c669349fd68e363d6db"

    public static let pageSize: Int = 20
    public static let platform = "ios"
    
    //Sticker Container Contants
    public static let stickerPerPage: Int = 8
    public static let emojiPerPage: Int = 32
    public static let stickerThumbHeight: Int = 40
    public static let stickerThumbWidth: Int = 45
    public static let stickerSize: Int = 115
    public static let emojiContainerHeight: CGFloat = 260
    public static let textToolbarHeight: CGFloat = 52
    public static let voucherHeight: CGFloat = 44

    //Downloaded Sticker Path
    public static let USER_DOWNLOADED_STICKER_BUNDLE_PLIST="USER_DOWNLOADED_STICKER_BUNDLE_PLIST"
    public static let USER_DOWNLOADED_STICKER_BUNDLE_PREFIX="USER_DOWNLOADED_STICKER_BUNDLE_PLIST_"
    public static let USER_DOWNLOADED_FU_BUNDLE_PLIST="USER_DOWNLOADED_FU_BUNDLE_PLIST"
    
    public static let VoiceOrVideoMuteNotificationKey = "yippi.app.MuteVoiceAndVideo"
    public static let ShowFrontOrBackCameraKey = "yippi.app.showFrontOrBackCamera"
    public static let GlobalChatWallpaperImageKey = "yippi.app.globalChatWallpaperImage"
    public static let ChatDraftKey = "yippi.app.ChatDraft"
    public static let UserStickerDefaultKey = "com.save.usersticker"
    public static let secretMessageTimerKey = "yippi.app.SecretMessageTimer"
    public static let energyUrls = "yippi.app.energyUrls"
    public static let trtEnergyUrls = "yippi.app.trtEnergyUrls"
    public static let socialSignedInUserID = "yippi.app.SocialSignedInId"
    public static let baseUserDefaultKey = "yippiusersh:"
    
    public static let supportEmail = "yippisupport@togalimited.com"
    public static let schemeAuthentication = "yippiapp"
    public static let hostAuthenticationCs = "CS"
    
    // Payment Method
    public static let redPay = "RedPay"
    public static let shopeePay = "ShopeePay"

    public static let minimumUsernameLength = 5
    public static let maximumUsernameLength = 30

    public static let maximumGroupNameLength = 25
    
    public static let timeout: TimeInterval = 10.0
    
    #if DEBUG
    public static let maximumTeamMemberAuthCompulsory: NSInteger = 50
    #else
    public static let maximumTeamMemberAuthCompulsory: NSInteger = 50
    #endif

    #if DEBUG
    public static let maximumTeamMemberAuthFromCardView: NSInteger = 49
    #else
    public static let maximumTeamMemberAuthFromCardView: NSInteger = 49
    #endif
    
    #if DEBUG
    public static let maximumSendContactCount: NSInteger = 5
    #else
    public static let maximumSendContactCount: NSInteger = 30
    #endif
    
    public static let maximumRequestCount: Int = 999
    public static let maximumLiveInfoTextCount: NSInteger = 255
    public static let minimumLiveInfoTextCount: NSInteger = 4
    
    public static let appStoreUrl: URL = URL(string: "https://itunes.apple.com/app/yippi/id1108775331")!

    public struct Layout {
        public static let stickerCellHeight: CGFloat = 60.0
        public static let bannerHeight: CGFloat = 200.0
        public static let stickerCollectionRowHeight: CGFloat = 100.0
        public static let stickerHeaderHeight: CGFloat = 40.0
        public static let stickerFeaturedCellHeight: CGFloat = 300.0
        
        public static let SearchCellContentFontSize: CGFloat = 12.0
        
        public static let SearchCellContentBottom: CGFloat = 8.0
        public static let SearchCellContentTop: CGFloat = 30.0
        public static let SearchCellContentMaxWidth: CGFloat = 260.0
        public static let SearchCellContentMinHeight: CGFloat = 15.0
        
        public static let nameLabelMaxSize: CGFloat = 120.0
        
        public static let UIScreenWidth = UIScreen.main.bounds.size.width
        public static let UIScreenHeight = UIScreen.main.bounds.size.height
        public static let UISreenWidthScale = Int(UIScreenWidth) / 320
        public static let MessageCellMaxHeight = 140
    }

    public struct KeyChain {
        static let deviceUUID = "yippi.app.device.uuid"
        public static let username = "yippi.app.device.username"
    }

    public struct Headers {
        public static let ClientType = "X-Client-Type"
        public static let ClientVersion = "X-Client-Version"
        public static let DeviceID = "X-Device-ID"
        public static let DeviceOS = "X-Device-OS"
        public static let Accept = "Accept"
        public static let DeviceModel = "X-Device-Model"
        public static let IOSDevice = "IOS_DEVICE"
        public static let AcceptLanguage = "Accept-Language"
        public static let AuthToken = "X-Token" // or Authorization?
        public static let AppFavor = "X-App-Favor"
        public static let ClientAppName = "X-Client-App-Name"
        public static let AppName = "X-Client-App-Name"
        public static let DeviceCountry = "X-Device-Country"
    }
    
    public static let toastPosition = CGPoint(x: UIScreen.main.bounds.size.width*0.5, y: UIScreen.main.bounds.size.height*0.5)

    public static let YippiWallet = "Yipps"
    
    public static let whatIsWaveHans = "http://www.yippiweb.com/zh/what-is-wave-cn"
    public static let whatIsWaveEn = "http://www.yippiweb.com/what-is-wave"
    public static let ScienceWaveEn = "http://www.yippiweb.com/wave-the-science-behind-it"
    public static let ScienceWaveHans = "http://www.yippiweb.com/zh/wave-the-science-behind-it-cn"
    public static let WaveDisclaimer = "http://www.yippiweb.com/wave-disclaimer"
    public static let swiftCodeInfoLink = "http://event.yiartkeji.com/swift-code/"

    public static let VideoPlayerPlayButtonWidth: CGFloat = 64
    public static let VideoPlayerPlayButtonHeight: CGFloat = 64
    
    public static let YippiNetCallRingtone = "yippi_ringtone.wav"
    
    public static let RewardLinkUserDefaultKey = "rewardlinkusersh:"
    public static let RewardsLinkScheme = "rewardslink"
    public static let merchantQRCode = "business.payment:branch."

    public struct NIM {
        public static let NIMKit_EmojiCatalog = "default"
        public static let NIMKit_EmojiPath = "Emoji"
        public static let NIMKit_ChartletChartletCatalogPath = "Chartlet"
        public static let NIMKit_ChartletChartletCatalogContentPath = "content"
        public static let NIMKit_ChartletChartletCatalogIconPath = "icon"
        public static let NIMKit_ChartletChartletCatalogIconsSuffixNormal = "normal"
        public static let NIMKit_ChartletChartletCatalogIconsSuffixHighLight = "highlighted"
        
        public static let NIMKit_EmojiLeftMargin = 8
        public static let NIMKit_EmojiRightMargin = 8
        public static let NIMKit_EmojiTopMargin = 14
        public static let NIMKit_DeleteIconWidth: CGFloat = 43.0
        public static let NIMKit_DeleteIconHeight: CGFloat = 43.0
        public static let NIMKit_EmojCellHeight: CGFloat = 46.0
        public static let NIMKit_EmojImageHeight: CGFloat = 43.0
        public static let NIMKit_EmojImageWidth: CGFloat = 43.0
        public static let NIMKit_EmojRows = 3
        
        public static let NIMKit_PicCellHeight: CGFloat = 76.0
        public static let NIMKit_PicImageHeight: CGFloat = 70.0
        public static let NIMKit_PicImageWidth: CGFloat = 70.0
        public static let NIMKit_PicRows = 2
        
        // Input Audio
        public static let NIMKit_ViewWidth: CGFloat = 160
        public static let NIMKit_ViewHeight: CGFloat = 110
        
        public static let NIMKit_BottomViewHeight: CGFloat = UIScreen.main.bounds.size.height * 0.22
     
        public static let NIMKit_TimeFontSize: CGFloat = 30
        public static let NIMKit_TipFontSize: CGFloat = 15
        public static let NIMKit_TextFontSize: CGFloat = 16
    
        // Input Emoticon Tab View
        public static let NIMInputEmoticonTabViewHeight: CGFloat = 35
        public static let NIMInputEmoticonSendButtonWidth: CGFloat = 50

        public static let NIMInputLineBoarder: CGFloat = 0.5
    }
}
