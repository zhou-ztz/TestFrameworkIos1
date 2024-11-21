//
//  TSViewController.swift
//  Thinksns Plus
//
//  Created by lip on 2016/12/30.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  抽象类

import UIKit
import SDWebImage
import MessageUI
import IQKeyboardManagerSwift
import Instructions
import NIMSDK

struct TSViewRightCustomViewUX {
    /// 最大宽度 （有音乐图标时）
    static let MaxWidth: CGFloat = 75
    /// 最小宽度 （无音乐图标时）
    static let MinWidth: CGFloat = 44
    /// 高度
    static let Height: CGFloat = 44
}

public class TSViewController: UIViewController {
    // By Kit Foong (Added new handle for dashboard location)
    
    public override var shouldAutorotate: Bool { return false }
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return [.portrait] }
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { return .portrait }
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    var isFloatEventLoaded = false
//    lazy var floatEventView: FeedFloatEventView = { return FeedFloatEventView() }()
    var moduleType: ModuleType { return .none }
    
    var placeholder = Placeholder()
    
    /// 是否是第一显示的视图
    var isShowing: Bool = false
    
    /// 导航栏右边的按钮
    var rightButton: UIButton? = nil
    
    /// 动态被删除后的占位图
    let deletedOccupiedView = UIView(frame: UIScreen.main.bounds)
    
    var titleColor: UIColor {
        return TSColor.main.theme
    }
    
    /// 辅导指示
    var coachMarksController = CoachMarksController()
    var coachTimer: Timer = Timer()
    
    var checkPreparationTimer : DispatchSourceTimer?
    
    //记录页面进入开始时间
    var stayBeginTimestamp: String = ""
    //记录页面离开时间
    var stayEndTimestamp: String = ""
    
    private lazy var loadingIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        var images: [UIImage] = []
        for index in 0..<30 {
            let imageName = "RL_IMG_default_center_000\(index)"
            let image = UIImage.set_image(named: imageName)!
            images.append(image)
        }
        imageView.animationImages = images
        imageView.contentMode = .center
        return imageView
    }()
    
    var stayTimer : Timer?
    var eventStartTime : Int = 0
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
        addNotic()
        let textAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    deinit {
        removeNotic()
        printIfDebug("deinit \(self.className())")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isShowing = true
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
//        if self is RewardsLinkHomeViewController || self is MainFeedController || self is FeedRecommendPageController || self is FeedFollowingController || self is NewMessageViewController || self is ChatListViewController || self is ReceiveCommentTableVC || self is HomePageViewController || self is TSHomepageGalleryCollageView {
//            self.tabBarController?.tabBar.isHidden = false
//            self.tabBarController?.tabBar.isTranslucent = false
//        } else {
//            self.tabBarController?.tabBar.isHidden = true
//            self.tabBarController?.tabBar.isTranslucent = true
//        }
        
        stopPreparationTimer()
        setupFloatEventView()
        navigationController?.navigationBar.barStyle = .default
        view.layoutIfNeeded()
        checkForFloatEvent()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isShowing = false
        
//        if let liveVC = parent?.getParentViewController() as? YippiLivePlayerViewController {
//            liveVC.unmutePlayer()
//        }
    }
    
    func viewStayEvent() {

    }
    
    func stopStayEvent() {

    }
    
    func getCurrentTime() -> Int {
        return Date().timeStamp.toInt()
    }
    
    func className(_ obj: AnyObject) -> String {
        return String(describing: type(of: obj))
    }
    
    func setStatusBar(color: UIColor) {
       // UIApplication.shared.statusBarView?.backgroundColor = color
    }
    
    func setTitleName(_ title: String = "") {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        label.textColor = .black
        label.font = UIFont.systemRegularFont(ofSize: 14.5)
        label.backgroundColor = UIColor.clear
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.text = title
        self.navigationItem.titleView = label
    }
    
    func setCloseButton(backImage: Bool = false, titleStr: String? = nil, customView: UIView? = nil, completion: (() -> Void)? = nil, needPop: Bool = true, color: UIColor = .black, backWhiteCircle: Bool = false) {
        var image: UIImage?
        if backImage == false {
            image = UIImage.set_image(named: "IMG_topbar_close")
        } else {
            image = UIImage.set_image(named: "iconsArrowCaretleftBlack")
        }
        
        var barButton = UIBarButtonItem()
        let backButtonView = UIView()
        backButtonView.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        let imageView = UIImageView(image: image)
        
        backButtonView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        if backWhiteCircle {
            backButtonView.backgroundColor = .white

            backButtonView.layer.masksToBounds = true
            backButtonView.clipsToBounds = true
            backButtonView.layer.cornerRadius = 15
        } else {
            backButtonView.backgroundColor = .clear
        }

        barButton = UIBarButtonItem(customView: backButtonView)
        backButtonView.addTap(action: { [weak self] (_) in
            if needPop {
                let _ = self?.navigationController?.popViewController(animated: true, completion: {
                    completion?()
                })
            } else {
                completion?()
            }
        })
        
        barButton.tintColor = color
        
        if let titleStr = titleStr {
            let btn = UIButton(type: .custom)
            btn.set(title: titleStr, titleColor: .black, for: .normal)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            btn.titleLabel?.lineBreakMode = .byTruncatingTail
            let titleButton = UIBarButtonItem(customView: btn)
            self.navigationItem.leftBarButtonItems = [barButton, titleButton]
            return
        }
        if let customView = customView {
            let titleButton = UIBarButtonItem(customView: customView)
            self.navigationItem.leftBarButtonItems = [barButton, titleButton]
            return
        }
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func setLeftNavTitle(titleStr: String? = nil) {
        if let titleStr = titleStr {
            let btn = UIButton(type: .custom)
            btn.set(title: titleStr, titleColor: .black, for: .normal)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            btn.titleLabel?.lineBreakMode = .byTruncatingTail
            let titleButton = UIBarButtonItem(customView: btn)
            self.navigationItem.leftBarButtonItems = [titleButton]
        }
    }
    
    func setNavigationBarBackgroundColor(color: UIColor, isTranslucent: Bool = false) {
        if let navigationBar = navigationController?.navigationBar {
            UIView.performWithoutAnimation {
                navigationBar.barTintColor = color
                navigationBar.isTranslucent = isTranslucent
                
                if let barBackgroundView = navigationBar.subviews.first {
                    barBackgroundView.backgroundColor = color
                }
                
                navigationBar.layoutIfNeeded()
            }
        }
    }
    
    func startPreparationTimer() {
        checkPreparationTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        
        checkPreparationTimer!.scheduleRepeating(deadline: .now(), interval: .seconds(2))
        checkPreparationTimer!.setEventHandler
        {
//            if LaunchManager.shared.preparationCompleted == true {
//                self.stopPreparationTimer()
//                
//                self.extractEventModule()
//                self.isFloatEventLoaded = true
//            }
        }
        checkPreparationTimer!.resume()
    }
    
    func stopPreparationTimer() {
        checkPreparationTimer = nil
    }
    
    func show(placeholder type: PlaceholderViewType, theme: Theme = .white) {
        if placeholder.superview == nil {
            view.addSubview(placeholder)
            placeholder.bindToEdges()
            placeholder.onTapActionButton = {
                self.placeholderButtonDidTapped()
            }
        }
        placeholder.set(type)
        placeholder.theme = theme
    }
    
    func removePlaceholderView() {
        placeholder.removeFromSuperview()
    }
    
    func placeholderButtonDidTapped() { }
    
    func deeplink(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        TSUtil.pushURLDetail(url: url, currentVC: self)
    }
}

