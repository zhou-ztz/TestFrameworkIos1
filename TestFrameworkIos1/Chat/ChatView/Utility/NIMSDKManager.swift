//
//  NIMSDKManager.swift
//  Yippi
//
//  Created by Tinnolab on 13/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
import NEMeetingKit
//import NIMPrivate
enum NimKitType {
    case infoId
    case showName
}

class NIMSDKManager: NSObject, NIMSDKConfigDelegate, MeetingServiceListener {
    var user: TSUser?
    var teams: [NIMTeam] = []
    public static let apiURL = "https://app.netease.im/api";
    public static let shared = NIMSDKManager()
    
    override init() {
        super.init()
    }
    
    func setup(_ delegate: NIMLoginManagerDelegate?, currentUser: TSUser?) -> Self {
        //        setupCustomBundleSetting()
        setupNIMSDK()
        setupServices()
        //
        commonInitListenEvents(delegate as! NIMLoginManagerDelegate)
        
        user = currentUser
        
        //        NTESServiceManager.shared().start()
        return self
    }
    
    func setupNIMSDK() {
        NIMSDKConfig.shared().delegate = self
        NIMSDKConfig.shared().shouldSyncUnreadCount = true
        NIMSDKConfig.shared().maxAutoLoginRetryTimes = 10
        NIMSDKConfig.shared().maximumLogDays = BundleSetting.sharedConfig().maximumLogDays()
        NIMSDKConfig.shared().shouldCountTeamNotification = BundleSetting.sharedConfig().countTeamNotification()
        NIMSDKConfig.shared().animatedImageThumbnailEnabled = BundleSetting.sharedConfig().animatedImageThumbnailEnabled()
        NIMSDKConfig.shared().fetchAttachmentAutomaticallyAfterReceiving = BundleSetting.sharedConfig().autoFetchAttachment()
        NIMSDKConfig.shared().fetchAttachmentAutomaticallyAfterReceivingInChatroom = BundleSetting.sharedConfig().autoFetchAttachment()
        NIMSDKConfig.shared().customTag = String(NIMLoginClientType.typeiOS.rawValue)
        // MARK: 2 - Yippi, 4 - Rewards Link
        NIMSDKConfig.shared().customClientType = 4
        NIMSDKConfig.shared().asyncLoadRecentSessionEnabled = true
        //同步置顶
        NIMSDKConfig.shared().shouldSyncStickTopSessionInfos = true
        
#if DEBUG
        let appKey = Constants.NIMKey
        let apnsCername = "RewardsLink Stg"
        let pkCername = "PUSHKITSTG"
#else
        let appKey  = Constants.NIMKey
        let apnsCername = "RewardsLink Prod"
        let pkCername = "YIPPIPUSHKIT"
#endif
        
        let option = NIMSDKOption(appKey: appKey)
        option.apnsCername = apnsCername
        option.pkCername = pkCername
        NIMSDK.shared().register(with: option)
        
        //注册自定义消息的解析器
        NIMCustomObject.registerCustomDecoder(CustomAttachmentDecoder())
        
        //        let isUsingDemoAppKey = NIMSDK.shared().isUsingDemoAppKey()
        //        NIMSDKConfig.shared().teamReceiptEnabled = isUsingDemoAppKey
        NIMSDKConfig.shared().teamReceiptEnabled = true
        
        let sceneDict: NSMutableDictionary = NSMutableDictionary(dictionary: ["nim_custom1":1])
        NIMSDK.shared().sceneDict = sceneDict
        
        //音视频2.0初始化
        //        let coreEngine = NERtcEngine.shared()
        //        let context = NERtcEngineContext()
        //        context.engineDelegate = self
        //        context.appKey = appKey
        //        coreEngine.setupEngine(with: context)
        loginAPP()
    }
    
