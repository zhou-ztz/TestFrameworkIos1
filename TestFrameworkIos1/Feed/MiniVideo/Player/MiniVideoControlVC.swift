//
//  MiniVideoControlVC.swift
//  Yippi
//
//  Created by Yong Tze Ling on 16/02/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import AVFoundation
import Toast
import AliyunVideoSDKPro
import AliyunPlayer

class MiniVideoControlVC: TSViewController, NSURLConnectionDataDelegate {
    
    var control: MiniVideoControlView = MiniVideoControlView()
    private(set) var model: FeedListCellModel
    var index: Int = 0
    var type: FeedListType?
    var onDataChanged: ((FeedListCellModel) -> Void)?
    var isPausedWhenEnterBackground: Bool = false
    var isTranslateText: Bool = false
    var translateHandler: ((Bool) -> Void)?
    
    var playUrlArrays: [URL] = []

    init(model: FeedListCellModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        control = MiniVideoControlView()
        control.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        self.view.addSubview(control)
        
        //刷新用户关注状态
        if model.userId != CurrentUserSessionInfo?.userIdentity {
            TSUserNetworkingManager().getUserInfo(userId: model.userId) { userModel, msg, status in
                if let status = userModel?.follower {
                    let followstatus: FollowStatus = status == true ? .follow : .unfollow
                    self.updateFollowStatus(followstatus, userId: self.model.userId.stringValue)
                }
                
            }
        }
        
        control.setFeed(model,self.isTranslateText)
        control.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(showReactionBottomSheet), name: NSNotification.Name.Reaction.show, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.control.coverImageView.setViewHidden(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //开始记录停留时间
        stayBeginTimestamp = Date().timeStamp
        MiniVideoListPlayerManager.shared.setPlayerView(self.control.previewView)
        MiniVideoListPlayerManager.shared.playWithVideo(self.model)
        MiniVideoListPlayerManager.shared.onCurrentPlayStatusUpdateHandler = { [weak self] status in
            // 解决页面图片直接隐藏闪屏的问题
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                if status == AVPStatusError {
                    //音频源文件问题导致播放失败了
                    self.control.coverImageView.setViewHidden(false)
                }else{
                    self.control.coverImageView.setViewHidden(true)
                }
            }
            DispatchQueue.main.async {
                //播放器开始播放
                guard let self = self else { return }
                if status == AVPStatusError {
                    //音频源文件问题导致播放失败了
                    self.showError(message: "error".localized)
                    self.control.setFeed(self.model,self.isTranslateText)
                    self.control.hidePlayBtn()
                }
                if status == AVPStatusPaused {
                    self.control.showPlayBtn()
                }else{
                    self.control.hidePlayBtn()
                }
                
            }
        }
        MiniVideoListPlayerManager.shared.onCurrentPositionUpdateHandler = { [weak self] position,duration in
            guard let self = self else { return }
            let progress = Float(position)/Float(duration)
            DispatchQueue.main.async {
                if self.control.coverImageView.isHidden == false {
                    self.control.coverImageView.setViewHidden(true)
                }
                self.control.videoDuration = TimeInterval(duration)
                self.control.setProgress(progress)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        control.resetToDefault()
        self.behaviorUserFeedStayData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        print("deinit MiniVideoControlVC")
        control.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    var parentVC: MiniVideoPageViewController? {
        return (parent as? MiniVideoPageViewController)
    }
    
    func didEnterBackground() {
        if  MiniVideoListPlayerManager.shared.getPlayStatus() == AVPStatusStarted {
            MiniVideoListPlayerManager.shared.pause()
            isPausedWhenEnterBackground = true
        }
    }
    
    func enterForeground() {
        if isPausedWhenEnterBackground {
            MiniVideoListPlayerManager.shared.play()
            isPausedWhenEnterBackground = false
        }
    }
    
    func onPanAtBottom(sender: UIPanGestureRecognizer) {
        control.panGestureRecognizer(sender)
    }
    
    func updateFollowStatus(_ status: FollowStatus, userId: String) {
        guard userId.toInt() == model.userId else {
            return
        }
        model.userInfo?.follower = status == .follow ? true : false
        control.updateFollowButton(status)
    }
    
    @objc func showReactionBottomSheet() {
        let vc = ResponsePageController(theme: .white, feed: model, defaultSegment: 1, onToolbarUpdate: self.parentVC?.onToolbarUpdate)
        vc.titleLabel.text = ""
        let nav = TSNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .custom
        nav.transitioningDelegate = self
        nav.view.backgroundColor = .clear
        self.present(nav, animated: true, completion: nil)
    }
}

extension MiniVideoControlVC {
    func behaviorUserFeedStayData() {
        if stayBeginTimestamp != "" {
            stayEndTimestamp = Date().timeStamp
            let stay = stayEndTimestamp.toInt()  - stayBeginTimestamp.toInt()
            if stay > 5 {
                self.stayBeginTimestamp = ""
                self.stayEndTimestamp = ""
                EventTrackingManager.instance.trackEvent(
                    itemId: self.model.idindex.stringValue,
                    itemType: ItemType.shortvideo.rawValue,
                    behaviorType: BehaviorType.stay,
                    sceneId: "",
                    moduleId: ModuleId.feed.rawValue,
                    pageId: PageId.feed.rawValue,
                    behaviorValue: stay.stringValue
                )
            }
        }
    }
}

extension MiniVideoControlVC: MiniVideoControlViewDelegate {
    
    func commentDidTapped(view: MiniVideoControlView) {
        
        let vc = ResponsePageController(theme: .white, feed: model) { [weak self] feed in
            if feed.idindex == self?.model.idindex {
                self?.model = feed
            }
            DispatchQueue.main.async {
                view.updateFeed(feed)
                self?.updateDataSouce(feed)
            }
        }
        let nav = TSNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .custom
        nav.transitioningDelegate = self
        nav.view.backgroundColor = .clear
        self.present(nav, animated: true, completion: nil)
        EventTrackingManager.instance.track(event: .innerFeedViewClicks, with: ["Clicked": "Comment Btn"])
        //上报动态点击事件
        //sceneId: type?.rawValue ?? "",
        EventTrackingManager.instance.trackEvent(
            itemId: model.idindex.stringValue,
            itemType: model.feedType == .miniVideo ? ItemType.shortvideo.rawValue : ItemType.image.rawValue,
            behaviorType: BehaviorType.click,
            sceneId: "",
            moduleId: ModuleId.feed.rawValue,
            pageId: PageId.feed.rawValue)
        
        self.stayBeginTimestamp = ""
        self.stayEndTimestamp = ""
        
    }
    
    func shareDidTapped(view: MiniVideoControlView) {
        var shareUrl = ShareURL.feed.rawValue + "\(model.idindex)"
        print(shareUrl)
        if let username = CurrentUserSessionInfo?.username {
            shareUrl += "?r=\(username)"
        }
        
        let messageModel = TSmessagePopModel(momentModel: model)
        let title = TSAppSettingInfoModel().appDisplayName + " " + "post".localized
        var defaultContent = "default_share_content".localized
        defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
        let description = model.content.isEmpty ? defaultContent : model.content
        var shareView: ShareListView?
        
        if model.userInfo?.isMe() == true {
            shareView = ShareListView(shareType: .custom(items: [.forward, .message, .shareExternal, .pinned(isPinned: model.isPinned), .edit(isEdited: model.isEdited), .delete, .comment(isCommentDisabled: model.toolModel?.isCommentDisabled ?? false)]), theme: .dark)
        } else {
            shareView = ShareListView(shareType: .custom(items: [.forward, .message, .save(isSaved: model.toolModel?.isCollect ?? false), .shareExternal, .report]), theme: .dark)
        }
        
        shareView?.delegate = self
        shareView?.feedIndex = IndexPath(row: index, section: 0)
        shareView?.messageModel = messageModel
        shareView?.show(URLString: shareUrl, image: nil, description: description, title: title)
    }
    
    func rewardDidTapped(view: MiniVideoControlView) {
//        if model.userInfo?.isMe() == true {
//            let vc = PostTipHistoryTVC(feedId: model.idindex)
//            if let nav = self.navigationController {
//                nav.pushViewController(vc, animated: true)
//            } else {
//                let nav = TSNavigationController(rootViewController: vc)
//                nav.setCloseButton(backImage: true)
//                self.present(nav.fullScreenRepresentation, animated: true, completion: nil)
//            }
//        } else {
//            self.presentTipping(target: model.idindex, type: .moment, theme: .dark) { [weak self] (_, _) in
//                if let tool = self?.model.toolModel {
//                    self?.showSuccess(message: "tip_successful_title".localized)
//                    
//                    tool.rewardCount += 1
//                    tool.isRewarded = true
//                    self?.model.toolModel = tool
//                    
//                    if let feed = self?.model {
//                        self?.updateDataSouce(feed)
//                    }
//                }
//            }
//        }
    }
    
    func followDidTapped(view: MiniVideoControlView) {
        guard var user = model.userInfo else {
            return
        }
        user.updateFollow(completion: { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil, userInfo: ["follow": user.follower, "userid": "\(user.userIdentity)"])
                    view.updateFollowButton(user.followStatus)
                    if let feed = self?.model {
                        self?.updateDataSouce(feed)
                    }
                }
            }
        })
    }
    
