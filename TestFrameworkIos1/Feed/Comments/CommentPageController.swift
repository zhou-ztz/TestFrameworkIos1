//
// Created by Francis Yeap on 27/11/2020.
// Copyright (c) 2020 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit
import Combine

class CommentPageController: TSViewController {
    private var cancellables = Set<AnyCancellable>()
    var pageIndex = 0
    
    var onLoaded: ((Int) -> Void)?
    private(set) var theme: Theme = .dark
    private(set) var feedId: Int
    private(set) var feedOwnerId: Int
    private(set) var feedItem: FeedListCellModel?
    
    private lazy var table: TSTableView = {
        let table = TSTableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.register(UINib(nibName: "TSDetailCommentTableViewCell", bundle: nil), forCellReuseIdentifier: TSDetailCommentTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        table.separatorInset = .zero
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.textToolbarHeight, right: 0)
        table.mj_header = TSRefreshHeader(refreshingBlock: { [weak self] in
            self?.getCommentList(isLoadMore: false)
        })
        table.mj_footer = TSRefreshFooter(refreshingBlock: { [weak self] in
            self?.getCommentList(isLoadMore: true)
        })
        return table
    }()
    
    private var selectedComment: FeedCommentListCellModel?
    private let fakeTextToolbar = MessageInputView()
    private let invisibleView = UIView().configure {
        $0.backgroundColor = .clear
    }
    private var comments: [FeedCommentListCellModel] = []
    
    init(theme: Theme, feedId: Int, feedOwnerId: Int, feedItem: FeedListCellModel?) {
        self.feedId = feedId
        self.feedOwnerId = feedOwnerId
        self.feedItem = feedItem
        super.init(nibName: nil, bundle: nil)
        self.theme = theme
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        updateTheme()
        setClearNavBar()
        TSKeyboardToolbar.share.theme = theme
        TSKeyboardToolbar.share.keyboardToolbarDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TSKeyboardToolbar.share.keyboarddisappear()
        TSKeyboardToolbar.share.keyboardStopNotice()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TSKeyboardToolbar.share.keyboardstartNotice()
    }
    
    private func updateTheme() {
        switch theme {
        case .white:
            view.backgroundColor = .white
            navigationController?.navigationBar.barTintColor = UIColor.white
            navigationController?.navigationBar.isTranslucent = false
            
        case .dark:
            view.backgroundColor = AppTheme.materialBlack
            navigationController?.navigationBar.barTintColor = AppTheme.materialBlack
            navigationController?.navigationBar.isTranslucent = false
        }
    }
    
    private func setup() {
        view.addSubview(table)
        table.bindToEdges()
        
        view.addSubview(fakeTextToolbar)
        fakeTextToolbar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        fakeTextToolbar.theme = self.theme
        fakeTextToolbar.sendTextView.delegate = self
        fakeTextToolbar.sendTextView.addAction { [weak self] in
            self?.selectedComment = nil
            self?.activeKeyboard()
        }
        fakeTextToolbar.smileButton.addAction { [weak self] in
            //self?.activeKeyboard()
            TSKeyboardToolbar.share.showEmojiView()
        }
        
        table.mj_header.beginRefreshing()
    }
    
    private func onUpdateSegmentTitle() {
        self.onLoaded?(self.comments.count)
    }
    
    private func getCommentList(isLoadMore: Bool) {
        let after = isLoadMore ? comments.last?.id["commentId"] : nil
        TSCommentNetWorkManager.getMomentCommentList(type: .momment, feedId: self.feedId, afterId: after, limit: TSAppConfig.share.localInfo.limit) { [weak self] (models, message, status) in
            guard let self = self else { return }
            defer {
                self.table.reloadData()
                if isLoadMore {
                    if (models?.count ?? 0) < TSAppConfig.share.localInfo.limit {
                        self.table.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.table.mj_footer.endRefreshing()
                    }
                } else {
                    self.table.mj_header.endRefreshing()
                }
            }
            guard status, let commentModels = models else {
                if let msg = message {
                    self.showError(message: msg)
                } else {
                    self.showError(message: "network_problem".localized)
                }
                self.table.show(placeholderView: .network, theme: self.theme)
                return
            }
            if isLoadMore {
                self.comments.append(contentsOf: commentModels)
            } else {
                self.comments = commentModels
                guard self.comments.count > 0 else {
                    self.table.show(placeholderView: .noComment, theme: self.theme, height: 100)
                    return
                }
                self.table.removePlaceholderViews()
                self.table.mj_footer.endRefreshing()
            }
        }
    }
    
