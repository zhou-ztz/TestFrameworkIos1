//
//  MiniVideoPageViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 02/02/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import Hero
import CoreMedia
import AVFoundation
import AliyunVideoSDKPro
import AliyunPlayer

public class MiniVideoPageViewController: BaseContentPageController {

    private(set) var videos: [FeedListCellModel]
    private(set) var type: FeedListType
    private var ableLoadMore: Bool = true
    private var isFetching: Bool = false

    //isModal判断有时会失误，增加一个参数用来指定当前Controller的跳转是否为NavPush方式
    var isControllerPush: Bool?

    //用来做列表播放的list对象
    private var listPlayer: AliListPlayer = AliListPlayer()
    
    var onToolbarUpdate: onToolbarUpdate?
    var currentView: MiniVideoControlVC? {
        didSet {
            if let view = currentView {
                self.view.hero.id = view.model.idindex.stringValue
            }
        }
    }
    var onDataChanged: ((FeedListCellModel) -> Void)?
    //当用户操作视频后需要让个人中心页面更新数据
    var needReloadHomaPageData: (() -> Void)?
    var isTranslateText: Bool = false
    var translateHandler: ((Bool) -> Void)?
    
    private lazy var placeHolder: PlaceHolderView = {
        let view = PlaceHolderView(offset: 0, heading: "", detail: "", lottieName: "feed-loading", theme: .dark)
        view.backgroundColor = .clear
        return view
    }()
    
    var onPassPlayer: ((AVPlayer?, CMTime?) -> Void)? = nil
    private var isMovingForward: Bool = false
    var tagVoucher: TagVoucherModel? = nil
//    private let taskManager = PostTaskManager.shared
    
    var bottomStackView = UIStackView().configure {
        $0.distribution = .fill
        $0.alignment = .fill
        $0.spacing = 5
        $0.axis = .vertical
    }
    
    init(type: FeedListType, videos: [FeedListCellModel], focus selectedVideoIndex: Int, onToolbarUpdate: onToolbarUpdate?, avPlayer: AVPlayer? = nil, isTranslateText: Bool = false,  translateHandler: ((Bool) -> Void)? = nil, tagVoucher: TagVoucherModel? = nil) {
        self.type = type
        self.videos = videos
        self.onToolbarUpdate = onToolbarUpdate
        self.isTranslateText = isTranslateText
        self.translateHandler = translateHandler
        self.tagVoucher = tagVoucher
        super.init(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
        self.disablePanAtBottom = true
        self.delegate = self
        self.dataSource = self
        self.initPlayerSource(videos)
        currentIndex = selectedVideoIndex
        currentView?.type = self.type
        
        switch self.type {
        case .detail(let feedId):
            placeHolder.makeVisible()
            
            if videos.count > 0 {
                self.placeHolder.makeHidden()
                self.ableLoadMore = false
                self.reloadPageData(false)
            } else {
                FeedListNetworkManager.getMomentFeed(id: feedId) { [weak self] (model, message, status, _) in
                    defer {
                        self?.placeHolder.makeHidden()
                    }
                    guard let self = self, let model = model, status else {
                        return
                    }
                    
                    let cellModel = FeedListCellModel(feedListModel: model)
                    self.videos = [cellModel]
                    //处理重复add uid的情况，先清除播放列表再添加，不然可能会导致串流
                    MiniVideoListPlayerManager.shared.clearPlayerSource()
                    self.initPlayerSource(self.videos)
                    //lixiaodong 在clear播放列表之后返回需要重新加载播放资源
                    UserDefaults.standard.setValue(true, forKey: "minivideo-ableReInit")
                    self.ableLoadMore = false
                    self.reloadPageData()
                    
                   
                }
            }
        default:
            self.reloadPageData(false)
        }
    }
    
    func initPlayerSource(_ videos: [FeedListCellModel]) {
        MiniVideoListPlayerManager.shared.initPlayerSource(videos)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return super.preferredStatusBarStyle
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if videos.count > 0 {
            self.hero.isEnabled = true
            self.view.hero.id = videos[currentIndex].idindex.stringValue
        }
        
        self.view.backgroundColor = .clear
        self.view.bringSubviewToFront(refreshView)
        
        self.view.addSubview(placeHolder)
        placeHolder.bindToEdges()
        placeHolder.isHidden = true
        
        setupTabbar()
        
        self.loadGestureEnabled = true
        self.onLoadMore = { [weak self] in
            
            guard let self = self else { return }
            
            guard self.ableLoadMore, !self.isFetching, self.currentIndex == self.videos.count - 1 else { return }

            DispatchQueue.main.async {
                let bottomView = ContentPageBottomView(bgColor: UIColor.darkGray.withAlphaComponent(0.5),
                                                       textColor: .white, text: "load_more".localized)
                self.showBottomFloatingView(with: bottomView, displayDuration: 1.0, allowTouch: true)
                bottomView.start()
                self.loadMore()
            }
        }
        
        self.onRefresh = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.refreshView.reset()
                self.fetch()
            }
        }
        
