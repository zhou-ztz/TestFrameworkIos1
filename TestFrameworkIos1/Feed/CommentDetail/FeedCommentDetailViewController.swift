//
//  FeedCommentDetailViewController.swift
//  Yippi
//
//  Created by ChuenWai on 15/01/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
import CoreMedia
import AliyunVideoSDKPro
import AliyunPlayer

class FeedCommentDetailViewController: TSViewController, TSCustomAcionSheetDelegate {
    
    private var table: TSTableView = {
        let table = TSTableView(frame: CGRect.zero, style: .plain)
        table.register(UINib(nibName: "TSDetailCommentTableViewCell", bundle: nil), forCellReuseIdentifier: TSDetailCommentTableViewCell.identifier)
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = TSColor.inconspicuous.disabled
        table.tableFooterView = UIView()
        table.separatorStyle = .none
        return table
    }()
    
    private let followButton: TSButton = {
        let button = TSButton(type: .custom)
        button.snp.makeConstraints { (m) in
            m.width.height.equalTo(27)
        }
        return button
    }()
    
    private let navView: TSMomentDetailNavTitle = TSMomentDetailNavTitle()
    var dontTriggerObservers:Bool = false
    public var model: FeedListCellModel? {
        didSet {
            if dontTriggerObservers == false {
                self.setHeader()
            }
            
        }
    }
    private var commentModel: FeedCommentListCellModel?
    private var commentDatas: [FeedCommentListCellModel] = [FeedCommentListCellModel]()
    private var sendText: String?
    private var isTapMore = false
    private var isClickCommentButton = false
    private let commentInputView = UIView()
    private var feedId: Int = 0
    private var feedOwnerId: Int = 0
    private var afterId: Int?
    private var isFullScreen: Bool = false
    private var sendCommentType: SendCommentType = .send
    private var headerView: FeedCommentDetailTableHeaderView = FeedCommentDetailTableHeaderView()
    var onToolbarUpdated: onToolbarUpdate?
    var reactionHandler: ReactionHandler?
    var reactionSelected: ReactionTypes?
    // feed type
    var type: FeedListType?
    
    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return true
    }
    
    var startPlayTime: CMTime = .zero
    var onDismiss: ((CMTime) -> Void)?
    
    init(feedId: Int, isTapMore: Bool = false, isClickCommentButton: Bool = false, isVideoFeed: Bool = false, onToolbarUpdated: onToolbarUpdate?) {
        super.init(nibName: nil, bundle: nil)
        self.feedId = feedId
        self.isTapMore = isTapMore
        self.isClickCommentButton = isClickCommentButton
        self.onToolbarUpdated = onToolbarUpdated
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        headerView.videoPlayerView.aliPlayerView.stop()
        headerView.videoPlayerView.aliPlayerView.destroy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loading()
        
        TSKeyboardToolbar.share.theme = .white
        TSKeyboardToolbar.share.setStickerNightMode(isNight: false)
        TSKeyboardToolbar.share.keyboardToolbarDelegate = self
        
        setupTableView()
        self.setRightButton(button: followButton)
        table.mj_header.beginRefreshing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        TSKeyboardToolbar.share.keyboarddisappear()
        TSKeyboardToolbar.share.keyboardStopNotice()
        
        willResignActive()
        
        onDismiss?(headerView.videoPlayerView.currentPlayTime())
        
        reactionHandler?.reset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        //   NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        // By Kit Foong (Added observer update follow status when follow user in profile)
        NotificationCenter.default.add(observer: self, name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil) { [weak self] (noti) in
            guard let self = self else { return }
            guard let userInfo = noti.userInfo, let followStatus = userInfo["follow"] as? FollowStatus, let uid = userInfo["userid"] as? String else { return }
            guard var object = self.model?.userInfo else { return }
            
            if object.userIdentity == uid.toInt() {
                if followStatus == .unfollow {
                    object.follower = false
                } else if followStatus == .follow {
                    object.follower = true
                }
                self.model?.userInfo = object
                self.update(followStatus: object)
            }
        }
        
        self.navigationItem.titleView = navView
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        TSKeyboardToolbar.share.keyboardstartNotice()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        becomeActive()
    }
    
    @objc func willResignActive() {
        let playerView = headerView.videoPlayerView
        guard playerView.playerViewState() == AVPStatusStarted else {
            return
        }
        playerView.pause()
    }
    
    @objc func becomeActive() {
        headerView.videoPlayerView.resume()
    }
    
    @objc func orientationChanged() {
        guard isFullScreen == false &&
                ((UIDevice.current.orientation == .landscapeLeft) || (UIDevice.current.orientation == .landscapeRight)) else {
            return
        }
        maximizePlayerView(with: UIDevice.current.orientation)
    }
    
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        
    }
    
    private func setupTableView() {
        table.delegate = self
        table.dataSource = self
        table.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        table.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        table.mj_footer.makeHidden()
        table.tableFooterView = UIView()
        table.keyboardDismissMode = .onDrag
        table.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(table)
        table.bindToSafeEdges()
    }
    
    /// 刷新数据
    /// - Parameter dontTriggerObservers: 这个参数控制是否需要刷新视图，下拉刷新的时候需要触发setHeader方法刷新视图，关注/取消关注则不需要刷新视图
    /// flase = 触发刷新  true 不需要刷新
    @objc func refresh(_ dontTriggerObservers: Bool = false) {
        FeedListNetworkManager.getMomentFeed(id: feedId) { [weak self] (listModel, errorMsg, status, networkResult) in
            
            if status == false {
                self?.showTopFloatingToast(with: errorMsg.orEmpty, desc: "")
                switch networkResult {
                case .failure(let failure):
                    switch failure.statusCode {
                    case 404:
                        self?.show(placeholder: .empty)
                    default:
                        self?.show(placeholder: .network)
                    }
                default:
                    self?.show(placeholder: .network)
                }
            }
            
            guard let listModel = listModel, let wself = self else {
                self?.showTopFloatingToast(with: errorMsg.orEmpty, desc: "")
                return
            }
            
            let cellModel = FeedListCellModel(feedListModel: listModel)
            self?.feedOwnerId = cellModel.userId
            self?.dontTriggerObservers = dontTriggerObservers
            
            wself.model = cellModel
            
            DispatchQueue.main.async {
                wself.removePlaceholderView()
                wself.getCommentList()
                wself.update(followStatus: cellModel.userInfo ?? UserInfoModel())
                wself.navView.update(model: cellModel.userInfo ?? UserInfoModel())
            }
        }
    }
    @objc func loadMore() {
        TSCommentNetWorkManager.getMomentCommentList(type: .momment, feedId: feedId, afterId: afterId) { [weak self] (commentList, errorMsg, status) in
            
            guard let commentList = commentList, status == true, let wself = self else {
                DispatchQueue.main.async {
                    self?.table.mj_footer.endRefreshingWithWeakNetwork()
                }
                return
            }
            
            wself.commentDatas += commentList
            wself.model?.comments = wself.commentDatas
            wself.afterId = commentList.last?.id["commentId"]
            
            DispatchQueue.main.async {
                if commentList.count < TSAppConfig.share.localInfo.limit {
                    wself.table.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    wself.table.mj_footer.endRefreshing()
                }
                
                wself.table.reloadData()
            }
        }
    }
    
    private func getCommentList() {
        TSCommentNetWorkManager.getMomentCommentList(type: .momment, feedId: feedId, afterId: nil) { [weak self] (commentList, errorMsg, status) in
            guard let commentList = commentList, status == true, let wself = self else {
                self?.table.mj_header.endRefreshing()
                self?.endLoading()
                UIViewController.showBottomFloatingToast(with: errorMsg.orEmpty, desc: "")
                self?.table.show(placeholderView: .network)
                return
            }
            
            wself.commentDatas = commentList
            wself.model?.comments = wself.commentDatas
            wself.table.mj_footer.isHidden = wself.commentDatas.count < TSAppConfig.share.localInfo.limit
            wself.afterId = commentList.last?.id["commentId"]
            wself.endLoading()
            wself.table.mj_header.endRefreshing()
            wself.checkEmptyComment()
            if wself.isClickCommentButton == true {
                TSKeyboardToolbar.share.keyboardBecomeFirstResponder()
            }
            wself.table.reloadData()
        }
    }
    
    private func checkEmptyComment() {
        if self.commentDatas.count <= 0 {
            self.table.show(placeholderView: .noComment, margin: self.headerView.frame.maxY, height: 100)
            self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 350, right: 0)
        } else {
            self.table.removePlaceholderViews()
            self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.table.mj_footer.height, right: 0)
            if self.isTapMore == true {
                self.isTapMore = false
                self.table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    private func update(followStatus object: UserInfoModel) {
        guard let relationship = object.relationshipWithCurrentUser else { return }
        var imageName = ""
        switch relationship.status {
        case .unfollow:
            followButton.isHidden = false
            imageName = "icProfileNotFollowing"
        case .follow:
            followButton.isHidden = false
            imageName = "icProfileFollowing"
        case .eachOther:
            followButton.isHidden = false
            imageName = "icProfileChat"
        case .oneself:
            followButton.isHidden = true
            imageName = ""
        default :
            followButton.isHidden = false
            imageName = "IMG_ico_me_follow"
        }
        followButton.setImage(UIImage.set_image(named: imageName), for: .normal)
        followButton.removeGestures()
        followButton.addTap { [weak self] (_) in
            self?.rightButtonClicked()
        }
    }
    
    override func rightButtonClicked() {
        // 1.判断是否为游客模式
        if !TSCurrentUserInfo.share.isLogin {
            // 如果是游客模式，拦截操作显示登录界面
            TSRootViewController.share.guestJoinLandingVC()
            return
        }
        
        guard var object = model?.userInfo else { return }
        
        guard let relationship = object.relationshipWithCurrentUser else {
            TSRootViewController.share.guestJoinLandingVC()
            return
        }
        if relationship.status == .eachOther {
            let session = NIMSession(object.username, type: .P2P)
            let vc = IMChatViewController(session: session, unread: 0)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            object.updateFollow { (success) in
                DispatchQueue.main.async {
                    if success {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil, userInfo: ["follow": object.follower, "userid": "\(object.userIdentity)"])
                        self.update(followStatus: object)
                        self.refresh(true)
                    }
                }
            }
        }
    }
    
    private func setHeader() {
        guard let model = model else { return }
        self.headerView.setModel(model: model)
        self.headerView.setNeedsLayout()
        self.headerView.layoutIfNeeded()
        self.table.tableHeaderView = headerView
        headerView.videoPlayerView.delegate = self
        playWith(model: model)
        
        let likeItem = headerView.toolbar.getItemAt(0)
        reactionHandler = ReactionHandler(reactionView: likeItem, toAppearIn: self.view, currentReaction: model.reactionType, feedId: model.idindex, feedItem: model, reactions: [.heart,.awesome,.wow,.cry,.angry])
        
        likeItem.addGestureRecognizer(reactionHandler!.longPressGesture)
        
        reactionHandler?.onSelect = { [weak self] reaction in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.animate(for: reaction)
                self.reactionSelected = reaction
            }
        }
        
        reactionHandler?.onSuccess = { [weak self] message in
            guard let self = self else { return }
            let feedId = model.idindex
            FeedListNetworkManager.getMomentFeed(id: feedId) { (model, message, status, networkResult) in
                guard let model = model else { return }
                DispatchQueue.main.async {
                    if status == true {
                        let cellModel = FeedListCellModel(feedListModel: model)
                        self.headerView.updateReactionView(reactionList: cellModel.topReactionList, total: (cellModel.toolModel?.diggCount).orZero)
                        if self.table.placeholder.superview != nil {
                            self.table.placeholder.snp.updateConstraints {
                                $0.top.equalToSuperview().offset(self.headerView.frame.maxY)
                            }
                        }
                        self.onToolbarUpdated?(cellModel)
                    }
                }
            }
        }
        
        self.headerView.onToolbarItemTapped = { [weak self] toolbarIndex in
            guard let self = self else {
                return
            }
            if toolbarIndex != 3 && TSCurrentUserInfo.share.isLogin == false {
                TSRootViewController.share.guestJoinLandingVC()
                return
            }
            
            switch toolbarIndex {
            case 0:
                self.reactionHandler?.onTapReactionView()
            case 1:
                TSKeyboardToolbar.share.keyboardBecomeFirstResponder()
                
            case 2:
//                if model.userInfo?.isMe() == true {
//                    let vc = PostTipHistoryTVC(feedId: self.feedId)
//                    self.navigation(navigateType: .pushView(viewController: vc))
//                } else {
//                    self.navigationController?.presentTipping(target: model.idindex, type: .moment, onSuccess: { [weak self] (_, _) in
//                        guard let self = self else { return }
//                        self.showSuccess(message: "tip_successful_title".localized)
//                        self.model?.toolModel?.rewardCount += 1
//                        self.model?.toolModel?.isRewarded = true
//                        self.headerView.updateRewardView()
//                        self.onToolbarUpdated?(self.model!)
//                    })
//                }
                break
                
            case 3:
                var shareUrl = ShareURL.feed.rawValue + "\(model.idindex)"
                if let username = CurrentUserSessionInfo?.username {
                    shareUrl += "?r=\(username)"
                }
                
                let messageModel = TSmessagePopModel(momentModel: model)
                let pictureView = PicturesTrellisView()
                pictureView.models = model.pictures
                // 当分享内容为空时，显示默认内容
                let image = (pictureView.pictures.first ?? nil) ?? UIImage.set_image(named: "IMG_icon")
                let title = TSAppSettingInfoModel().appDisplayName + " " + "post".localized
                var defaultContent = "default_share_content".localized
                defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
                let description = model.content.isEmpty ? defaultContent : model.content
                if model.userId == CurrentUserSessionInfo?.userIdentity {
                    let shareView = ShareListView(isMineSend: true, isCollection: (model.toolModel?.isCollect).orFalse, isDisabledCommentFeed: (model.toolModel?.isCommentDisabled).orFalse, isEdited: model.isEdited, shareType: ShareListType.momentList)
                    shareView.delegate = self
                    shareView.messageModel = messageModel
                    shareView.feedIndex = IndexPath()
                    shareView.show(URLString: shareUrl, image: image, description: description, title: title)
                } else {
                    let shareView = ShareListView(isMineSend: false, isCollection: (model.toolModel?.isCollect).orFalse, isDisabledCommentFeed: (model.toolModel?.isCommentDisabled).orFalse, isEdited: model.isEdited, shareType: ShareListType.momentList)
                    shareView.delegate = self
                    shareView.messageModel = messageModel
                    shareView.feedIndex = IndexPath()
                    shareView.show(URLString: shareUrl, image: image, description: description, title: title)
                }
                
            default: break
            }
            
        }
        
        headerView.onTranslated = { [weak self] in
            guard let self = self else { return }
            self.headerView.setNeedsLayout()
            self.headerView.layoutIfNeeded()
            self.table.tableHeaderView = self.headerView
            // By Kit Foong (Remove place holder and update the header frame margin)
            self.table.removePlaceholderViews()
            if self.commentDatas.count <= 0 {
                self.table.show(placeholderView: .noComment, margin: self.headerView.frame.maxY, height: 350)
            }
            self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 350, right: 0)
            self.table.setNeedsLayout()
            self.table.layoutIfNeeded()
        }
        
    }
    
    private func animate(for reaction: ReactionTypes?) {
        let toolbaritem = headerView.toolbar.getItemAt(0)
        
        if let reaction = reaction {
            UIView.transition(with: toolbaritem.imageView, duration: 0.3) {
                toolbaritem.imageView.image = reaction.image
                toolbaritem.titleLabel.text = reaction.title
                toolbaritem.titleLabel.textColor = AppTheme.softBlue
            }
        } else {
            UIView.transition(with: toolbaritem.imageView, duration: 0.3) {
                toolbaritem.imageView.image = UIImage.set_image(named: "IMG_home_ico_love")
                toolbaritem.titleLabel.text = "love_reaction".localized
                toolbaritem.titleLabel.textColor = .black
            }
        }
    }
    
    // 删除动态的二次确认弹窗
    private func showFeedDeleteConfirmAlert(model: FeedListCellModel) -> Void {
        let alertVC = TSAlertController.deleteConfirmAlert(deleteActionTitle: "delete_feed".localized) {
            self.deleteFeed(model: model)
        }
        self.present(alertVC, animated: false, completion: nil)
    }
    
    private func deleteFeed(model: FeedListCellModel) {
        TSMomentNetworkManager().deleteMoment(model.idindex) { [weak self] (result) in
            if result == true {
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.showTopFloatingToast(with: "please_retry_option".localized, desc: "")
            }
        }
    }
    
    private func setTSKeyboard(placeholderText: String, cell: TSDetailCommentTableViewCell?) {
        TSKeyboardToolbar.share.keyboardBecomeFirstResponder()
        TSKeyboardToolbar.share.keyboardSetPlaceholderText(placeholderText: placeholderText)
    }
    
    private func postComment(message: String, contentType: CommentContentType) {
        guard TSCurrentUserInfo.share.isLogin, let currentUserInfo = TSCurrentUserInfo.share.userInfo, let feedId = model?.idindex else { return }
        let commentType = TSCommentType(type: .feed)
        
        self.showLoading()
        //上报动态评论事件
        EventTrackingManager.instance.trackEvent(
            itemId: feedId.stringValue,
            itemType: model?.feedType == .miniVideo ? ItemType.shortvideo.rawValue   : ItemType.image.rawValue,
            behaviorType: BehaviorType.comment,
            sceneId: "",
            moduleId: ModuleId.feed.rawValue,
            pageId: PageId.feed.rawValue)
        
        
        TSCommentNetWorkManager.submitComment(for: commentType, content: message, sourceId: feedId, replyUserId: self.commentModel?.userInfo?.userIdentity, contentType: contentType) { [weak self] (commentModel, message, result) in
            
            defer {
                DispatchQueue.main.async {
                    self?.dismissLoading()
                }
            }
            
            guard result == true, let data = commentModel, let wself = self else {
                UIViewController.showBottomFloatingToast(with: message ?? "please_retry_option".localized, desc: "", displayDuration: 4.0)
                return
            }
            var simpleModel = data.simpleModel()
            simpleModel.userInfo = CurrentUserSessionInfo?.toType(type: UserInfoModel.self)
            switch wself.sendCommentType {
            case .send:
                simpleModel.replyUserInfo = nil
            case .replySend:
                simpleModel.replyUserInfo = wself.commentModel?.userInfo?.toType(type: UserInfoModel.self)
            default:
                simpleModel.replyUserInfo = wself.commentModel?.replyUserInfo?.toType(type: UserInfoModel.self)
            }
            let newCommentModel = FeedCommentListCellModel(object: simpleModel, feedId: feedId)
            newCommentModel.userId = currentUserInfo.userIdentity
            if let lastPinnedIndex = wself.commentDatas.lastIndex(where: { $0.showTopIcon == true }) {
                wself.commentDatas.insert(newCommentModel, at: lastPinnedIndex + 1)
            } else {
                wself.commentDatas.insert(newCommentModel, at: 0)
            }
            wself.model?.comments = wself.commentDatas
            wself.model?.toolModel?.commentCount += 1
            DispatchQueue.main.async {
                wself.table.removePlaceholderViews()
                wself.headerView.toolbar.setTitle((wself.model?.toolModel?.commentCount).orZero.abbreviated, At: 1)
                wself.headerView.setCommentLabel(count: wself.model?.toolModel?.commentCount, isCommentDisabled: false)
                wself.headerView.layoutIfNeeded()
                wself.table.reloadData()
                guard let model = wself.model else { return }
                wself.onToolbarUpdated?(model)
            }
        }
    }
    
    private func deleteComment(with cellModel: FeedCommentListCellModel) {
        guard let commentId = cellModel.id["commentId"], let feedId = model?.id["feedId"] else {
            return
        }
        TSCommentNetWorkManager.deleteComment(for: .momment, commentId: commentId, sourceId: feedId) { [weak self] (message, status) in
            DispatchQueue.main.async {
                if status == true {
                    self?.commentDatas.removeAll(where: { $0.id["commentId"] == commentId })
                    self?.model?.toolModel?.commentCount -= 1
                    self?.headerView.setCommentLabel(count: self?.model?.toolModel?.commentCount, isCommentDisabled: false)
                    self?.headerView.toolbar.setTitle((self?.model?.toolModel?.commentCount).orZero.abbreviated, At: 1)
                    self?.table.reloadData()
                    guard let model = self?.model else { return }
                    self?.onToolbarUpdated?(model)
                } else {
                    self?.showTopFloatingToast(with: "", desc: message.orEmpty)
                }
            }
        }
    }
}