    private func pinComment(in cell: TSDetailCommentTableViewCell, comment: FeedCommentListCellModel) {
        guard let commentId = comment.id["commentId"], let cellIndex = self.comments.firstIndex(where: { $0.id["commentId"] == commentId }) else {
            return
        }
        cell.showLoading()
        TSCommentNetWorkManager.pinComment(for: commentId, sourceId: feedId) { [weak self] (message, status) in
            cell.hideLoading()
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let commentIndex = self.comments.firstIndex(where: { $0.id["commentId"] == commentId }) else { return }
                guard status == true else {
                    self.showError(message: message.orEmpty)
                    return
                }
                self.showError(message: "feed_live_pinned_comment".localized)
                
                self.comments[cellIndex].showTopIcon == true
                cell.setAsPinned(pinned: true, isDarkMode: false)
                self.table.moveRow(at: IndexPath(row: cellIndex, section: 0), to: IndexPath(row: 0, section: 0))
                self.comments.remove(at: cellIndex)
                self.comments.insert(comment, at: 0)
            }
        }
    }
    
    private func unpinComment(in cell: TSDetailCommentTableViewCell, comment: FeedCommentListCellModel) {
        guard let commentId = comment.id["commentId"], let cellIndex = self.comments.firstIndex(where: { $0.id["commentId"] == commentId }) else {
            return
        }
        cell.showLoading()
        TSCommentNetWorkManager.unpinComment(for: commentId, sourceId: feedId) { [weak self] (message, status) in
            cell.hideLoading()
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let commentIndex = self.comments.firstIndex(where: { $0.id["commentId"] == commentId }) else { return }
                guard status == true else {
                    self.showError(message: message.orEmpty)
                    return
                }
                self.showError(message: "feed_live_unpinned_comment".localized)
                
                self.comments[cellIndex].showTopIcon = false
                cell.setAsPinned(pinned: false, isDarkMode: false)
                self.table.moveRow(at: IndexPath(row: cellIndex, section: 0), to: IndexPath(row: self.comments.count - 1, section: 0))
                self.comments.remove(at: cellIndex)
                self.comments.append(comment)
            }
        }
    }
}

extension CommentPageController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TSDetailCommentTableViewCell.identifier, for: indexPath) as! TSDetailCommentTableViewCell
        cell.theme = theme
        cell.commnetModel = comments[indexPath.row]
        cell.detailCommentcellType = .normal
        cell.isShowLine = false
        cell.setDatas(width: ScreenWidth)
        cell.cellDelegate = self
        cell.indexPath = indexPath
        cell.setAsPinned(pinned: comments[indexPath.row].showTopIcon, isDarkMode: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TSDetailCommentTableViewCell else {
            return
        }
        let model = comments[indexPath.row]
        didTapToReplyUser(in: cell, model: model)
    }
}

extension CommentPageController: TSDetailCommentTableViewCellDelegate {
    func repeatTap(cell: TSDetailCommentTableViewCell, commnetModel: FeedCommentListCellModel) {
        
    }
    
    func didSelectName(userId: Int) {
        
    }
    
    func didSelectHeader(userId: Int) {
        
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
        guard TSCurrentUserInfo.share.isLogin else { return }
        guard let userInfo = model.userInfo else { return }
        guard userInfo.isMe() == false else { return }
        self.selectedComment = model
        activeKeyboard()
    }
    
    func needShowError() {
        
    }
}

extension CommentPageController: TSKeyboardToolbarDelegate {
    private func activeKeyboard() {
        guard TSCurrentUserInfo.share.isLogin == true else {
            TSRootViewController.share.guestJoinLandingVC()
            return
        }
        TSKeyboardToolbar.share.keyboardBecomeFirstResponder()
        if let userInfo = self.selectedComment?.userInfo {
            TSKeyboardToolbar.share.keyboardSetPlaceholderText(placeholderText: "reply_with_string".localized + "\(userInfo.name)")
        } else {
            TSKeyboardToolbar.share.keyboardSetPlaceholderText(placeholderText: "rw_placeholder_comment".localized)
        }
    }
    
