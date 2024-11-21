//
//  TSRootViewController.swift
//  Thinksns Plus
//
//  Created by lip on 2017/1/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  根视图控制器
//  负责切换/控制 登录控制器和主页标签控制器
//  每次该视图控制器初始化(应用启动)或者切换根视图(登录,注销)时都会检查一次当前登录用户口令有效期

import UIKit
import ObjectMapper
import Lottie
import SnapKit
import SwiftyUserDefaults
import NIMSDK

enum TSMainViewControllerType {
    case launchScreen
    case landing
    case tabbar
    case resetTabbar
}

class TSRootViewController: TSViewController {
    
    override var shouldAutomaticallyForwardAppearanceMethods: Bool { return true }
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { return .portrait }
    override var childForStatusBarHidden: UIViewController? { return currentShowViewcontroller }
    override var prefersStatusBarHidden: Bool { return VideoPlayerViewController.isShowing ? true : false }
    
    
    static let share = TSRootViewController()
    /// 环信需要保存的数量
    var groupArray = NSMutableArray()
    var userArray = NSMutableArray()
    var datasArray = NSMutableArray()
    var tempArray = NSMutableArray()
    /// bar的高度
    let barHeight: CGFloat = 49
    /// 启动画面
    var launchScreenVC: TSViewController? = nil
    /// 登录控制器
    var landingVC: TSNavigationController? = nil
    /// 主页标签控制器
    //var tabbarVC: TSHomeTabBarController? = nil
//    var tabbarVC: TabBarViewController? = nil
    // Tool Tip
    var toolTip: TSToolChoose? = nil
    var toolTipIM: TSIMToolChoose? = nil
    var isFirst = true
    /// 当前显示的视图的控制器
    var currentShowViewcontroller: UIViewController? = nil
    /// 广告启动图
//    lazy var advert: TSAdvetLaunchView = {
//        return TSAdvetLaunchView()
//    }()
    /// 版本检测弹窗
//    var appVersionCheckVC: TSVersionCheck?
    /// 是否已经更新过服务器配置的app版本信息
    var didUpdateAppVersionInfo = false
    
#if DEBUG
    var lastLocalizationType: Int = -1
#endif
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        LaunchManager.shared.run()
        