extension TSViewController {
    fileprivate func customSetup() {
        view.backgroundColor = TSColor.inconspicuous.background
    }
    
    internal func emailUs(email:String, mailComposeDelegate:MFMailComposeViewControllerDelegate){
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = mailComposeDelegate
            mail.setToRecipients([email])
            mail.setMessageBody("", isHTML: true)
            
            present(mail, animated: true)
        } else {
            if let url = URL(string: "mailto:\(email)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    public func showToast(with title: String, desc: String) {
        view.endEditing(true)
        self.showTopFloatingToast(with: title, desc: desc)
    }
}

extension UITabBarController {
    public func showToast(with title: String, desc: String) {
        view.endEditing(true)
        self.showTopFloatingToast(with: title, desc: desc)
    }
}

// MARK: - LoadingViewDelegate: loading view 的代理事件
extension TSViewController: LoadingViewDelegate {
    
    // 点击了加载视图的重新加载按钮
    func reloadingButtonTaped() {
        fatalError("必须重写该方法,执行加载视图重点击新加载按钮的逻辑")
    }
    
    // 点击了加载视图的返回按钮
    @objc func loadingBackButtonTaped() {
        navigationController?.popViewController(animated: true)
    }
}

/// 添加音乐入口点击的监听
extension TSViewController {
    
