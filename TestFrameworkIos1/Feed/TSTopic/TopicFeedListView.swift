//
//  TopicFeedListView.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/30.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

import ObjectMapper
//
//protocol TopicFeedListViewDelegate: class {
//    func didClickVideoCell(_ feedListView: TopicFeedListView, cellIndexPath: IndexPath, fatherViewTag: Int)
//    /// 当tableView 滑动停止后如果屏幕上出现了可以播放视频的cell
//    func canPlayVideoCell(_ feedListView: TopicFeedListView, indexPath: IndexPath)
//}
//
//class TopicFeedListView: FeedListView {
//    
//    weak var feedListViewDelegate: TopicFeedListViewDelegate?
//    var playIngCellIndexPath: IndexPath?
//    /// 创建新评论需要用到的信息
//    ///
//    /// - (feedIndexPath, feedId, replyId, replyName)
//    var newCommentInfo: (IndexPath, Int, Int?, String?)?
//    /// 评论编辑弹框需要用的属性（大概是这样）
//    var yAxis: CGFloat = 0
//    /// 置顶数据条数
//    var pinnedCounts: Int = 0
//    // 如果是个人主页的时候使用，使用在举报信息中
//    var homePageUserName: String = ""
//    
//    override func setUI() {
//        super.setUI()
//        interactDelegate = self
//        // 自动刷新
//        mj_header.beginRefreshing()
//    }
//    
//    override func processRefresh(data: [FeedListCellModel]?, message: String?, status: Bool) {
//        // 1.隐藏指示器
//        dismissIndicatorA()
//        if mj_header != nil {
//            if mj_header.isRefreshing {
//                mj_header.endRefreshing()
//            }
//        }
//        mj_footer.resetNoMoreData()
//        // 2.获取数据失败，显示占位图或者 A 指示器
//        if let message = message {
//            datas.isEmpty ? show(placeholderView: .network) : show(indicatorA: message)
//            return
//        }
//        // 3.获取数据成功，更新数据
//        guard let newDatas = data else {
//            return
//        }
//        datas = newDatas
//        // 如果数据为空，显示占位图
//        if datas.isEmpty {
//            show(placeholderView: .empty)
//        }
//        // 刷新界面
//        reloadData()
//        if let findCellIndexPath = self.getPlayVideoInVisiableCellIndexPath() {
//            self.feedListViewDelegate?.canPlayVideoCell(self, indexPath: findCellIndexPath)
//        }
//    }
//    
//    func getPlayVideoInVisiableCellIndexPath() -> IndexPath? {
//        let visiableCells = self.visibleCells
//        var canPlayCell: FeedListCell? = nil
//        var spac: CGFloat = CGFloat.greatestFiniteMagnitude
//        for cell in visiableCells {
//            guard let cell = cell as? FeedListCell, let cellIndexPath = self.indexPath(for: cell) else {
//                return nil
//            }
//            let model = self.datas[cellIndexPath.row]
//            if model.videoURL.count > 0 {
//                if let cellCenter = cell.superview?.convert(cell.center, to: nil) {
//                    // 如果中心点的y轴坐标不在屏幕内的话就不算
//                    if cellCenter.y < 44.0 || cellCenter.y > UIScreen.main.bounds.height - 40 {
//                    } else {
//                        let cellSpac = abs(cellCenter.y - UIScreen.main.bounds.height / 2)
//                        if cellSpac < spac {
//                            spac = cellSpac
//                            canPlayCell = cell
//                        }
//                    }
//                }
//            }
//        }
//        if let canPlayCell = canPlayCell {
//            return self.indexPath(for: canPlayCell)
//        }
//        return nil
//    }
//    //
//    //    func handleScrollStop() {
//    //        guard let findCellIndexPath = self.getPlayVideoInVisiableCellIndexPath() else {
//    //            return
//    //        }
//    //        if self.playIngCellIndexPath != findCellIndexPath {
//    //            self.playIngCellIndexPath = findCellIndexPath
//    //            self.feedListViewDelegate?.canPlayVideoCell(self, indexPath: findCellIndexPath)
//    //        }
//    //    }
//}
//
////extension TopicFeedListView {
////    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
////        super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
////        if decelerate == false {
////            self.handleScrollStop()
////        }
////    }
////    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
////        super.scrollViewDidEndDecelerating(scrollView)
////        self.handleScrollStop()
////    }
////}
//
//// MARK: - FeedListViewDelegate: 用户交互事件代理
//extension TopicFeedListView: FeedListViewDelegate {
//    /// 点击了Follow按钮
//    func feedList(_ view: FeedListView, didSelected cell: FeedListCell, didClickFollow userId: Int) {
//        // 发起网络请求
//        TSDataQueueManager.share.moment.start(follow: userId, isFollow: true)
//        // 刷新界面
//        for (index, model) in datas.enumerated() {
//            if model.userId == userId {
//                updateUserLocalFollowStatus(model: model.userInfo)
//                datas[index].userInfo?.follower = true
//                let indexPath = IndexPath(row: index, section: 0)
//                reloadRow(at: indexPath, with: UITableView.RowAnimation.none)
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil, userInfo: ["follow": "1","userid": "\(userId)"])
//            }
//        }
//    }
//    
//    func updateUserLocalFollowStatus(model: UserInfoModel?) {
//        if let model = model {
//            if let userExtra = model.extra {
//                userExtra.followersCount = userExtra.followersCount + 1
//                model.extra = userExtra
//            } else {
//                let extraStr = """
//                {
//                "user_id": \(model.userIdentity),"followers_count": 1,
//                }
//                """
//                let extra = Mapper<TSUserExtraModel>().map(JSONString: extraStr)
//                model.extra = extra
//            }
//            
//            DatabaseUser().saveUserInfo(model)
//        }
//    }
//    
//    /// 点击了动态 cell
//    func feedList(_ view: FeedListView, didSelected cell: FeedListCell, onSeeAllButton: Bool) {
//        // 如果是游客模式，触发登录注册操作
//        if TSCurrentUserInfo.share.isLogin == false {
//            TSRootViewController.share.guestJoinLandingVC()
//            return
//        }
//        TSKeyboardToolbar.share.keyboarddisappear()
//        let indexPath = view.indexPath(for: cell)!
//        let model = cell.model
//        switch model.id {
//        // 1.如果是广告，跳转广告页面
//        case .advert(_, let link):
//            TSAdvertTaskQueue.showDetailVC(urlString: link)
//        // 2.如果是动态，跳转动态详情页
//        case .feed(let feedId):
//        // 如果点的是进行中的直播
//        func getLiveModel(_ feedId: Int) {
//            self.parentViewController?.navigationController?.loadingOverlay()
//            TSMomentNetworkManager.getOneMoment(feedId: feedId) { [unowned self] (object, error, _, _) in
//                DispatchQueue.main.async {
//                    self.parentViewController?.navigationController?.endLoading()
//                    
//                    if let object = object, let liveModel = object.liveModel, liveModel.status != YPLiveStatus.finishProcess.rawValue {
//                        let vc = YippiLivePlayerViewController(feedId: feedId, entry: .moment(object: object)).fullScreenRepresentation
//                        self.parentViewController?.navigationController?.present(vc, animated: true, completion: nil)
//                    } else {
//                        self.parentViewController?.navigationController?.pushToFeedDetail(feedId: feedId, sendStatus: (model.sendStatus == .success), isTapMore: onSeeAllButton, isClickCommentButton: false)
//                    }
//                }
//            }
//        }
//        if let sharedModel = model.sharedModel, let attachment = sharedModel.customAttachment, sharedModel.type == .live {
//            // 如果是游客模式，触发登录注册操作
//                  if TSCurrentUserInfo.share.isLogin == false {
//                      TSRootViewController.share.guestJoinLandingVC()
//                      return
//                  }
//            getLiveModel(attachment.attachId)
//        } else if let liveModel = model.liveModel, liveModel.status != YPLiveStatus.finishProcess.rawValue {
//            // 如果是游客模式，触发登录注册操作
//                  if TSCurrentUserInfo.share.isLogin == false {
//                      TSRootViewController.share.guestJoinLandingVC()
//                      return
//                  }
//            getLiveModel(feedId)
//        }  else {
//            self.parentViewController?.navigationController?.pushToFeedDetail(feedId: feedId, sendStatus: (model.sendStatus == .success), isTapMore: onSeeAllButton, isClickCommentButton: false)
//        }
//        default:
//            break
//        }
//    }
//    
//    /// 点击了图片
//    /// TODO: clean up this on refactor
//    func feedList(_ view: FeedListView, didSelected cell: FeedListCell, on pictureView: PicturesTrellisView, withPictureIndex index: Int) {
//        let indexPath = view.indexPath(for: cell)!
//        let model = view.datas[indexPath.row]
//        // 如果点的是进行中的直播
//        if let liveModel = model.liveModel, liveModel.status != YPLiveStatus.finishProcess.rawValue {
//            // 如果是游客模式，触发登录注册操作
//                  if TSCurrentUserInfo.share.isLogin == false {
//                      TSRootViewController.share.guestJoinLandingVC()
//                      return
//                  }
//
//            self.parentViewController?.navigationController?.loadingOverlay()
//            
//            let feedId = model.id["feedId"] ?? -1
//            self.parentViewController?.navigationController?.navigateLive(feedId: feedId, sendStatus: (model.sendStatus == .success))
//            return
//        }
//        // 如果点的是以一张且目前的Cell内加载的数据是视频数据,那么就通知不同的代理,传递视频需要的数据
//        
//        if index == 0 && (model.videoURL.count > 0 || model.localVideoFileURL != nil) {
//            guard let feedId = view.datas[indexPath.row].id["feedId"] else { return }
//            self.parentViewController?.navigationController?.pushToFeedDetail(feedId: feedId, sendStatus: (model.sendStatus == .success), isTapMore: true, isClickCommentButton: false)
//            return
//        }
//        // 1.如果是游客模式，触发登录注册操作
//        if TSCurrentUserInfo.share.isLogin == false {
//            TSRootViewController.share.guestJoinLandingVC()
//            return
//        }
//        
//        TSKeyboardToolbar.share.keyboarddisappear()
//        // 解析一下图片的数据
//        let imageModels = pictureView.models
//        let imageModel = imageModels[index]
//        
//        // 3.如果以上情况都没有发生，就跳转图片查看器
//        let imageFrames = pictureView.frames
//        let images = pictureView.pictures
//        let imageObjects = imageModels.map { $0.imageObject() }
//        let picturePreview = TSPicturePreviewVC(objects: Array(imageObjects), imageFrames: imageFrames, images: images, At: index)
//        picturePreview.show()
//        
//    }
//    
//    /// 点击了工具栏
//    func feedList(_ view: FeedListView, didSelected cell: FeedListCell, on toolbar: TSToolbarView, withToolbarButtonIndex index: Int) {
//        let feedIndexPath = view.indexPath(for: cell)!
//        let model = cell.model
//        // 如果是游客模式，触发登录注册操作
//        if TSCurrentUserInfo.share.isLogin == false && index != 3 {
//            TSRootViewController.share.guestJoinLandingVC()
//            return
//        }
//        
//        guard let feedId = model.id["feedId"], let toolModel = model.toolModel else {
//            return
//        }
//        // 点赞
//        if index == 0, model.sendStatus == .success {
//            // 发起网络请求
//            TSDataQueueManager.share.moment.start(digg: feedId, isDigg: !toolModel.isDigg)
//            // 刷新界面
//            model.toolModel?.isDigg = !toolModel.isDigg
//            let diggCount = toolModel.diggCount
//            model.toolModel?.diggCount = toolModel.isDigg ? diggCount + 1 : diggCount - 1
//            model.isPlaying = true
//            cell.model = model
//            model.isPlaying = false
//            NotificationCenter.default.post(name: NSNotification.Name.Moment.update, object: nil, userInfo: ["feedId": feedId, "isDigg": model.toolModel?.isDigg ?? 0])
//        }
//        // 评论
//        if index == 1, model.sendStatus == .success {
//            // 记录点击的位置信息
//            newCommentInfo = (feedIndexPath, feedId, nil, nil)
//            self.parentViewController?.navigationController?.pushToFeedDetail(feedId: feedId, sendStatus: (model.sendStatus == .success), isTapMore: false, isClickCommentButton: true)
//        }
//        if index == 2, model.sendStatus == .success {
//            if model.userId == CurrentUserSessionInfo?.userIdentity {
//                let alert = TSAlertController(title: "text_tips".localized, message: "feed_detail_cnt_reward_own".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
//                self.parentViewController?.present(alert, animated: true, completion: nil)
//                return
//            }
//            self.parentViewController?.presentTipping(target: feedId, type: .moment, onSuccess: { [weak self] sourceId, _ in
//                self?.datas.enumerated().forEach { index, model in
//                    if model.id["feedId"] == (sourceId as? Int) {
//                        self?.datas[index].toolModel?.rewardCount += 1
//                        self?.datas[index].toolModel?.isRewarded = true
//                        self?.reloadRow(at: IndexPath(row: index, section: 0), with: .none)
//                        self?.tableHeaderView?.reloadInputViews()
//                        NotificationCenter.default.post(name: NSNotification.Name.Moment.update, object: nil, userInfo: ["feedId": sourceId, "has_reward": true])
//                        NotificationCenter.default.post(name: NSNotification.Name.Moment.update, object: nil, userInfo: ["feedId": sourceId, "rewardCount": self?.datas[index].toolModel?.rewardCount ?? 0])
//                    }
//                }
//            })
//        }
//        if index == 3 {
//            if model.sendStatus == .success {
//                let messageModel = TSmessagePopModel(momentModel: model)
//                // 当分享内容为空时，显示默认内容
//                var image = (cell.feedContentView.pictureView.pictures.first ?? nil) ?? UIImage.set_image(named: "IMG_icon")
//                if cell.feedContentView.pictureView.isHidden {
//                    image = UIImage.set_image(named: "IMG_icon")
//                }
//                let title = TSAppSettingInfoModel().appDisplayName + " " + "post".localized
//                var defaultContent = "default_share_content".localized
//                defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
//                let description = model.content.isEmpty ? defaultContent : model.content
//                guard let isDisabledCommentFeed = model.toolModel?.isCommentDisabled, let isCollect = model.toolModel?.isCollect else {
//                    view.show(indicatorA: "please_retry_option".localized, timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
//                    return
//                }
//                if model.userId == CurrentUserSessionInfo?.userIdentity {
//                    let shareView = ShareListView(isMineSend: true, isCollection: isCollect, isDisabledCommentFeed: isDisabledCommentFeed, isEdited: model.isEdited, shareType: ShareListType.topicFeedList)
//                    shareView.delegate = self
//                    shareView.messageModel = messageModel
//                    shareView.feedIndex = feedIndexPath
//                    shareView.show(URLString: ShareURL.feed.rawValue + "\(feedId)", image: image, description: description, title: title)
//                } else {
//                    let shareView = ShareListView(isMineSend: false, isCollection: isCollect, isDisabledCommentFeed: isDisabledCommentFeed, isEdited: model.isEdited, shareType: ShareListType.topicFeedList)
//                    shareView.delegate = self
//                    shareView.messageModel = messageModel
//                    shareView.feedIndex = feedIndexPath
//                    shareView.show(URLString: ShareURL.feed.rawValue + "\(feedId)", image: image, description: description, title: title)
//                }
//            } else {
//                if model.userId == CurrentUserSessionInfo?.userIdentity {
//                    // 显示弹窗
//                    let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
//                    // 添加删除动态选项
//                    alert.addAction(deleteFeedAction(feedId: feedId, feedIndexPath: feedIndexPath))
//                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
//                }
//            }
//        }
//    }
//    
//    /// 点击了评论行
//    func feedList(_ view: FeedListView, didSelected cell: FeedListCell, on commentView: FeedCommentListView, withCommentIndexPath commentIndexPath: IndexPath) {
//        let feedIndexPath = view.indexPath(for: cell)!
//        
//        // 如果是游客模式，触发登录注册操作
//        if TSCurrentUserInfo.share.isLogin == false {
//            TSRootViewController.share.guestJoinLandingVC()
//            return
//        }
//        
//        // 获取评论信息
//        let model = commentView.datas[commentIndexPath.row]
//        guard let feedId = model.id["feedId"], let commentId = model.id["commentId"] else {
//            return
//        }
//        // 1.如果是当前用户自己的评论，则显示弹窗
//        if model.userId == CurrentUserSessionInfo?.userIdentity {
//            let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
//            // 2.如果是发送成功的评论，添加置顶选项
//            // Hide - YP-3830
//            //            if model.sendStatus == .success {
//            //                alert.addAction(topCommentAction(commentId: commentId, feedId: feedId))
//            //            }
//            // 1.添加删除选项
//            alert.addAction(deleteCommetAction(commentId: commentId, feedId: feedId, commentIndexPath: commentIndexPath, feedIndexPath: feedIndexPath))
//            // 3.如果是发送失败的评论，添加重新发送选项
//            if model.sendStatus == .faild {
//                alert.addAction(submitCommetAction(feedIndexPath: feedIndexPath, commentIndexPath: commentIndexPath))
//            }
//            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
//            return
//        }
//        // 4.如果点击了别人的评论，显示评论编辑
//        // 记录点击的位置信息
//        newCommentInfo = (feedIndexPath, feedId, model.userId, model.name)
//        setTSKeyboard(placeholderText: "reply_with_string".localized + "\(model.name)", feedCell: cell)
//    }
//    /// 长按了评论行
//    func feedList(_ view: FeedListView, didLongPress cell: FeedListCell, on commentView: FeedCommentListView, withCommentIndexPath commentIndexPath: IndexPath) {
//        guard let feedIndexPath = view.indexPath(for: cell) else {
//            return
//        }
//        self.informCommentAction(feedIndexPath: feedIndexPath, commentIndexPath: commentIndexPath)
//    }
//    
//    /// 点击了评论内容中的用户名
//    func feedList(_ view: FeedListView, didSelected cell: FeedListCell, didSelectedComment commentCell: FeedCommentListCell, onUser userId: Int) {
//        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": userId])
//    }
//    
//    /// 点击了动态重发动态按钮
//    func feedList(_ view: FeedListView, didSelectedResendButton cell: FeedListCell) {
//        let feedIndexPath = view.indexPath(for: cell)!
//        let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
//        alert.addAction(resendFeedAction(feedIndexPath: feedIndexPath))
//        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
//    }
//    
//    /// 点击了话题板块儿
//    func feedListDidClickTopic(_ view: FeedListView, topicId: Int) {
//        let topicVC = TopicPostListVC(groupId: topicId)
//        parentViewController?.navigationController?.pushViewController(topicVC, animated: true)
//    }
//    
//    func feedListDidClickLocation(_ view: FeedListView, locationID: String, locationName:String) {
//        let locationVC = TSLocationDetailVC(locationID: locationID, locationName:locationName)
//        parentViewController?.navigationController?.pushViewController(locationVC, animated: true)
//    }
//}
//
//extension TopicFeedListView: TSKeyboardToolbarDelegate {
//    
//    /// 键盘准备收起（emmmm....，旧代码中这个方法是空着的）
//    func keyboardWillHide() {
//    }
//    
//    /// 点了评论编辑上发送按钮
//    func keyboardToolbarSendTextMessage(message: String, bundleId: String?, inputBox: AnyObject?, contentType: CommentContentType) {
//        // 0.处理解析新评论的数据
//        guard let (feedIndexPath, feedId, replyId, replyName) = newCommentInfo, !message.isEmpty else {
//            return
//        }
//        // 1.创建新评论的数据模型
//        let newCommentModel = FeedCommentListCellModel(feedId: feedId, content: message, replyId: replyId, replyName: replyName, contentType: contentType)
//        // 2.将新评论显示在列表上
//        // 插入到置顶内容下一条
//        var pinnedCounts: Int = 0
//        for item in datas[feedIndexPath.row].comments {
//            if item.showTopIcon == true {
//                pinnedCounts += 1
//            }
//        }
//        datas[feedIndexPath.row].comments.insert(newCommentModel, at: pinnedCounts)
//        datas[feedIndexPath.row].toolModel?.commentCount += 1
//        if let cell = self.cellForRow(at: feedIndexPath) as? FeedListCell {
//            datas[feedIndexPath.row].isPlaying = true
//            self.beginUpdates()
//            cell.model = datas[feedIndexPath.row]
//            self.endUpdates()
//            datas[feedIndexPath.row].isPlaying = false
//        }
//        // 3.发起网络请求提交新评论
//        let commentIndexPath = IndexPath(row: pinnedCounts, section: 0 )
//        submitCommet(atFeedIndexPath: feedIndexPath, commentIndexPath: commentIndexPath)
//    }
//    
//    /// 回传键盘工具栏的Frame（ctrl+v 旧代码）
//    func keyboardToolbarFrame(frame: CGRect, type: keyboardRectChangeType) {
//        let toScrollValue = frame.origin.y - yAxis
//        if  frame.origin.y > yAxis && contentOffset.y < toScrollValue {
//            return
//        }
//        if Int(frame.origin.y) == Int(yAxis) {
//            return
//        }
//        switch type {
//        case .popUp, .typing:
//            setContentOffset(CGPoint(x: 0, y: contentOffset.y - toScrollValue), animated: false)
//            yAxis = frame.origin.y
//        default:
//            break
//        }
//    }
//}
//
//// MARK: - 动态列表相关操作
//extension TopicFeedListView {
//    /// 提交某条评论
//    func submitCommet(atFeedIndexPath feedIndexPath: IndexPath, commentIndexPath: IndexPath) {
//        // 1.获取评论 model
//        let commentModel = datas[feedIndexPath.row].comments[commentIndexPath.row]
//        // 2.切换评论的状态为正在发送中
//        commentModel.sendStatus = .sending
//        // 3.获取网络请求相关参数
//        let content = commentModel.content
//        guard let feedId = commentModel.id["feedId"] else {
//            return
//        }
//        var replyId: Int?
//        switch commentModel.type {
//        case .user(_, let replyUserId):
//            replyId = replyUserId
//        default:
//            break
//        }
//        // 4.发起网络请求
//        TSCommentTaskQueue.submitComment(for: .momment, content: content, sourceId: feedId, replyUserId: replyId, contentType: commentModel.contentType) { [weak self] (model: TSCommentModel?, faildModel: TSFailedCommentModel?, _, _) in
//            guard let `self` = self else {
//                return
//            }
//            // 5.如果评论成功，更新列表中的 newCommentModel 的信息
//            if let model = model {
//                commentModel.id = .feed(feedId: feedId, commentId: model.id)
//                commentModel.sendStatus = .success
//            }
//            // 6.评论失败，更新列表中的 newCommentModel 的信息
//            if let faildModel = faildModel {
//                commentModel.id = .feed(feedId: feedId, commentId: faildModel.id)
//                commentModel.sendStatus = .faild
//                if let cell = self.cellForRow(at: feedIndexPath) as? FeedListCell {
//                    self.datas[feedIndexPath.row].isPlaying = true
//                    self.beginUpdates()
//                    cell.model = self.datas[feedIndexPath.row]
//                    self.endUpdates()
//                    self.datas[feedIndexPath.row].isPlaying = false
//                }
//            }
//        }
//    }
//    
//    /// 设置键盘
//    ///
//    /// - Parameters:
//    ///   - placeholderText: 占位字符串
//    ///   - cell: cell
//        fileprivate func setTSKeyboard(placeholderText: String, feedCell: FeedListCell) {
//            let origin = feedCell.convert(feedCell.feedContentView.bottomStackView.frame.origin, to: UIApplication.shared.keyWindow)
//            yAxis = origin.y
//            TSKeyboardToolbar.share.keyboardToolbarDelegate = self
//            TSKeyboardToolbar.share.keyboardBecomeFirstResponder()
//            TSKeyboardToolbar.share.keyboardSetPlaceholderText(placeholderText: placeholderText)
//        }
//}
//
//// MARK: - 弹窗操作选项
//extension TopicFeedListView {
//    // MARK: 动态
//    /// 重发动态 alert action
//    func resendFeedAction(feedIndexPath: IndexPath) -> TSAlertAction {
//        // 1.解析数据
//        let model = datas[feedIndexPath.row]
//        // 2.创建 action
//        let action = TSAlertAction(title:"resend".localized, style: TSAlertSheetActionStyle.default, handler: { [weak self] (_) in
//            guard let `self` = self else {
//                return
//            }
//            // 刷新界面
//            model.sendStatus = .sending
//            if let cell = self.cellForRow(at: feedIndexPath) as? FeedListCell {
//                self.datas[feedIndexPath.row].isPlaying = true
//                self.beginUpdates()
//                cell.model = self.datas[feedIndexPath.row]
//                self.endUpdates()
//                self.datas[feedIndexPath.row].isPlaying = false
//            }
//            // 获取发送失败的动态
//            guard let feedId = model.id["feedId"], let feedObject = TSDatabaseMoment().getList(feedId) else {
//                return
//            }
//            
//            do {
//                
//                let realm = FeedIMSDKManager.shared.param.realm!
//                
//                try realm.safeWrite {
//                    feedObject.sendState = 0
//                    feedObject.feedIdentity = TSCurrentUserInfo.share.createResourceID()
//                }
//            } catch let err { handleException(err) }
//            
//            if feedObject.shortVideoOutputUrl != nil {
//                TSDataQueueManager.share.moment.uploadVideo(momentListObject: feedObject, oldId: feedId, isTopicPublish: true)
//            } else {
//                // 重发动态
//                TSDataQueueManager.share.moment.releasePulseImages(momentListObject: feedObject, isTopicPublish: true)
//            }
//        })
//        return action
//    }
//    
//    
//    /// 删除动态 alert action
//    func deleteFeedAction(feedId: Int, feedIndexPath: IndexPath) -> TSAlertAction {
//        let action = TSAlertAction(title: "choice_remove_status".localized, style: TSAlertSheetActionStyle.default, handler: { [weak self] (_) in
//            self?.showFeedDeleteConfirmAlert(feedId: feedId, feedIndexPath: feedIndexPath)
//        })
//        return action
//    }
//    
//    /// 显示删除动态的二次确认弹窗
//    fileprivate func showFeedDeleteConfirmAlert(feedId: Int, feedIndexPath: IndexPath) -> Void {
//        let alertVC = TSAlertController.deleteConfirmAlert(deleteActionTitle: "delete_feed".localized) {
//            self.deleteFeed(feedId: feedId, feedIndexPath: feedIndexPath)
//        }
//        UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: false, completion: nil)
//    }
//    /// 删除动态
//    fileprivate func deleteFeed(feedId: Int, feedIndexPath: IndexPath) -> Void {
//        let sendStatus = datas[feedIndexPath.row].sendStatus
//        if sendStatus != .success {
//            // 1.如果是发送失败的动态
//            DatabaseManager().moment.delete(moment: feedId)
//        } else {
//            // 2.如果是发送成功的动态
//            TSDataQueueManager.share.moment.start(delete: feedId)
//        }
//        /// 刷新列表
//        self.datas.remove(at: feedIndexPath.row)
//        self.reloadData()
//    }
//    
//    /// 举报动态 alert action
//    func informFeedAction(feedIndexPath: IndexPath) {
//        let cellModel = datas[feedIndexPath.row]
//        let informModel = ReportTargetModel(feedModel: cellModel)!
//        let informVC = ReportViewController(reportTarget: informModel)
//        if #available(iOS 11, *) {
//            self.parentViewController?.navigationController?.pushViewController(informVC, animated: true)
//        } else {
//            self.parentViewController?.present(TSNavigationController(rootViewController: informVC).fullScreenRepresentation,
//                                               animated: true,
//                                               completion: nil)
//        }
//    }
//    
//    // MARK: 评论
//    /// 举报评论 alert action
//    func informCommentAction(feedIndexPath: IndexPath, commentIndexPath: IndexPath) {
//        let commentModel = datas[feedIndexPath.row].comments[commentIndexPath.row]
//        let informModel = ReportTargetModel(feedCommentModel: commentModel)
//        //如果时候自己的评论，弹出置顶申请弹窗
//        if commentModel.userId == CurrentUserSessionInfo?.userIdentity {
//            let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
//            let feedID = commentModel.id["feedId"]
//            let commentID = commentModel.id["commentId"]
//            // Hide - YP-3830
//            //            alert.addAction(topCommentAction(commentId: commentID!, feedId: feedID!))
//            alert.addAction(deleteCommetAction(commentId: commentID!, feedId: feedID!, commentIndexPath: commentIndexPath, feedIndexPath: feedIndexPath))
//            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
//            return
//        }
//        
//        let informVC = ReportViewController(reportTarget: informModel)
//        if #available(iOS 11, *) {
//            self.parentViewController?.navigationController?.pushViewController(informVC, animated: true)
//        } else {
//            self.parentViewController?.present(TSNavigationController(rootViewController: informVC).fullScreenRepresentation,
//                                               animated: true,
//                                               completion: nil)
//        }
//    }
//    
//    /// 重发评论 alert action
//    func submitCommetAction(feedIndexPath: IndexPath, commentIndexPath: IndexPath) -> TSAlertAction {
//        let action = TSAlertAction(title: "resend".localized, style: TSAlertSheetActionStyle.default) { [weak self] (_) in
//            self?.submitCommet(atFeedIndexPath: feedIndexPath, commentIndexPath: commentIndexPath)
//        }
//        return action
//    }
//    
//    /// 置顶评论 alert action
//    // Hide - YP-3830
//    //    func topCommentAction(commentId: Int, feedId: Int) -> TSAlertAction {
//    //        let action = TSAlertAction(title: "pin_comment_request".localized, style: .default) { [weak self] (_) in
//    //            let topVC = TSTopAppilicationManager.commentTopVC(comment: commentId, feed: feedId)
//    //            self?.parentViewController?.navigationController?.pushViewController(topVC, animated: true)
//    //        }
//    //        return action
//    //    }
//    
//    /// 删除评论 alert action
//    func deleteCommetAction(commentId: Int, feedId: Int, commentIndexPath: IndexPath, feedIndexPath: IndexPath) -> TSAlertAction {
//        let action = TSAlertAction(title: "delete_comment".localized, style: TSAlertSheetActionStyle.default, handler: { [weak self] (_) in
//            self?.showCommentDeleteConfirmAlert(commentId: commentId, feedId: feedId, commentIndexPath: commentIndexPath, feedIndexPath: feedIndexPath)
//        })
//        return action
//    }
//    
//    /// 显示删除评论的二次确认弹窗
//    fileprivate func showCommentDeleteConfirmAlert(commentId: Int, feedId: Int, commentIndexPath: IndexPath, feedIndexPath: IndexPath) -> Void {
//        let alertVC = TSAlertController.deleteConfirmAlert(deleteActionTitle: "tip_confirm_delete_comment".localized) {
//            self.delteComment(commentId: commentId, feedId: feedId, commentIndexPath: commentIndexPath, feedIndexPath: feedIndexPath)
//        }
//        UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: false, completion: nil)
//    }
//    /// 删除评论
//    fileprivate func delteComment(commentId: Int, feedId: Int, commentIndexPath: IndexPath, feedIndexPath: IndexPath) -> Void {
//        // 发起删除的网络请求
//        TSCommentNetWorkManager().delete(feedId: feedId, commentId: commentId, complete: { (_) in
//        })
//        // 刷新界面
//        self.datas[feedIndexPath.row].comments.remove(at: commentIndexPath.row)
//        self.datas[feedIndexPath.row].toolModel?.commentCount -= 1
//        if let cell = self.cellForRow(at: feedIndexPath) as? FeedListCell {
//            datas[feedIndexPath.row].isPlaying = true
//            self.beginUpdates()
//            cell.model = datas[feedIndexPath.row]
//            self.endUpdates()
//            datas[feedIndexPath.row].isPlaying = false
//        }
//    }
//}
//
//extension TopicFeedListView: ShareListViewDelegate {
//    //编辑
//    func didClickEditButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
//        let cell = self.cellForRow(at: feedIndex) as! FeedListCell
//        let model = cell.model
//        guard let feedId = model.id["feedId"] else {
//            return
//        }
//        let isHot = model.hot == 0 ? false : true
//        let editPostVC = EditPostViewController(feedId: feedId, name: (model.userInfo?.name).orEmpty, avatarInfo: model.avatarInfo!, timeStamp: model.timeLeftFormatted, postContent: model.content, pictures: model.pictures, videoUrl: model.videoURL, localVideoFileUrl: model.localVideoFileURL, liveModel: model.liveModel, repostID: model.repostId, repostType: model.repostType, repostModel: model.repostModel, sharedModel: model.sharedModel, locationModel: model.location, topicList: model.topics, isHotFeed: isHot, privacy: model.privacy, feedType: model.feedType)
//
//        parentViewController?.navigationController?.pushViewController(editPostVC, animated: true)
//    }
//
//    func didClickDisableCommentButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
//        let cell = self.cellForRow(at: feedIndex) as! FeedListCell
//        let model = cell.model
//        guard let feedId = model.id["feedId"] else {
//            return
//        }
//        let isCommentDisabled = (model.toolModel?.isCommentDisabled)! ? false : true
//        //        // 发起任务
//        TSDataQueueManager.share.moment.start(comment: feedId, isCommentDisabled: isCommentDisabled)
//        // 刷新界面
//        self.datas[feedIndex.row].toolModel?.isCommentDisabled = isCommentDisabled
//        
//        if isCommentDisabled {
//            let loadingAlert = TSIndicatorWindowTop(state: .success, title: "Disabled successful".localized)
//            loadingAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
//            
//        } else {
//            let loadingAlert = TSIndicatorWindowTop(state: .success, title: "Enabled successful".localized)
//            loadingAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
//        }
//        NotificationCenter.default.post(name: NSNotification.Name.Moment.update, object: nil, userInfo: ["feedId": feedId, "isCommentDisabled": isCommentDisabled])
//    }
//    
//    func didClickSetTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
//    }
//    
//    func didClickCancelTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
//    }
//    
//    func didClickSetExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
//    }
//    
//    func didClickCancelExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
//    }
//    /// 私信
//    func didClickMessageButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, model: TSmessagePopModel) {
//        let chooseFriendVC = ContactsPickerViewController(model: model, configuration: ContactsPickerConfig.shareToChatConfig(), finishClosure: nil)
//        parentViewController?.navigationController?.pushViewController(chooseFriendVC, animated: true)
//    }
//    /// 举报
//    func didClickReportButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
//        let cell = self.cellForRow(at: feedIndex) as! FeedListCell
//        let model = cell.model
//        let reportTarget = ReportTargetModel(feedModel: model)
//        if self.tableIdentifier == "homepage" {
//            reportTarget?.user?.name = self.homePageUserName
//        }
//        let reportVC: ReportViewController = ReportViewController(reportTarget: reportTarget!)
//        if #available(iOS 11, *) {
//            self.parentViewController?.navigationController?.pushViewController(reportVC, animated: true)
//        } else {
//            self.parentViewController?.present(TSNavigationController(rootViewController: reportVC).fullScreenRepresentation,
//                                               animated: true,
//                                               completion: nil)
//        }
//    }
//    /// 收藏
//    func didClickCollectionButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
//        let cell = self.cellForRow(at: feedIndex) as! FeedListCell
//        let model = cell.model
//        guard let feedId = model.id["feedId"] else {
//            return
//        }
//        let isCollect = (model.toolModel?.isCollect)! ? false : true
//        // 发起收藏任务
//        TSDataQueueManager.share.moment.start(collect: feedId, isCollect: isCollect)
//        // 刷新界面
//        self.datas[feedIndex.row].toolModel?.isCollect = isCollect
//        shareView.updateView(tag: fatherViewTag, iscollect: isCollect)
//    }
//    /// 删除
//    func didClickDeleteButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
//        let cell = self.cellForRow(at: feedIndex) as! FeedListCell
//        let model = cell.model
//        guard let feedId = model.id["feedId"] else {
//            return
//        }
//        let alertVC = TSAlertController.deleteConfirmAlert(deleteActionTitle: "delete_feed".localized) {
//            self.deleteFeed(feedId: feedId, feedIndexPath: feedIndex)
//        }
//        UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: false, completion: nil)
//    }
//    
//    /// 转发
//    func didClickRepostButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?) {
//        let cell = self.cellForRow(at: feedIndex!) as! FeedListCell
//        let model = cell.model
//        let repostModel = TSRepostModel.coverPostModel(feedModel: model)
//        let releaseVC = TSReleasePulseViewController(isHiddenshowImageCollectionView: true)
//        releaseVC.repostModel = repostModel
//        let navigation = TSNavigationController(rootViewController: releaseVC).fullScreenRepresentation
//        self.parentViewController?.present(navigation, animated: true, completion: nil)
//    }
//    /// 申请置顶
//    func didClickApplyTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
//    }
//    
//    func didClickShareExternal(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, items: [Any]) {
//        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
//        activityVC.popoverPresentationController?.sourceView = self.parentViewController?.view
//        self.parentViewController?.present(activityVC, animated: true, completion: nil)
//    }
//}