// Video Player
extension FeedCommentDetailViewController: VideoPlayerVODDelegate {
    private func maximizePlayerView(with orientation: UIDeviceOrientation) {
        let playerView = headerView.videoPlayerView
        
        isFullScreen = true
        
        let originalFrame = playerView.frame
        
        let videoPlayerVC = VideoPlayerViewController(player: playerView)
        
        videoPlayerVC.onDismiss = { [weak self] in
            guard let self = self else { return }
            self.isFullScreen = false
            self.headerView.contentStackView.insertArrangedSubview(playerView, at: 0)
            playerView.snp.makeConstraints { (m) in
                m.width.equalTo(originalFrame.width)
                m.height.equalTo(originalFrame.height)
            }
            playerView.delegate = self
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        
        videoPlayerVC.modalTransitionStyle = .crossDissolve
        
        self.present(videoPlayerVC.fullScreenRepresentation, animated: true, completion: nil)
    }
    
    func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, onResume currentPlayTime: TimeInterval) {}
    
    func onFinish(with playerView: VideoPlayerVODView?) { }
    
    func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, onStop currentPlayTime: TimeInterval) {}
    
    func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, onSeekDone seekDoneTime: TimeInterval) {}
    
    func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, fullScreen: Bool) {
        if isFullScreen == false {
            maximizePlayerView(with: UIDevice.current.orientation)
        }
    }
    
    private func playWith(model: FeedListCellModel) {
        if VideoPlayer.shared.isPlaying { VideoPlayer.shared.stop() }
        var url: URL?
        url = URL(string: model.videoURL)
        if let fileURL = model.localVideoFileURL {
            let filePath = TSUtil.getWholeFilePath(name: fileURL)
            url = URL(fileURLWithPath: filePath)
        }
        guard url != nil else {
            return
        }
        
        headerView.videoPlayerView.aliPlayerView.reload()
        headerView.videoPlayerView.startPlaytime = self.startPlayTime
        headerView.videoPlayerView.playViewPrepare(with: url)
    }
}

