//
//  NoticeCommentTableVC.swift
//  ThinkSNS +
//
//  Created by lip on 2017/9/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  用户通知收到的At - 控制器

import UIKit
import MJRefresh

class TSAtMeListVCViewController: TSTableViewController, NoticePendingProtocol, TSKeyboardToolbarDelegate {
    // MARK: - property
    var sourceData: [ReceiveCommentModel] = []
    /// 记录当前Y轴坐标
    private var yAxis: CGFloat = 0
    /// 发送评论的 indexPath
    var postCommentIndexPath = IndexPath()
    /// 当前页面
    var page: Int = 1

    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "title_tag_me".localized
        tableView.register(NoticeContentCell.self, forCellReuseIdentifier: "NoticePendingCell")
        tableView.mj_header.beginRefreshing()
        tableView.mj_footer.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TSKeyboardToolbar.share.keyboardstartNotice()
        TSKeyboardToolbar.share.keyboardToolbarDelegate = self
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TSKeyboardToolbar.share.keyboarddisappear()
        TSKeyboardToolbar.share.keyboardStopNotice()
    }

    // MARK: - Delegete
    // MARK: Refresh delegate
    override func refresh() {
        page = 1
        NoticeReceiveInfoNetworkManager.receiveAtMeList(index: page) {[weak self] (models, msg) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.page += 1
            weakSelf.tableView.mj_header.endRefreshing()
            guard let models = models else {
                weakSelf.show(placeholderView: .network)
                weakSelf.page -= 1
                return
            }
            if models.isEmpty {
                weakSelf.show(placeholderView: .empty)
                return
            }
            weakSelf.sourceData = models
            if models.count < TSAppConfig.share.localInfo.limit {
                weakSelf.tableView.mj_footer.isHidden = true
            } else {
                weakSelf.tableView.mj_footer.isHidden = false
            }
            weakSelf.tableView.reloadData()
        }

        /// 清除对应的小红点
        var request = UserNetworkRequest().readCounts
        request.urlPath = request.fullPathWith(replacers: [])
        request.urlPath = request.urlPath + "?type=at"
        RequestNetworkData.share.text(request: request) { (_) in
            // 直接清理本地的数据
            TSCurrentUserInfo.share.unreadCount.at = 0
        }
    }

    // MARK: GTMLoadMoreFooterDelegate
    override func loadMore() {
//        guard self.sourceData.last != nil else {
//            self.tableView.mj_footer.endRefreshingWithNoMoreData()
//            return
//        }
        NoticeReceiveInfoNetworkManager.receiveAtMeList(index: page) {[weak self] (models, msg) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tableView.mj_footer.endRefreshing()
            weakSelf.page += 1
            guard let models = models else {
                weakSelf.page -= 1
                weakSelf.show(placeholderView: .network)
                return
            }
            if models.isEmpty {
                weakSelf.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            } else {
                weakSelf.removePlaceholderViews()
            }
            weakSelf.sourceData += models
            if models.count < TSAppConfig.share.localInfo.limit {
                weakSelf.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
            weakSelf.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sourceData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticePendingCell") as! NoticePendingCell
        var config = sourceData[indexPath.row].convert()
        config.titleInfo = nil
        cell.config = config
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    // MARK: - about post comment
    private func setTSKeyboard(placeholderText: String, cell: UITableViewCell?) {
        if let cell = cell {
            let origin = cell.convert(cell.contentView.frame.origin, to: UIApplication.shared.keyWindow)
            yAxis = origin.y + cell.contentView.frame.size.height
        }
        TSKeyboardToolbar.share.keyboardBecomeFirstResponder()
        TSKeyboardToolbar.share.keyboardSetPlaceholderText(placeholderText: placeholderText)
    }

    // MARK: - 键盘相关代理
    /// 回传字符串和响应对象
    ///
    /// - Parameter message: 回传的String
    func keyboardToolbarSendTextMessage(message: String, bundleId: String?, inputBox: AnyObject?, contentType: CommentContentType) {
        if message == "" {
            return
        }
        let model = sourceData[postCommentIndexPath.row]
        guard let exten = model.exten, let targetId = exten.targetId else {
            assert(false, "被删除数据源的信息,不应该出现键盘信息回调")
            // 数据源被删除,导致无法回复
            return
        }

        let loadingShow = TSIndicatorWindowTop(state: .loading, title: "sending_comment".localized)
        loadingShow.show()
        TSCommentNetWorkManager().send(commentContent: message, replyToUserId: model.userId, feedId: targetId, type: model.sourceType, contentType: contentType) { (_, commentId, _) in
            loadingShow.dismiss()
            if commentId != nil {
                let successShow = TSIndicatorWindowTop(state: .success, title: "comment_success".localized)
                successShow.show()
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                    DispatchQueue.main.async {
                        successShow.dismiss()
                    }
                })
                return
            }

            let faildShow = TSIndicatorWindowTop(state: .faild, title: "comment_fail".localized)
            faildShow.show()
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                DispatchQueue.main.async {
                    faildShow.dismiss()
                }
            })
        }
    }

    /// 回传键盘工具栏的Frame
    ///
    /// - Parameter frame: 坐标和尺寸
    func keyboardToolbarFrame(frame: CGRect, type: keyboardRectChangeType) {
        let toScrollValue = frame.origin.y - yAxis
        if  frame.origin.y > yAxis && self.tableView.contentOffset.y < toScrollValue {
            return
        }

        if Int(frame.origin.y) == Int(yAxis) {
            return
        }

        switch type {
        case .popUp, .typing:
            self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentOffset.y - toScrollValue), animated: false)
            yAxis = frame.origin.y
        default:
            break
        }
    }

    func keyboardWillHide() {
        if TSKeyboardToolbar.share.isEmojiSelected() == false {
            TSKeyboardToolbar.share.removeToolBar()
        }
    }

    // MARK: - did click
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 回复评论
        let model = sourceData[indexPath.row]
        guard model.exten != nil else {
            TSCustomActionsheetView(titles: ["review_content_deleted".localized]).show()
            return
        }
        TSKeyboardToolbar.share.keyboarddisappear()
        let cell = tableView.cellForRow(at: indexPath) as? NoticePendingCell
        postCommentIndexPath = indexPath
        setTSKeyboard(placeholderText: "reply_with_string".localized + "\(model.user?.name)", cell: cell)
    }

    func notice(pendingCell: NoticePendingCell, didClickRegion: NoticePendingCellClickRegion) {
        let model = sourceData[pendingCell.indexPath.row]
        switch didClickRegion {
        case .avatar, .title:
//            let userHomPage = HomePageViewController(userId: model.userId)
//            navigationController?.pushViewController(userHomPage, animated: true)
            break
        case .subTitle:
            if let otherUserId = model.replyUserId {
//                let userHomPage = HomePageViewController(userId: otherUserId)
//                navigationController?.pushViewController(userHomPage, animated: true)
                return
            }
            assert(false, "点击了回复用户,但是数据源没有回复用户")
        case .content:
            self.tableView(tableView, didSelectRowAt: pendingCell.indexPath)
        case .pending:
            break // 该页面没有使用这个区域.不应该出现该类型回调
        case .exten:
            didClickExtenRegion(model)
        }
    }

    private func didClickExtenRegion(_ model: ReceiveCommentModel) {
        guard  let exten = model.exten, let targetId = exten.targetId else {
            assert(false, "点击了页面的扩展区域,但是查询到的数据没有扩展数据")
            return
        }
        switch model.sourceType {
        case .feed:
            let detailVC = FeedInfoDetailViewController(feedId: targetId, onToolbarUpdated: nil)
            navigationController?.pushViewController(detailVC, animated: true)
        case .song:
            break
//            let commentVC = TSMusicCommentVC(musicType: .song, sourceId: targetId)
//            navigationController?.pushViewController(commentVC, animated: true)
        case .musicAlbum:
            break
//            let commentVC = TSMusicCommentVC(musicType: .album, sourceId: targetId)
//            navigationController?.pushViewController(commentVC, animated: true)
        case .reject:
            break
        default:
            break
        }
    }
}