    //meetingkit 初始化
    func meetingKitConfig(completion: @escaping () -> Void) {
#if DEBUG
        let appKey = Constants.NIMKey
        let apnsCername = "RewardsLink Stg"
        let pkCername = "PUSHKITSTG"
#else
        let appKey  = Constants.NIMKey
        let apnsCername = "RewardsLink Prod"
        let pkCername = "YIPPIPUSHKIT"
#endif
        //meetingkit
        let config = NEMeetingKitConfig()
        config.appKey = appKey
        let language =  LocalizationManager.getCurrentLanguage()
        if language == LanguageIdentifier.chineseSimplified.rawValue || language == LanguageIdentifier.chineseTraditional.rawValue {
            config.language = .CHINESE
        } else if language == LanguageIdentifier.japanese.rawValue {
            config.language = .JAPANESE
        } else {
            config.language = .ENGLISH
        }
        //config.reuseIM = true
        config.broadcastAppGroup = "group.com.togl.getyippi.share"
        NEMeetingKit.getInstance().initialize(config) { resultCode, resultMsg, result in
            if resultCode == 0 {
                //成功
                completion()
                NEMeetingKit.getInstance().getMeetingService()?.add(self)
            }
        }
        
    }
    
    func fetchGroupInfo(completion: @escaping () -> Void) {
        NIMSDK.shared().teamManager.fetchTeams(withTimestamp: 0, completion: { error, teams  in
            if (error != nil) {
                printIfDebug("NIM SDK fetch team error: \(error)")
            }
            
            self.teams = teams ?? []
            
            self.teams = self.teams.sorted(by: {
                let date = Date(timeIntervalSince1970: $0.createTime)
                let date2 = Date(timeIntervalSince1970: $1.createTime)
                
                return date.compare(date2) == .orderedDescending
            })
            
            completion()
        })
    }
    
    func getRecentSession() -> [NIMRecentSession] {
        return NIMSDK.shared().conversationManager.allRecentSessions() ?? []
    }
    
    func fetchMessageHistory(completion: @escaping () -> Void) {
        let currentRecent = getRecentSession()
        let totalTeamCount = self.teams.count
        var processItemsCount = 0
        
        DispatchQueue.global(qos: .background).async {
            for item in self.teams {
                if let exist = currentRecent.filter({ $0.session?.sessionId == item.teamId }).first {
                    processItemsCount += 1
                    
                    if processItemsCount == totalTeamCount {
                        completion()
                    }
                    continue
                }
                
                if let teamId = item.teamId {
                    let session = NIMSession(teamId as String, type: .team)
                    
                    let serverOption = NIMHistoryMessageSearchOption()
                    serverOption.startTime = item.createTime
                    serverOption.endTime = Date().timeIntervalSince1970
                    serverOption.limit = 1
                    serverOption.order = .desc
                    serverOption.sync = true
                    serverOption.createRecentSessionIfNotExists = true
                    
                    NIMSDK.shared().conversationManager.fetchMessageHistory(session, option: serverOption, result: { error, messages in
                        if error != nil {
                            printIfDebug("fetch message history: \(error)")
                        }
                        processItemsCount += 1
                        
                        if processItemsCount == totalTeamCount {
                            completion()
                        }
                    })
                } else {
                    processItemsCount += 1
                    
                    if processItemsCount == totalTeamCount {
                        completion()
                    }
                }
            }
        }
    }
    
    func addEmptyRecentSession() {
        let currentRecent = getRecentSession()
        
        DispatchQueue.global(qos: .background).async {
            for item in self.teams {
                if let exist = currentRecent.filter({ $0.session?.sessionId == item.teamId }).first {
                    continue
                }
                
                if let teamId = item.teamId {
                    let session = NIMSession(teamId as String, type: .team)
                    NIMSDK.shared().conversationManager.addEmptyRecentSession(by: session)
                }
            }
        }
    }
    
    func loginAPP(){
        var request: LoginRequestType? = nil
        var accountType: String = ""
        let username = "azizistg16"
        let password = "123456"
        request = LoginRequestType(logType: .username, id: username, pass: password, verifiable_code: nil)
        accountType = "Username"
        request?.execute(
            onSuccess: { [weak self] response in
                guard let self = self else { return }
                
                guard let response = response, let username = response.username else {
                  return
                }
                
                let token = TSAccountTokenModel(
                    with: response.accessToken.orEmpty,
                    neteaseToken: response.neteaseToken.orEmpty,
                    expireInterval: response.expireIn ?? 60,
                    refreshTTL: response.refreshTTL ?? 20160,
                    tokenType: response.tokenType.orEmpty)
                
                token?.save()
                TSCurrentUserInfo.share.loginType = .normal
                TSCurrentUserInfo.share.accountToken = token
                UserDefaults.standard.set(TSAppConfig.share.environment.identifier, forKey: AppEnvironment.AppEnvinronmentIdentifier)
                UserDefaults.sponsoredEnabled = true
                RequestNetworkData.share.configAuthorization(TSCurrentUserInfo.share.accountToken?.token)
                self.login(username: username, password: token!.neteaseToken) { error in
                    
                }
                self.getUserInfo()
                
            },
            onError: { [weak self] (error) in
  
        })
            
        
    }
    