// Table View Delegate
extension FeedCommentDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TSDetailCommentTableViewCell.identifier) as! TSDetailCommentTableViewCell
        cell.cellDelegate = self
        cell.commnetModel = self.commentDatas[indexPath.row]
        cell.detailCommentcellType = .normal
        cell.setDatas(width: tableView.bounds.size.width)
        cell.setAsPinned(pinned: self.commentDatas[indexPath.row].showTopIcon, isDarkMode: false)
        cell.indexPath = indexPath
        cell.layer.removeFromSuperlayer()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentDatas.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? TSDetailCommentTableViewCell
        guard cell?.nothingImageView.isHidden == true else { return }
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        
        let comment = self.commentDatas[indexPath.row]
        
        guard let userInfo = comment.userInfo else {
            needShowError()
            return
        }
        guard !userInfo.isMe() else { return }
        
        TSKeyboardToolbar.share.keyboarddisappear()
        
        self.sendCommentType = .replySend
        self.commentModel = self.commentDatas[indexPath.row]
        if model?.toolModel?.isCommentDisabled == false {
            setTSKeyboard(placeholderText: "reply_with_string".localized + "\((self.commentModel?.userInfo?.name)!)", cell: cell)
        }
    }
    
}

// Table comment cell delegate
extension FeedCommentDetailViewController: TSDetailCommentTableViewCellDelegate {
    func repeatTap(cell: TSDetailCommentTableViewCell, commnetModel: FeedCommentListCellModel) {
        
    }
    