        //        if tabbarVC?.tabBar.frame.origin.y != UIScreen.main.bounds.size.height - barHeight {
        //            tabbarVC?.tabBar.frame.origin.y = UIScreen.main.bounds.size.height - barHeight - UIApplication.shared.statusBarFrame.size.height
        //            NotificationCenter.default.addObserver(self, selector: #selector(changeStatuBar), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
        //        }
        NotificationCenter.default.addObserver(self, selector: #selector(authenticationIllicit(notification:)), name: NSNotification.Name.Network.Illicit, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hostDown(notification:)), name: NSNotification.Name.Network.HostDown, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notiNetstatesChange), name: Notification.Name.Reachability.Changed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showForceLogoutAlert(_:)), name: NSNotification.Name.Session.forceLoggedOut, object: nil)
        //设置Moment - Following 小红点
        UserDefaults.standard.set(false, forKey: "MAINFEEDFIRST")
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentAudioCall), name: NSNotification.Name(rawValue: "NIMNETCALL_AUDIO"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentVideoCall), name: NSNotification.Name(rawValue: "NIMNETCALL_VIDEO"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentTeamCall), name: NSNotification.Name(rawValue: "NIMNETCALL_TEAM"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 注册推送别名
//        let AppDelegate = UIApplication.shared.delegate as! AppDelegate
//        AppDelegate.registerEngageLabAlias()
        NotificationCenter.default.addObserver(self, selector: #selector(showUnknowUserUIWindow), name: Notification.Name.AvatarButton.UnknowDidClick, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*
         需求要求：
         如果用户点击了启动页广告，跳转到了广告网页，
         启动页广告是不可跳过的，就要暂停，等用户从网页回来之后，再继续刚才的进度显示.
         启动广告是可跳过的，返回时进入APP首页.
         */
//        if advert.getCurrentAdInfo()?.canSkip == false {
//            advert.resumeAnimation()
//        } else if advert.getCurrentAdInfo()?.canSkip == true {
//            //            advert.dismiss()
//        }
        
        //verifyAppVersion()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /*
         需求要求：
         如果用户点击了启动页广告，跳转到了广告网页，
         启动页广告是不可跳过的，就要暂停，等用户从网页回来之后，再继续刚才的进度显示.
         启动广告是可跳过的，返回时进入APP首页.
         */
//        if advert.getCurrentAdInfo()?.canSkip == false {
//            advert.pauseAnimation()
//        }
    }
    /// 网络环境改变
    @objc func notiNetstatesChange() {
        if TSAppConfig.share.reachabilityStatus != .NotReachable && didUpdateAppVersionInfo == false {
            /// 请求服务器配置的版本信息
            getVersionData()
        }
    }
    
    func verifyAppVersion() {
        /// 请求服务器配置的版本信息
        getVersionData()
        if let lastCheckModel = TSCurrentUserInfo.share.lastCheckAppVesin {
            checkAppVersion(lastCheckModel: lastCheckModel)
        }
    }
    
    @objc func changeStatuBar () {
        //        if UIApplication.shared.statusBarFrame.size.height == 20 {
        //            self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        //            if isFirst {
        //                tabbarVC?.tabBar.frame.origin.y = UIScreen.main.bounds.size.height - barHeight
        //                isFirst = false
        //                return
        //            }
        //            tabbarVC?.tabBar.frame.origin.y = UIScreen.main.bounds.size.height - 29
        //        } else {
        //            tabbarVC?.tabBar.frame.origin.y = UIScreen.main.bounds.size.height - barHeight - UIApplication.shared.statusBarFrame.size.height
        //        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Custom user interface
    /// 切换根控制器显示的控制器
    ///
    /// - Parameter mainViewControllerType: 显示的控制器对应类型
    func show(childViewController mainViewControllerType: TSMainViewControllerType, completion: (() -> Void)? = nil) {
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
        checkAccountStatus()
        switch mainViewControllerType {
        case .landing:
            if currentShowViewcontroller == nil {
                addLoginVC()
                currentShowViewcontroller = self.landingVC
                completion?()
                return
            }
            if currentShowViewcontroller == landingVC {
                completion?()
                //assert(false, "错误的根视图切换")
                return
            }
            addLoginVC()
            currentShowViewcontroller = landingVC
            
            launchScreenVC?.view.removeFromSuperview()
            launchScreenVC?.removeFromParent()
            launchScreenVC = nil
            
//            tabbarVC?.view.removeFromSuperview()
//            tabbarVC?.removeFromParent()
//            tabbarVC = nil
            
            completion?()
        case .tabbar:
//            if currentShowViewcontroller == nil {
//                addHomeTabVC()
//                currentShowViewcontroller = self.tabbarVC
//                completion?()
//                return
//            }
//            if currentShowViewcontroller == tabbarVC {
//                completion?()
//                //assert(false, "错误的根视图切换")
//                return
//            }
//           
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//                self.addHomeTabVC()
//                self.currentShowViewcontroller = self.tabbarVC
//                
//                self.removeLaunchScreen()
//                self.removeLandingScreen()
//                
//                completion?()
//            }
            return
        case .resetTabbar:
            if currentShowViewcontroller == nil {
                addHomeTabVC()
                //self.tabbarVC?.homepageViewController.updateModel()
//                currentShowViewcontroller = self.tabbarVC
                return
            } else {
                currentShowViewcontroller?.view.removeFromSuperview()
                currentShowViewcontroller?.removeFromParent()
                currentShowViewcontroller = nil
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
                self.addHomeTabVC()
//                self.currentShowViewcontroller = self.tabbarVC
                
                self.removeLaunchScreen()
                self.removeLandingScreen()
            }
            
            // self.tabbarVC?.customTabBar.hideAllBadge()
        case .launchScreen:
            if currentShowViewcontroller == nil {
                addLaunchScreenVC()
                currentShowViewcontroller = self.launchScreenVC
                
//                tabbarVC?.view.removeFromSuperview()
//                tabbarVC?.removeFromParent()
//                tabbarVC = nil
                
                landingVC?.view.removeFromSuperview()
                landingVC?.removeFromParent()
                landingVC = nil
                
                completion?()
                return
            }
            if currentShowViewcontroller == launchScreenVC {
                completion?()
                //assert(false, "错误的根视图切换")
                return
            }
            
            addLaunchScreenVC()
            currentShowViewcontroller = self.launchScreenVC
            
//            tabbarVC?.view.removeFromSuperview()
//            tabbarVC?.removeFromParent()
//            tabbarVC = nil
//            
            landingVC?.view.removeFromSuperview()
            landingVC?.removeFromParent()
            landingVC = nil
            
            completion?()
            return
            
        }
    }
    
    /// 游客进入登录视图
    func guestJoinLandingVC() {
        landingVC = presentAuthentication(isDismissBtnHidden: false, isGuestBtnHidden: true)
    }
    
    func presentUpdateTandC() {
        guard currentShowViewcontroller != nil else {
            return
        }
//        let nav = TSNavigationController(rootViewController: NewUpdateController()).fullScreenRepresentation
//        currentShowViewcontroller?.present(nav, animated: true, completion: nil)
    }
    
    /// 创建主页标签控制器
    func addLaunchScreenVC() {
//        launchScreenVC = SplashScreenViewController()
//        self.addChild(launchScreenVC!)
//        self.view.addSubview(launchScreenVC!.view)
//        self.launchScreenVC?.didMove(toParent: self)
    }
    
    /// 创建主页标签控制器
    func addHomeTabVC() {
//        tabbarVC = TabBarViewController()
//        self.addChild(tabbarVC!)
//        self.view.addSubview(tabbarVC!.view)
//        self.tabbarVC?.didMove(toParent: self)
    }
    
    /// 创建登录视图控制器
    func addLoginVC() {
        //_ = TSAppConfig.share.environment.isHiddenGuestLoginButtonInLaunch
//        let landing = OnboardingLandingViewController()
//        landingVC = TSNavigationController(rootViewController: landing, availableOrientations: .portrait)
//        self.addChild(landingVC!)
//        self.view.addSubview(landingVC!.view)
    }
    
    private func checkAccountStatus() {
        RequestNetworkData.share.configAuthorization(TSCurrentUserInfo.share.accountToken?.token)
        guard TSCurrentUserInfo.share.isOvertimeAccount() == true else {
            return
        }
        guard let accountToken = TSCurrentUserInfo.share.accountToken else {
            return
        }
        
        // 刷新口令成功才会替换旧的数据,所以失败不用做任何处理,下次会使用上次的数据
        TSAccountNetworkManager.refreshAccountToken(token: accountToken.token) { (_, _) in
        }
    }
    
    func backdoor(successLogin: @escaping EmptyClosure, failure: @escaping EmptyClosure) {
//        if let currentUser = Defaults.currentUser {
//            
//            let request: BackdoorRequestType = BackdoorRequestType(socialToken: currentUser.token)
//            request.execute(
//                onSuccess: { response in
//                    guard let response = response, let username = response.username else { return }
//                    
//                    /// Clear old token once success login user.
//                    Defaults.currentUser = nil
//                    
//                    /// Replace with new tokens.
//                    let token = TSAccountTokenModel(
//                        with: response.accessToken.orEmpty,
//                        neteaseToken: response.neteaseToken.orEmpty,
//                        expireInterval: response.expireIn ?? 60,
//                        refreshTTL: response.refreshTTL ?? 20160,
//                        tokenType: response.tokenType.orEmpty)
//                    token?.save()
//                    TSCurrentUserInfo.share.accountToken = token
//                    UserDefaults.standard.set(TSAppConfig.share.environment.identifier, forKey: AppEnvironment.AppEnvinronmentIdentifier)
//                    //                    NIMBridgeManager.sharedInstance().login(username, password: token!.neteaseToken) { error in
//                    //                        guard error == nil else {
//                    //                            failure()
//                    //                            return
//                    //                        }
//                    //                        successLogin()
//                    //                    }
//                    
//                    
//                    NIMSDKManager.shared.login(username: username, password: token!.neteaseToken, completion: { error in
//                        guard error == nil else {
//                            failure()
//                            return
//                        }
//                        successLogin()
//                    })
//                },
//                onError: { _ in
//                    failure()
//                })
//        } else {
//            failure()
//        }
    }
    
    // MARK: - Private
    
    /// 是否正在显示超时警告框
    var isShowingOverTimeAlert = false
    /// 显示超时的警告框
    func showOverTimeAlert(message: String?) {
        if currentShowViewcontroller == landingVC {
            return
        }
        if !isShowingOverTimeAlert {
            isShowingOverTimeAlert = true
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "confirm".localized, style: .default, handler: { [unowned self] (_) in
                TSRootViewController.share.show(childViewController: .landing)
                TSCurrentUserInfo.share.logOut()
                self.isShowingOverTimeAlert = false
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    /// 检查版本更新
    func checkAppVersion(lastCheckModel: AppVersionCheckModel, forceShowAlert: Bool = false) {
//        if let appVersionCheckVC = self.appVersionCheckVC {
//            appVersionCheckVC.hidSelf()
//        }
//        let locVersionCode = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
//        let lastIgnoreModel = TSCurrentUserInfo.share.lastIgnoreAppVersion
//        let showNoticeVC = { (checkModel: AppVersionCheckModel)
//            in
//            
//            guard self.currentShowViewcontroller != nil else { return }
//            printIfDebug("没有忽略的版本直接提示更新")
//            let messagePopVC = TSVersionCheck()
//            messagePopVC.show(vc: messagePopVC, presentVC: self.currentShowViewcontroller!)
//            messagePopVC.setVersionInfo(model: checkModel)
//            self.appVersionCheckVC = messagePopVC
//        }
//        
//        if let locVersionCode = locVersionCode {
//            printIfDebug("服务器版本信息比本地更高")
//            if locVersionCode.compare(lastCheckModel.version_code, options: .numeric) == ComparisonResult.orderedAscending {
//                printIfDebug("server version is newer")
//                
//                /// 有忽略版本信息
//                if let lastIgnoreModel = lastIgnoreModel, !forceShowAlert {
//                    if lastIgnoreModel.version_code.compare(lastCheckModel.version_code, options: .numeric) == ComparisonResult.orderedAscending {
//                        showNoticeVC(lastCheckModel)
//                    } else {
//                        printIfDebug("已经忽略过，不提示")
//                        return
//                    }
//                } else {
//                    printIfDebug("没有忽略的版本信息，直接升级")
//                    showNoticeVC(lastCheckModel)
//                }
//            } else {
//                /// "local version is newer"
//                printIfDebug("version相同或者本地版本信息比缓存信息更高不提示")
//                return
//            }
//        }
    }
    
    // Hide View By App Version
    func shouldHideViewByAppVersion() -> Bool {
#if DEBUG
        return false
#else
        let locVersionCode = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        if let lastCheckModel = TSCurrentUserInfo.share.lastCheckAppVesin, let locVersionCode = locVersionCode {
            /// 服务器版本信息比本地更高
            if locVersionCode.compare(lastCheckModel.version_code, options: .numeric) == ComparisonResult.orderedSame ||
                locVersionCode.compare(lastCheckModel.version_code, options: .numeric) == ComparisonResult.orderedAscending {
                return false
            } else {
                return true
            }
        }
        
        return false
#endif
    }
    
    // MARK: - Notification
    // Note: 当收到"口令违法"通知时,根据口令超时时间决定提示文字,然后注销用户
    @objc func authenticationIllicit(notification: Notification) {
        if TSCurrentUserInfo.share.isLogin {
            logOut()
            TSRootViewController.share.guestJoinLandingVC()
        }
    }
    
    @objc func hostDown(notification: Notification) {
        self.show(placeholder: .serverUnavailable)
    }
    
    @objc func popBack() {
    }
    
    /// 收到未知用户头像点击后显示弹窗
    @objc func showUnknowUserUIWindow() {
        let alert = TSIndicatorWindowTop(state: .success, title: "user_deleted".localized)
        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    
    // MARK: Tab Usage
//    func clearAllTabNavStack(index: Int, feedId: Int? = nil, tabType: RewardsLinkQrTabType? = nil, fromMP: Bool? = nil, previousIndex: Int? = nil, completion: (() -> Void)? = nil) {
//        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
//            presentedView.dismiss(animated: false, completion: nil)
//        }
//        
//        if let tabVC = tabbarVC {
//            for (tabIndex, nav) in (tabVC.viewControllers ?? []).enumerated() {
//                if let nav = nav as? TSNavigationController, let viewController = nav.viewControllers.first {
//                    if let feedId = feedId, viewController is MainFeedController {
//                        tabVC.feedVC.feedIndex = feedId
//                    }
//                    
//                    if let tabType = tabType, let fromMP = fromMP, viewController is RewardsLinkQRCodeViewController {
//                        tabVC.scanVC.tabType = tabType
//                        tabVC.scanVC.fromMP = fromMP
//                        
//                        if let previousIndex = previousIndex {
//                            tabVC.scanVC.previousTabIndex = previousIndex
//                        }
//                    }
//                    
//                    if let previousIndex = previousIndex {
//                        if previousIndex != tabIndex {
//                            nav.popToRootViewController(animated: false)
//                        }
//                    } else {
//                        nav.popToRootViewController(animated: false)
//                    }
//                }
//            }
//            
//            tabVC.selectedIndex = index
//            tabVC.updateTabBarSize(selectedIndex: index)
//            completion?()
//        }
//    }
    
    func navigateTabByIndex(previousIndex: Int? = nil) {
        if let previousIndex = previousIndex {
            switch (previousIndex) {
            case 0:
                presentHome()
            case 1:
                presentFeed()
//            case 2:
//                presentScan()
            case 3:
                presentMessage(previousIndex: previousIndex)
            case 4:
                presentMyPage()
            default:
                presentHome()
            }
            return
        }
        
        presentHome()
    }
    
    func presentHome(completion: (() -> Void)? = nil) {
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            self.clearAllTabNavStack(index: 0, completion: completion)
//        }
    }
    
    func presentFeed(feedId: Int? = nil, completion: (() -> Void)? = nil) {
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            self.clearAllTabNavStack(index: 1, feedId: feedId, completion: completion)
//        }
    }
    
//    func presentScan(tabType: RewardsLinkQrTabType = .scan, fromMP: Bool = false, previousIndex: Int? = nil, completion: (() -> Void)? = nil) {
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            self.clearAllTabNavStack(index: 2, tabType: tabType, fromMP: fromMP, previousIndex: previousIndex, completion: completion)
//        }
//    }
    
    func presentMessage(previousIndex: Int? = nil, completion: (() -> Void)? = nil) {
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            self.clearAllTabNavStack(index: 3, previousIndex: previousIndex, completion: completion)
//        }
    }
    
    func presentMyPage(completion: (() -> Void)? = nil) {
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            self.clearAllTabNavStack(index: 4, completion: completion)
//        }
    }
    
    // MARK: Dismiss Tool Tip
    func dismissTooTip() {
        if let toolTip = self.toolTip {
            toolTip.dismissToolTips()
        }
        
        if let toolTipIM = self.toolTipIM {
            toolTipIM.dismissToolTips()
        }
    }
    
    /// Present feeds
    func presentFeedDetail(_ feedId: Int, shouldCloseLive: Bool = true) {
        guard currentShowViewcontroller != nil, TSCurrentUserInfo.share.isLogin == true else { return }
        
        DispatchQueue.main.async {
            if let presentedView = self.currentShowViewcontroller?.presentedViewController {
//                if let livePlayer = presentedView as? YippiLivePlayerViewController {
//                    if shouldCloseLive {
//                        livePlayer.exitLive()
//                    } else {
//                        livePlayer.dismiss(animated: false, completion: nil)
//                    }
//                    return
//                }
                
                if let innerView = presentedView as? FeedContentPageController {
                    innerView.dismiss(animated: false, completion: nil)
                    return
                }
                
                if let videoPlayer = presentedView as? MiniVideoPageViewController {
                    videoPlayer.dismiss(animated: false, completion: nil)
                    return
                }
                
                self.currentShowViewcontroller?.presentedViewController?.dismiss(animated: false, completion: nil)
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.launchScreenDismissWithDelay()) {
                self.currentShowViewcontroller?.navigateLive(feedId: feedId, isDeepLink: true)
            }
        }
        
        //        TSMomentNetworkManager.getOneMoment(feedId: feedId) { [weak self] (momentObject, error, resposeInfo, code) in
        //
        //            guard let self = self else { return }
        //            DispatchQueue.main.async {
        //
        //                if let code = code, code != 200 {
        //                    let detailVC = TSCommetDetailTableView(feedId: feedId, isTapMore: false)
        //                    self.currentShowViewcontroller?.navigationController?.pushViewController(detailVC, animated: true)
        //                    return
        //                }
        //
        //                if let presentedView = self.currentShowViewcontroller?.presentedViewController {
        //                    if let livePlayer = presentedView as? YippiLivePlayerViewController {
        //                        if shouldCloseLive {
        //                            livePlayer.exitLive()
        //                        }
        //                    } else {
        //                        self.currentShowViewcontroller?.presentedViewController?.dismiss(animated: false, completion: nil)
        //                    }
        //                }
        //
        //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //                    if let liveModel = momentObject?.liveModel, liveModel.status == YPLiveStatus.onlive.rawValue {
        //                        self.currentShowViewcontroller?.navigateLive(feedId: feedId)
        //
        //                    } else {
        //                        let detailVC = TSCommetDetailTableView(feedId: feedId, isTapMore: false)
        //                        detailVC.setCloseButton(backImage: true)
        //                        self.currentShowViewcontroller?.present(TSNavigationController(rootViewController:detailVC).fullScreenRepresentation, animated: true, completion: nil)
        //                    }
        //                }
        //            }
        //        }
    }
    
    /// Present home pages
    func presentUserPage(userId: Int? = nil, userName: String? = nil) {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
//        
//        let home = HomePageViewController(userId: userId ?? 0, username: userName)
//        home.navigationBar.buttonAtLeft.addAction {
//            home.dismiss(animated: true, completion: nil)
//        }
//        let nav = TSNavigationController(rootViewController: home).fullScreenRepresentation
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            self.currentShowViewcontroller?.present(nav, animated: true, completion: nil)
//        }
    }
    
    func presentDailyTreasureBoxPage() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
//        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
//            presentedView.dismiss(animated: false, completion: nil)
//        }
//        
//        let vc = TreasureChestViewController()
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//        }
    }
    
    func presentChatViewController(roomType: String, sessionId: String) {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        
//        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
//            presentedView.dismiss(animated: false, completion: nil)
//        }
//        let session: NIMSession = NIMSession(sessionId, type: roomType == "p2p" ? .P2P : .team)
//        NIMSDK.shared().conversationManager.markAllMessagesRead(in: session)
//        let vc = IMChatViewController(session: session, unread: 0)
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
//            UIApplication.topViewController()?.heroPush(nav)
//        }
    }
    
    func presentDiscover(atIndex index: Int) {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
        let aps: [String: Any] = ["discoverIndex": index]
        let info: [String: Any] = [
            "index": 1,
            "aps": aps
        ]
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
            TSRootViewController.share.changeView(info)
        }
    }
    
    func presentFeedHome(atIndex index: Int, isEditPost: Bool? = nil) {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
        let aps: [String: Any] = ["homeIndex": index]
        let info: [String: Any] = [
            "index": 0,
            "aps": aps,
            "editPost": isEditPost
        ]
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
            TSRootViewController.share.changeView(info)
        }
    }
    
//    func presentMiniProgram(type: MiniProgramType, param: String) {
//        // check if require login to access the page
//        guard TSCurrentUserInfo.share.isLogin == true else { return }
//        
//        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
//            presentedView.dismiss(animated: false, completion: nil)
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            let path = ["path" : param]
//            
//            let tabbar = self.tabbarVC
//            
//            if let topVC = UIApplication.topViewController() {
//                miniProgramExecutor.startApplet(type: type, param: path, parentVC: topVC)
//            }
//        }
//    }
    
    func presentYipsWanted() {
        // check if require login to access the page
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            self.tabbarVC?.children.forEach({ child in
//                if let nav = child as? TSNavigationController {
//                    print(nav.viewControllers)
//                    nav.popToRootViewController(animated: false)
//                }
//            })
//        }
        
        //        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
        //            let tabbar =  TSRootViewController.share.tabbarVC
        //            let indexOfyw = 4
        //           // tabbar?.selectedIndex = indexOfyw
        //
        //        }
    }
    
    func presentWalletMain() {
        // check if require login to access the page
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
//        let vc = WalletViewController()
//        
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//        }
    }
    
    func presentYipsTopup() {
        // check if require login to access the page
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
//        let vc = TopUpViewController()
//        
//        let nav = TSNavigationController(rootViewController: vc)
//        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//        }
    }
    
    func presentWalletHistory(index:Int) {
        // check if require login to access the page
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
//        
//        let vc = WalletHistoryViewController()
//        
//        vc.selectedIndex = index
//        
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//        }
    }
    
    func presentMobileTopup(index: Int) {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
//        let vc = MobileTopupMainViewController()
//        vc.selectedIndex = index
//        
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//        }
    }
    
    func presentServiceListVC() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
        //        let vc = YippsWantedServicesListViewController()
        //        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
        //        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
        //            UIApplication.topViewController()?.heroPush(nav)
        //        }
    }
    
    func presentUtilityTopup(index:Int) {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
//        let vc = SRSUtilitiesMainViewController()
//        vc.selectedIndex = index
//        
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//        }
    }
    
    func presentChatRoomHome(_ userInfo: Dictionary<String, Any>) {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
        let aps: [String: Any] = [:]
        var info: [String: Any] = [
            "index": 2,
            "aps": aps
        ]
        info.updateValue(userInfo["sessionID"], forKey: "sessionID")
        info.updateValue(userInfo["sessionType"], forKey: "sessionType")
        print(info)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
            TSRootViewController.share.changeView(info)
        }
    }
    
    func presentSubscriptionHome() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
        let aps: [String: Any] = ["Initiate": "init"]
        let info: [String: Any] = [
            "index": 3,
            "aps": aps
        ]
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
            TSRootViewController.share.changeView(info)
        }
    }
    
    func presentCustomerSupportCategory() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
//        let vc = UIStoryboard(name: "SobotStoryboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "sobot_category") as! SobotCategoryVC
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//        }
    }
    
