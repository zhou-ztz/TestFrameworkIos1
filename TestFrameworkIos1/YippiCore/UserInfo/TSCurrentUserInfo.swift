//
//  TSCurrentUserInfo.swift
//  Thinksns Plus
//
//  Created by lip on 2017/1/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  当前用户数据存储类

import UIKit
import RealmSwift
import SDWebImage
import SobotKit
import NIMSDK

var CurrentUserSessionInfo: UserSessionInfo? {
    return TSCurrentUserInfo.share.userInfo?.toType(type: UserSessionInfo.self)
}

var CurrentUser: UserInfoModel? {
    return TSCurrentUserInfo.share.userInfo?.toType(type: UserInfoModel.self)
}


enum UserLoginType: String {
    case normal = "Normal"
    case facebook = "Facebook"
    case alipay = "Alipay"
    case apple = "Apple"
    
    var displayText:String {
        switch self {
        case .facebook:
            return "text_facebook".localized
        case .apple:
            return "text_apple".localized
        case .alipay:
            return "text_alipay".localized
        default:
            return "text_normal".localized
        }
    }
}

class TSCurrentUserInfo: NSObject {
    static let OneDaySecond: Int = 24 * 60 * 60
    static let share = TSCurrentUserInfo()
    static let isFirstToWalletVCKey = "isFirstToWalletVC"
    static let lastIgnoreAppVesinKey = "lastIgnoreAppVesin"
    static let lastCheckAppVesinKey = "lastCheckAppVesin"
    
    private override init() {
        accountToken = TSAccountTokenModel()
        accountManagerInfo = TSCurrentUserInfoSave()
    }
    
    var _userInfo: UserInfoType? {
        get {
            let user = UserSessionStoreManager().fetch().first
            return user as? UserInfoType
        }
        set {
            if let session = newValue?.toType(type: UserSessionInfo.self) {
                UserSessionStoreManager().removeAll()
                UserSessionStoreManager().add(list: [session])
            }
       
            _userInfo?.toType(type: UserSessionInfo.self)?.save()
        }
    }
    var userInfo: UserInfoType? {
        set {
            var newValue = newValue?.toType(type: UserSessionInfo.self)
            
            if newValue?.userIdentity != -1 {
                _userInfo = newValue
                UserDefaults.standard.set(newValue?.userIdentity, forKey: "TSCurrentUserInfo.uid")
                UserDefaults.standard.synchronize()
            }
            guard let autoUpgradeDialog = newValue?.haslevelUpgraded else { return }
            if autoUpgradeDialog == true {
                UserDefaults.standard.set(true, forKey: "gamification_leveling_upgrade")
                UserDefaults.standard.synchronize()
                TSUserNetworkingManager().getAutoLevelingDialogMessage { [weak self] (messageModel, msg, success) in
                guard success, let model = messageModel, let dialogMessage = model.displayMsg, let self = self else {
                    return
                }
                DispatchQueue.main.async {
                    let image = UIImage(contentsOfURL: dialogMessage.imageURL ?? "")
                    let resizeImage = image?.imageResize(sizeChange: CGSize(width: 172, height: 170))
                    
                    let lView = ZTLevelView(frame:CGRect(x: 0, y: 0, width: 0, height: 0), image: resizeImage, title: dialogMessage.title ?? "", descriptions: [dialogMessage.description ?? ""], buttonName: "View")
                    
                    let popup = TSAlertController(style: .popup(customview: lView))

                    lView.okBtnClosure = {
                        TSUserNetworkingManager().updateUserAutoLevelingUpgrade { (msg, success) in
                            newValue?.haslevelUpgraded = false
                            newValue?.save()
                            let isGamificationEnabled = TSAppConfig.share.moduleFlags.gamificationEnabled
                            popup.dismiss()
                            ///
                            if (isGamificationEnabled) {
                                UserDefaults.standard.set(false, forKey: "gamification_leveling_upgrade")
                                UserDefaults.standard.synchronize()
//                                let editVC = GamificationViewController()
//                                if let nc = TSRootViewController.share.tabbarVC?.selectedViewController as? UINavigationController {
//                                    nc.pushViewController(editVC, animated: true)
//                                }
                            }
                        }
                        
                    }
                    popup.modalPresentationStyle = .overFullScreen
//                    if let vc = TSRootViewController.share.tabbarVC {
//                        vc.present(popup, animated: false)
//                    }
                    
                    }
                }
            }
        }
        get {
            return _userInfo
        }
    }
    /// 当前用户的未读数信息
    lazy var unreadCount = TSUnreadCount()
    /// 显示红点如果当前用户有未读信息
    func showUnreadCountRedPoint() -> Bool {
        var flag = false
        
        var count = TSCurrentUserInfo.share.unreadCount.at + TSCurrentUserInfo.share.unreadCount.comments + TSCurrentUserInfo.share.unreadCount.reject + TSCurrentUserInfo.share.unreadCount.follows + TSCurrentUserInfo.share.unreadCount.like + TSCurrentUserInfo.share.unreadCount.system
        
        if count > 0 {
            flag = true
        }
        
        return flag
    }
    func getUnreadCount() -> Int {
        return TSCurrentUserInfo.share.unreadCount.at + TSCurrentUserInfo.share.unreadCount.comments + TSCurrentUserInfo.share.unreadCount.reject + TSCurrentUserInfo.share.unreadCount.follows + TSCurrentUserInfo.share.unreadCount.like + TSCurrentUserInfo.share.unreadCount.system
    }
    /// 是否同意使用蜂窝网络查看短视频
    var isAgreeUserCelluarWatchShortVideo: Bool = false
    /// 是否同意使用蜂窝网络下载短视频
    var isAgreeUserCelluarDownloadShortVideo: Bool = false
    