    func didSelectName(userId: Int) {
//        let userHomePage = HomePageViewController(userId: userId)
//        self.navigation(navigateType: .pushView(viewController: userHomePage))
        FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: userId, username: nil, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
    }
    
    func didSelectHeader(userId: Int) {
//        let userHomePage = HomePageViewController(userId: userId)
//        self.navigation(navigateType: .pushView(viewController: userHomePage))
        FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: userId, username: nil, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
    }
    
    func didLongPressComment(in cell: TSDetailCommentTableViewCell, model: FeedCommentListCellModel) {
        guard TSCurrentUserInfo.share.isLogin, let currentUserInfo = TSCurrentUserInfo.share.userInfo else {
            return
        }
        
        // 显示举报评论弹窗
        let isFeedOwner = currentUserInfo.userIdentity == self.feedOwnerId
        let isCommentOwner = currentUserInfo.userIdentity == model.userId
        
        if isCommentOwner {
            self.navigationController?.presentPopVC(target: LivePinCommentModel(target: cell, requiredPinMessage: isFeedOwner, model: model), type: .selfComment, delegate: self)
        } else {
            self.navigationController?.presentPopVC(target: LivePinCommentModel(target: cell, requiredPinMessage: isFeedOwner, model: model), type: .normalComment , delegate: self)
        }
    }
    
