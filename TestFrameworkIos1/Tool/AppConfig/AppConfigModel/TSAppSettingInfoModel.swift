//
//  TSAppSettingInfoModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 18/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  启动信息的数据模型

// 广告/支付配置/打赏金额配置等暂时使用的别处,后续迁移过来 2017年10月17日13:42:47
// 后台提供的 site内的站点开关等 暂时不支持解析和使用
// site.gold:open 暂不支持

import Foundation
import ObjectMapper

/// 注册的类型
enum RegisterMethod: String {
    case all
    case mobile = "mobile-only"
    case mail = "mail-only"
}

class RegisterMethodTransform: TransformType {
    public typealias Object = RegisterMethod
    public typealias JSON = String

    open func transformFromJSON(_ value: Any?) -> RegisterMethod? {
        if let type = value as? String {
            return RegisterMethod(rawValue: type)
        }
        return nil
    }

    open func transformToJSON(_ value: RegisterMethod?) -> String? {
        if let type = value {
            return type.rawValue
        }
        return nil
    }
}

/// 是否需要完善资料
enum RegisterFixed: String {
    case need = "need"
    case noneed = "no-need"
}

class RegisterFixedTransform: TransformType {
    public typealias Object = RegisterFixed
    public typealias JSON = String
    open func transformFromJSON(_ value: Any?) -> RegisterFixed? {
        if let type = value as? String {
            return RegisterFixed(rawValue: type)
        }
        return nil
    }

    open func transformToJSON(_ value: RegisterFixed?) -> String? {
        if let type = value {
            return type.rawValue
        }
        return nil
    }
}

/// 注册的方式
enum AccountType: String {
    case all
    case thirdPart
    case invited // 该类型暂时不支持更多操作
}

class AccountTypeTransform: TransformType {
    public typealias Object = AccountType
    public typealias JSON = String

    open func transformFromJSON(_ value: Any?) -> AccountType? {
        if let type = value as? String {
            return AccountType(rawValue: type)
        }
        return nil
    }

    open func transformToJSON(_ value: AccountType?) -> String? {
        if let type = value {
            return type.rawValue
        }
        return nil
    }
}

/// Note: - 此处记录的属性初始值没有意义,会被plist 文件内的值覆盖
class TSAppSettingInfoModel: Mappable {
    // IM 聊天助手用户信息
    var imHelper: Int?
    var walletRatio: Int = 0 {
        didSet {
            guard walletRatio >= 1 else {
                walletRatio = oldValue
                return
            }
        }
    }
    var walletRechargeType: [String] = [String]()
    var ads: [TSAdvertModel]?
    var httpdnsPullConfig: Bool = false
    var httpdnsPushConfig: Bool = false

    /// 是否开启付费投稿
    var newsContributePay: Bool = false
    /// 是否开启只允许认证用户投稿
    var newsContributeVerified: Bool = false
    /// 付费投稿金额，开启付费投稿时投稿会自动扣除
    var newsContributeAmount: Int = 0 {
        didSet {
            guard newsContributeAmount >= 0 else {
                newsContributeAmount = oldValue
                return
            }
        }
    }
    /// 后台是否配置签到
    var checkin: Bool = false
    /// 签到金额配置
    var checkBalance: Int = 0
    /// 是否开启打赏功能
    var isOpenReward: Bool = false
    /// 打赏参数
    var rewardAmounts: [Int] = [] {
        didSet {
            guard rewardAmounts.isEmpty == false && rewardAmounts.count >= 4 else {
                rewardAmounts = oldValue
                return
            }
            if rewardAmounts.count >= 4 {
                rewardAmounts = Array(rewardAmounts[0...3])
            }
        }
    }
    /// 悬赏规则 reward_rule
    var reward_rule: String = ""
    /// 积分名称
    var goldName: String =  "defualt_golde_name".localized
    /// 是否开放注册
    var registerAllOpen: Bool = true
    /// 注册时展示服务条款及隐私政策
    var registerShowTerms: Bool = true
    /// 注册类型
    var registerMethod: RegisterMethod = .all
    /// 账号类型
    var accountType: AccountType = .all
    /// 用户服务条款及隐私政策
    ///
    /// - Note: markdown 格式
    var content: String = "" {
        didSet {
            guard content.count >= 1 else {
                content = oldValue
                return
            }
        }
    }
    /// 注册完成后是否需要立即完善资料
    ///
    /// - Note: 暂时处理为是否显示 选择标签页面
    var registerCompleteData: Bool = true
    var registerFixed: RegisterFixed = .need
    /// 动态打赏
    var isFeedReward: Bool = false
    /// 动态支付
    var isFeedPay: Bool = false
    /// 动态项目项目金额
    var feedItems: [Int] = []
    /// 动态文字数量
    var feedLimit: Int = 0
    /// 邀请信息
    var inviteUserInfo: String =  "invite_msg_not_set_up".localized
    /// 关于我们
    var aboutUsUrl: String = ""

