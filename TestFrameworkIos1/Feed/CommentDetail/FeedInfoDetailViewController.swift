//
//  FeedInfoDetailViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/10/11.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
import CoreMedia
public class FeedInfoDetailViewController: TSViewController, TSCustomAcionSheetDelegate {
    
    private var table: TSTableView = {
        let table = TSTableView(frame: CGRect.zero, style: .plain)
        table.register(UINib(nibName: "TSDetailCommentTableViewCell", bundle: nil), forCellReuseIdentifier: TSDetailCommentTableViewCell.identifier)
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = .white
        table.tableFooterView = UIView()
        table.separatorStyle = .none
        return table
    }()
    
    private let navView: TSMomentDetailNavTitle = TSMomentDetailNavTitle()
    
    var currentPrimaryButtonState: SocialButtonState = .follow
    
    private let primaryButton: TSButton = {
        let button = TSButton(type: .custom)
        button.setTitle("display_follow".localized, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = AppTheme.Font.regular(12)
        button.backgroundColor = AppTheme.primaryRedColor
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.roundCorner(10)
        return button
    }()
    let moreButton = UIButton(type: .custom).configure {
        $0.setImage(UIImage.set_image(named: "IMG_topbar_more_black"), for: .normal)
    }
    
    var dontTriggerObservers:Bool = false
    var model: FeedListCellModel? {
        didSet {
            self.setHeader()
            self.setBottomViewData()
            self.getCommentList()
            self.navView.updateSponsorStatus(model?.isSponsored ?? false)
        }
    }
    public var transitionId = UUID().uuidString
    public var afterTime: String = ""
    
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
    private var bottomToolBarView: FeedCommentDetailBottomView = FeedCommentDetailBottomView(frame: .zero, colorStyle: .normal)
    private var voucherBottomView: VoucherBottomView = VoucherBottomView()

    var onToolbarUpdated: onToolbarUpdate?
    var reactionHandler: ReactionHandler?
    var reactionSelected: ReactionTypes?
    
    var isHomePage: Bool = false
    // feed type
    var type: FeedListType?
    
    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return true
    }
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    var startPlayTime: CMTime = .zero
    var onDismiss: ((CMTime) -> Void)?
    var tagVoucher: TagVoucherModel?
    
    init(feedId: Int, isTapMore: Bool = false, isClickCommentButton: Bool = false, isVideoFeed: Bool = false, onToolbarUpdated: onToolbarUpdate?) {
        super.init(nibName: nil, bundle: nil)
        self.feedId = feedId
        self.isTapMore = isTapMore
        self.isClickCommentButton = isClickCommentButton
        self.onToolbarUpdated = onToolbarUpdated
    }
    