    func didTapToReplyUser(in cell: TSDetailCommentTableViewCell, model: FeedCommentListCellModel) {
        if !cell.nothingImageView.isHidden {
            return
        }
        let userId = model.userInfo?.userIdentity
        TSKeyboardToolbar.share.keyboarddisappear()
        if userId == (CurrentUserSessionInfo?.userIdentity)! {
            let customAction = TSCustomActionsheetView(titles: ["choice_delete".localized])
            customAction.delegate = self
            customAction.tag = 250
            customAction.show()
            return
        }
        
        self.sendCommentType = .replySend
        self.commentModel = model
        setTSKeyboard(placeholderText: "reply_with_string".localized + "\((self.commentModel?.userInfo?.name)!)", cell: cell)
    }
    
    func needShowError() {
        self.showTopFloatingToast(with: "text_user_suspended", desc: "")
    }
    
    private func pinComment(in cell: TSDetailCommentTableViewCell, comment: FeedCommentListCellModel) {
        guard let commentId = comment.id["commentId"], let cellIndex = self.commentDatas.firstIndex(where: { $0.id["commentId"] == commentId }) else {
            return
        }
        cell.showLoading()
        TSCommentNetWorkManager.pinComment(for: commentId, sourceId: feedId) { [weak self] (message, status) in
            cell.hideLoading()
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let commentIndex = self.commentDatas.firstIndex(where: { $0.id["commentId"] == commentId }) else { return }
                guard status == true else {
                    self.showError(message: message.orEmpty)
                    return
                }
                self.showError(message: "feed_live_pinned_comment".localized)
                
                self.commentDatas[cellIndex].showTopIcon == true
                cell.setAsPinned(pinned: true, isDarkMode: false)
                self.table.moveRow(at: IndexPath(row: cellIndex, section: 0), to: IndexPath(row: 0, section: 0))
                self.commentDatas.remove(at: cellIndex)
                self.commentDatas.insert(comment, at: 0)
            }
        }
    }
    
    private func unpinComment(in cell: TSDetailCommentTableViewCell, comment: FeedCommentListCellModel) {
        guard let commentId = comment.id["commentId"], let cellIndex = self.commentDatas.firstIndex(where: { $0.id["commentId"] == commentId }) else {
            return
        }
        cell.showLoading()
        TSCommentNetWorkManager.unpinComment(for: commentId, sourceId: feedId) { [weak self] (message, status) in
            cell.hideLoading()
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let commentIndex = self.commentDatas.firstIndex(where: { $0.id["commentId"] == commentId }) else { return }
                guard status == true else {
                    self.showError(message: message.orEmpty)
                    return
                }
                self.showError(message: "feed_live_unpinned_comment".localized)
                
                self.commentDatas[cellIndex].showTopIcon = false
                cell.setAsPinned(pinned: false, isDarkMode: false)
                self.table.moveRow(at: IndexPath(row: cellIndex, section: 0), to: IndexPath(row: self.commentDatas.count - 1, section: 0))
                self.commentDatas.remove(at: cellIndex)
                self.commentDatas.append(comment)
            }
        }
    }
}