    func addNotic() {
        /// 音乐暂停后等待一段时间 视图自动消失的通知
      //  NotificationCenter.default.addObserver(self, selector: #selector(setRightCustomViewWidthMin), name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
    }
    
    func removeNotic() {
       // NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
    }
}

/// 导航栏右边按钮相关
extension TSViewController {
    
    /// 设置右边按钮
    /// 增加导航栏右边按钮
    ///
    /// - Note: 在 viewWillAppear 和 viewDidLoad 各写一次，一共写两次
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - img: 图片
    func setRightButton(title: String?, img: UIImage?) {
        
        if self.navigationController == nil {
            return
        }
        
        if rightButton == nil {
            initRightCustom()
        }
        
        rightButton?.setImage(img, for: UIControl.State.normal)
        rightButton?.setTitle(title, for: UIControl.State.normal)
        
       // setRightCustomViewWidth(Max: TSMusicPlayStatusView.shareView.isShow)
    }
    
    func setRightButton(button: UIButton) {
        rightButton = button
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.rightButton!)
    }
    
    func setLeftButton(button: UIButton, onTap: EmptyClosure? = nil) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        if onTap != nil {
            button.addAction {
                onTap?()
            }
        }
    }
    
    /// 初始化右边的按钮区域
    func initRightCustom() {
        self.rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: TSViewRightCustomViewUX.MinWidth, height: 44))
        self.rightButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        self.rightButton?.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        self.rightButton?.addTarget(self, action: #selector(rightButtonClicked), for: UIControl.Event.touchUpInside)
        self.rightButton?.setTitleColor(titleColor, for: UIControl.State.normal)
        self.rightButton?.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.navigation.rawValue)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.rightButton!)
    }
    
    override public func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        userConfiguration?.sesssionCheckThrottler.call()
        super.dismiss(animated: flag, completion: completion)
    }
    
    
    
    func setCloseButton(tintColor: UIColor = .black, image: UIImage? = nil) {
        let barButton = UIBarButtonItem(image: image ?? UIImage.set_image(named: "IMG_topbar_close")!, action: { [weak self] in
            if self?.isModal ?? true {
                self?.dismiss(animated: true)
            } else {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        })
        barButton.tintColor = tintColor
        
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    /// 设置按钮标题颜色
    ///
    /// - Parameter color: 颜色
    func setRightButtonTextColor(color: UIColor) {
        self.rightButton?.setTitleColor(color, for: UIControl.State.normal)
    }
    
    /// 设置按钮是否可以点击
    ///
    /// - Parameter enable: 是否可以点击
    func rightButtonEnable(enable: Bool) {
        self.rightButton?.isEnabled = enable
        self.rightButton?.setTitleColor(enable ? titleColor : TSColor.normal.disabled, for: UIControl.State.normal)
    }
    
    /// 设置按钮区域的宽度
    ///
    /// - Parameter Max: 是否是最大宽度
    func setRightCustomViewWidth(Max: Bool) {
        
        if isShowing == false {
            return
        }
        
        if self.rightButton == nil {
            return
        }
        
        let width = Max ? TSViewRightCustomViewUX.MaxWidth: TSViewRightCustomViewUX.MinWidth
        
        if self.rightButton?.frame.width == width {
            return
        }
        
        self.rightButton!.frame = CGRect(x: 0, y: 0, width: width, height: TSViewRightCustomViewUX.Height)
    }
    
    /// 设置为最小宽度 （用于音乐图标自动消失时重置宽度）
    @objc func setRightCustomViewWidthMin() {
        setRightCustomViewWidth(Max: false)
    }
    
    /// 按钮点击方法
    @objc func rightButtonClicked() {
        fatalError("请重写此方法实现右边按钮的点击事件")
    }
}

// MARK: - 导航栏
extension TSViewController {
    // 配置导航栏的文字按钮
    //
    // 快捷设置按钮,适合添加到导航栏
    func setupNavigationTitleItem(_ button: UIButton, title: String?) -> Void {
        let font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = font
        button.setTitle(title, for: .normal)
        // Remark: - 关于这里的长度，应重新设计一下，特别是牵扯到右侧可能有音乐图标时
        // 音乐图标包括在内,导航栏右侧按钮做多只能出现3个
        if let size = title?.size(maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), font: font) {
            button.bounds = CGRect(x: 0, y: 0, width: size.width + 10, height: 44)
        } else {
            button.bounds = CGRect(x: 0, y: 0, width: TSViewRightCustomViewUX.MaxWidth, height: 44)
        }
    }
    
    func transitionFromRight() {
        self.view.makeVisible()
        
        let transition = CATransition.init()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        transition.type = .moveIn
        transition.subtype = .fromRight
        
        self.view.layer.add(transition, forKey: nil)
    }
}