    func keyboardToolbarSendTextMessage(message: String, bundleId: String?, inputBox: AnyObject?, contentType: CommentContentType) {
        guard TSCurrentUserInfo.share.isLogin, let currentUserInfo = TSCurrentUserInfo.share.userInfo else { return }
        
        self.showLoading()
        //上报动态评论事件
        EventTrackingManager.instance.trackEvent(
            itemId: feedId.stringValue,
            itemType: self.feedItem?.feedType == .miniVideo ? ItemType.shortvideo.rawValue   : ItemType.image.rawValue,
            behaviorType: BehaviorType.comment,
            sceneId: "",
            moduleId: ModuleId.feed.rawValue,
            pageId: PageId.feed.rawValue)
        
        
        TSCommentNetWorkManager.submitComment(for: .momment, content: message, sourceId: feedId, replyUserId: self.selectedComment?.userInfo?.userIdentity, contentType: contentType) { [weak self] (commentModel, msg, status) in
            
            DispatchQueue.main.async {
                defer {
                    self?.selectedComment = nil
                    self?.dismissLoading()
                }
                
                guard let commentModel = commentModel, let feedId = self?.feedId, status == true else {
                    self?.showTopIndicator(status: .faild, msg.orEmpty)
                    return
                }
                
                let model = FeedCommentListCellModel(object: commentModel, feedId: feedId)
                model.replyUserInfo = self?.selectedComment?.userInfo
                model.userId = currentUserInfo.userIdentity
                
                if let lastPinnedIndex = self?.comments.lastIndex(where: { $0.showTopIcon == true }) {
                    self?.comments.insert(model, at: lastPinnedIndex + 1)
                } else {
                    self?.comments.insert(model, at: 0)
                }
                self?.onUpdateSegmentTitle()
                self?.table.removePlaceholderViews()
                self?.table.reloadData()
                self?.table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
    }
    
    func keyboardToolbarDidDismiss() {
        
    }
    
    func keyboardWillHide() {
        //        TSKeyboardToolbar.share.clearCurrentTextOnSend()
        if TSKeyboardToolbar.share.isEmojiSelected() == false {
            TSKeyboardToolbar.share.removeToolBar()
        }
    }
    
    func keyboardToolbarFrame(frame: CGRect, type: keyboardRectChangeType) {
        
    }
}

extension CommentPageController {
    private func reportComment(in cell: TSDetailCommentTableViewCell, model: FeedCommentListCellModel) {
        let reportTarget = ReportTargetModel(feedCommentModel: model)
        let reportVC = ReportViewController(reportTarget: reportTarget)
        let nav = TSNavigationController(rootViewController: reportVC).fullScreenRepresentation
        self.present(nav, animated: true, completion: nil)
    }
    
    private func deleteComment(in cell: TSDetailCommentTableViewCell, comment: FeedCommentListCellModel) {
        guard let commentId = comment.id["commentId"] else {
            return
        }
        TSCommentNetWorkManager.deleteComment(for: .momment, commentId: commentId, sourceId: feedId) { [weak self] (message, status) in
            DispatchQueue.main.async {
                if let indexPath = cell.indexPath, status == true {
                    self?.comments.removeAll(where: { $0.id["commentId"] == commentId })
                    self?.table.reloadData()
                    self?.onUpdateSegmentTitle()
                } else {
                    self?.showError(message: message.orEmpty)
                }
            }
        }
    }
}

extension CommentPageController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard TSCurrentUserInfo.share.isLogin == true else {
            TSRootViewController.share.guestJoinLandingVC()
            return false
        }
        activeKeyboard()
        return false
    }
}

extension CommentPageController: CustomPopListProtocol {
    func customPopList(itemType: TSPopUpItem) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.handlePopUpItemAction(itemType: itemType)
        }
    }
    
    func handlePopUpItemAction(itemType: TSPopUpItem) {
        switch itemType {
        case .reportComment(model: let model):
            guard let cell = model.target as? TSDetailCommentTableViewCell, let feedModel = model.model as? FeedCommentListCellModel else { return }
            DispatchQueue.main.async {
                self.reportComment(in: cell, model: feedModel)
            }
            break
        case .deleteComment(model: let model):
            guard let cell = model.target as? TSDetailCommentTableViewCell, let feedModel = model.model as? FeedCommentListCellModel else { return }
            self.showRLDelete(title: "delete_comment".localized, message: "rw_delete_comment_action_desc".localized, dismissedButtonTitle: "delete".localized, onDismissed: { [weak self] in
                guard let self = self else { return }
                self.deleteComment(in: cell, comment: feedModel)
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
