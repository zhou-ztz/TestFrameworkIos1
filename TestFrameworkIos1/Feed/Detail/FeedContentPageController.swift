//
// Created by Francis Yeap on 12/11/2020.
// Copyright (c) 2020 Toga Capital. All rights reserved.
//

import Foundation
import Lottie
import Hero

public class CustomSizePresentationController : UIPresentationController {
    var heightPercent: CGFloat = 0.66
    var dismissHandler: EmptyClosure?
    private let background = UIView().configure {
        $0.backgroundColor = .clear
    }
    
    override public var frameOfPresentedViewInContainerView: CGRect {
        guard let parentView = containerView else {
            return .zero
        }
        if parentView.frame.width > parentView.frame.height {
            return CGRect(x: parentView.bounds.width/2, y: 0, width:  parentView.bounds.width/2, height: parentView.bounds.height)
        } else {
            return CGRect(x: 0, y: parentView.bounds.height * (1 - heightPercent), width: parentView.bounds.width, height: parentView.bounds.height * heightPercent)
        }
    }
    override public func presentationTransitionDidEnd(_ completed: Bool) {
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
    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            background.removeFromSuperview()
        }
    }
    
    public override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}

class FeedContentPageController: BaseContentPageController {
    private let animateView = AnimationView()
    private(set) var dataModel = FeedListCellModel()
    private var pageHandler = PageHandler()
    let interactiveView = FeedDetailInteractiveView()
    var onIndexUpdate: ((Int, String) -> Void)?
    var onToolbarUpdated: onToolbarUpdate?
    var translateHandler: ((Bool) -> Void)?
    var onTapHiddenUpdate: ((Bool) -> Void)?
    private var imageIndex: Int = 0
    var isClickComment: Bool = false
    var isTranslateText: Bool = false
    var onDelete: EmptyClosure?
    // feed type
    var type: FeedListType?
    