    func presentStickerDetail(for id: String) {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        let vc = StickerDetailViewController(bundleId: id)
        vc.setCloseButton(backImage: true)
        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
            UIApplication.topViewController()?.heroPush(nav)
        }
    }
    
    func presentReferAndEarn() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
//        let vc = ReferAndEarnVC(qrType: .user, qrContent: (CurrentUserSessionInfo?.username).orEmpty, descStr: "refer_earn_scan_qr_to_register".localized)
//        vc.setCloseButton(backImage: true)
//        vc.avatarString = (CurrentUserSessionInfo?.avatarUrl).orEmpty
//        vc.nameString = CurrentUserSessionInfo?.name
//        vc.introString = CurrentUserSessionInfo?.bio
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//        }
    }
    
    func presentSetting() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        self.presentMyPage()
        

//        let vc = AppSettingViewController()
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//        }
    }
    
    func presentGoama() {
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }

//        GameRequestType().execute(onSuccess: { [weak self] (gameModel) in
//            guard let self = self,
//                  let gameModel = gameModel,
//                  let url = URL(string:  gameModel.launch_url)
//            else { return }
//            
//            let web = TSWebViewController(url: url, type: .defaultType, title: "Goama Game")
//            let nav = TSNavigationController(rootViewController: web).fullScreenRepresentation
//            
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//                UIApplication.topViewController()?.heroPush(nav)
//            }
//        }) { [weak self] (error) in
//            self?.showError(message: error.localizedDescription)
//        }
    }
    
    func presentGlobalsearch() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
