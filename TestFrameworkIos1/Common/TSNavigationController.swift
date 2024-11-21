//
//  TSNavigationController.swift
//  Thinksns Plus
//
//  Created by lip on 2016/12/30.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  抽象类

import UIKit
import Toast
import AVFoundation


extension UIViewController {
    
    var fullScreenRepresentation: UIViewController {
        self.modalPresentationStyle = .fullScreen
        return self
    }
    
}

@objc class TSNavigationController: UINavigationController, TSIndicatorAProrocol, UIGestureRecognizerDelegate {
    // 右侧按钮容器视图
    //
    // - Warning: 为了处理对音乐的显示情况,右侧按钮使用该视图
    lazy var rightBarContentView = UIView(frame: CGRect.zero)
    lazy var rightBarContentWidth: CGFloat = 0
    
    var customBarStyle: UIBarStyle = .default
    
    private var availableOrientations: UIInterfaceOrientationMask?
    private var isPushing = false
    
    // This variable to check if want use presenting view controller orientations, if not use back orientation from top most controller/available orientations
    private var shouldSupportPresentingController = true
    
    override open var shouldAutorotate: Bool {
        if availableOrientations != nil && availableOrientations == .portrait {
            return false
        }
        
        //guard availableOrientations == nil else { return true }
        return visibleViewController?.shouldAutorotate ?? false
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if availableOrientations != nil {
            return availableOrientations!
        }
        
        //guard availableOrientations == nil else { return availableOrientations! }
        return visibleViewController?.supportedInterfaceOrientations ?? .portrait
    }
    
    public var onPopViewController: (()->())? = nil
    
