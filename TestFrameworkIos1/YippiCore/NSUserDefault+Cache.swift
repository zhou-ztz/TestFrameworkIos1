//
//  NSUserDefault+Wellness.swift
//  Yippi
//
//  Created by francis on 12/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation


extension UserDefaults {
    static var wellnessFloatShouldHide: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "wellness-float-should-hide")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "wellness-float-should-hide")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var socialTokenToolTipShouldHide: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "social-tooltip-should-hide")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "social-tooltip-should-hide")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    static var socialTokenOnboardHasShown: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "social-onboard-should-hide")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "social-onboard-should-hide")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var treasureToolTipShouldHide: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "treasure-tooltip-should-hide")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "treasure-tooltip-should-hide")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var luckyBagToolTipShouldHide: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "luckybag-tooltip-should-hide")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "luckybag-tooltip-should-hide")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var dailyTreasureHasShown: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "daily-treasure-box-should-shake")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "daily-treasure-box-should-shake")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var mobileTopUpDefaultRegion: String? {
        get {
            return UserDefaults.standard.value(forKey: "mobile-top-up-region") as? String
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "mobile-top-up-region")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var utilitiesBillTopUpHasUnread: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "srs-utilities-history-has-unread")
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: "srs-utilities-history-has-unread")
            UserDefaults.standard.synchronize()
        }
    }
    
    static func getMobileTopUpHasUnread(_ region: String) -> Bool {
        return UserDefaults.standard.bool(forKey: "mobile-top-up-has-unread-\(region)")
    }
    
    static func setMobileTopupHasUnread(hasUnread: Bool, _ region: String) {
        UserDefaults.standard.set(hasUnread, forKey: "mobile-top-up-has-unread-\(region)")
        UserDefaults.standard.synchronize()
    }
    
    static var biometricEnabled: Bool {
        get {
            guard let username = CurrentUserSessionInfo?.username else {
                return false
            }
            return UserDefaults.standard.bool(forKey: "biometric-enabled-\(username)")
        }
        
        set {
            guard let username = CurrentUserSessionInfo?.username else {
                return
            }
            UserDefaults.standard.set(newValue, forKey: "biometric-enabled-\(username)")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var sponsoredEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "sponsored-enabled")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "sponsored-enabled")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var recommendedEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "recommended-enabled")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "recommended-enabled")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var oldBuildVersion: String? {
        get {
            return UserDefaults.standard.string(forKey: "old-build-version")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "old-build-version")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var selectedFilterCountry: String? {
        get {
            return UserDefaults.standard.string(forKey: "selected-filter-country")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "selected-filter-country")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var selectedFilterLanguage: String? {
        get {
            return UserDefaults.standard.string(forKey: "selected-filter-language")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "selected-filter-language")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var selectedCreateLiveFilterLanguage: String? {
        get {
            return UserDefaults.standard.string(forKey: "selected-create-live-filter-language")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "selected-create-live-filter-language")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var countryFilterHadDefault: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "filter-country-had-default")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "filter-country-had-default")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var countryFilterTooltipShouldHide: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "filter-country-tooltip-should-hide")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "filter-country-tooltip-should-hide")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var languageFilterTooltipShouldHide: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "filter-language-tooltip-should-hide")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "filter-language-tooltip-should-hide")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var createLiveLanguageFilterTooltipShouldHide: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "create-live-filter-language-tooltip-should-hide")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "create-live-filter-language-tooltip-should-hide")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var lastPlayedAds: String? {
        get {
            return UserDefaults.standard.string(forKey: "previousAd")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "previousAd")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var adsPlayedCount: Int? {
        get {
            return UserDefaults.standard.integer(forKey: "playedCount")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "playedCount")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isMiniVideoTutorialHide: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "mini-video-tutorial-should-hide")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "mini-video-tutorial-should-hide")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var messageCollectionFilterTooltipShouldHide: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "message-collection-filter-language-tooltip-should-hide")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "message-collection-filter-language-tooltip-should-hide")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var messageFirstCollectionFilterTooltipShouldHide: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "message-first-collection-filter-language-tooltip-should-hide")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "message-first-collection-filter-language-tooltip-should-hide")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isInnerFeedTutorialHide: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "inner-feed-tutorial-should-hide")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "inner-feed-tutorial-should-hide")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    static var isMessageFirstCollection: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "is-message-first-collection")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "is-message-first-collection")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isLiveTutorialHide: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "live-scrollview-tutorial-should-hide")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "live-scrollview-tutorial-should-hide")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var referralCode: String? {
        get {
            return UserDefaults.standard.string(forKey: "referral-code")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "referral-code")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var yippsWantedNeedHideTooltip: Bool {
        get {
            guard let userinfo = CurrentUserSessionInfo else {
                return UserDefaults.standard.bool(forKey: Constants.baseUserDefaultKey + "GUEST01")
            }
            let keyname = Constants.baseUserDefaultKey + userinfo.userIdentity.stringValue
            
            return UserDefaults.standard.bool(forKey: keyname)
        }
        
        set {
            guard let userinfo = CurrentUserSessionInfo else {
                let keyname = Constants.baseUserDefaultKey + "GUEST01"
                UserDefaults.standard.set(newValue, forKey: keyname)
                UserDefaults.standard.synchronize()
                return
            }
            let keyname = Constants.baseUserDefaultKey + userinfo.userIdentity.stringValue
            
            UserDefaults.standard.set(newValue, forKey: keyname)
            UserDefaults.standard.synchronize()
        }
    }
    
    static func getCurrentModuleVersion(_ moduleId: Int) -> Int {
        guard let userinfo = CurrentUserSessionInfo else {
            return UserDefaults.standard.value(forKey: "app-module-GUEST01-\(moduleId)") as? Int ?? 1
        }
        return UserDefaults.standard.value(forKey: "app-module-\(userinfo.userIdentity)-\(moduleId)") as? Int ?? 1
    }
    
    static func setCurrentModuleVersion(_ module: ModuleModel) {
        updateIsModuleNewlyUpdated(module)
        guard let userinfo = CurrentUserSessionInfo else {
            UserDefaults.standard.set(module.version, forKey: "app-module-GUEST01-\(module.id)")
            UserDefaults.standard.synchronize()
            return
        }
        UserDefaults.standard.set(module.version, forKey: "app-module-\(userinfo.userIdentity)-\(module.id)")
        UserDefaults.standard.synchronize()
    }
    
    static func checkIsModuleNewlyUpdated(_ moduleId: Int) -> Bool {
        guard let userinfo = CurrentUserSessionInfo else {
            return UserDefaults.standard.bool(forKey: "app-module-is-new-GUEST01-\(moduleId)")
        }
        return UserDefaults.standard.bool(forKey: "app-module-is-new-\(userinfo.userIdentity)-\(moduleId)")
    }
    
    static func updateIsModuleNewlyUpdated(_ module: ModuleModel) {
        let currentVersion = getCurrentModuleVersion(module.id)
        if currentVersion < module.version {
            guard let userinfo = CurrentUserSessionInfo else {
                UserDefaults.standard.set(true, forKey: "app-module-is-new-GUEST01-\(module.id)")
                UserDefaults.standard.synchronize()
                return
            }
            UserDefaults.standard.set(true, forKey: "app-module-is-new-\(userinfo.userIdentity)-\(module.id)")
            UserDefaults.standard.synchronize()
        }
    }
    
    static func setIsModuleNewlyUpdated(_ moduleId: Int, isNew: Bool) {
        guard let userinfo = CurrentUserSessionInfo else {
            UserDefaults.standard.set(isNew, forKey: "app-module-is-new-GUEST01-\(moduleId)")
            UserDefaults.standard.synchronize()
            return
        }
        UserDefaults.standard.set(isNew, forKey: "app-module-is-new-\(userinfo.userIdentity)-\(moduleId)")
        UserDefaults.standard.synchronize()
    }
    
    static var isAutoPlayVideoDisable: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "autoplay-video-disable")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "autoplay-video-disable")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isVideoSoundEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "autoplay-video-sound-enable")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "autoplay-video-sound-enable")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isPlayVideoUsingWifiOnly: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "autoplay-video-using-wifi")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "autoplay-video-using-wifi")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isPlayVideoUsingWifiAndMobileData: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "autoplay-video-using-mobile-data-wifi")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "autoplay-video-using-mobile-data-wifi")
            UserDefaults.standard.synchronize()
        }
    }
    
    // IM Pull team list for the first time
    static var isDonePullTeamList: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "im-isDonePullTeamList")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "im-isDonePullTeamList")
            UserDefaults.standard.synchronize()
        }
    }
    
    // For IM fetch message use
    static var enableFetchIMMessage: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "disable-Fetch-IMMessage")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "disable-Fetch-IMMessage")
            UserDefaults.standard.synchronize()
        }
    }
    
    // For Yun Dun captcha epoch time
    static var yunDunEpochTime: Double {
        get {
            return UserDefaults.standard.double(forKey: "yundun-epoch")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "yundun-epoch")
        }
    }
    
    static var saveDownloadedAppId: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: "save-downloaded-appid") ?? [String]()
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "save-downloaded-appid")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var logRequestModel: LogRequestCheckModel? {
        get {
            if let jsonString = UserDefaults.standard.string(forKey: "logRequestModel"), let data = jsonString.data(using: .utf8) {
                do {
                    let jsonDecoder = JSONDecoder()
                    let model = try jsonDecoder.decode(LogRequestCheckModel.self, from: data)
                    return model
                } catch {
                    printIfDebug(error.localizedDescription)
                }
            }
            return nil
        }
        set {
            let jsonEncoder = JSONEncoder()
            if let data = newValue, let jsonData = try? jsonEncoder.encode(data) {
                let json = String(data: jsonData, encoding: .utf8)
                UserDefaults.standard.set(json, forKey: "logRequestModel")
                UserDefaults.standard.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: "logRequestModel")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    // MARK: Rewards Link
    static var dashboardServicesData: [[String: Any]]? {
        get {
            return UserDefaults.standard.value(forKey: "dashboardServices-data") as? [[String : Any]]
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: "dashboardServices-data")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var dashboardBannerData: [[String: Any]]? {
        get {
            return UserDefaults.standard.value(forKey: "dashboardBanner-data") as? [[String : Any]]
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: "dashboardBanner-data")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var dashboardMerchantData: [[String: Any]]? {
        get {
            return UserDefaults.standard.value(forKey: "dashboardMerchant-data") as? [[String: Any]]
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: "dashboardMerchant-data")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var dashboardDiscoverMoreData: [[String: Any]]? {
        get {
            return UserDefaults.standard.value(forKey: "dashboardDiscoverMore-data") as? [[String: Any]]
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: "dashboardDiscoverMore-data")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isCompleteTutorial: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "tutorial-coach")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "tutorial-coach")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var selectedCountryCode: String? {
        get {
            return UserDefaults.standard.string(forKey: "selected-country-code")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "selected-country-code")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var selectedCountryName: String? {
        get {
            return UserDefaults.standard.string(forKey: "selected-country-name")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "selected-country-name")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var loggerEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "logger-enabled")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "logger-enabled")
            UserDefaults.standard.synchronize()
        }
    }
    
    // Teen Mode
    static var teenModeIsEnable: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "teen-mode-enable")
        }

        set {
            UserDefaults.standard.set(newValue, forKey: "teen-mode-enable")
            UserDefaults.standard.synchronize()
        }
    }

    static var teenModePassword: String? {
        get {
            return UserDefaults.standard.string(forKey: "teen-mode-password")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "teen-mode-password")
            UserDefaults.standard.synchronize()
        }
    }
    
    // Deep link URL
    static var deeplinkURL: URL? {
        get {
            return UserDefaults.standard.url(forKey: "deeplink-url")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "deeplink-url")
            UserDefaults.standard.synchronize()
        }
    }
    
    // Push Notification Payload
    static var pushNotificationPayload: [String: Any]? {
        get {
            if let jsonData = UserDefaults.standard.data(forKey: "pushNotification-payload") {
                do {
                    if let payload = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        printIfDebug("userInfo = \(payload)")
                        return payload
                    }
                } catch {
                    printIfDebug("Failed to decode notification payload: \(error)")
                }
            }

            return nil
        }
        
        set {
            do {
                if let newValue = newValue {
                    let jsonData = try JSONSerialization.data(withJSONObject: newValue, options: [])
                    UserDefaults.standard.set(jsonData, forKey: "pushNotification-payload")
                } else {
                    UserDefaults.standard.set(newValue, forKey: "pushNotification-payload")
                }
                UserDefaults.standard.synchronize()
            } catch {
                printIfDebug("Failed to encode notification payload: \(error)")
            }
        }
    }
}