    func login(username: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        NIMSDK.shared().loginManager.login(username, token: password) { error in
            if (error == nil) {
                let sdkData = IMLoginData(account: username, token: password)
                //IMLoginManager.shared.setCurrentLoginData(sdkData)
                self.autoLogin(loginData: sdkData)
                self.quertMeetingKitAccountInfo()
                completion(error)
            } else {
                completion(error)
            }
        }
    }
    
    func getUserInfo(){
        TSUserNetworkingManager().getCurrentUserInfo { (user, message, status) in
            guard let user = user else { return }
            
            userConfiguration = UserConfig.get()
            userConfiguration?.avatarUrl = user.avatarUrl
            userConfiguration?.displayname = user.name
            userConfiguration?.certificateUrl = user.verificationIcon
            
            userConfiguration?.save()
            NotificationCenter.default.post(name: Notification.Name.Setting.configUpdated, object: nil)
        }
    }
    
    func autoLogin(loginData: IMLoginData, currentUser: TSUser? = nil) {
        let autoLoginData = NIMAutoLoginData()
        autoLoginData.account = loginData.account
        autoLoginData.token = loginData.token
        
        NIMSDK.shared().loginManager.autoLogin(autoLoginData)
        
        if (currentUser != nil) {
            self.user = currentUser
        }
    }
    
    func updateApnsToken(deviceToken: Data) {
        NIMSDK.shared().updateApnsToken(deviceToken)
    }
    
    func updatePushkitToken(token: Data) {
        NIMSDK.shared().updatePushKitToken(token)
    }
    