        if videos.count == 1 && ableLoadMore {
            loadMore()
        }
        
        NotificationCenter.default.add(observer: self, name: UIApplication.didEnterBackgroundNotification) { [weak self] in
            if let currentView = self?.currentView {
                currentView.didEnterBackground()
            }
        }
        
        NotificationCenter.default.add(observer: self, name: UIApplication.willEnterForegroundNotification) { [weak self] in
            if let currentView = self?.currentView {
                currentView.enterForeground()
            }
        }
        
        NotificationCenter.default.add(observer: self, name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil) { [weak self] (noti) in
            guard let self = self else { return }
            guard let userInfo = noti.userInfo, let followStatus = userInfo["follow"] as? FollowStatus, let uid = userInfo["userid"] as? String else { return }
            self.currentView?.updateFollowStatus(followStatus, userId: uid)
        }
        //筛选条件更新
        NotificationCenter.default.observe(Notification.Name.Setting.configUpdated) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.filterDidApplied(nil)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit MiniVideoPageViewController")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setClearNavBar(shadowColor: .clear)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        TSKeyboardToolbar.share.theme = .white
        TSKeyboardToolbar.share.setStickerNightMode(isNight: false)
        
        if let ableReInit = UserDefaults.standard.value(forKey: "minivideo-ableReInit") as? Bool {
            if ableReInit == true && self.videos.count > 1 {
                //重新加载阿里云播放器列表数据
                UserDefaults.standard.set(false, forKey: "minivideo-ableReInit")
                self.initPlayerSource(videos)
            }
        }
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        //进入页面时将状态栏的字体改为白色
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setWhiteNavBar(normal: true)
        if self.navigationController?.isBeingDismissed == true {
            dataSource = nil
            delegate = nil
        }
        MiniVideoListPlayerManager.shared.stop()
        TSKeyboardToolbar.share.setStickerNightMode(isNight: false)
        TSKeyboardToolbar.share.theme = .white
        //离开页面还原
        if #available(iOS 13.0, *) {
            UIApplication.shared.setStatusBarStyle(.darkContent, animated: true)
        } else {
            UIApplication.shared.setStatusBarStyle(.default, animated: true)
        }
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ///关闭右滑跳转个人详情页面
//        self.pushDestination = { [weak self] in
//            guard let self = self else { return nil }
//            if let user = self.videos[self.currentIndex].userInfo {
//                let vc = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "HomePageViewController") as! HomePageViewController
//                vc.model = HomepageModel(userIdentity: user.userIdentity)
//                return vc
//            }
//            return nil
//        }
//        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
//             DispatchQueue.main.async {
//                 print("minivideo  =========== \(self.avPlayer) ")
//                 //在通过feedCell进入miniVideoController时禁用侧滑手势
//                 if self.avPlayer != nil {
//                     self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//                 }
//             }
//         })
        
    }
  
    override func finishRefresh() {
        refreshView.reset()
    }
    
    // 单独处理视频类型的逻辑
    public override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == refreshGesture {
            let translation = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: view)
            guard translation.y < 0 || currentIndex == 0 else {
                return false
            }
            
        }
        return true
    }
    
    // Public
    func deleteVideo() {
        self.needReloadHomaPageData?()
        if videos.count > 1 {
            videos.remove(at: currentIndex)
            if currentIndex == videos.count - 1 {
                currentIndex = 0
            }
            self.dataSource = nil
            self.dataSource = self
//            self.avPlayer = nil
            self.reloadPageData()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func onDataChanged(_ model: FeedListCellModel) {
        self.onDataChanged?(model)
        if let index = self.videos.firstIndex(where: { $0.idindex == model.idindex }) {
            self.videos[index] = model
        }
    }
    
    override func onPanAtBottom(sender: UIPanGestureRecognizer) {
        self.currentView?.onPanAtBottom(sender: sender)
    }
    
    public override var shouldAutorotate: Bool {
        return false
    }
}

extension MiniVideoPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? MiniVideoControlVC else { return nil }
        var index = currentVC.index
        if index == 0 {
            return nil
        }
        
        index -= 1
        let vc = MiniVideoControlVC(model: videos[index])
        vc.type = type
        vc.index = index
        return vc
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? MiniVideoControlVC else { return nil }
        var index = currentVC.index
        if index >= videos.count - 1 {
            return nil
        }
        index += 1
        let vc = MiniVideoControlVC(model: videos[index])
        vc.type = type
        vc.index = index
        return vc
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {
            return
        }
        guard let currentVC = pageViewController.viewControllers?.first as? MiniVideoControlVC else { return }
        
        currentIndex = currentVC.index
        currentView = currentVC
        self.isLast = currentIndex == videos.count - 1
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return videos.count
    }
}