//        let vc = RLSearchViewController()
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//        }
    }
    
    func presentVoucherDashboard() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
        let vc = UIStoryboard(name: "Voucher", bundle: Bundle.main).instantiateViewController(withIdentifier: "voucher") as! VoucherViewController
        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
            UIApplication.topViewController()?.heroPush(nav)
        }
    }
    
    func presentVoucherDetails(voucherId: Int) {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
        let vc = VoucherDetailViewController()
        vc.voucherId = voucherId
        
        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
            UIApplication.topViewController()?.heroPush(nav)
        }
    }
    
    func presentWalletQrcode() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            self.presentScan(tabType: .wallet)
//        }
    }
    
    func presentProfileQrcode() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            self.presentScan(tabType: .profile)
//        }
    }
    
    func presentQrScan() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            self.presentScan()
//        }
    }
    
    func presentComment() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }

        let vc = ReceiveCommentTableVC()
        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
            UIApplication.topViewController()?.heroPush(nav)
        }
    }
    
    func presentService() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
//        let vc = YippsWantedServicesListViewController()
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//            if let nav = vc.navigationController as? TSNavigationController {
//                nav.setCloseButton(backImage: true, titleStr: "dashboard_services".localized, customView: nil)
//            }
//        }
    }
    
    func presentPostPhoto() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        self.currentShowViewcontroller?.showCameraVC(true, onSelectPhoto: { [weak self] (assets, _, _, _, _) in
            let releasePulseVC = TSReleasePulseViewController(isHiddenshowImageCollectionView: false)
            releasePulseVC.selectedPHAssets = assets
            let navigation = TSNavigationController(rootViewController: releasePulseVC).fullScreenRepresentation
            if let presentedView = self?.currentShowViewcontroller?.presentedViewController {
                presentedView.dismiss(animated: false, completion: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (self?.launchScreenDismissWithDelay() ?? 0.0)) {
                self?.currentShowViewcontroller?.present(navigation, animated: true, completion: nil)
            }
        })
    }
    
    func presentPostText() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        let releasePulseVC = TSReleasePulseViewController(isHiddenshowImageCollectionView: true,isText: true)
        let navigation = TSNavigationController(rootViewController: releasePulseVC).fullScreenRepresentation
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
            self.currentShowViewcontroller?.present(navigation, animated: true, completion: nil)
        }
    }
    
    func presentMiniVideo() {
        DispatchQueue.main.async {
            let nav = TSNavigationController(rootViewController: MiniVideoRecorderViewController()).fullScreenRepresentation
            self.currentShowViewcontroller?.present(nav, animated: true, completion: nil)
        }
    }
    
    func presentLive() {
//        DispatchQueue.main.async {
//            let vc = YippiLiveViewController().fullScreenRepresentation
//            self.currentShowViewcontroller?.present(vc, animated: true, completion: nil)
//        }
    }
    
    func presentFanListVC( _ userinfo: [String: Any]) {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
//        let vc = MyFansFollowFriendsVC(userIdentity: CurrentUserSessionInfo?.userIdentity ?? 0)
//        vc.setCloseButton(backImage: true)
//        vc.setSelectedAt(0)
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            self.currentShowViewcontroller?.present(nav, animated: true, completion: nil)
//        }
    }
    
    func presentSubscribeVC( _ userinfo: [String: Any]) {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
//        SubscriptionStatusRequestType().execute { [weak self] (responseModel) in
//            guard let self = self else { return }
//            guard let model = responseModel else { return }
//            
//            let vc = SubscriptionHomePageViewController(model: model)
//            vc.setCloseButton(image: UIImage.set_image(named: "iconsArrowCaretleftBlack"))
//            let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//                self.currentShowViewcontroller?.present(nav, animated: true, completion: nil)
//            }
//        } onError: { (error) in
//            print(error.localizedDescription)
//        }
    }
    
    func presentLiveList() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