extension TSViewController {
    func showLoadingAnimation() {
        self.view.addSubview(loadingIndicator)
        loadingIndicator.bindToEdges()
        loadingIndicator.startAnimating()
    }
    
    func dismissLoadingAnimation() {
        self.loadingIndicator.stopAnimating()
        self.loadingIndicator.removeFromSuperview()
    }
}

extension TSViewController {
    private func setupFloatEventView() {
//        //guard let tabbar = tabBarController?.tabBar else { return }
//        if floatEventView.frame != CGRect.zero { return }
//        view.addSubview(floatEventView)
//        
//        floatEventView.snp.makeConstraints {
//            $0.bottom.equalToSuperview().inset(TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight() + 70)
//            $0.right.equalToSuperview().inset(14)
//            //$0.width.height.equalTo(66)
//            // By Kit Foong (Enlarge floating icon size)
//            $0.width.height.equalTo(80)
//        }
    }
    
    @objc func checkForFloatEvent() {
        guard TSCurrentUserInfo.share.isLogin == true else {
            return
        }
        guard isFloatEventLoaded == false else { return }
        
        startPreparationTimer()
        //        guard LaunchManager.shared.preparationCompleted == true else { return }
        //
        //        extractEventModule()
        //
        //        isFloatEventLoaded = true
    }
    