    func profileDidTapped(view: MiniVideoControlView) {
        switch self.type {
        case .user:
            if let liveId = model.userInfo?.liveFeedId {
                self.navigationController?.navigateLive(feedId: liveId)
            } else {
                // By Kit Foong (Check if same navigation controller use pop, else use dismiss)
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                } else {
                    // By Kit Foong (This mainly is for user profile gallery)
                    self.dismiss(animated: true)
                }
                //self.navigationController?.popViewController(animated: true)
            }
            
        default:
            guard let user = model.userInfo else {
                return
            }
            if let liveId = user.liveFeedId {
                self.navigationController?.navigateLive(feedId: liveId)
            } else {
//                let vc = HomePageViewController(userId: user.userIdentity)
//                self.navigationController?.pushViewController(vc, animated: true)
                FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: user.userIdentity, username: nil, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
            }
        }
    }
    
    func reactionsDidSelect(view: MiniVideoControlView) {
        
        FeedListNetworkManager.getMomentFeed(id: model.idindex) { [weak self] (listModel, message, status, _) in
            
            DispatchQueue.main.async {
                guard status == true, let listModel = listModel, let weakself = self else {
                    self?.showTopIndicator(status: .faild, "system_error_msg".localized)
                    return
                }
                let cellModel = FeedListCellModel(feedListModel: listModel)
                view.updateReactionList(cellModel)
                
                if weakself.model.idindex == cellModel.idindex {
                    weakself.model = cellModel
                }
                weakself.updateDataSouce(cellModel)
            }
        }
    }
    
    func reactionsListDidTap(view: MiniVideoControlView) {
        showReactionBottomSheet()
    }
    
    func controlViewDidTapped(view: MiniVideoControlView) {
        if MiniVideoListPlayerManager.shared.getPlayStatus() == AVPStatusStarted {
            MiniVideoListPlayerManager.shared.pause()
            view.showPlayBtn()
        } else {
            MiniVideoListPlayerManager.shared.play()
            view.hidePlayBtn()
        }
    }
    
    func voucherDidTap(view: MiniVideoControlView) {
        let vc = VoucherDetailViewController()
        vc.voucherId = model.tagVoucher?.taggedVoucherId ?? 0
        vc.isMiniVideo = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func sliderDidChanged(time: TimeInterval) {
        MiniVideoListPlayerManager.shared.setSeek(Int64(time) * 1000)
    }
}