    func commonInitListenEvents(_ delegate: NIMLoginManagerDelegate) {
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: NSNotification.Name("NTESNotificationLogout"), object: nil)
        NIMSDK.shared().loginManager.add(delegate)
    }
    
    @objc func logout() {
        IMLoginManager.shared.currentLoginData = nil
        NIMSDK.shared().loginManager.logout()
        NEMeetingKit.getInstance().logout { code, msg, result in
            
        }
    }
    
    func showAutoLoginErrorAlert(_ error: Error?) {
        //        let message = SessionUtil.formatAutoLoginMessage(error)
        NotificationCenter.default.post(name: NSNotification.Name.Session.forceLoggedOut, object: nil, userInfo: [
            "message": "acc_kicked_out".localized
        ])
    }
    
    func onAppWillEnterForeground() {
        //        NIMSDKConfig.shared().fetchAttachmentAutomaticallyAfterReceiving = NTESBundleSetting.sharedConfig().autoFetchAttachment()
        //        NIMSDKConfig.shared().fetchAttachmentAutomaticallyAfterReceivingInChatroom = NTESBundleSetting.sharedConfig().autoFetchAttachment()
    }
    
    func setupServices() {
//        NTESNotificationCenter.shared().start()
//        NTESServiceManager.shared().start()
        IMNotificationCenter.sharedCenter.start()
        //        [[NTESNotificationCenter sharedCenter] start];
        //        [[NTESSubscribeManager sharedManager] start];
        //        [[NTESServiceManager sharedManager] start];
        //[[NTESRedPacketManager sharedManager] start];
    }
    
    //meetingkit 登录
    func meetingkitLogin(username: String, password: String) {
        NEMeetingKit.getInstance().login(username, token: password) { code, msg, result in
            if code == 0 {
                print("NEMeetingKit登录成功")
            }
            print("NEMeetingKit登录=\(msg)")
        }
    }
    
    func quertMeetingKitAccountInfo() {
        TSIMNetworkManager.quertMeetingKitAccountInfo { model, error in
            if let error = error {
                
            }else {
                if let model = model {
                    UserDefaults.standard.setValue(model.userUuid, forKey: "MeetingKit-userUuid")
                    UserDefaults.standard.setValue(model.userToken, forKey: "MeetingKit-userToken")
                    UserDefaults.standard.synchronize()
                    //self.meetingkitLogin(username: model.userUuid, password: model.userToken)
                }
            }
            
        }
    }
    
    func onInjectedMenuItemClick(_ clickInfo: NEMenuClickInfo, meetingInfo: NEMeetingInfo, stateController: @escaping NEMenuStateController) {
        if clickInfo.itemId == 1000 {
            //邀请好友
            if let vc = UIApplication.topViewController() {
                let invite = MeetingInviteViewController(meetingNum: meetingInfo.meetingNum)
                invite.view.backgroundColor = .white
                let nav = TSNavigationController(rootViewController: invite)
                nav.setCloseButton(backImage: true, titleStr: "meeting_private_invite".localized, customView: nil)
                vc.present(nav.fullScreenRepresentation, animated: true)
            }
        }
    }
    
    func getNimKitInfo(userId: String, type: NimKitType = .infoId) -> String {
        var result: String = ""
        
//        switch type {
//        case .infoId:
//            result = NIMBridgeManager.sharedInstance().getUserInfo(userId).infoId ?? ""
//        case .showName:
//            result = NIMBridgeManager.sharedInstance().getUserInfo(userId).showName ?? ""
//        default:
//            break
//        }
        
        return result
    }
    
    func getCurrentLoginUserName() -> String {
        return NIMSDK.shared().loginManager.currentAccount()
    }
    
    func getDisplayNameByUsername(username: String) -> String {
        guard let nickname = NIMSDK.shared().userManager.userInfo(username)?.userInfo?.nickName else {
            return username
        }
        
        return nickname
    }
    
    func getDisplayName(from message: NIMMessage) -> String {
        let senderNick = message.senderName.orEmpty
        let username = message.from.orEmpty
        
        guard let nickname = NIMSDK.shared().userManager.userInfo(username)?.userInfo?.nickName else {
            if senderNick.isEmpty == false {
                return senderNick
            }
            return username
        }
        
        return nickname
    }
    
    func getAvatarIconFromMessage(message: NIMMessage?) -> AvatarInfo {
        var info = AvatarInfo()
        info.username = message?.from ?? ""
        info.avatarPlaceholderType = .unknown
        
        guard let message = message else { return info }
        
        if let ext = message.remoteExt, let avatarURL = ext["avatar"] as? String, avatarURL != "" {
            info.avatarURL = avatarURL
            if let badgeURL = ext["badge_url"] as? String, badgeURL != "" {
                info.verifiedIcon = badgeURL
                info.verifiedType = "badge"
                return info
            }
        }
        
        return getAvatarIcon(userId: message.from ?? "")
    }
    
    func getAvatarIcon(userId: String, isTeam: Bool = false) -> AvatarInfo {
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = ""
        avatarInfo.verifiedIcon = ""
        avatarInfo.verifiedType = ""
        
        if isTeam {
            if let team: NIMTeam = NIMSDK.shared().teamManager.team(byId: userId) {
                avatarInfo.nickname = team.teamName
                avatarInfo.avatarURL = team.thumbAvatarUrl
                avatarInfo.avatarPlaceholderType = .group
            }
        } else {
            let user = NIMSDK.shared().userManager.userInfo(userId)
            let info = user?.userInfo?.ext
            
            if let data = info?.data(using: .utf8) {
                do {
                    let jsonDecoder = JSONDecoder()
                    let userInfo = try jsonDecoder.decode(TSNIMUserInfo.self, from: data)
                    avatarInfo.avatarURL = userInfo.avatar?.url ?? ""
                    avatarInfo.verifiedIcon = userInfo.verified?.icon ?? ""
                    avatarInfo.verifiedType = userInfo.verified?.type ?? ""
                    avatarInfo.nickname = user?.userInfo?.nickName ?? ""
                } catch let error {
                    printIfDebug(error.localizedDescription)
                }
            }
            
//            if let avatarURL = avatarInfo.avatarURL, !avatarURL.isEmpty {
//                return avatarInfo
//            }
//            
//            avatarInfo.avatarURL = TSUserNetworkingManager().profileImageURL(userId)
        }
        
        return  avatarInfo
    }
}