    private func extractEventModule() {
//        guard let modules = TSAppConfig.share.launchInfo?.modules, let floatModule = modules.filter { $0.floatLocation == moduleType.rawValue && $0.status == true && $0.floatImageUrl.isEmpty == false }.sorted(by: { $0.id > $1.id }).first else { return }
//        
//        floatEventView.imageUrl = floatModule.floatImageUrl
//        
//        switch floatModule.actionName {
//        case "mini-program": floatEventView.tapAction = .miniProgram(appId: floatModule.actionValue)
//        case "link": floatEventView.tapAction = .link(url: floatModule.actionValue)
//        default: break
//        }
//        floatEventView.moduleName = floatModule.module
//        
//        floatEventView.onTapCallback = { [weak self] action in
//            EventTrackingManager.instance.track(event: .FloatingEventClicked, with: ["Action": "Click", "Campaign": floatModule.module])
//            guard let self = self else { return }
//            
//            if let url = URL(string:floatModule.actionValue) {
//                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//                    appDelegate.deeplinkingHandler(url: url)
//                }
//            } else {
//                switch action {
//                case .link(let url):
//                    guard let link = URL(string: url) else { return }
//                    switch floatModule.authMode.lowercased() {
//                    case "query-string":
//                        let web = BridgedWebController(url: link, query: true, frame: self.view.frame)
//                        if let nav = self.navigationController {
//                            nav.pushViewController(web, animated: true)
//                        } else {
//                            self.heroPush(web)
//                        }
//                    default:
//                        switch floatModule.id {
//                        case AppModuleId.ReferAndEarn.rawValue:
//                            let web = ReferAndEarnWebVC(url: link, type: .defaultType, title: "")
//                            web.openReferAndEarnHandler = { [weak self] in
//                                guard let self = self else { return }
//                                if !self.isKind(of: ReferAndEarnVC.self) {
//                                    self.heroPush(ReferAndEarnVC(qrType: .user, qrContent: (CurrentUserSessionInfo?.username).orEmpty, descStr: "refer_earn_scan_qr_to_register".localized))
//                                }
//                            }
//                            self.heroPush(web)
//                        default:
//                            let web = BridgedWebController(url: link, query: false, frame: self.view.frame)
//                            if let nav = self.navigationController {
//                                nav.pushViewController(web, animated: true)
//                            } else {
//                                self.heroPush(web)
//                            }
//                        }
//                    }
//                case .miniProgram(let appId):
//                    guard TSCurrentUserInfo.share.isLogin == true else {
//                        TSRootViewController.share.guestJoinLandingVC()
//                        return
//                    }
//                    miniProgramExecutor.startApplet(type: .normal(appId: appId), parentVC: self)
//                }
//            }
//        }
//        
//        if TSRootViewController.share.shouldHideViewByAppVersion() == false && !UserDefaults.teenModeIsEnable {
//            floatEventView.show()
//        } else {
//            if let userServicesWhitelist = TSAppConfig.share.localInfo.userServicesWhitelist, let uid = CurrentUserSessionInfo?.userIdentity, userServicesWhitelist.contains(where: { $0 == uid }) {
//                floatEventView.show()
//            } else {
//                floatEventView.hide()
//            }
//        }
//        
//        floatEventView.layoutIfNeeded()
    }
}

// MARK: - Display Country bottom sheet
extension TSViewController {
    func showCountryBottomSheet(completion: ((CountryEntity) -> Void)? = nil) {
//        let bottomSheet = CountryBottomSheetVC()
//        
//        if !bottomSheet.countries.isEmpty {
//            bottomSheet.modalPresentationStyle = .custom
//            let transitionDelegate = HalfScreenTransitionDelegate()
//            let bottomSheetHeight = 0.08 * CGFloat(bottomSheet.countries.count + 1)
//            transitionDelegate.heightPercentage = bottomSheetHeight > 0.4 ? 0.4 : bottomSheetHeight
//            bottomSheet.transitioningDelegate = transitionDelegate
//            bottomSheet.onSelectRegion = { region in
//               completion?(region)
//            }
//            self.present(bottomSheet, animated: true)
//        }
    }
}

// MARK: - 辅导指示
extension TSViewController {
    func dismissTutorial() {
        self.coachMarksController.stop(emulatingSkip: true)
        UserDefaults.isCompleteTutorial = true
        self.coachTimer.invalidate()
    }
}
extension TSViewController {
    