//        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
//            presentedView.dismiss(animated: false, completion: nil)
//        }
//
//        let vc = MainDiscoverController()
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        vc.handleDeeplinking(atIndex: 1, contentType: DiscoverContentType.live )
//        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//        }
    }
    
    func presentLiveGame() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
//        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
//            presentedView.dismiss(animated: false, completion: nil)
//        }
//        
//        let vc = MainDiscoverController()
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        vc.handleDeeplinking(atIndex: 2, contentType: DiscoverContentType.games)
//        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//        }
    }
    
    func presentTrending() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
        let vc = GalleryCollageViewController()
        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
            UIApplication.topViewController()?.heroPush(nav)
        }
    }
    
    func presentTrt() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
//        let vc = EnergyListViewController()
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//            if let nav = vc.navigationController as? TSNavigationController {
//                nav.setCloseButton(backImage: true, titleStr: "title_trt".localized, customView: nil)
//            }
//        }
    }
    
    func presentPlayz() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
//        let vc = YippiTVViewController()
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//            if let nav1 = vc.navigationController as? TSNavigationController {
//                let selectedImage = UIImage.set_image(named: "bitmap")!.configure { i in
//                    i.withAlignmentRectInsets(UIEdgeInsets(top: -2, left: -2, bottom: -2, right: 0))
//                }
//                let imageview = UIImageView()
//                imageview.image = selectedImage
//                nav1.setCloseButton(backImage: true, titleStr: nil, customView: imageview)
//            }
//        }
    }
    
    func presentEvent() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