// Private
extension MiniVideoPageViewController {
    private func reloadPageData(_ isReload: Bool = true) {
        guard !videos.isEmpty else {
            return
        }
        
        let initialVC = MiniVideoControlVC(model: videos[currentIndex])
        initialVC.type = type
        initialVC.index = self.currentIndex
        self.currentView = initialVC
        if isReload == false {
            self.currentView?.isTranslateText =  self.isTranslateText
            self.currentView?.translateHandler = self.translateHandler
        }
        self.setViewControllers([initialVC], direction: .forward, animated: false, completion: nil)
    }
    
    private func filterDidApplied(_ type: FeedListType?) {
        if let type = type {
            guard self.type != type else {
                return
            }
            self.type = type
        }
        
        guard !isFetching else {
            return
        }
        
        isFetching = true
        placeHolder.makeVisible()
        
        FeedListNetworkManager.getFeeds(mediaType: .miniVideo, feedType: self.type) { [weak self] (models, errorMessage, status) in
            DispatchQueue.main.async {
                defer {
                    self?.isFetching = false
                    self?.placeHolder.makeHidden()
                }
                
                if let error = errorMessage {
                    self?.showTopIndicator(status: .faild, error)
                    return
                }
            }
                
            guard let self = self, let models = models else { return }
        
            self.videos = models
            self.currentIndex = 0
            DispatchQueue.main.async {
                self.reloadPageData()
                self.initPlayerSource(models)
            }
        }
    }
    
    private func fetch() {
        FeedListNetworkManager.getFeeds(mediaType: .miniVideo, feedType: self.type) { [weak self] (models, errorMessage, status) in
            DispatchQueue.main.async {
                defer {
                    self?.isFetching = false
                    self?.placeHolder.makeHidden()
                }
                
                if let error = errorMessage {
                    self?.showTopIndicator(status: .faild, error)
                    return
                }
            }
                
            guard let self = self, let models = models else { return }
        
            self.videos = models
            self.currentIndex = 0
            DispatchQueue.main.async {
                self.reloadPageData()
                self.initPlayerSource(models)
            }
        }
    }
    
    private func loadMore() {
        guard !isFetching else {
            return
        }
        isFetching = true
        
        let lastId = videos.last?.idindex ?? 0
        let afterTime = videos.last?.afterTime
        
        FeedListNetworkManager.getFeeds(mediaType: .miniVideo, feedType: type, after: lastId, afterTime: afterTime) { [weak self] (models, errorMessage, status) in
            defer {
                self?.isFetching = false
            }
            
            DispatchQueue.main.async {
                if let error = errorMessage {
                    self?.showError(message: error)
                    return
                }
            }
            guard let self = self, let models = models else {
                return
            }
            
            DispatchQueue.main.async {
                if models.count == 0 {
                    UIViewController.showBottomFloatingToast(with: "", desc: "no_more_data_tips".localized)
                } else {
                    self.videos.append(contentsOf: models)
                    self.initPlayerSource(models)
                    self.dataSource = nil
                    self.dataSource = self
                }
            }
        }
    }
    