    /// 处理对于动态的一些配置
    /// - Parameters:
    ///   - rejectDetailModel: 动态内容
    ///   - releasePulseVC: vc视图
    /// - Returns:
    func configureReleasePulseViewController(rejectDetailModel: RejectDetailModel, viewController: TSViewController) -> TSViewController{
        //分享类型 - 所有人、朋友、我
        if let privacy = rejectDetailModel.privacy,
           let privacyType = PrivacyType(rawValue: privacy) {
            if let releasePulseVC = viewController as? TSReleasePulseViewController {
                releasePulseVC.rejectPrivacyType = privacyType
            } else if let postShortVC = viewController as? PostShortVideoViewController {
                postShortVC.rejectPrivacyType = privacyType
            }
        }
        //话题
        if rejectDetailModel.topics.count > 0 {
            let topic = TopicCommonModel()
            topic.id = rejectDetailModel.topics[0].id
            topic.name = rejectDetailModel.topics[0].name ?? ""
            if let releasePulseVC = viewController as? TSReleasePulseViewController {
                releasePulseVC.topics = [topic]
            } else if let postShortVC = viewController as? PostShortVideoViewController {
                postShortVC.topics = [topic]
            }
        }
        //位置签到
        if let loc = rejectDetailModel.location {
            let location = TSPostLocationObject()
            location.locationID = loc.lid ?? ""
            location.locationName = loc.name ?? ""
            location.locationLatitude = loc.lat
            location.locationLongtitude = loc.lng
            location.address = loc.address ?? ""
            if let releasePulseVC = viewController as? TSReleasePulseViewController {
                releasePulseVC.rejectLocation = location
            } else if let postShortVC = viewController as? PostShortVideoViewController {
                postShortVC.rejectLocation = location
            }
        }
        // Tagged 用户
        if let users = rejectDetailModel.tagUsers {
            if let releasePulseVC = viewController as? TSReleasePulseViewController {
                releasePulseVC.selectedUsers = users
            } else if let postShortVC = viewController as? PostShortVideoViewController {
                postShortVC.selectedUsers = users
            }
        }
        // 标记 merchant 用户
        if let tagMerchants = rejectDetailModel.rewardsLinkMerchantUsers {
            if let releasePulseVC = viewController as? TSReleasePulseViewController {
                releasePulseVC.selectedMerchants = tagMerchants
            } else if let postShortVC = viewController as? PostShortVideoViewController {
                postShortVC.selectedMerchants = tagMerchants
            }
        }
        return viewController
    }
  
    
    
    /// 处理对于动态的一些配置
    /// - Parameters:
    ///   - detailModel: 动态内容
    ///   - releasePulseVC: vc视图
    /// - Returns:
    func configureReleasePulseViewController(detailModel: FeedListCellModel, viewController: TSViewController) -> TSViewController{
        //分享类型 - 所有人、朋友、我
        if let privacyType = PrivacyType(rawValue: detailModel.privacy) {
            if let releasePulseVC = viewController as? TSReleasePulseViewController {
                releasePulseVC.rejectPrivacyType = privacyType
            } else if let postShortVC = viewController as? PostShortVideoViewController {
                postShortVC.rejectPrivacyType = privacyType
            }
        }
        //话题
        if detailModel.topics.count > 0 {
            let topic = TopicCommonModel()
            topic.id = detailModel.topics[0].topicId
            topic.name = detailModel.topics[0].topicTitle ?? ""
            if let releasePulseVC = viewController as? TSReleasePulseViewController {
                releasePulseVC.topics = [topic]
            } else if let postShortVC = viewController as? PostShortVideoViewController {
                postShortVC.topics = [topic]
            }
        }
        //位置签到
        if let loc = detailModel.location {
            let location = TSPostLocationObject()
            location.locationID = loc.locationID ?? ""
            location.locationName = loc.locationName ?? ""
            location.locationLatitude = loc.locationLatitude
            location.locationLongtitude = loc.locationLongtitude
            location.address = loc.address ?? ""
            if let releasePulseVC = viewController as? TSReleasePulseViewController {
                releasePulseVC.rejectLocation = location
            } else if let postShortVC = viewController as? PostShortVideoViewController {
                postShortVC.rejectLocation = location
            }
        }
        // Tagged 用户
        let users = detailModel.tagUsers
        if let releasePulseVC = viewController as? TSReleasePulseViewController {
            releasePulseVC.selectedUsers = users
        } else if let postShortVC = viewController as? PostShortVideoViewController {
            postShortVC.selectedUsers = users
        }
        
        // 标记 merchant 用户
        let tagMerchants = detailModel.rewardsLinkMerchantUsers
        if let releasePulseVC = viewController as? TSReleasePulseViewController {
            releasePulseVC.selectedMerchants = tagMerchants
        } else if let postShortVC = viewController as? PostShortVideoViewController {
            postShortVC.selectedMerchants = tagMerchants
        }
        
        return viewController
    }
    
}
// For show float event purpose base on module's float location
enum ModuleType: String {
    case feed, discover, yipps_wanted, im, account, dashboard, none
}

class PortraitNavigationController: TSNavigationController {
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