//        let vc = YippiEventsListViewController()
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//            if let nav = vc.navigationController as? TSNavigationController {
//                nav.setCloseButton(backImage: true, titleStr: "title_events".localized, customView: nil)
//            }
//        }
    }
    
    func presentStickerShop() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
        UserDefaults.setIsModuleNewlyUpdated(AppModuleId.Sticker.rawValue, isNew: false)
        let vc = StickerMainViewController()
        vc.loading(showBackButton: true)
        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
            UIApplication.topViewController()?.heroPush(nav)
        }
    }
    
    func presentMpList() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
                
//        UserDefaults.setIsModuleNewlyUpdated(AppModuleId.MiniProgram.rawValue, isNew: false)
//        let vc = MiniProgramLandingViewController()
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//        }
    }
    
    func presentSCashPaymentDetail(transactionId: String, redirectURL: String? = nil, isMPMerchant: Bool? = nil, isVoucher: Bool? = nil, isSoftpin: Bool? = nil) {
        // check if require login to access the page
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        
        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
            presentedView.dismiss(animated: false, completion: nil)
        }
        
//        let vc = SCashPaymentDetailViewController()
//        vc.transactionId = transactionId
//        vc.redirectURL = redirectURL
//        vc.isMPMerchant = isMPMerchant ?? false
//        vc.isVoucher = isVoucher ?? false
//        vc.isSoftpin = isSoftpin ?? false
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            UIApplication.topViewController()?.heroPush(nav)
//        }
    }
    
    func postFeedCenterButtonTapped() {
        guard currentShowViewcontroller != nil else {
            return
        }
        
        let view = PostFeedSelectionView()
        currentShowViewcontroller?.view.addSubview(view)
        view.bindToSafeEdges()
        currentShowViewcontroller?.view.layoutIfNeeded()
        
        view.notifyButtonTapped = { [weak self] postType in
            switch postType {
            case .photo:
                self?.presentPostPhoto()
            case .live:
                self?.presentLive()
                
            case .video:
                self?.currentShowViewcontroller?.showShortVideoPickerVC()
                
            case .text:
                self?.presentPostText()
            case .miniVideo:
                self?.presentMiniVideo()
            }
        }
    }
    
    // MARK: - 发布动态Pop弹窗，需对用户权限进行判断,参数传入点击按钮
    func postFeedCenterButtonTapped(_ button: UIButton) {
        guard currentShowViewcontroller != nil else {
            return
        }
        var data = [TSToolModel]()
        var titles: [String] = []
        var images: [String] = []
        var types: [TSToolType] = []
        if CurrentUserSessionInfo?.isLiveEnabled == false && CurrentUserSessionInfo?.isMiniVideoEnabled == false {
            //显示 图片、视频
            titles = ["photo".localized]
            images = ["ic_rl_feed_photo"]
            types = [.photo]
            
        } else if CurrentUserSessionInfo?.isLiveEnabled == true && CurrentUserSessionInfo?.isMiniVideoEnabled == false {
            if TSRootViewController.share.shouldHideViewByAppVersion() == false {
                //显示图片、直播
                titles = ["photo".localized, "text_live".localized]
                images = ["ic_rl_feed_photo", "ic_discover_live"]
                types = [.photo, .live]
            } else {
                //显示 图片
                titles = ["photo".localized]
                images = ["ic_rl_feed_photo"]
                types = [.photo]
            }
            // MARK: 第一阶段不需要直播
            //            titles = ["photo".localized]
            //            images = ["ic_rl_feed_photo"]
            //            types = [.photo]
        } else if CurrentUserSessionInfo?.isLiveEnabled == false && CurrentUserSessionInfo?.isMiniVideoEnabled == true {
            //显示、图片、视频、小视频
            titles = ["photo".localized, "mini_video".localized]
            images = ["ic_rl_feed_photo", "ic_rl_feed_video"]
            types = [.photo, .miniVideo]
        } else if CurrentUserSessionInfo?.isLiveEnabled == true && CurrentUserSessionInfo?.isMiniVideoEnabled == true {
            if TSRootViewController.share.shouldHideViewByAppVersion() == false {
                //显示图片、直播
                titles = ["photo".localized, "text_live".localized, "mini_video".localized]
                images = ["ic_rl_feed_photo", "ic_discover_live", "ic_rl_feed_video"]
                types = [.photo, .live, .miniVideo]
            } else {
                //显示图片、小视频
                titles = ["photo".localized, "mini_video".localized]
                images = ["ic_rl_feed_photo", "ic_rl_feed_video"]
                types = [.photo, .miniVideo]
            }
            // MARK: 第一阶段不需要直播
            //            titles = ["photo".localized, "mini_video".localized]
            //            images = ["ic_rl_feed_photo", "ic_rl_feed_video"]
            //            types = [.photo, .miniVideo]
        } else {
            titles = ["photo".localized, "mini_video".localized]
            images = ["ic_rl_feed_photo", "ic_rl_feed_video"]
            types = [.photo, .miniVideo]
        }
        for i in 0 ..< titles.count {
            let model = TSToolModel(title: titles[i], image: images[i], type: types[i])
            data.append(model)
        }
        let preference = ToolChoosePreferences()
        preference.drawing.bubble.color = .white
        preference.drawing.message.color = UIColor(hex: 0x242424)
        preference.drawing.button.color = UIColor(hex: 0x242424)
        button.showToolChoose(identifier: "", data: data, arrowPosition: .top, preferences: preference, delegate: self, isMessage: false)
    }
    
    func yippsWantedButtonTapped() {
        //        self.tabbarVC?.selectedIndex = 4
        //
        //        if let navVC = self.tabbarVC?.selectedViewController as? UINavigationController {
        //            navVC.popToRootViewController(animated: false)
        //        }
    }
    
    func presentSobotChat(_ data: [String: Any]) {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        guard currentShowViewcontroller != nil else {
            return
        }
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + launchScreenDismissWithDelay()) {
//            LaunchManager.shared.launchSobot(in: self.currentShowViewcontroller!)
//        }
    }
    
    func presentYippsWantedTransaction(_ data: [String: Any]) {
        guard currentShowViewcontroller != nil else {
            return
        }
//        guard let receipt = data["receipt"] as? [String: Any],
//              let model = Mapper<YippsWantedTransaction>().map(JSON: receipt) else {
//            return
//        }
//        if UIApplication.topViewController()?.navigationController?.topViewController?.isKind(of: YippsWantedTransactionVC.self) == true {
//            let vc = UIApplication.topViewController()?.navigationController?.topViewController as? YippsWantedTransactionVC
//            vc?.data = model
//            return
//        }
//        
//        let vc = YippsWantedTransactionVC(data: model)
//        UIApplication.topViewController()?.present(TSNavigationController(rootViewController: vc).fullScreenRepresentation, animated: true, completion: nil)
    }
    
    func changeView(_ userinfo: Dictionary<String, Any>) {
//        if let vc = UIApplication.topViewController(), vc.isKind(of: TreasureChestViewController.self) {
//            vc.navigationController?.dismiss(animated: false, completion: nil)
//        }
        //        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
        //            presentedView.dismiss(animated: false, completion: nil)
        //        }
        
        // Pop back all view
//        if let mainNav = tabbarVC?.selectedViewController as? TSNavigationController {
//            mainNav.popToRootViewController(animated: false)
//        }
    
        guard let aps = userinfo["aps"] as? [String: Any] else {
            return
        }
        if let index = userinfo["index"] as? Int {
            switch index {
            case 0:
                if let presentedView = self.currentShowViewcontroller?.presentedViewController {
                    presentedView.dismiss(animated: false, completion: nil)
                }
                if let index = aps["homeIndex"] as? Int, let type = FeedHeaderType(rawValue: index), let isEditPost = userinfo["editPost"] as? Bool {
                    if isEditPost {
                        self.presentFeed(feedId: 0)
                    } else {
                        self.presentFeed(feedId: index)
                    }
                }
            case 1:
                if let presentedView = self.currentShowViewcontroller?.presentedViewController {
                    presentedView.dismiss(animated: false, completion: nil)
                }
//                if  let index = aps["discoverIndex"] as? Int, let type = DiscoverContentType(rawValue: index) {
//                    let vc = MainDiscoverController()
//                    vc.handleDeeplinking(atIndex: index, contentType: type)
//                    if let navigation = UIApplication.topViewController()?.navigationController {
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    } else {
//                        self.heroPush(vc)
//                    }
//                }
            case 2:
                guard let sessionID = userinfo["sessionID"] else {
                    return
                }
                if let presentedView = self.currentShowViewcontroller?.presentedViewController {
                    presentedView.dismiss(animated: false, completion: nil)
                }
                                
                if let sessId = userinfo["sessionID"] as? String, let type = userinfo["sessionType"] as? String {
                    self.presentMessage(completion: {
                        let sessType: NIMSessionType = type == "0" ? .P2P : .team
                        let session: NIMSession = NIMSession(sessId, type: sessType)
                        // By Kit Foong (will read all message with same session when click on notification)
                        NIMSDK.shared().conversationManager.markAllMessagesRead(in: session)
                        let vc = IMChatViewController(session: session, unread: 0)
                        if let navigation = UIApplication.topViewController()?.navigationController {
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            self.heroPush(vc)
                        }
                    })
                } else {
                    self.presentMessage()
                }
            case 3:
                if let presentedView = self.currentShowViewcontroller?.presentedViewController {
                    presentedView.dismiss(animated: false, completion: nil)
                }
                
                EventTrackingManager.instance.track(event: .SubscriptionMenu)
//                SubscriptionStatusRequestType().execute { [weak self] (responseModel) in
//                    guard let self = self else { return }
//                    guard let model = responseModel else { return }
//                    
//                    let vc = SubscriptionHomePageViewController(model: model)
//                    if let navigation = UIApplication.topViewController()?.navigationController {
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    } else {
//                        self.heroPush(vc)
//                    }
//                } onError: { (error) in
//                    print(error.localizedDescription)
//                }
            default:
                break
            }
        } else if let type = userinfo["tag"] as? String {
            if let presentedView = self.currentShowViewcontroller?.presentedViewController {
                presentedView.dismiss(animated: false, completion: nil)
            }
            switch type {
            case "notification:comments":
                if let vc = UIApplication.topViewController() as? ReceiveCommentTableVC {
                    vc.tableView.mj_header.beginRefreshing()
                } else {
                    let receiveCommentVC = ReceiveCommentTableVC()
                    if let navigation = UIApplication.topViewController()?.navigationController {
                        self.navigationController?.pushViewController(receiveCommentVC, animated: true)
                    } else {
                        self.heroPush(receiveCommentVC)
                    }
                }
                break
            case "notification:likes":
                if let vc = UIApplication.topViewController() as? ReceiveLikeTableVC {
                    vc.tableView.mj_header.beginRefreshing()
                } else {
                    let receiveLikeTableVC = ReceiveLikeTableVC()
                    if let navigation = UIApplication.topViewController()?.navigationController {
                        self.navigationController?.pushViewController(receiveLikeTableVC, animated: true)
                    } else {
                        self.heroPush(receiveLikeTableVC)
                    }
                }
                break
            case "notification:system":
                if let vc = UIApplication.topViewController() as? NoticeTableViewController {
                    vc.tableView.mj_header.beginRefreshing()
                } else {
                    let systemNoticeVC = NoticeTableViewController()
                    if let navigation = UIApplication.topViewController()?.navigationController {
                        self.navigationController?.pushViewController(systemNoticeVC, animated: true)
                    } else {
                        self.heroPush(systemNoticeVC)
                    }
                }
                break
            case "notification:at":
                //TSAtMeListVCViewController
                if let vc = UIApplication.topViewController() as? ReceiveCommentTableVC {
                    vc.tableView.mj_header.beginRefreshing()
                } else {
                    let receiveCommentVC = ReceiveCommentTableVC()
                    if let navigation = UIApplication.topViewController()?.navigationController {
                        self.navigationController?.pushViewController(receiveCommentVC, animated: true)
                    } else {
                        self.heroPush(receiveCommentVC)
                    }
                }
                break
            case "notification:live":
                guard let feedId = userinfo["feed_id"] as? String else { return }
                self.navigateLive(feedId: Int(feedId) ?? 0)
            case "notification:yipps-wanted-ack":
                self.presentYippsWantedTransaction(userinfo)
            case "in-app:wallet:yipps":
//                let vc = WalletHistoryViewController()
//                if let navigation = UIApplication.topViewController()?.navigationController {
//                    self.navigationController?.pushViewController(vc, animated: true)
//                } else {
//                    self.heroPush(vc)
//                }
                break
            default:
                break
            }
        }
    }
    
    /// 收到通知推送信息后,显示小红点,数据再进入[消息]页面时抓取
    func showMessageNotiBadge() {
        //tabbarVC?.customTabBar.showBadge(.message)
    }
    
    /// Call this for logout
    @objc  func logOut() {
//        TSCurrentUserInfo.share.logOut()
//        TSCurrentUserInfo.resetIsFirstToWalletVC()
//        LiveConfigCacheManager().wipe()
//        self.show(childViewController: .landing)
//        
//        let now = Date.getCurrentTime().timeIntervalSince1970
//        userConfiguration?.updateLocalDataWithEndTime(endTime: now)
//        userConfiguration?.updateUserDuration(duration: userConfiguration?.activeSessions ?? [])
//        userConfiguration?.activeSessions = []
//        userConfiguration?.feedcontentCountry = nil
//        userConfiguration?.starRankCountry = nil
//        userConfiguration?.save()
//        
//        userConfiguration = nil
//        FATClient.shared().clearMemoryCache()
//        
//        XCGLoggerManager.shared.clearAllZipFiles(needClearLog: true)
//        XCGLoggerManager.shared.setupXCGLogger()
//        
//        UserDefaults.isVideoSoundEnabled = true
//        UserDefaults.isPlayVideoUsingWifiOnly = false
//        UserDefaults.isPlayVideoUsingWifiAndMobileData = true
//        UserDefaults.isAutoPlayVideoDisable = false
//        UserDefaults.teenModeIsEnable = false
//        UserDefaults.teenModePassword = nil
//        UserDefaults.saveDownloadedAppId.removeAll()
//        UserDefaults.logRequestModel = nil
//        UserDefaults.sponsoredEnabled = false
//        UserDefaults.recommendedEnabled = false
    }
    
    func clearAllDashboardCache() {
        UserDefaults.dashboardServicesData = nil
        UserDefaults.dashboardBannerData = nil
        UserDefaults.dashboardMerchantData = nil
        UserDefaults.dashboardDiscoverMoreData = nil
    }
    
    @objc func showForceLogoutAlert(_ notification: Notification) {
        TSCurrentUserInfo.share.logOut()
        // meetingkit 会议中
        if let vc = UIApplication.topViewController(), vc.className() == "FlutterViewController" {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                self.showMeetingkitForceLogoutAlert()
            }
            return
        }
        let message: String = notification.userInfo?["message"] as? String ?? ""
        let alert = UIAlertController(title: "server_kicked_out".localized,
                                      message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "confirm".localized, style: .cancel, handler: { _ in
            self.show(childViewController: .landing)
            NotificationCenter.default.post(name: Notification.Name("FORCE_EXIT_LIVE"), object: nil)
        })
        alert.addAction(confirmAction)
        
        if let presentedViewController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
            presentedViewController.present(alert, animated: true, completion: nil)
            return
        }
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func showMeetingkitForceLogoutAlert() {
        let message: String = "acc_kicked_out".localized
        let alert = UIAlertController(title: "server_kicked_out".localized,
                                      message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "confirm".localized, style: .cancel, handler: { _ in
            self.show(childViewController: .landing)
            NotificationCenter.default.post(name: Notification.Name("FORCE_EXIT_LIVE"), object: nil)
        })
        alert.addAction(confirmAction)
        
        if let presentedViewController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
            presentedViewController.present(alert, animated: true, completion: nil)
            return
        }
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