extension FeedCommentDetailViewController: TSKeyboardToolbarDelegate {
    func keyboardToolbarSendTextMessage(message: String, bundleId: String?, inputBox: AnyObject?, contentType: CommentContentType) {
        if TSCurrentUserInfo.share.isLogin == false {
            TSRootViewController.share.guestJoinLandingVC()
            return
        }
        
        if message == "" {
            return
        }
        sendText = message
        self.postComment(message: message, contentType: contentType)
    }
    
    func keyboardToolbarFrame(frame: CGRect, type: keyboardRectChangeType) {
        
    }
    
    func keyboardWillHide() {
        if sendText != nil {
            sendText = nil
            if self.commentDatas.count > 0 {
                self.table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
            return
        } else {
            if TSKeyboardToolbar.share.isEmojiSelected() == false {
                TSKeyboardToolbar.share.removeToolBar()
            }
        }
        
        if self.table.contentOffset.y > self.table.contentSize.height - self.table.bounds.height {
            if self.table.contentSize.height < self.table.bounds.size.height {
                self.table.setContentOffset(CGPoint.zero, animated: true)
                return
            }
            self.table.setContentOffset(CGPoint(x: 0, y: self.table.contentSize.height - self.table.bounds.height), animated: true)
        }
    }
}

// Share List View Delegate
extension FeedCommentDetailViewController: ShareListViewDelegate {
    //编辑
    func didClickEditButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        guard let data = model, let info = data.userInfo else {
            return
        }
        let pictureModels: [PaidPictureModel] = data.pictures
        let locationModels: TSPostLocationModel? = data.location
        
