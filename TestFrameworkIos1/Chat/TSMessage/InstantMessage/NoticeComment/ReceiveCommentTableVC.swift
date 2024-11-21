//
//  NoticeCommentTableVC.swift
//  ThinkSNS +
//
//  Created by lip on 2017/9/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  用户通知收到的评论 - 控制器

import UIKit
import MJRefresh

class ReceiveCommentTableVC: TSViewController, TSKeyboardToolbarDelegate {
    
    // MARK: - property
    var sourceData: [ReceiveCommentModel] = []
    /// 记录当前Y轴坐标
    private var yAxis: CGFloat = 0
    /// 发送评论的 indexPath
    var postCommentIndexPath = IndexPath()
    /// 翻页
    var page = 1
    let limit: Int = 15

    lazy var tableView: TSTableView = {
        let table = TSTableView(bgColor: .white)
        //table.register(NoticeContentCell.self, forCellReuseIdentifier: "NoticePendingCell")
        table.register(RLNotificationsCell.self, forCellReuseIdentifier: RLNotificationsCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        
        return table
    }()
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCloseButton(backImage: true, titleStr: "menu_notification".localized)
        //self.setLeftNavTitle(titleStr: "menu_notification".localized)
   
        view.addSubview(tableView)
        tableView.bindToEdges()
        
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_header.beginRefreshing()
        tableView.mj_footer.isHidden = true
        tableView.separatorColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name(rawValue: "RefreshRemarkName"), object: nil)
        TSKeyboardToolbar.share.theme = .white
        TSKeyboardToolbar.share.setStickerNightMode(isNight: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
    @objc func refresh() {
        /// 清除对应的小红点
        var request = UserNetworkRequest().readCounts
        request.urlPath = request.fullPathWith(replacers: [])
        request.urlPath = request.urlPath + "?type=new_comment"
        RequestNetworkData.share.text(request: request) { (_) in
            // 直接清理本地的数据
            TSCurrentUserInfo.share.unreadCount.comments = 0
            TSCurrentUserInfo.share.unreadCount.at = 0
            TSCurrentUserInfo.share.unreadCount.reject = 0
            TSCurrentUserInfo.share.unreadCount.system = 0
            TSCurrentUserInfo.share.unreadCount.follows = 0
            TSCurrentUserInfo.share.unreadCount.like = 0
            DispatchQueue.main.async{
                //刷新tabbar 未读红点次数
                NotificationCenter.default.post(name: NSNotification.Name.DashBoard.reloadNotificationBadge, object: nil)
            }
        }
        page = 1
        NoticeReceiveInfoNetworkManager.receiveCommentList(limit: limit, after: page) { [weak self] models, originModels, _ in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tableView.mj_header.endRefreshing()
            weakSelf.tableView.removePlaceholderViews()
            weakSelf.tableView.mj_footer.isHidden = false
            weakSelf.page += 1
            guard let models = models , let originModels = originModels else {
                weakSelf.page -= 1
                weakSelf.tableView.show(placeholderView: .network)
                return
            }
            if models.isEmpty {
                weakSelf.tableView.show(placeholderView: .empty)
                return
            }
            weakSelf.sourceData = models
            if originModels.count < weakSelf.limit {
                weakSelf.tableView.mj_footer.endRefreshingWithNoMoreData()
            }else {
                weakSelf.tableView.mj_footer.endRefreshing()
            }
            weakSelf.tableView.reloadData()
        }
    }

    // MARK: GTMLoadMoreFooterDelegate
    @objc func loadMore() {
        guard let _ = self.sourceData.last else {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
            return
        }
        
        NoticeReceiveInfoNetworkManager.receiveCommentList(limit: limit, after: page) { [weak self] models, originModels, _ in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tableView.mj_footer.endRefreshing()
            weakSelf.page += 1
            guard let models = models, let originModels = originModels else {
                weakSelf.page -= 1
                weakSelf.tableView.show(placeholderView: .network)
                return
            }
            if models.isEmpty {
                weakSelf.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            } else {
                weakSelf.tableView.removePlaceholderViews()
            }
            weakSelf.sourceData += models
            if originModels.count < weakSelf.limit {
                weakSelf.tableView.mj_footer.endRefreshingWithNoMoreData()
            }else {
                weakSelf.tableView.mj_footer.endRefreshing()
            }
            weakSelf.tableView.reloadData()
        }
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
}

extension ReceiveCommentTableVC: RLNotificationsCellDelegate{
    func noticeClick(notificationsCell: RLNotificationsCell, type: RLNotificationsCellClickType, indexPath: IndexPath) {
        let model = sourceData[indexPath.row]
        guard  let exten = model.exten, let targetId = exten.targetId else {
            TSCustomActionsheetView(titles: ["review_content_deleted".localized]).show()
            return
        }
        switch type {
        case .detail://查询详情
            self.navigateToSingleDetail(targetId)
        case .reply: //回复
            if let username = model.user?.name {
                TSKeyboardToolbar.share.keyboarddisappear()
                let cell = tableView.cellForRow(at: indexPath) as? NoticePendingCell
                postCommentIndexPath = indexPath
                setTSKeyboard(placeholderText: "reply_with_string".localized + "\(username)", cell: cell)
            }
        case .view: //查看拒绝的动态
            let vc = TSRejectedDetailController(feedId: targetId.stringValue)
            vc.onDelete = {
                self.tableView.mj_header.beginRefreshing()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    //关注用户
    func followClick(notificationsCell: RLNotificationsCell, indexPath: IndexPath) {
        if let model = sourceData[safe: indexPath.row], var user = model.user {
            user.updateFollow {[weak self] success in
                guard let self = self else { return }
                model.user = user
                self.sourceData[indexPath.row] = model
                DispatchQueue.main.async{
                    self.tableView.reloadRow(at: indexPath, with: .none)
                }
            }
        }
    }
}

extension ReceiveCommentTableVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sourceData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RLNotificationsCell.identifier, for: indexPath) as! RLNotificationsCell
        cell.selectionStyle = .none
        cell.indexPath = indexPath
        cell.delegate = self
        cell.setNoticeData(data: sourceData[indexPath.row])
        return cell
    }
    
    // MARK: - did click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = sourceData[indexPath.row]
        if (model.sortType == .system && model.systemType != "feeds") || model.sortType == .follow {
            return
        }
        
        guard  let exten = model.exten, let targetId = exten.targetId else {
            TSCustomActionsheetView(titles: ["review_content_deleted".localized]).show()
            return
        }
        
        if model.sourceType == .reject {
            let vc = TSRejectedDetailController(feedId: targetId.stringValue)
            vc.onDelete = {
                self.tableView.mj_header.beginRefreshing()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.navigateToSingleDetail(targetId)
        }
    }
}