    init(currentIndex: Int = 0, dataModel: FeedListCellModel,
         imageIndex: Int = 0, placeholderImage: UIImage?,
         transitionId: String? = nil, isClickComment: Bool = false,
         isTranslateText: Bool = false,
         onRefresh: EmptyClosure?, onLoadMore: EmptyClosure?,
         onToolbarUpdated: onToolbarUpdate?,
         onIndexUpdate: ((Int, String) -> Void)? = nil,
         translateHandler: ((Bool) -> Void)? = nil,
         onTapHiddenUpdate: ((Bool) -> Void)? = nil
    ) { // require to update transition animation to correct trellis view
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        self.onIndexUpdate = onIndexUpdate
        self.currentIndex = currentIndex
        self.dataModel = dataModel
        self.onRefresh = onRefresh
        self.onLoadMore = onLoadMore
        self.pageHandler.controller = self
        self.imageIndex = imageIndex
        self.isClickComment = isClickComment
        self.isTranslateText = isTranslateText
        self.onToolbarUpdated = onToolbarUpdated
        self.translateHandler = translateHandler
        self.onTapHiddenUpdate = onTapHiddenUpdate
        
        let imageController = FeedDetailImageController(imageUrlPath: (dataModel.pictures[imageIndex].url).orEmpty, imageIndex: imageIndex, model: dataModel, placeholderImage: placeholderImage, transitionId: transitionId)
        
        setGesture(for: imageController)
        self.setViewControllers([imageController], direction: .forward, animated: true)
        self.hero.isEnabled = true
        
        updateInteractiveView()
        interactiveView.readMoreLabel.setAllowTruncation()
        interactiveView.alpha = 1
        
        interactiveView.onCommentTouched = { [unowned self] in
            self.openCommentView()
        }
        
        interactiveView.onGiftTouched = { [unowned self] in
            guard TSCurrentUserInfo.share.isLogin == true else {
                TSRootViewController.share.guestJoinLandingVC()
                return
            }
//            DispatchQueue.main.async {
//                if dataModel.userInfo?.isMe() == true {
//                    let vc = PostTipHistoryTVC(feedId: dataModel.idindex)
//                    self.navigationController?.pushViewController(vc, animated: true)
//                } else {
//                    self.presentTipping(target: dataModel.idindex, type: .moment, theme: .white) { [weak self] (feedId, _) in
//                        guard let self = self else { return }
//                        self.showSuccess(message: "tip_successful_title".localized)
//                        self.dataModel.toolModel?.rewardCount += 1
//                        self.dataModel.toolModel?.isRewarded = true
//                        self.interactiveView.updateCount(comment: (self.dataModel.toolModel?.commentCount).orZero, like: (self.dataModel.toolModel?.diggCount).orZero, forwardCount: (self.dataModel.toolModel?.forwardCount).orZero)
//                        self.interactiveView.updateCommentStatus(isCommentDisabled: self.dataModel.toolModel?.isCommentDisabled)
//                        self.updateInteractiveView()
//                        self.onToolbarUpdated?(self.dataModel)
//                    }
//                }
//            }
        }
        
        interactiveView.onForwardTouched =  { [unowned self] in
            if TSCurrentUserInfo.share.isLogin == false {
                TSRootViewController.share.guestJoinLandingVC()
                return
            }
            self.navigationController?.presentPopVC(target: "", type: .share, delegate: self)
        }
        
        interactiveView.onMoreTouched = { [unowned self] in
            guard let id = CurrentUserSessionInfo?.userIdentity else {
                return
            }
            
            self.navigationController?.presentPopVC(target: self.dataModel, type: self.dataModel.userId == id ? .moreMe : .moreUser , delegate: self)
        }
        
        interactiveView.onFollowTouched = { [weak self] in
            guard TSCurrentUserInfo.share.isLogin == true else {
                self?.isClickComment = false
                TSRootViewController.share.guestJoinLandingVC()
                return
            }
            guard var user = dataModel.userInfo else { return }
            user.updateFollow(completion: { [weak self] (success) in
                if success {
                    DispatchQueue.main.async {
                        self?.interactiveView.updateFollowButton(user.followStatus)
                    }
                }
            })
        }
        
        interactiveView.onVoucherTouched = { [weak self] in
            let vc = VoucherDetailViewController()
            vc.voucherId = dataModel.tagVoucher?.taggedVoucherId ?? 0
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        interactiveView.translateHandler = self.translateHandler
        
        interactiveView.onTapHiddenUpdate = self.onTapHiddenUpdate
        
        interactiveView.onLocationViewTapped = { [unowned self] (locationID, locationName) in
            let locationVC = TSLocationDetailVC(locationID: locationID, locationName: locationName)
            self.navigationController?.pushViewController(locationVC, animated: true)
        }
        
        interactiveView.onTopicViewTapped = { [unowned self] topicID in
            let topicVC = TopicPostListVC(groupId: topicID)
            if #available(iOS 11, *) {
                self.navigationController?.pushViewController(topicVC, animated: true)
            } else {
                let nav = TSNavigationController(rootViewController: topicVC).fullScreenRepresentation
                self.present(nav, animated: true, completion: nil)
            }
        }
        
        interactiveView.reactionSuccess = { [weak self] in
            guard let self = self else {
                return
            }
            FeedListNetworkManager.getMomentFeed(id: dataModel.idindex) { [weak self] (listModel, message, status, networkResult) in
                guard let listModel = listModel, status else {
                    return
                }
                
                let cellModel = FeedListCellModel(feedListModel: listModel)
                
                self?.dataModel = cellModel
                self?.interactiveView.updateUserReactionView(topReactionList: cellModel.topReactionList, totalReactions: (cellModel.toolModel?.diggCount).orZero)
                self?.onToolbarUpdated?(cellModel)
                self?.view.layoutIfNeeded()
            }
        }
        
        interactiveView.onTapReactionList = { [unowned self] feedId in
            self.showReactionBottomSheet()
        }
        
        if dataModel.tagVoucher?.taggedVoucherId != nil && dataModel.tagVoucher?.taggedVoucherId != 0 {
            if let title = dataModel.tagVoucher?.taggedVoucherTitle {
                interactiveView.voucherBottomView.isHidden = false
                interactiveView.voucherBottomView.voucherLabel.text = title
            }
        } else {
            interactiveView.voucherBottomView.isHidden = true
        }
    }
    