        let topicLists: [TopicListModel] = data.topics
        let editPostVC = EditPostViewController(feedId: data.idindex, name: info.displayName, avatarInfo: info.avatarInfo(), postContent: data.content, pictures: pictureModels, videoUrl: data.videoURL, localVideoFileUrl: data.localVideoFileURL, liveModel: data.liveModel, repostID: data.repostId, repostType: data.repostType, repostModel: data.repostModel, sharedModel: data.sharedModel, locationModel: locationModels, topicList: topicLists, isHotFeed: (data.hot == 0 ? true : false), privacy: data.privacy, feedType: data.feedType, tagVoucher: data.tagVoucher)
        
        editPostVC.onSucessEdit = { [weak self] (newFeedId, repostModel, sharedModel, feedContent) in
            if data.id["feedId"] == newFeedId {
                data.content = feedContent
                data.repostModel = repostModel
                data.sharedModel = sharedModel
                data.isEdited = true
                self?.model = data
            }
            
        }
        
        self.navigationController?.pushViewController(editPostVC, animated: true)
    }
    
    func didClickDisableCommentButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        if let data = model, let feedId = data.id["feedId"] {
            let isCommentDisabled = (data.toolModel?.isCommentDisabled).orFalse ? false : true
            TSMomentNetworkManager().commentPrivacy(isCommentDisabled == false ? 0 : 1, feedIdentity: feedId) { [weak self] (result) in
                guard let self = self else { return }
                if result == true {
                    self.model?.toolModel?.isCommentDisabled = isCommentDisabled
                    self.headerView.toolbar.item(isHidden: isCommentDisabled, at: 1)
                    
                    if isCommentDisabled {
                        self.showTopFloatingToast(with: "Disabled successful".localized, desc: "")
                        self.headerView.setCommentLabel(count: 0, isCommentDisabled: true)
                    } else {
                        self.showTopFloatingToast(with: "Enabled successful".localized, desc: "")
                        self.headerView.setCommentLabel(count: self.model?.toolModel?.commentCount, isCommentDisabled: false)
                    }
                    self.getCommentList()
                }
            }
        }
    }
    
    func didClickSetTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }
    
    func didClickCancelTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }
    
    func didClickSetExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }
    
    func didClickCancelExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }
    
    func didClickMessageButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, model: TSmessagePopModel) {
        
        let vc = ContactsPickerViewController(model: model, configuration: ContactsPickerConfig.shareToChatConfig(), finishClosure: nil)
        if #available(iOS 11, *) {
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let navigation = TSNavigationController(rootViewController: vc).fullScreenRepresentation
            self.navigationController?.present(navigation, animated: true, completion: nil)
        }
        
    }
    
    func didClickReportButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        if let model = model {
            guard let reportTarget: ReportTargetModel = ReportTargetModel(feedModel: model) else { return }
            let reportVC: ReportViewController = ReportViewController(reportTarget: reportTarget)
            self.present(TSNavigationController(rootViewController: reportVC).fullScreenRepresentation,
                         animated: true,
                         completion: nil)
        }
    }
    
    func didClickCollectionButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        if let data = model {
            let isCollect = (data.toolModel?.isCollect).orFalse ? false : true
            
            TSMomentNetworkManager().colloction(isCollect ? 1 : 0, feedIdentity: data.idindex, feedItem: data) { [weak self] (result) in
                if result == true {
                    self?.model?.toolModel?.isCollect = isCollect
                    
                    DispatchQueue.main.async {
                        shareView.updateView(tag: fatherViewTag, iscollect: isCollect)
                        if isCollect {
                            self?.showTopFloatingToast(with: "success_save".localized, desc: "")
                            
                        }
                    }
                }
            }
        }
    }
    
    func didClickDeleteButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        if let model = model {
            self.showFeedDeleteConfirmAlert(model: model)
        }
    }
    
    func didClickRepostButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?) {
        if let model = model {
            let repostModel = TSRepostModel(model: model)
            let releaseVC = TSReleasePulseViewController(isHiddenshowImageCollectionView: true)
            releaseVC.repostModel = repostModel
            let navigation = TSNavigationController(rootViewController: releaseVC).fullScreenRepresentation
            self.present(navigation, animated: true, completion: nil)
        }
    }
    
    func didClickApplyTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        
    }
    
    func didClickShareExternal(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, items: [Any]) {
        if let model = model {
            let messagePopModel = TSmessagePopModel(momentModel: model)
            let fullUrlString = TSAppConfig.share.environment.serverAddress + "feeds/" + String(messagePopModel.feedId)
            // By Kit Foong (Hide Yippi App from share)
            let items: [Any] = [URL(string: fullUrlString), messagePopModel.titleSecond, ShareExtensionBlockerItem()]
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
        
    }
    
    func didClickShareQr(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, items: [Any]) {
    }
    
    func didClickBlackListButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension FeedCommentDetailViewController: CustomPopListProtocol {
    func customPopList(itemType: TSPopUpItem) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.handlePopUpItemAction(itemType: itemType)
        }
    }
    
    func handlePopUpItemAction(itemType: TSPopUpItem) {
        switch itemType {
        case .reportComment(model: let model):
            guard let feedModel = model.model as? FeedCommentListCellModel else { return }
            let reportTarget = ReportTargetModel(feedCommentModel: feedModel)
            let reportVC = ReportViewController(reportTarget: reportTarget)
            self.present(TSNavigationController(rootViewController: reportVC).fullScreenRepresentation, animated: true, completion: nil)
            break
        case .deleteComment(model: let model):
            guard let feedModel = model.model as? FeedCommentListCellModel else { return }
            self.showRLDelete(title: "delete_comment".localized, message: "rw_delete_comment_action_desc".localized, dismissedButtonTitle: "delete".localized, onDismissed: { [weak self] in
                guard let self = self else { return }
                self.deleteComment(with: feedModel)
            }, cancelButtonTitle: "cancel".localized)
            break
        case .livePinComment(model: let model):
            guard let cell = model.target as? TSDetailCommentTableViewCell, let feedModel = model.model as? FeedCommentListCellModel else { return }
            DispatchQueue.main.async {
                self.pinComment(in: cell, comment: feedModel)
            }
            break
        case .liveUnPinComment(model: let model):
            guard let cell = model.target as? TSDetailCommentTableViewCell, let feedModel = model.model as? FeedCommentListCellModel else { return }
            DispatchQueue.main.async {
                self.unpinComment(in: cell, comment: feedModel)
            }
            break
        case .copy(model: let model):
            guard let feedModel = model.model as? FeedCommentListCellModel else { return }
            UIPasteboard.general.string = feedModel.content
            UIViewController.showBottomFloatingToast(with: "rw_copy_to_clipboard".localized, desc: "")
            break
        default:
            break
        }
    }
}