    public init(feedId: Int, isTapMore: Bool = false, isClickCommentButton: Bool = false, isVideoFeed: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.feedId = feedId
        self.isTapMore = isTapMore
        self.isClickCommentButton = isClickCommentButton
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loading()
        
        TSKeyboardToolbar.share.theme = .white
        TSKeyboardToolbar.share.setStickerNightMode(isNight: false)
        TSKeyboardToolbar.share.keyboardToolbarDelegate = self
        prepareRightItems()
        setupTableView()
        setBottomView()
        configurePrimaryButton()
        table.mj_header.beginRefreshing()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        TSKeyboardToolbar.share.keyboarddisappear()
        TSKeyboardToolbar.share.keyboardStopNotice()
        
        onDismiss?(headerView.videoPlayerView.currentPlayTime())
        
        self.reactionHandler?.reset()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        //   NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
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
                self.updatePrimaryButton()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updatePinnedCell(notice:)), name: NSNotification.Name(rawValue: "newPinnedFeed"), object: nil)
        
        var backButton = UIBarButtonItem(image: UIImage.set_image(named: "btn_back_normal"), style: .plain, target: self, action: #selector(backAction))
        let titleView = UIBarButtonItem(customView: navView)
        self.navigationItem.leftBarButtonItems = [backButton , titleView]
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        TSKeyboardToolbar.share.keyboardstartNotice()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refresh(true)
        //开始记录停留时间
        stayBeginTimestamp = Date().timeStamp
    }
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.behaviorUserFeedStayData()
    }
    @objc func orientationChanged() {
        guard isFullScreen == false &&
                ((UIDevice.current.orientation == .landscapeLeft) || (UIDevice.current.orientation == .landscapeRight)) else {
            return
        }
        maximizePlayerView(with: UIDevice.current.orientation)
    }
    @objc func updatePinnedCell(notice: NSNotification) {
        guard let userInfo = notice.userInfo else { return }
        guard let feedId = userInfo["feedId"] as? Int, let isPinned = userInfo["isPinned"] as? Bool else { return }
        self.model?.isPinned = isPinned
    }
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        
    }
    @objc func backAction () {
        self.view.endEditing(true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
            if self.isHomePage {
                self.navigationController?.popViewController(animated: true)
            } else {
                if self.isModal ?? true {
                    self.dismiss(animated: true)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    // MARK: - 商家小程序跳转
    @objc func momentMerchantDidClick(noti: Notification) {
        
        if let wantedMid = noti.userInfo?["wanted_mid"] as? String, let path = noti.userInfo?["path"] as? String {
            var pathRoute  = path + "?id=\(wantedMid)"
            guard let extras = TSAppConfig.share.localInfo.mpExtras else { return }
           // miniProgramExecutor.startApplet(type: .normal(appId: extras), param: ["path": pathRoute], parentVC: self)
            FeedIMSDKManager.shared.delegate?.didOpenMiniProgram(appId: extras, path: path)
        }
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
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 75))
        view.addSubview(table)
        table.bindToSafeEdges()
        table.tableHeaderView = headerView
        
    }
    // MARK: - 设置右侧按钮
    private func prepareRightItems() {
        
        primaryButton.addTap { [weak self] (_) in
            guard let self = self else { return }
            self.followUserClicked()
        }
        primaryButton.snp.makeConstraints {
            $0.width.equalTo(70)
            $0.height.equalTo(25)
        }
        let followView = UIBarButtonItem(customView: primaryButton)
        moreButton.addAction {
            guard let id = CurrentUserSessionInfo?.userIdentity else {
                return
            }
            guard let model = self.model else { return }
            
            self.navigationController?.presentPopVC(target: model, type: model.userId == id ? .moreMe : .moreUser , delegate: self)
        }
        let moreView = UIBarButtonItem(customView: moreButton)
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 12
        //等数据加载成功再显示按钮
        primaryButton.isHidden = true
        moreButton.isHidden = true
        self.navigationItem.rightBarButtonItems = [moreView, space ,followView]
    }
    /// 刷新数据
    /// - Parameter dontTriggerObservers: 这个参数控制是否需要刷新视图，下拉刷新的时候需要触发setHeader方法刷新视图，关注/取消关注则不需要刷新视图
    /// flase = 触发刷新  true 不需要刷新
    @objc func refresh(_ dontTriggerObservers: Bool = false) {
        FeedListNetworkManager.getMomentFeed(id: feedId) { [weak self] (listModel, errorMsg, status, networkResult) in
            if status == false {
                switch networkResult {
                case .failure(let failure):
                    switch failure.statusCode {
                    case 404:
                        self?.show(placeholder: .removed)
                    default:
                        self?.show(placeholder: .network)
                    }
                default:
                    self?.show(placeholder: .network)
                }
            }
            
            guard let listModel = listModel, let wself = self else {
                return
            }
            
            let cellModel = FeedListCellModel(feedListModel: listModel)
            self?.feedOwnerId = cellModel.userId
            self?.dontTriggerObservers = dontTriggerObservers
            self?.tagVoucher = cellModel.tagVoucher
            
            if wself.tagVoucher?.taggedVoucherId != nil && wself.tagVoucher?.taggedVoucherId != 0 {
                wself.voucherBottomView.isHidden = false
                wself.voucherBottomView.voucherLabel.text = wself.tagVoucher?.taggedVoucherTitle ?? ""
            } else {
                wself.voucherBottomView.isHidden = true
            }
            
            wself.model = cellModel
            
            DispatchQueue.main.async {
                wself.removePlaceholderView()
                wself.updatePrimaryButton()
                wself.navView.update(model: cellModel.userInfo ?? UserInfoModel())
                wself.setBottomViewData()
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
    
    
    private func updatePrimaryButton() {
        guard let relationship = self.model?.userInfo?.relationshipWithCurrentUser else { return }
        primaryButton.isHidden = false
        moreButton.isHidden = false
        //        switch relationship.status {
        //            case .unfollow:
        //            primaryButton.backgroundColor = AppTheme.primaryRedColor
        //            primaryButton.isEnabled = true
        //        case .follow, .eachOther:
        //            primaryButton.backgroundColor = UIColor(hex: 0xB4B4B4)
        //            primaryButton.isEnabled = false
        //        default:
        //            primaryButton.backgroundColor = UIColor(hex: 0xB4B4B4)
        //            primaryButton.isEnabled = false
        //            break
        //        }
        guard let followStatus = self.model?.userInfo?.followStatus else { return }
        
        
        var followStatusDidChanged:Bool = false
        var actionTitle: String = "profile_follow".localized
        switch followStatus {
        case .eachOther:
            actionTitle = "profile_home_follow_mutual".localized
            currentPrimaryButtonState = .followMutually
            primaryButton.backgroundColor = UIColor(hex: 0xB4B4B4)
            
        case .follow:
            if currentPrimaryButtonState != .follow {
                followStatusDidChanged = true
            }
            actionTitle = "profile_home_follow".localized
            primaryButton.backgroundColor = UIColor(hex: 0xB4B4B4)
            currentPrimaryButtonState = .follow
            
        case .unfollow:
            if currentPrimaryButtonState != .unfollow {
                followStatusDidChanged = true
            }
            actionTitle = "display_follow".localized
            primaryButton.backgroundColor = AppTheme.primaryRedColor
            currentPrimaryButtonState = .unfollow
            
            
        case .oneself:
            actionTitle = "display_follow".localized
            primaryButton.backgroundColor = UIColor(hex: 0xB4B4B4)
            currentPrimaryButtonState = .follow
            primaryButton.isHidden = true
            
        }
        
        if followStatusDidChanged {
            UIView.transition(with: self.primaryButton, duration: 0.2, options: .transitionCrossDissolve, animations: { [weak self] in
                guard let self = self else { return }
                self.primaryButton.setTitle(actionTitle)
            }, completion: nil)
        } else {
            primaryButton.setTitle(actionTitle)
            
        }
    }
    private func configurePrimaryButton() {
        primaryButton.addTap { [weak self] (_) in
            guard let self = self else { return }
            guard TSCurrentUserInfo.share.isLogin == true else {
                TSRootViewController.share.guestJoinLandingVC()
                return
            }
            primaryButton.setTitle("Loading...".localized, for: .normal)
            self.model?.userInfo?.updateFollow { [weak self] (success) in
                DispatchQueue.main.async {
                    if success {
                        guard let self = self  else { return }
                        
                        // By Kit Foong (Trigger observer to update follow status)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil, userInfo: ["follow": self.model?.userInfo?.follower, "userid": "\(self.model?.userInfo?.userIdentity)"])
                        self.updatePrimaryButton()
                        self.refresh(true)
                    } else {
                        self?.updatePrimaryButton()
                    }
                }
            }
        }
    }
    private func followUserClicked() {
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
//            let session = NIMSession(object.username, type: .P2P)
//            let vc = IMChatViewController(session: session, unread: 0)
//            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            object.updateFollow { (success) in
                DispatchQueue.main.async {
                    if success {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil, userInfo: ["follow": object.follower, "userid": "\(object.userIdentity)"])
                        self.updatePrimaryButton()
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
        headerView.feedShopView.momentMerchantDidClick = { [weak self] merchantData in
            guard let self = self else { return }
            
            let appId = merchantData.wantedMid
            var path = merchantData.wantedPath
            path = path + "?id=\(appId)"
            print("=path = \(path)")
            guard let extras = TSAppConfig.share.localInfo.mpExtras else { return }
            //miniProgramExecutor.startApplet(type: .normal(appId: extras), param: ["path": path], parentVC: self)
            FeedIMSDKManager.shared.delegate?.didOpenMiniProgram(appId: extras, path: path)
        }
        
        headerView.pictureView.onTapPictureView =  { [weak self] (trellis, tappedIndex, transitionID) in
            guard let self = self else { return }
            guard let userID = TSCurrentUserInfo.share.userInfo?.userIdentity else { return }
            guard let model = self.model else { return }
            
            var dest = FeedDetailImagePageController(config: .list(data: [model], tappedIndex: tappedIndex, mediaType: .image, listType: self.type ?? .user(userId: userID), transitionId: transitionId, placeholderImage: self.headerView.pictureView.pictures[0] ?? UIImage(), isClickComment: false, isTranslateText: false), completeHandler: nil, onToolbarUpdated: onToolbarUpdated, translateHandler: nil, tagVoucher: self.tagVoucher)
            dest.isControllerPush = true
            dest.afterTime = self.afterTime
            
            self.navigationController?.pushViewController(dest, animated: true)
        }
    }
    private func setBottomView() {
        view.addSubview(bottomToolBarView)
        view.addSubview(voucherBottomView)
        
        bottomToolBarView.isHidden = true
        bottomToolBarView.onCommentAction = { [weak self] in
            guard let self = self else { return }
            TSKeyboardToolbar.share.keyboardBecomeFirstResponder()
            if let tagVoucher = self.tagVoucher {
                TSKeyboardToolbar.share.setTagVoucher(tagVoucher)
            }
           
        }
        
        bottomToolBarView.snp.makeConstraints {
            $0.right.left.bottom.equalToSuperview()
            $0.height.equalTo(70)
        }
        
        voucherBottomView.isHidden = true
        voucherBottomView.isUserInteractionEnabled = true
        voucherBottomView.snp.makeConstraints {
            $0.bottom.equalTo(bottomToolBarView.snp.top).offset(0)
            $0.right.left.equalToSuperview()
            $0.height.equalTo(44)
        }
        voucherBottomView.voucherOnTapped = { [weak self] in
            let vc = VoucherDetailViewController()
            vc.voucherId = self?.tagVoucher?.taggedVoucherId ?? 0
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    private func setBottomViewData() {
        guard let model = model else { return }
        bottomToolBarView.isHidden = false
        bottomToolBarView.loadToolbar(model: model.toolModel, canAcceptReward: model.canAcceptReward == 1 ? true : false, reactionType: model.reactionType)
        
        let likeItem = bottomToolBarView.toolbar.getItemAt(0)
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
                        self.model = cellModel
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
        
        bottomToolBarView.onToolbarItemTapped = { [weak self] toolbarIndex in
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
                self.navigationController?.presentPopVC(target: "", type: .share, delegate: self)
                
            default: break
            }
            
        }
    }
    private func animate(for reaction: ReactionTypes?) {
        let toolbaritem = bottomToolBarView.toolbar.getItemAt(0)
        
        //设置点赞状态
        if let reaction = reaction {
            if self.model?.topReactionList.contains(reaction) == false {
                self.model?.topReactionList.append(reaction)
            }
            
            if self.model?.reactionType == nil {
                self.model?.toolModel?.diggCount += 1
            }
            UIView.transition(with: toolbaritem.imageView, duration: 0.3) {
                toolbaritem.imageView.image = reaction.image
            }
        } else {
            self.model?.toolModel?.diggCount -= 1
            UIView.transition(with: toolbaritem.imageView, duration: 0.3) {
                toolbaritem.imageView.image = UIImage.set_image(named: "IMG_home_ico_love")
            }
        }
        if let count = self.model?.toolModel?.diggCount, count >= 0 {
            toolbaritem.titleLabel.text = count.stringValue
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
    // MARK: - 记录转发
    private func forwardFeed() {
        guard let feedId = model?.idindex else { return }
        self.showLoading()
        FeedListNetworkManager.forwardFeed(feedId: feedId) { [weak self] (errMessage, statusCode, status) in
            guard let self = self else { return }
            defer {
                DispatchQueue.main.async {
                    self.dismissLoading()
                    self.refresh(false)
                }
                //上报动态转发事件
                EventTrackingManager.instance.trackEvent(
                    itemId: feedId.stringValue,
                    itemType: self.model?.feedType == .miniVideo ? ItemType.shortvideo.rawValue   : ItemType.image.rawValue,
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
    private func postComment(message: String, contentType: CommentContentType) {
        guard TSCurrentUserInfo.share.isLogin, let currentUserInfo = TSCurrentUserInfo.share.userInfo, let feedId = model?.idindex else { return }
        let commentType = TSCommentType(type: .feed)
        
        self.showLoading()
        //上报动态评论事件
        EventTrackingManager.instance.trackEvent(
            itemId: feedId.stringValue,
            itemType: self.model?.feedType == .miniVideo ? ItemType.shortvideo.rawValue   : ItemType.image.rawValue,
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
                wself.bottomToolBarView.toolbar.setTitle((wself.model?.toolModel?.commentCount).orZero.abbreviated, At: 1)
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
                    self?.bottomToolBarView.toolbar.setTitle((self?.model?.toolModel?.commentCount).orZero.abbreviated, At: 1)
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
extension FeedInfoDetailViewController: VideoPlayerVODDelegate {
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
extension FeedInfoDetailViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentDatas.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
extension FeedInfoDetailViewController: TSDetailCommentTableViewCellDelegate {
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

extension FeedInfoDetailViewController: TSKeyboardToolbarDelegate {
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

extension FeedInfoDetailViewController: CustomPopListProtocol {
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
            
            if let model = self.model {
                let messageModel = TSmessagePopModel(momentModel: model)
                let vc = ContactsPickerViewController(model: messageModel, configuration: ContactsPickerConfig.shareToChatConfig(), finishClosure: nil)
                if #available(iOS 11, *) {
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let navigation = TSNavigationController(rootViewController: vc).fullScreenRepresentation
                    self.navigationController?.present(navigation, animated: true, completion: nil)
                }
            }
        case .shareExternal:
            // 记录转发数
            self.forwardFeed()
            
            if let model = self.model {
                let messagePopModel = TSmessagePopModel(momentModel: model)
                let fullUrlString = TSAppConfig.share.environment.serverAddress + "feeds/" + String(messagePopModel.feedId)
                // By Kit Foong (Hide Yippi App from share)
                let items: [Any] = [URL(string: fullUrlString), messagePopModel.titleSecond, ShareExtensionBlockerItem()]
                let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                self.present(activityVC, animated: true, completion: nil)
            }
        case .save(isSaved: let isSaved):
            if let data = self.model {
                let isCollect = (data.toolModel?.isCollect).orFalse ? false : true
                TSMomentNetworkManager().colloction(isCollect ? 1 : 0, feedIdentity: data.idindex, feedItem: data) { [weak self] (result) in
                    if result == true {
                        self?.model?.toolModel?.isCollect = isCollect
                        DispatchQueue.main.async {
                            if isCollect {
                                self?.showTopFloatingToast(with: "success_save".localized, desc: "")
                            }
                        }
                    }
                }
            }
        case .reportPost:
            if let model = self.model {
                guard let reportTarget: ReportTargetModel = ReportTargetModel(feedModel: model) else { return }
                let reportVC: ReportViewController = ReportViewController(reportTarget: reportTarget)
                self.present(TSNavigationController(rootViewController: reportVC).fullScreenRepresentation,
                             animated: true,
                             completion: nil)
            }
        case .edit:
            guard let model = self.model, let avatarInfo = self.model?.avatarInfo else {
                return
            }
           let pictures =  model.pictures.map{ RejectDetailModelImages(fileId: $0.file, imagePath: $0.url ?? "", isSensitive: false, sensitiveType: "")   }
            var vc = TSReleasePulseViewController(isHiddenshowImageCollectionView: false)
            
            vc.selectedModelImages = pictures
           
            vc.preText = model.content
            
            vc.feedId = model.idindex.stringValue
            vc.isFromEditFeed = true
            
            vc.tagVoucher = tagVoucher
            
            if let extenVC = self.configureReleasePulseViewController(detailModel: model, viewController: vc) as? TSReleasePulseViewController{
                vc = extenVC
            }
            
            let navigation = TSNavigationController(rootViewController: vc).fullScreenRepresentation
            self.present(navigation, animated: true, completion: nil)
            
        case .deletePost:
            guard let model = model else { return }
            self.showRLDelete(title: "rw_delete_action_title".localized, message: "rw_delete_action_desc".localized, dismissedButtonTitle: "delete".localized, onDismissed: { [weak self] in
                guard let self = self else { return }
                TSMomentNetworkManager().deleteMoment(self.model?.idindex ?? 0) { [weak self] (result) in
                    guard let self = self else { return }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedDelete"), object: nil, userInfo: ["feedId": feedId])
                    self.navigationController?.popViewController(animated: true)
                }
            }, cancelButtonTitle: "cancel".localized)
        case .pinTop(isPinned: let isPinned):
            guard let feedId = self.model?.idindex else { return }
            
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
                
                self.model?.isPinned = newPined
                self.showError(message: newPined ? "feed_pinned".localized : "feed_unpinned".localized)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPinnedFeed"), object: nil, userInfo: ["isPinned": !isPinned, "feedId": feedId])
            }
            break
        case .comment(isCommentDisabled: let isCommentDisabled):
            guard let feedId = self.model?.idindex else { return }
            
            let newValue = self.model?.toolModel?.isCommentDisabled ?? true ? 0 : 1
            TSMomentNetworkManager().commentPrivacy(newValue, feedIdentity: feedId) { [weak self] success in
                guard let self = self else { return }
                if success {
                    self.model?.toolModel?.isCommentDisabled = newValue == 1
                    DispatchQueue.main.async {
                        if newValue == 1 {
                            self.showTopIndicator(status: .success, "disable_comment_success".localized)
                        } else {
                            self.showTopIndicator(status: .success, "enable_comment_success".localized)
                        }
                        self.setBottomViewData()
                    }
                }
            }
            break
        case .deleteComment(model: let model):
            guard let feedModel = model.model as? FeedCommentListCellModel else { return }
            self.showRLDelete(title: "delete_comment".localized, message: "rw_delete_comment_action_desc".localized, dismissedButtonTitle: "delete".localized, onDismissed: { [weak self] in
                guard let self = self else { return }
                self.deleteComment(with: feedModel)
            }, cancelButtonTitle: "cancel".localized)
        case .reportComment(model: let model):
            guard let feedModel = model.model as? FeedCommentListCellModel else { return }
            let reportTarget = ReportTargetModel(feedCommentModel: feedModel)
            let reportVC = ReportViewController(reportTarget: reportTarget)
            self.present(TSNavigationController(rootViewController: reportVC).fullScreenRepresentation, animated: true, completion: nil)
        case .livePinComment(model: let model):
            guard let cell = model.target as? TSDetailCommentTableViewCell, let model = model.model as? FeedCommentListCellModel else { return }
            DispatchQueue.main.async {
                self.pinComment(in: cell, comment: model)
            }
            break
        case .liveUnPinComment(model: let model):
            guard let cell = model.target as? TSDetailCommentTableViewCell, let model = model.model as? FeedCommentListCellModel else { return }
            DispatchQueue.main.async {
                self.unpinComment(in: cell, comment: model)
            }
            break
        case .copy(model: let model):
            guard let model = model.model as? FeedCommentListCellModel else { return }
            UIPasteboard.general.string = model.content
            UIViewController.showBottomFloatingToast(with: "rw_copy_to_clipboard".localized, desc: "")
            break
        default:
            break
        }
    }
}

extension FeedInfoDetailViewController {
    // MARK: - 上报停留数据
    func behaviorUserFeedStayData() {
        if stayBeginTimestamp != "" {
            stayEndTimestamp = Date().timeStamp
            let stay = stayEndTimestamp.toInt()  - stayBeginTimestamp.toInt()
            if stay > 5 {
                self.stayBeginTimestamp = ""
                self.stayEndTimestamp = ""
                EventTrackingManager.instance.trackEvent(
                    itemId: self.model?.idindex.stringValue ?? "",
                    itemType: ItemType.image.rawValue,
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