    func openCommentView() {
        defer {
            EventTrackingManager.instance.track(event: .innerFeedViewClicks, with: ["Clicked": "Comment Btn"])
        }
        TSKeyboardToolbar.share.theme = .white
        TSKeyboardToolbar.share.setStickerNightMode(isNight: false)
        let respondVC = ResponsePageController(theme: .white, feed: self.dataModel) { [weak self] (feed) in
            guard let toolbar = feed.toolModel else {
                return
            }
            self?.interactiveView.updateCount(comment: toolbar.commentCount, like: toolbar.diggCount, forwardCount: toolbar.forwardCount)
            self?.interactiveView.updateCommentStatus(isCommentDisabled: toolbar.isCommentDisabled)
            self?.onToolbarUpdated?(feed)
        }
        let nav = TSNavigationController(rootViewController: respondVC)
        nav.modalPresentationStyle = .custom
        nav.transitioningDelegate = self
        nav.view.backgroundColor = .clear
        self.present(nav, animated: true, completion: nil)
    }
    
    private func updateInteractiveView(isEdit: Bool? = nil) {
        interactiveView.updateTimeAndView(date: dataModel.time , views: (dataModel.toolModel?.viewCount).orZero, isEdit: isEdit ?? false)
        interactiveView.updateUser(user: dataModel.userInfo)
        interactiveView.updateSponsorStatus(dataModel.isSponsored)
        //Rewardslink hidden topic view
        //interactiveView.updateTopicsView(with: dataModel.topics)
        //        interactiveView.updateLocationView(with: dataModel.location)
        interactiveView.updateLocationAndMerchantNameView(location: dataModel.location, rewardsMerchantUsers: dataModel.rewardsMerchantUsers)
        interactiveView.updateInfo(caption: dataModel.content)
        //处理商家的显示逻辑
        interactiveView.updateMerchantView(with: dataModel.rewardsMerchantUsers)
        interactiveView.updateCount(comment: (dataModel.toolModel?.commentCount).orZero, like: (dataModel.toolModel?.diggCount).orZero, forwardCount: (dataModel.toolModel?.forwardCount).orZero)
        interactiveView.updateCommentStatus(isCommentDisabled: dataModel.toolModel?.isCommentDisabled)
        interactiveView.updateReactionButton(reactionType: dataModel.reactionType)
        interactiveView.updateUserReactionView(topReactionList: dataModel.topReactionList, totalReactions: (dataModel.toolModel?.diggCount).orZero)
        interactiveView.updateGiftImage(canAcceptReward: (dataModel.userInfo?.isRewardAcceptEnabled).orFalse ,imageName: dataModel.toolModel?.isRewarded == true ? "ic_reward" : "ic_feed_inner_tips")
        
        interactiveView.updatePageCount(cur: imageIndex, max: dataModel.pictures.count)
        
        interactiveView.feedId = dataModel.idindex
        interactiveView.feedItem = dataModel
        interactiveView.reactionType = dataModel.reactionType
        
        if isTranslateText {
            interactiveView.updateTranslateText()
        }
        
        if let user = UserInfoModel.retrieveUser(username: (dataModel.userInfo?.username).orEmpty) {
            interactiveView.updateFollowButton(user.followStatus)
        } else {
            interactiveView.updateFollowButton(dataModel.userInfo?.followStatus ?? .unfollow)
        }
        //评论按钮显示/隐藏逻辑
        if let isCommentDisabled = dataModel.toolModel?.isCommentDisabled {
            interactiveView.updateCommentStatus(isCommentDisabled: isCommentDisabled)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.insertSubview(interactiveView, belowSubview: refreshView)
        interactiveView.bindToEdges()
        
        view.addSubview(animateView)
        animateView.snp.makeConstraints { v in
            v.width.height.equalTo(250)
            v.center.equalToSuperview()
        }
        animateView.isHidden = true
        
        view.layoutIfNeeded()
        
        NotificationCenter.default.add(observer: self, name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil) { [weak self] (noti) in
            guard let self = self else { return }
            guard let userInfo = noti.userInfo, let followStatus = userInfo["follow"] as? FollowStatus, let uid = userInfo["userid"] as? String else { return }
            guard var object = self.dataModel.userInfo else { return }
            
            if object.userIdentity == uid.toInt() {
                if followStatus == .unfollow {
                    object.follower = false
                } else if followStatus == .follow {
                    object.follower = true
                }
                self.dataModel.userInfo = object
                self.interactiveView.updateFollowButton(self.dataModel.userInfo!.followStatus)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showReactionBottomSheet), name: NSNotification.Name.Reaction.show, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setClearNavBar(shadowColor: .clear)
        //进入页面时将状态栏的字体改为白色
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setWhiteNavBar(normal: true)
        //离开页面还原
        if #available(iOS 13.0, *) {
            UIApplication.shared.setStatusBarStyle(.darkContent, animated: true)
        } else {
            UIApplication.shared.setStatusBarStyle(.default, animated: true)
        }
        //        TSKeyboardToolbar.share.setStickerNightMode(isNight: false)
        //        TSKeyboardToolbar.share.theme = .white
    }
    
    func setGesture(for controller: FeedDetailImageController) {
        controller.onSingleTapView = { [weak self] in self?.toggleInteractiveView() }
        controller.onDoubleTapView = { [weak self] in
            guard TSCurrentUserInfo.share.isLogin == true else {
                TSRootViewController.share.guestJoinLandingVC()
                return
            }
            self?.executeLike()
            self?.interactiveView.reactionHandler?.didSelectIcon = ReactionTypes.heart.rawValue
            self?.interactiveView.reactionHandler?.onSelect(reaction: .heart)
        }
        
        controller.onZoomUpdate = { [weak self] in
            guard let self = self else { return }
            if self.interactiveView.isHidden == false {
                self.toggleInteractiveView()
            }
        }
    }
    
    func toggleInteractiveView() {
        guard let currentVC = self.viewControllers?.first as? FeedDetailImageController else { return }
        if interactiveView.isHidden == true {
            interactiveView.fadeIn()
            currentVC.state = .normal
        } else {
            interactiveView.fadeOut()
            currentVC.state = .zoomable
        }
    }
    
    private func executeLike() {
        let likeAnimation = Animation.named("reaction-love")
        animateView.animation = likeAnimation
        
        animateView.isHidden = false
        animateView.play { finished in
            guard finished == true else { return }
            self.animateView.makeHidden()
        }
    }
    
    // MARK: - 转发后获取最新转发数
    private func updateForwardCount(_ dontTriggerObservers: Bool = false) {
        let feedId = self.dataModel.idindex
        FeedListNetworkManager.getMomentFeed(id: feedId) { [weak self] (listModel, errorMsg, status, networkResult) in
            
            guard let listModel = listModel, let self = self else {
                return
            }
            let cellModel = FeedListCellModel(feedListModel: listModel)
            self.dataModel = cellModel
            self.interactiveView.updateCount(comment: (self.dataModel.toolModel?.commentCount).orZero, like: (self.dataModel.toolModel?.diggCount).orZero, forwardCount: (self.dataModel.toolModel?.forwardCount).orZero)
            self.interactiveView.updateCommentStatus(isCommentDisabled: self.dataModel.toolModel?.isCommentDisabled)
        }
    }
    
    // MARK: - 记录转发
    private func forwardFeed() {
        let feedId = self.dataModel.idindex
        self.showLoading()
        FeedListNetworkManager.forwardFeed(feedId: feedId) { [weak self] (errMessage, statusCode, status) in
            guard let self = self else { return }
            defer {
                DispatchQueue.main.async {
                    self.dismissLoading()
                    self.updateForwardCount()
                }
                //上报动态转发事件
                EventTrackingManager.instance.trackEvent(
                    itemId: feedId.stringValue,
                    itemType: self.dataModel.feedType == .miniVideo ? ItemType.shortvideo.rawValue   : ItemType.image.rawValue,
                    behaviorType: BehaviorType.forward,
                    sceneId: "",
                    moduleId: ModuleId.feed.rawValue,
                    pageId: PageId.feed.rawValue)
                
            }
            guard status == true else {
                if statusCode == 241 {
                    self.showDialog(image: nil, title: "fail_to_pin_title".localized, message: "fail_to_pin_desc".localized, dismissedButtonTitle: "ok".localized, onDismissed: nil, onCancelled: nil)
                } else {
                    self.showError(message: errMessage)
                }
                return
            }
        }
    }
    
    override func finishRefresh() {
        UIView.animate(withDuration: 0.25) { () -> () in
            self.interactiveView.pageCounterLabel.alpha = 1
            
        }
        refreshView.reset()
    }
    
    override func refreshViewOnChanged(progressRatio: CGFloat) {
        interactiveView.pageCounterLabel.alpha = 1 - progressRatio
    }
    
    @objc func showReactionBottomSheet() {
        TSKeyboardToolbar.share.theme = .white
        TSKeyboardToolbar.share.setStickerNightMode(isNight: false)
        let respondVC = ResponsePageController(theme: .white, feed: self.dataModel, defaultSegment: 1, onToolbarUpdate: self.onToolbarUpdated)
        respondVC.titleLabel.text = ""
        let nav = TSNavigationController(rootViewController: respondVC)
        nav.modalPresentationStyle = .custom
        nav.transitioningDelegate = self
        nav.view.backgroundColor = .clear
        self.present(nav, animated: true, completion: nil)
    }
}

private class PageHandler: NSObject, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIGestureRecognizerDelegate {
    weak var controller: FeedContentPageController? {
        didSet {
            controller?.delegate = self
            controller?.dataSource = self
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard finished == true else { return }
        guard let controller = controller else { return }
        guard let currentVC = pageViewController.viewControllers?.first as? FeedDetailImageController else { return }
        let index = currentVC.imageIndex
        
        let transitionId = UUID().uuidString
        currentVC.imageView.hero.id = transitionId
        controller.interactiveView.updatePageCount(cur: index, max: controller.dataModel.pictures.count)
        
        controller.onIndexUpdate?(index, transitionId)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let controller = controller else { return nil }
        guard let currentVC = pageViewController.viewControllers?.first as? FeedDetailImageController else { return nil }
        
        let newIndex = currentVC.imageIndex - 1
        guard newIndex >= 0 else { return nil }
        
        let newController = FeedDetailImageController(imageUrlPath: (controller.dataModel.pictures[newIndex].url).orEmpty, imageIndex: newIndex, model: controller.dataModel)
        controller.setGesture(for: newController)
        return newController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let controller = controller else { return nil }
        guard let currentVC = pageViewController.viewControllers?.first as? FeedDetailImageController else { return nil }
        
        let newIndex = currentVC.imageIndex + 1
        guard newIndex > 0, newIndex < (controller.dataModel.pictures.count) else { return nil }
        
        let newController = FeedDetailImageController(imageUrlPath: (controller.dataModel.pictures[newIndex].url).orEmpty, imageIndex: newIndex, model: controller.dataModel)
        controller.setGesture(for: newController)
        return newController
    }
}

extension FeedContentPageController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = CustomSizePresentationController(presentedViewController: presented, presenting: presenting)
        controller.heightPercent = 0.7
        return controller
    }
}