    var createID: Int = 0

    /// 账户鉴权口令
    ///
    /// - Note: 只要拥有该口令,就认为用户是合法的登录后的状态
    var accountToken: TSAccountTokenModel? = nil
    /// 用户管理权限信息
    var accountManagerInfo: TSCurrentUserInfoSave? = nil
    /// 登录状态
    var isLogin: Bool {
        return (self.accountToken == nil ? false : true)
    }
    var loginType: UserLoginType {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "isusersociallogin")
        }
        get {
            guard let value = UserDefaults.standard.value(forKey: "isusersociallogin") as? String, let type = UserLoginType(rawValue: value) else {
                return .normal
            }
            return type
        }
    }
    /// 检查鉴权口令的过期状态
    func isOvertimeAccount() -> Bool {
        guard let accountToken = self.accountToken else { return false }
        if accountToken.token.isEmpty || accountToken.expireInterval == 0 {
            return false
        }
        let currentTime = Int(Date().timeIntervalSince1970)
        // 注：之前token有效期不足一天时则刷新口令，但刷新时别的地方有使用token的请求导致异常。
        let overtimerTimeStamp = accountToken.createInterval + accountToken.expireInterval * 60
        return currentTime > overtimerTimeStamp
    }

    /// 当前用户创建的资源的本地唯一标志
    ///
    /// Note (old method): 唯一标志等于 MaxInt * 0.5 + 已发送失败的资源数量(来自数据库) - 秒时间戳 + 1 拼接上用户id，每获取一次，该数字+1。应用重启后数字重置
    func createResourceID() -> Int {
//        let timestamp = Int(Date().timeIntervalSince1970)
//
//        let failMoments = TSDatabaseMoment().getFaildSendMoments()
//        guard let uid = self.userInfo?.userIdentity else {
//            assertionFailure()
//            return 0
//        }
//
//        var failResource = 0
//        if failMoments.isEmpty == false {
//            for item in failMoments {
//                failResource += item.pictures.count
//                failResource += 1
//            }
//        }
//
//        return Int([uid, timestamp].map(String.init).joined()) ?? 0
        return Int(Date().timeIntervalSince1970)
    }
    
    /// Used for upload image ID
    func createImageID() -> Int {
//        let timestamp = Int(Date().timeIntervalSince1970)
//            let failMoments = TSDatabaseMoment().getFaildSendMoments()
//            guard let uid = self.userInfo?.userIdentity else {
//                assertionFailure()
//                return 0
//            }
//
//            var failResource = 0
//            if failMoments.isEmpty == false {
//                for item in failMoments {
//                    failResource += item.pictures.count
//                    failResource += 1
//                }
//            }
//
//            self.createID = self.createID + uid + timestamp + failResource + 1
//        return self.createID
        return Int(Date().timeIntervalSince1970)
    }

    /// 当前用户注销
    func logOut() {
        
        //重置当前用户的高级资料卡片状态
        if let userInfo = TSCurrentUserInfo.share.userInfo {
            let userId = userInfo.userIdentity.stringValue
            let professional_key = "FIRESTLOADPROFESSIONAL\(userId)"
            UserDefaults.standard.set(false, forKey: professional_key)
            UserDefaults.standard.synchronize()
        }
        // 注销鉴权数据
        TSAccountTokenModel.reset()
        TSCurrentUserInfoSave.reset()
        TSCurrentUserInfo.share._userInfo = nil
                
        StoreManager.shared.deleteAllFiles()
        
        IMTokenModel.reset()
        accountToken = nil
        accountManagerInfo = nil
        RequestNetworkData.share.configAuthorization(nil)
        // 注销推送别名
//        let AppDelegate = UIApplication.shared.delegate as! AppDelegate
//        AppDelegate.logoutEngageLabAlias()
//        AppDelegate.resetScreenBrightness()
        
        unreadCount.clearAllUnreadCount()
        // 数据库
//        DatabaseManager().deleteAll()
        TSCurrentUserInfo.resetIsFirstToWalletVC()
        // 清空所有缓存图片
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
        
        let cacheDefault: VerifyCacheUserInfo & VerifyCacheAccountInfo & VerifyAddressUserInfo = UserDefaults.standard
        cacheDefault.clearVerifyAccCache()
        cacheDefault.clearVerifyUserCache()
        cacheDefault.clearCache()

        UserDefaults.dailyTreasureHasShown = false
        UserDefaults.mobileTopUpDefaultRegion = nil
        UserDefaults.selectedFilterLanguage = nil
        UserDefaults.selectedFilterCountry = nil
        UserDefaults.selectedCountryCode = nil
        UserDefaults.countryFilterHadDefault = false
        UserDefaults.enableFetchIMMessage = false
        UserDefaults.isDonePullTeamList = false

        PostTaskManager.shared.clear()
        
        // NIM
        NIMSDK.shared().loginManager.logout { _ in
//            NIMBridgeManager.sharedInstance().logout()
            NIMSDKManager.shared.logout()
        }
        
        // clear user info from zclib
//        ZCLibClient.getZCLibClient().libInitInfo = LaunchManager.shared.generateZCLibInitInfo(userInfo: nil)
    }
    // MARK: - 钱包

    /// 钱包页面是否第一次进入状态
    var isFirstToWalletVC: Bool {
        return UserDefaults.standard.bool(forKey: TSCurrentUserInfo.isFirstToWalletVCKey)
    }

    /// 重置钱包页面是否第一次进入状态
    class func resetIsFirstToWalletVC() {
        UserDefaults.standard.removeObject(forKey: TSCurrentUserInfo.isFirstToWalletVCKey)
    }

    /// 改变钱包页面是否第一次进入状态
    class func setNoTheFirstToWalletVC() {
        UserDefaults.standard.set(true, forKey: TSCurrentUserInfo.isFirstToWalletVCKey)
    }
    /// 最新忽略的版本号
    var lastCheckAppVesin: AppVersionCheckModel? {
        set {
            let modelJson = newValue?.toJSONString() != nil ? newValue?.toJSONString() : ""
            UserDefaults.standard.set(modelJson, forKey: TSCurrentUserInfo.lastIgnoreAppVesinKey)
            UserDefaults.standard.synchronize()
        }
        get {
            if let modelJson = UserDefaults.standard.value(forKey: TSCurrentUserInfo.lastIgnoreAppVesinKey) as? String {
                if let model = AppVersionCheckModel(JSONString: modelJson) {
                    return model
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    /// 最新忽略的版本号
    var lastIgnoreAppVersion: AppVersionCheckModel? {
        set {
            let modelJson = newValue?.toJSONString()
            if modelJson != nil {
                UserDefaults.standard.set(modelJson, forKey: TSCurrentUserInfo.lastCheckAppVesinKey)
                UserDefaults.standard.synchronize()
            }
        }
        get {
            if let modelJson = UserDefaults.standard.value(forKey: TSCurrentUserInfo.lastCheckAppVesinKey) as? String {
                if let model = AppVersionCheckModel(JSONString: modelJson) {
                    return model
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    
    /// NIM 的群组邀约系统信息
    var groupInvitationUnreadCount: Int {
        let filter = NIMSystemNotificationFilter()
        filter.notificationTypes = [NIMSystemNotificationType.teamInvite.rawValue, NIMSystemNotificationType.teamApply.rawValue] as [NSNumber]
        return NIMSDK.shared().systemNotificationManager.allUnreadCount(filter)
    }

    /// 直播按钮显示
    var isLiveEnabled: Bool {
        return (self.userInfo?.toType(type: UserSessionInfo.self))?.isLiveEnabled == true || TSAppConfig.share.launchInfo?.isLiveEnabled == true
    }
    
    var isMiniVideoEnabled: Bool {
        return (self.userInfo?.toType(type: UserSessionInfo.self))?.isMiniVideoEnabled == true || TSAppConfig.share.launchInfo?.isMiniVideoEnabled == true
    }
}