extension TSRootViewController: ToolChooseDelegate {
    func didSelectedItem(type: TSToolType, title: String) {
        //        if let presentedView = self.currentShowViewcontroller?.presentedViewController {
        //            presentedView.dismiss(animated: false, completion: nil)
        //        }
        switch type {
        case .photo:
            self.presentPostPhoto()
        case .live:
            self.presentLive()
        case .video:
            self.currentShowViewcontroller?.showShortVideoPickerVC()
        case .text:
            self.presentPostText()
        case .miniVideo:
            self.presentMiniVideo()
        default:
            break
        }
    }
}

// MARK: Dismiss tutorial coach
extension TSRootViewController {
    func dismissTutorialCoach() {
//        if let tabVC = TSRootViewController.share.tabbarVC as? TabBarViewController {
//            tabVC.viewControllers?.forEach({ nav in
//                if let nav = nav as? TSNavigationController, let vc = nav.viewControllers.first as? RewardsLinkHomeViewController {
//                    vc.dismissTutorial()
//                }
//            })
//        }
    }
    
    func launchScreenDismissWithDelay() -> Double {
//        return (launchScreenVC != nil ? 1.2 : 0.3)
        return 0.3
    }
    
    func removeLaunchScreen() {
        launchScreenVC?.view.removeFromSuperview()
        launchScreenVC?.removeFromParent()
        launchScreenVC = nil
    }
    
    func removeLandingScreen() {
        landingVC?.view.removeFromSuperview()
        landingVC?.removeFromParent()
        landingVC = nil
    }
}