    var appDisplayName: String {
        let infoDic = Bundle.main.infoDictionary
        var appName = NSLocalizedString("CFBundleDisplayName", tableName: "InfoPlist", bundle: Bundle.main, value: "", comment: "") as String
        if appName == "CFBundleDisplayName" {
            // 没有配置或者错误配置InfoPlist.strings
            if (infoDic?.keys.contains("CFBundleDisplayName"))! {
                // 配置了plist中的显示名称
                appName = infoDic!["CFBundleDisplayName"] as! String
            } else {
                appName = infoDic!["BundleName"] as! String
            }
        }
        return appName
    }
    var appURLScheme: String {
        return Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
    }

    /// 创建圈子是否需要用户认证
    var groupBuildNeedVerified = false
    /// 圈子打赏开关
    var isGroupReward = false
    /// 数据请求数目
    var limit: Int = 15
    /// 是否开启积分支付输入密码
    var shouldShowRewardAlert = false
    /// 是否开启积分支付输入密码
    var shouldShowTransferAlert = false
    /// 发动态最小视频时长
    let postMomentsRecorderVideoMinDuration: CGFloat = 10
    /// 发动态最大视频时长
    let postMomentsRecorderVideoMaxDuration: CGFloat = 60
    /// Modules in more tab
    var modules: [ModuleModel]?
    
    //var yippiAds: WaveAdsModel?
    
    var showTrtMenu: Bool? 

    var waveUrl: String?
    var waveAbstractVideoUrl: String?
    var waveBlueVideoUrl: String?

    var shareUrlPrefix: String?

    var referralUrlPrefix: String?
    /// 打赏参数
    var rewardList: [RewardModel] = []
    var showMessageRequest: Bool = false
    var isLiveEnabled = false
    var isSocialTokenEnabled = false
    var isMiniVideoEnabled = false
    var liveEggCountDowns: [Int] = [5,10,15,20]
    var liveRewardOptions: [Int] = [10,20,50,100]
    var showReferral: Bool = false
    var userSessionInterval: Int = 5
    var discoverSOTDRankShow: Bool = false
    var servicesModuleUIOptionValue: Int?
    var scashPaymentGatewayOption: Int?
    var pandaProviderCountry: [String]?
    var rlPaymentType: Int?
    var mpExtras: String?
    var userServicesWhitelist: [Int]?
    var eostreApi: String?

    required init?(map: Map) {
    }

    init() {
    }