extension MiniVideoControlVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = CommentListPresentationController(presentedViewController: presented, presenting: presenting)
        controller.heightPercent = 0.7
        return controller
    }
}

extension MiniVideoControlVC: ShareListViewDelegate {
    
    private func updateDataSouce(_ model: FeedListCellModel) {
        self.parentVC?.onToolbarUpdate?(model)
        self.parentVC?.onDataChanged(model)
    }
    
    func didClickEditButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
       
    }
    
    func didClickMessageButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, model: TSmessagePopModel) {
        let chooseFriendVC = ContactsPickerViewController(model: model, configuration: ContactsPickerConfig.shareToChatConfig(), finishClosure: nil)
        let nav = TSNavigationController(rootViewController: chooseFriendVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    func didClickReportButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        guard let reportTarget = ReportTargetModel(feedModel: model) else {
            return
        }
        let vc = ReportViewController(reportTarget: reportTarget)
        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
        self.present(nav, animated: true, completion: nil)
    }
    
    func didClickRepostButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?) {
        let repostModel = TSRepostModel(model: model)
        let releaseVC = TSReleasePulseViewController(isHiddenshowImageCollectionView: true, isReposting:true)
        releaseVC.repostModel = repostModel
        let navigation = TSNavigationController(rootViewController: releaseVC).fullScreenRepresentation
        self.present(navigation, animated: true, completion: nil)
    }
    
    func didClickShareExternal(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, items: [Any]) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.parent?.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func didClickShareQr(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, items: [Any]) {
    }
    
    func didClickCollectionButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        let newValue = model.toolModel?.isCollect ?? true ? 0 : 1
        TSMomentNetworkManager().colloction(newValue, feedIdentity: model.idindex, feedItem: model) { [weak self] success in
            guard let self = self else { return }
            if success {
                self.model.toolModel?.isCollect = newValue == 1
                
                DispatchQueue.main.async {
                    shareView.updateView(tag: fatherViewTag, iscollect: newValue == 1)
                    if newValue == 1 {
                        self.showTopIndicator(status: .success, "success_save".localized)
                    }
                }
            }
        }
    }
    
    func didClickDisableCommentButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        
        let newValue = model.toolModel?.isCommentDisabled ?? true ? 0 : 1
        TSMomentNetworkManager().commentPrivacy(newValue, feedIdentity: model.idindex) { [weak self] success in
            guard let self = self else { return }
            if success {
                self.model.toolModel?.isCommentDisabled = newValue == 1
                DispatchQueue.main.async {
                    if newValue == 1 {
                        self.showTopIndicator(status: .success, "disable_comment_success".localized)
                    } else {
                        self.showTopIndicator(status: .success, "enable_comment_success".localized)
                    }
                }
            }
        }
    }
    
    func didClickDeleteButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        if self.model.isPinned {
            self.showDialog(image: nil, title: "pin_confirm_to_delete_title".localized, message: "pin_confirm_to_delete_desc".localized, dismissedButtonTitle: "delete".localized, onDismissed: { [weak self] in
                guard let self = self else { return }
                TSMomentNetworkManager().deleteMoment(self.model.idindex) { [weak self] (result) in
                    guard let self = self else { return }
                    if result == true {
                        self.parentVC?.deleteVideo()
                    }
                }
            }, cancelButtonTitle: "cancel".localized)
        } else {
            let alertVC = TSAlertController.deleteConfirmAlert(deleteActionTitle: "delete_feed".localized) { [weak self] in
                guard let self = self else { return }
                TSMomentNetworkManager().deleteMoment(self.model.idindex) { [weak self] (result) in
                    guard let self = self else { return }
                    if result == true {
                        self.parentVC?.deleteVideo()
                    }
                }
            }
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func didClickUnpinButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        guard let feedId = model.id["feedId"] else {
            return
        }
        FeedListNetworkManager.unpinFeed(feedId: feedId) { [weak self] (errMessage, statusCode, status) in
            guard let self = self else { return }
            guard status == true else {
                self.showError(message: errMessage)
                return
            }
            self.model.isPinned = false
            self.showError(message: "feed_unpinned".localized)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPinnedFeed"), object: nil, userInfo: ["isPinned": false, "feedId": feedId])
        }
    }
    
    func didClickPinButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        guard let feedId = model.id["feedId"] else {
            return
        }
        FeedListNetworkManager.pinFeed(feedId: feedId) { [weak self] (errMessage, statusCode, status) in
            guard let self = self else { return }
            guard status == true else {
                if statusCode == 241 {
                    self.showDialog(image: nil, title: "fail_to_pin_title".localized, message: "fail_to_pin_desc".localized, dismissedButtonTitle: "ok".localized, onDismissed: nil)
                } else {
                    self.showError(message: errMessage)
                }
                return
            }
            self.model.isPinned = true
            self.showError(message: "feed_pinned".localized)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPinnedFeed"), object: nil, userInfo: ["isPinned": true, "feedId": feedId])
        }
    }
}