extension FeedContentPageController: CustomPopListProtocol {
    func customPopList(itemType: TSPopUpItem) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.handlePopUpItemAction(itemType: itemType)
        }
    }
    
    func handlePopUpItemAction(itemType: TSPopUpItem) {
        switch itemType {
        case .message:
            // 记录转发数
            self.forwardFeed()
            let messageModel = TSmessagePopModel(momentModel: self.dataModel)
            let vc = ContactsPickerViewController(model: messageModel, configuration: ContactsPickerConfig.shareToChatConfig(), finishClosure: nil)
            if #available(iOS 11, *) {
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let navigation = TSNavigationController(rootViewController: vc).fullScreenRepresentation
                self.navigationController?.present(navigation, animated: true, completion: nil)
            }
        case .shareExternal:
            // 记录转发数
            self.forwardFeed()
            let messagePopModel = TSmessagePopModel(momentModel: self.dataModel)
            let fullUrlString = TSAppConfig.share.environment.serverAddress + "feeds/" + String(messagePopModel.feedId)
            // By Kit Foong (Hide Yippi App from share)
            let items: [Any] = [URL(string: fullUrlString), messagePopModel.titleSecond, ShareExtensionBlockerItem()]
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        case .save(isSaved: let isSaved):
            let isCollect = (self.dataModel.toolModel?.isCollect).orFalse ? false : true
            TSMomentNetworkManager().colloction(isCollect ? 1 : 0, feedIdentity: self.dataModel.idindex, feedItem: self.dataModel) { [weak self] (result) in
                if result == true {
                    self?.dataModel.toolModel?.isCollect = isCollect
                    DispatchQueue.main.async {
                        if isCollect {
                            self?.showTopFloatingToast(with: "success_save".localized, desc: "")
                        }
                    }
                }
                
            }
        case .reportPost:
            guard let reportTarget: ReportTargetModel = ReportTargetModel(feedModel: self.dataModel) else { return }
            let reportVC: ReportViewController = ReportViewController(reportTarget: reportTarget)
            self.present(TSNavigationController(rootViewController: reportVC).fullScreenRepresentation,
                         animated: true,
                         completion: nil)
        case .edit:
            let model = self.dataModel
            let pictures =  model.pictures.map{ RejectDetailModelImages(fileId: $0.file, imagePath: $0.url ?? "", isSensitive: false, sensitiveType: "")   }
            
            var vc = TSReleasePulseViewController(isHiddenshowImageCollectionView: false)
            
            vc.selectedModelImages = pictures
            
            vc.preText = model.content
            
            vc.feedId = model.idindex.stringValue
            vc.isFromEditFeed = true
            
            vc.tagVoucher = model.tagVoucher
            
            if let extenVC = self.configureReleasePulseViewController(detailModel: model, viewController: vc) as? TSReleasePulseViewController{
                vc = extenVC
            }
            
            let navigation = TSNavigationController(rootViewController: vc).fullScreenRepresentation
            self.present(navigation, animated: true, completion: nil)
        case .deletePost:
            self.showRLDelete(title: "rw_delete_action_title".localized, message: "rw_delete_action_desc".localized, dismissedButtonTitle: "delete".localized, onDismissed: { [weak self] in
                guard let self = self else { return }
                TSMomentNetworkManager().deleteMoment(self.dataModel.idindex) { [weak self] (result) in
                    guard let self = self else { return }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedDelete"), object: nil, userInfo: ["feedId": self.dataModel.idindex])
                    self.onDelete?()
                }
            }, cancelButtonTitle: "cancel".localized)
        case .pinTop(isPinned: let isPinned):
            let feedId = self.dataModel.idindex
            
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
                
                self.dataModel.isPinned = newPined
                self.showError(message: newPined ? "feed_pinned".localized : "feed_unpinned".localized)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPinnedFeed"), object: nil, userInfo: ["isPinned": !isPinned, "feedId": feedId])
            }
            break
        case .comment(isCommentDisabled: let isCommentDisabled):
            let feedId = self.dataModel.idindex
            
            let newValue = self.dataModel.toolModel?.isCommentDisabled ?? true ? 0 : 1
            
            TSMomentNetworkManager().commentPrivacy(newValue, feedIdentity: feedId) { [weak self] success in
                guard let self = self else { return }
                if success {
                    self.dataModel.toolModel?.isCommentDisabled = newValue == 1
                    DispatchQueue.main.async {
                        if newValue == 1 {
                            self.showTopIndicator(status: .success, "disable_comment_success".localized)
                        } else {
                            self.showTopIndicator(status: .success, "enable_comment_success".localized)
                        }
                        self.updateInteractiveView(isEdit: true)
                    }
                }
            }
            break
        default:
            break
        }
    }
}