    func mapping(map: Map) {
        imHelper <- (map["im:helper-user"], SingleStringTransform())
        walletRatio <- map["wallet.ratio"]
        walletRechargeType <- map["wallet.recharge.types"]
        ads <- map["ad"]
        newsContributePay <- map["news.contribute.pay"]
        newsContributeVerified <- map["news.contribute.verified"]
        newsContributeAmount <- map["news.pay_contribute"]
        checkin <- map["checkin.switch"]
        checkBalance <- map["checkin.balance"]
        isOpenReward <- map["site.reward.status"]
        rewardAmounts <- (map["site.reward.amounts"], StringIntArrayTransformer)
        reward_rule <- map["Q&A.reward_rule"]
        goldName <- map["site.currency_name.name"]
        registerAllOpen <- map["registerSettings.open"]
        registerShowTerms <- map["registerSettings.showTerms"]
        registerMethod <- (map["registerSettings.method"], RegisterMethodTransform())
        accountType <- (map["registerSettings.type"], AccountTypeTransform())
        content <- map["registerSettings.content"]
        registerCompleteData <- map["registerSettings.completeData"]
        registerFixed <- (map["registerSettings.fixed"], RegisterFixedTransform())
        isFeedReward <- map["feed.reward"]
        isFeedPay <- map["feed.paycontrol"]
        feedItems <- (map["feed.items"], SingleStringTransform())
        feedLimit <- map["feed.limit"]
        groupBuildNeedVerified <- map["group:create.need_verified"]
        isGroupReward <- map["group:reward.status"]
        inviteUserInfo <- map["site.user_invite_template"]
        aboutUsUrl <- map["site.about_url"]
        limit <- map["limit"]
        shouldShowTransferAlert <- map["transfer-validate-user-password"]
        shouldShowRewardAlert <- map["reward-validate-user-password"]
        waveUrl <- map["wave-url"]
        waveAbstractVideoUrl <- map["wave-abstract-video-url"]
        waveBlueVideoUrl <- map["wave-blue-video-url"]
        modules <- map["modules"]
       // yippiAds <- map["yippi-ads"]
        shareUrlPrefix <- map["share-url-prefix"]
        referralUrlPrefix <- map["referral-url-prefix"]
        showMessageRequest <- map["features.message_request"]
        isLiveEnabled <- map["features.live"]
        isSocialTokenEnabled <- map["features.token"]
        isMiniVideoEnabled <- map["features.is_enabled_mini_video"]
        rewardList <- map["site.reward_list"]
        liveEggCountDowns <- (map["site.live_egg.countdown_options.countdown"], StringIntArrayTransformer)
        liveRewardOptions <- (map["site.live_egg.reward_options.amounts"], StringIntArrayTransformer)
        showReferral <- map["registerSettings.showReferral"]
        showTrtMenu <- map["float_menu.show_trt"]
        userSessionInterval <- map["site.session_interval"]
        httpdnsPullConfig <- map["httpdns.pull-stream"]
        httpdnsPushConfig <- map["httpdns.push-stream"]
        discoverSOTDRankShow <- map["features.discover_sotd_rank_show"]
        servicesModuleUIOptionValue <- map["services_module_ui_option_value"]
        scashPaymentGatewayOption <- map["scash_payment_gateway_option"]
        pandaProviderCountry <- map["panda_provider_country"]
        rlPaymentType <- map["rl_payment_type"]
        mpExtras <- map["rl_biz.extra"]
        userServicesWhitelist <- map["user_services_whitelist"]
        eostreApi <- map["eostre_api"]
    }
}

/// 资讯投稿限制类型
enum TSNewsContributeLimitType {
    /// 无限制
    case none
    /// 仅认证
    case onlyVerified
    /// 仅投稿付费
    case onlyPay
    /// 认证且投稿付费
    case verifiedAndPay
}

/// 配置扩展
extension TSAppSettingInfoModel {
    // 获取资讯投稿限制类型
    var newContributeLimitType: TSNewsContributeLimitType {
        var limitType: TSNewsContributeLimitType = .none
        if self.newsContributeVerified && self.newsContributePay {
            limitType = .verifiedAndPay
        } else if self.newsContributeVerified && !self.newsContributePay {
            limitType = .onlyVerified
        } else if !self.newsContributeVerified && self.newsContributePay {
            limitType = .onlyPay
        }
        return limitType
   }
}