    private func setupTabbar() {
        let navbar = MiniVideoNavBar()
        self.view.addSubview(navbar)
        self.view.addSubview(bottomStackView)
        navbar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.topLayoutGuide.snp.bottom)
            $0.height.equalTo(TSNavigationBarHeight)
        }
        
        bottomStackView.snp.makeConstraints {
            $0.top.equalTo(navbar.snp.bottom).offset(-15)
            $0.left.right.equalToSuperview()
        }

        navbar.backButtonDidTapped = { [weak self] in
            if self?.isModal == true && self?.isControllerPush == nil  {
                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
//        if (type == FeedListType.hot || type == FeedListType.follow || type == FeedListType.recommend) {
//            navbar.setType(type)
//        }
      
        navbar.searchButtonDidTapped = { [weak self] in
            self?.searchButtonClick()
        }
        navbar.createPostButtonDidTapped = { [weak self] button in
            self?.createPostButtonClick(button)
        }
        navbar.moreButtonDidTapped = { [weak self] in
            self?.moreButtonClick()
        }
        
//        bottomStackView.addArrangedSubview(taskManager.taskProgressView)
//        taskManager.updateColor = true
//        taskManager.updateTextColor()
//        taskManager.onUpdateView = { [weak self] in
//            self?.taskManager.updateColor = true
//            self?.view.layoutIfNeeded()
//        }
    }
  
    // MARK: - 筛选页面
    private func filterButtonClick() {
//        let destination = DiscoverCategoryViewController(type: .miniVideoCountryAndLanguage)
//        self.navigationController?.present(TSNavigationController(rootViewController: destination).fullScreenRepresentation, animated: true)
    }
    
    // MARK: - 搜索页面
    private func searchButtonClick() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let vc = GalleryCollageViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 发布动态
    private func createPostButtonClick(_ button: UIButton) {
        guard TSCurrentUserInfo.share.isLogin == true else {
            TSRootViewController.share.guestJoinLandingVC()
            return
        }
        guard PostTaskManager.shared.isAbleToPost() else {
            self.showError(message: "feed_upload_max_error".localized)
            return
        }
        TSRootViewController.share.postFeedCenterButtonTapped(button)
    }
    
    // MARK: - 更多
    private func moreButtonClick() {
        guard let id = CurrentUserSessionInfo?.userIdentity else {
            return
        }
        let model = self.videos[currentIndex]
        self.navigationController?.presentPopVC(target: model, type: model.userId == id ? .moreMe : .moreUser , delegate: self)
    }
}

extension MiniVideoPageViewController: CustomPopListProtocol{
    func customPopList(itemType: TSPopUpItem) {
        self.handlePopUpItemAction(itemType: itemType)
    }
    