    // MARK: - Lifecycle
    class func initializeNavigationBar() {
        super.initialize()
        let navigationBar = UINavigationBar.appearance()
        let navigationBarTitleAttributes = [NSAttributedString.Key.foregroundColor: InconspicuousColor().navTitle, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: TSFont.Navigation.headline.rawValue)]
        navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        navigationBar.titleTextAttributes = navigationBarTitleAttributes
        navigationBar.barTintColor = UIColor.white
        navigationBar.tintColor = InconspicuousColor().navTitle
        navigationBar.isTranslucent = false
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowColor = .clear
            appearance.shadowImage = UIImage()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    init(rootViewController: UIViewController, availableOrientations: UIInterfaceOrientationMask? = nil, shouldSupportPresentingController: Bool = true) {
        super.init(rootViewController: rootViewController)
        
        self.shouldSupportPresentingController = shouldSupportPresentingController
        self.availableOrientations = availableOrientations
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
        self.hero.navigationAnimationType = .none
        self.delegate = self
        interactivePopGestureRecognizer?.delegate = self
        
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AvatarButton.DidClick, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.CommentChange.editModel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReciveAvatarDidClick), name: NSNotification.Name.AvatarButton.DidClick, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(presentAudioCall), name: NSNotification.Name(rawValue: "NIMNETCALL_AUDIO"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(presentVideoCall), name: NSNotification.Name(rawValue: "NIMNETCALL_VIDEO"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(presentTeamCall), name: NSNotification.Name(rawValue: "NIMNETCALL_TEAM"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showIndicatorA(noti:)), name: NSNotification.Name.NavigationController.showIndicatorA, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReciveFeedEditModelDidClick), name: NSNotification.Name.CommentChange.editModel, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.hero.isEnabled = true
        self.navigationBar.barStyle = customBarStyle
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if self.viewControllers.isEmpty == false {
            let backBarItem = UIBarButtonItem(image: UIImage.set_image(named: "iconsArrowCaretleftBlack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popBack))
            viewController.navigationItem.leftBarButtonItem = backBarItem
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        userConfiguration?.sesssionCheckThrottler.call()

        if super.popViewController(animated: animated) == nil {
            self.visibleViewController?.dismiss(animated: true, completion: nil)
        }
        
        onPopViewController?()

        return nil
    }

    @objc func popBack() {
        let _ = self.popViewController(animated: true)
//        super.popViewController(animated: true)
    }

    @objc func didReciveAvatarDidClick(noti: Notification) {
        guard let userInfo = noti.userInfo as? Dictionary<String, Any> else { return }
        // 判断跳转方式是uid还是uname分别进行跳转
        // uid兼容Int、String、NSNumber
        // uname只支持String
        // 如果都不是就不跳转
        
        var isFromReactionList : Bool = false
        
        if let temp = userInfo["isFromReactionList"] as? Bool {
            isFromReactionList = temp
        }
        
        if userInfo["uid"] != nil {
            var uidInt: Int = 0
            if let uid = userInfo["uid"] as? Int {
                uidInt = uid
            } else if let uidStr = userInfo["uid"] as? String, let uid = Int(uidStr) {
                uidInt = uid
            } else if let uidNumber = userInfo["uid"] as? NSNumber {
                uidInt = uidNumber.intValue
            }
            
            if uidInt > 0 {
//                let userHomPage = HomePageViewController(userId: uidInt, isFromReactionList: isFromReactionList)
//                if (self.topViewController?.navigationController?.isNavigationBarHidden ?? false) {
//                    userHomPage.isFromNonNavigateVC = true
//                }
//                if let defaultPageType = userInfo["defaultPage"] as? HomeTabSectionType {
//                    userHomPage.defaultToTab = defaultPageType
//                }
//                self.pushViewController(userHomPage, animated: true)
            } else {
                self.topViewController?.showError(message: "text_user_suspended".localized)
            }
        } else if let nickName = userInfo["uname"] as? String {
//            let userHomPage = HomePageViewController(userId: 0, nickname: nickName, isFromReactionList: isFromReactionList)
//            if let defaultPageType = userInfo["defaultPage"] as? HomeTabSectionType {
//                userHomPage.defaultToTab = defaultPageType
//            }
//            self.pushViewController(userHomPage, animated: true)
        } else {
            self.topViewController?.showError(message: "text_user_suspended".localized)
        }
    }
    @objc func didReciveFeedEditModelDidClick(noti: Notification) {
        guard let userInfo = noti.userInfo as? Dictionary<String, Any> else { return }
        if let postModel =  userInfo["post_model"] as? PostModel {
            //被拒绝动态为视频动态
            if let video = postModel.video, let videoUrl = video.videoFileURL{
                // 创建一个表示网络视频文件的URL对象
                let asset = AVURLAsset(url: videoUrl)
                let coverImage = TSUtil.generateAVAssetVideoCoverImage(avAsset: asset)
                var vc = PostShortVideoViewController(nibName: "PostShortVideoViewController", bundle: nil)
                vc.shortVideoAsset = ShortVideoAsset(coverImage: coverImage, asset: nil, recorderSession: nil, videoFileURL: videoUrl)
                vc.isMiniVideo = true
                vc.isFromEditFeed = true
                vc.feedId = postModel.feedId
                vc.coverId = postModel.videoCoverId
                vc.videoId = postModel.videoDataId
                if let extenVC = self.configureReleasePulseViewController(postModel: postModel, viewController: vc) as? PostShortVideoViewController{
                    vc = extenVC
                }
                if postModel.feedContent.count > 0  {
                    vc.preText = postModel.feedContent
                }
                let navigation = TSNavigationController(rootViewController: vc).fullScreenRepresentation
                self.present(navigation, animated: true, completion: nil)
                return
            }
            //被拒绝动态为图片动态
            if (postModel.images?.count ?? 0) > 0 || (postModel.phAssets?.count ?? 0) > 0 {
                var vc = TSReleasePulseViewController(isHiddenshowImageCollectionView: false)
                vc.selectedPHAssets = postModel.phAssets ?? []
                vc.selectedModelImages = postModel.images ?? []
                if postModel.feedContent.count > 0  {
                    vc.preText = postModel.feedContent
                }
                vc.feedId = postModel.feedId
                vc.isFromEditFeed = true
                if let extenVC = self.configureReleasePulseViewController(postModel: postModel, viewController: vc) as? TSReleasePulseViewController{
                    vc = extenVC
                }
                let navigation = TSNavigationController(rootViewController: vc).fullScreenRepresentation
                self.present(navigation, animated: true, completion: nil)
                return
            }
            //被拒绝动态为纯文本
          
            var vc = TSReleasePulseViewController(isHiddenshowImageCollectionView: true, isText: true)
            vc.preText = postModel.feedContent
            vc.feedId = postModel.feedId
            vc.isFromEditFeed = true
            if let extenVC = self.configureReleasePulseViewController(postModel: postModel, viewController: vc) as? TSReleasePulseViewController{
                vc = extenVC
            }
            let navigation = TSNavigationController(rootViewController: vc).fullScreenRepresentation
            self.present(navigation, animated: true, completion: nil)
            
        }
    }
    @objc func showIndicatorA(noti: Notification) {
        var title: String
        if let str = noti.userInfo?["content"] as? String {
            title = str
        } else {
            title = "error_network".localized
        }
        show(indicatorA: title)
    }
    
    public func setCloseButton(backImage: Bool = false, titleStr: String? = nil, customView: UIView? = nil) {
        guard let viewController = visibleViewController else { return }
        
        let image: UIImage
        if backImage == false {
            image = UIImage.set_image(named: "IMG_topbar_close")!
        } else {
            image = UIImage.set_image(named: "iconsArrowCaretleftBlack")!
        }
        let barButton = UIBarButtonItem(image: image, action: { [weak self] in
            let _ = self?.popViewController(animated: true)
        })
        barButton.tintColor = .black
        if let titleStr = titleStr {
            let btn = UIButton(type: .custom)
            btn.set(title: titleStr, titleColor: .black, for: .normal)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            let titleButton = UIBarButtonItem(customView: btn)
            viewController.navigationItem.leftBarButtonItems = [barButton, titleButton]
            return
        }
        if let customView = customView {
            let titleButton = UIBarButtonItem(customView: customView)
            viewController.navigationItem.leftBarButtonItems = [barButton, titleButton]
            return
        }
        viewController.navigationItem.leftBarButtonItem = barButton
    }
}

extension TSNavigationController {
    fileprivate func customSetup() {
        view.backgroundColor = TSColor.inconspicuous.background
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension TSNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if responds(to: #selector(getter: self.interactivePopGestureRecognizer)) {
            if viewControllers.count > 1 {
                interactivePopGestureRecognizer?.isEnabled = true
            } else {
                interactivePopGestureRecognizer?.isEnabled = false
            }
        }
    }
    
}

extension TSNavigationController {
    
 
    func configureReleasePulseViewController(postModel: PostModel, viewController: TSViewController) -> TSViewController {
        //分享类型 - 所有人、朋友、我
        if let privacyType = PrivacyType(rawValue: postModel.privacy) {
            if let releasePulseVC = viewController as? TSReleasePulseViewController {
                releasePulseVC.rejectPrivacyType = privacyType
            } else if let postShortVC = viewController as? PostShortVideoViewController {
                postShortVC.rejectPrivacyType = privacyType
            }
        }
        
        //话题
        if let topics = postModel.topics, topics.count > 0 {
            let topic = TopicCommonModel()
            topic.id = topics[0].id
            topic.name = topics[0].name ?? ""
            if let releasePulseVC = viewController as? TSReleasePulseViewController {
                releasePulseVC.topics = [topic]
            } else if let postShortVC = viewController as? PostShortVideoViewController {
                postShortVC.topics = [topic]
            }
        }
        //位置签到
        if let loc = postModel.taggedLocation {
            let location = TSPostLocationObject()
            location.locationID = loc.locationID
            location.locationName = loc.locationName
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
        if let userIds = postModel.tagUsers {
            if let releasePulseVC = viewController as? TSReleasePulseViewController {
                releasePulseVC.selectedUsers = userIds
            } else if let postShortVC = viewController as? PostShortVideoViewController {
                postShortVC.selectedUsers = userIds
            }
        }
        // 标记 merchant 用户
        if let tagMerchants = postModel.tagMerchants {
            if let releasePulseVC = viewController as? TSReleasePulseViewController {
                releasePulseVC.selectedMerchants = tagMerchants
            } else if let postShortVC = viewController as? PostShortVideoViewController {
                postShortVC.selectedMerchants = tagMerchants
            }
        }

        return viewController
    }
    
    
}