    func handlePopUpItemAction(itemType: TSPopUpItem) {
        let model = self.videos[currentIndex]
        
        switch itemType {
          case .save(isSaved: let isSaved):
            let isCollect = (model.toolModel?.isCollect).orFalse ? false : true
            
            TSMomentNetworkManager().colloction(isCollect ? 1 : 0, feedIdentity: model.idindex, feedItem: model) { [weak self] (result) in
                if result == true {
                    model.toolModel?.isCollect = isCollect
                    DispatchQueue.main.async {
                        if isCollect {
                            self?.showTopFloatingToast(with: "success_save".localized, desc: "")
                        }
                    }
                }
                
            }

          case .reportPost:
             
            guard let reportTarget: ReportTargetModel = ReportTargetModel(feedModel: model) else { return }
                  let reportVC: ReportViewController = ReportViewController(reportTarget: reportTarget)
                  self.present(TSNavigationController(rootViewController: reportVC).fullScreenRepresentation,
                               animated: true,
                               completion: nil)
              

        case .edit:
            
            guard let url = URL(string: model.videoPath) else { return }
            
            // 创建一个表示网络视频文件的URL对象
            let asset = AVURLAsset(url: url)
            let coverImage = TSUtil.generateAVAssetVideoCoverImage(avAsset: asset)
            
            var vc = PostShortVideoViewController(nibName: "PostShortVideoViewController", bundle: nil)
            vc.shortVideoAsset = ShortVideoAsset(coverImage: coverImage, asset: nil, recorderSession: nil, videoFileURL: url)
            
            vc.isMiniVideo = true
            vc.feedId = model.idindex.stringValue
            vc.coverId = model.videoCoverId
            vc.videoId = model.videoId
            vc.preText = model.content
            vc.isFromEditFeed = true
            vc.tagVoucher = self.tagVoucher
            
            if let extenVC = self.configureReleasePulseViewController(detailModel: model, viewController: vc) as? PostShortVideoViewController{
                vc = extenVC
            }
            
            let navigation = TSNavigationController(rootViewController: vc).fullScreenRepresentation
            self.present(navigation, animated: true, completion: nil)
            

          case .deletePost:
             let feedId = model.idindex
            
              self.showRLDelete(title: "rw_delete_action_title".localized, message: "rw_delete_action_desc".localized, dismissedButtonTitle: "delete".localized, onDismissed: { [weak self] in
                  guard let self = self else { return }
                  TSMomentNetworkManager().deleteMoment(model.idindex ?? 0) { [weak self] (result) in
                      guard let self = self else { return }
                      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedDelete"), object: nil, userInfo: ["feedId": feedId])
                      self.navigationController?.popViewController(animated: true)
                  }
              }, cancelButtonTitle: "cancel".localized)
  
          case .pinTop(isPinned: let isPinned):
            let feedId = model.idindex
            
              let networkManager: (Int, @escaping (String, Int, Bool?) -> Void) -> Void = isPinned ? FeedListNetworkManager.unpinFeed: FeedListNetworkManager.pinFeed
            
              networkManager(feedId) { [weak self] (errMessage, statusCode, status) in

                  guard let self = self else { return }
                  guard status == true else {
                      if statusCode == 241 {
                          self.showDialog(image: nil, title: isPinned ? "fail_to_pin_title".localized : "fail_to_unpin_title".localized, message: isPinned ? "fail_to_pin_desc".localized : "fail_to_unpin_desc".localized, dismissedButtonTitle: "ok".localized, onDismissed: nil, onCancelled: nil)
                      } else {
                          self.showError(message: errMessage)
                      }
                      return
                  }
                  let newPined = !isPinned
                  
                  model.isPinned = newPined
                  self.showError(message: newPined ? "feed_pinned".localized : "feed_unpinned".localized)
                  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPinnedFeed"), object: nil, userInfo: ["isPinned": !isPinned, "feedId": feedId])
              }
              break

          case .comment(isCommentDisabled: let isCommentDisabled):
            let feedId = model.idindex
              
              let newValue = model.toolModel?.isCommentDisabled ?? true ? 0 : 1
              TSMomentNetworkManager().commentPrivacy(newValue, feedIdentity: feedId) { [weak self] success in
                  guard let self = self else { return }
                  if success {
                      model.toolModel?.isCommentDisabled = newValue == 1
                      DispatchQueue.main.async {
                          if newValue == 1 {
                              self.showTopIndicator(status: .success, "disable_comment_success".localized)
                          } else {
                              self.showTopIndicator(status: .success, "enable_comment_success".localized)
                          }
                          DispatchQueue.main.async {
                              self.reloadPageData()
                          }
                      }
                  }
              }
              
              break
              
          default:
              break
          }
      }
}

class CommentListPresentationController: UIPresentationController {
    var heightPercent: CGFloat = 0.66
    var dismissHandler: EmptyClosure?

    private let background = UIView().configure {
        $0.backgroundColor = .clear
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            guard let parentView = containerView else {
                return .zero
            }

            return CGRect(x: 0, y: parentView.bounds.height * (1 - heightPercent), width: parentView.bounds.width, height: parentView.bounds.height * heightPercent)
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if let frame = containerView?.frame, completed {
            background.frame = frame
            background.addTap { [weak self] _ in
                self?.presentedViewController.dismiss(animated: true, completion: {
                    self?.dismissHandler?()
                })
            }
            containerView?.insertSubview(background, at: 0)
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            background.removeFromSuperview()
        }
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}

class MiniVideoTab: UIView {

    lazy var titleView: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.white, for: .selected)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        button.dropShadow()
        return button
    }()
    lazy var drawLineView: UIView = {
        let lineV = UIView()
        lineV.backgroundColor = .clear
        lineV.roundCorner(3)
        return lineV
    }()

    init(title: String) {
        super.init(frame: .zero)

        self.isUserInteractionEnabled = true

        addSubview(titleView)
        addSubview(drawLineView)
        
        titleView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        titleView.setTitle(title, for: .normal)
        
        drawLineView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(5)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(3)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isSelected: Bool = false {
        didSet {
            titleView.isSelected = isSelected
            titleView.set(font: isSelected == true ? UIFont.systemFont(ofSize: 16, weight: .semibold) : UIFont.systemRegularFont(ofSize: 16))
            drawLineView.backgroundColor = isSelected == true ? AppTheme.primaryRedColor : .clear
        }
    }
}

class MiniVideoNavBar: UIView {

    private lazy var recommendBtn: MiniVideoTab = {
        let button = MiniVideoTab(title: "search_user_recommend".localized)
        button.titleView.addAction { [weak self] in
            self?.buttonDidTapped(.recommend)
        }
        return button
    }()

    private lazy var followBtn: MiniVideoTab = {
        let button = MiniVideoTab(title: "home_tab_following".localized)
        button.titleView.addAction { [weak self] in
            self?.buttonDidTapped(.follow)
        }
        return button
    }()

    lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.set_image(named: "iconsArrowCaretleftWhite"), for: .normal)
        button.addAction { [weak self] in
            self?.backButtonDidTapped?()
        }
        return button
    }()
    
    lazy var searchButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.set_image(named: "icFeedSearchInactiveWhite"), for: .normal)
        button.addAction { [weak self] in
            self?.searchButtonDidTapped?()
        }
        return button
    }()
    
    lazy var createPostButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.set_image(named: "iconsAddmomentWhite"), for: .normal)
        button.addAction { [weak self] in
            self?.createPostButtonDidTapped?(button)
        }
        return button
    }()
    
    lazy var filterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.set_image(named: "iconsFilterWhite"), for: .normal)
        button.addAction { [weak self] in
            self?.filterButtonDidTapped?()
        }
        return button
    }()
    
    lazy var moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.set_image(named: "IMG_topbar_more_white"), for: .normal)
        button.addAction { [weak self] in
            self?.moreButtonDidTapped?()
        }
        return button
    }()
    
    var filterDidApplied: ((FeedListType) -> Void)?
    var backButtonDidTapped: EmptyClosure?
    var filterButtonDidTapped: EmptyClosure?
    var searchButtonDidTapped: EmptyClosure?
    var moreButtonDidTapped: EmptyClosure?
    var createPostButtonDidTapped: ((UIButton) -> Void)?
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear

        self.addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        let rightStackview = UIStackView().configure {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .fillEqually
            $0.spacing = 12
        }

        self.addSubview(rightStackview)
        rightStackview.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-15)
            $0.centerY.equalToSuperview()
        }

        rightStackview.addArrangedSubview(moreButton)

        moreButton.snp.makeConstraints {
            $0.height.equalTo(25)
            $0.width.equalTo(25)
        }
    }

    func setType(_ type : FeedListType) {
        let stackview = UIStackView().configure {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .fillEqually
            
            $0.spacing = 5
        }

        self.addSubview(stackview)
        stackview.snp.makeConstraints {
            $0.left.equalTo(backButton.snp.right).offset(15)
            $0.centerY.equalToSuperview()
        }

        stackview.addArrangedSubview(recommendBtn)
        stackview.addArrangedSubview(followBtn)

        recommendBtn.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalTo(50)
        }

        followBtn.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalTo(50)
        }

        recommendBtn.isSelected = type == .recommend
        followBtn.isSelected = type == .follow
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buttonDidTapped(_ type: FeedListType) {
        recommendBtn.isSelected = type == .recommend
        followBtn.isSelected = type == .follow
    
    }

    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
}
