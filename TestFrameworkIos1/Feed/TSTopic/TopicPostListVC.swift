//
//  TopicPostListVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/24.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Photos
import TZImagePickerController
import RealmSwift

class TopicPostListVC: UIViewController {

    enum PostsType: String {
        /// 最新帖子
        case latest = "latest_post"
        /// 最新回复
        case reply = "latest_reply"
    }

    /// 话题 id
    var groupId = 0
    /// 帖子类型
    var postsType = PostsType.latest
    /// 左边视图
    let leftView = UIView()
    /// 导航视图
    let navView = TopicListNavView()
    /// header view
    let headerView = TopicListHeaderView()

    var topicListModel = TopicListControllerModel()
    /// 列表视图
    let table = BaseFeedController()//TopicFeedListView(frame: UIScreen.main.bounds, tableIdentifier: "topicPostlist")
    /// 蒙板视图（当右边视图显示时，用来遮挡左边视图的蒙板）
    let maskView = UIControl()
    var isPlaying = false
    /// 当前正在播放视频的视图
//    var currentPlayingView: TopicFeedListView?
    /// 当前正在播放视频的cell
    var currentPlayingCell: FeedListCell?
    var topicModel = TopicModel()
    var lastFeedId: Int = 0

    init(groupId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.groupId = groupId
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNotification()
        loading()
        setUI()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        // 更新导航栏右方按钮的位置
        navView.updateRightButtonFrame()

        table.table.delegate = self
        table.table.mj_header = nil
        table.table.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        table.table.mj_footer.makeHidden()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TSKeyboardToolbar.share.keyboardstartNotice()
        /// 销毁创建话题页面
        dismissCreatTopicVC()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        TSKeyboardToolbar.share.keyboarddisappear()
        TSKeyboardToolbar.share.keyboardStopNotice()
        // 更新状态栏的颜色
        if #available(iOS 13.0, *) {
            UIApplication.shared.statusBarStyle = .darkContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didClickShortVideoShareBtn"), object: nil)
    }

    // MARK: - 销毁创建话题页面
    func dismissCreatTopicVC() {
        if let vcs = self.navigationController?.viewControllers {
            let vcArray = NSMutableArray(array: vcs)
            for item in vcArray {
                if item is CreatTopicVC {
                    vcArray.remove(item)
                    break
                }
            }
            self.navigationController?.setViewControllers(vcArray as! [UIViewController], animated: false)
        }
    }

    // MARK: - UI

    func setUI() {
        view.backgroundColor = .white
        // 1.加载左边视图
//        leftView.frame = UIScreen.main.bounds
               
        leftView.frame = CGRect(origin: .zero, size: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height))

        // 1.1 导航视图
        navView.delegate = self
        // 1.2 帖子 table
        addChild(table)
        table.parentVC = self
        table.didMove(toParent: self)
        // 1.3 header 视图
        headerView.set(taleView: table.table)
        headerView.delegate = self
        
        let frame = CGRect(x: 0, y:navView.frame.size.height , width: table.view.frame.size.width, height: table.view.frame.size.height)
        
        table.view.frame = frame


        leftView.addSubview(table.view)
        leftView.addSubview(navView)
        view.addSubview(leftView)
    }

    // MARK: - Data
    func loadData() {

        // 获取话题详情信息
        TSUserNetworkingManager().getTopicInfo(groupId: groupId) { [weak self] (model, message, status) in
            guard let model = model else {
                self?.loadFaild(type: .network)
                return
            }
            self?.endLoading()
            // 1.设置 model
            self?.topicModel = model
            self?.loadTopic(model: TopicListControllerModel(topicModel: model))
            // 2.加载帖子视图
            self?.refresh()
        }
    }

    func loadTopic(model: TopicListControllerModel) {
        self.topicListModel = model
        // 1.加载 section view
        let sectionModel = FilterSectionViewModel()
        sectionModel.countInfo = String(format: "feed_count".localized, String(model.postCount)) + " \(model.followCount) " + "topics_follower".localized
        sectionModel.followStatus = model.followStatus
        sectionModel.hidFolloeButton = true
        // 2.加载 header 视图
        headerView.load(contentModel: model)
        navView.setTitle(model.name)
        // 4.table
        table.table.reloadData()
        
        navView.updateChildView(offset: 0, buttonKeepBlack: true)

    }

    // MARK: - Notification

    func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTopicDetail), name: NSNotification.Name(rawValue: "reloadTopicDetailVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addNewFeed(_:)), name: NSNotification.Name.Moment.TopicAddNew, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateFollowStatus(noti:)), name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil)
    }

    @objc func updateFollowStatus(noti: Notification) {
        guard let info = noti.userInfo else {
            return
        }

        let follow: FollowStatus = info["follow"] as! FollowStatus
        let userId: String = info["userid"] as! String

        let followStatus: Bool = follow == .follow ? true : false

        for (index, model) in self.table.datasource.enumerated() {
            if "\(model.userId)" == userId {
                self.table.datasource[index].userInfo?.follower = followStatus
                self.table.table.reloadRow(at: IndexPath(row: index, section: 0), with: UITableView.RowAnimation.none)
            }
        }
    }
}

extension TopicPostListVC: LoadingViewDelegate {

    func reloadingButtonTaped() {
        loadData()
    }

    func loadingBackButtonTaped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - 帖子列表滚动代理事件
extension TopicPostListVC: UITableViewDelegate {

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 2.更新导航视图的动画效果
        // 这里需要把 offset 处理一下，移除 headerView 引起的 table inset 偏移的影响
        let offset = -(scrollView.contentOffset.y + headerView.stretchModel.headerHeightMin)
        // 3.当下拉到一定程度的时候，发起下拉刷新操作
        if offset > (TSStatusBarHeight + 25) {
            // 如果下拉刷新正在进行，就什么都不做
            if navView.indicator.isAnimating {
                return
            }
            // 发起下拉刷新操作
            refresh()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 1.更新 header view 的动画效果
//        headerView.updateChildviews(tableOffset: scrollView.contentOffset.y)
        let offset = -(scrollView.contentOffset.y + headerView.stretchModel.headerHeightMin)
        navView.updateChildView(offset: offset, buttonKeepBlack: topicModel.avatar == nil)
    }

    // 下拉刷新
    func refresh() {
        navView.indicator.starAnimationForFlowerGrey() // 显示小菊花

        // 获取话题下动态列表
        TSUserNetworkingManager().getTopicMomentList(topicID: groupId, offset: nil) { [weak self] (model, message, status) in
            self?.navView.indicator.dismiss()
            guard let model = model else  { return }
            self?.table.datasource = model.map { FeedListCellModel(feedListModel: $0) }
            self?.lastFeedId = self?.table.datasource.last?.index ?? 0
            self?.table.table.mj_footer.makeVisible()
            self?.table.table.reloadData()
        }

        // 获取话题详情信息
        TSUserNetworkingManager().getTopicInfo(groupId: groupId) { [weak self] (model, message, status) in
            guard let model = model else {
                self?.loadFaild(type: .network)
                return
            }
            self?.endLoading()
            // 1.设置 model
            self?.topicModel = model
            self?.loadTopic(model: TopicListControllerModel(topicModel: model))
        }
    }

    @objc func loadMore() {
        TSUserNetworkingManager().getTopicMomentList(topicID: groupId, offset: lastFeedId) { [weak self] (model, message, status) in
            self?.navView.indicator.dismiss()
            if model?.count == 0 {
                self?.table.table.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            guard let model = model else { return }
            self?.table.datasource += model.map { FeedListCellModel(feedListModel: $0) }
            self?.lastFeedId = self?.table.datasource.last?.index ?? 0
            self?.table.table.mj_footer.endRefreshing()
            self?.table.table.reloadData()
        }
    }

    // 下拉刷新
    @objc func refreshTopicDetail() {
        navView.indicator.starAnimationForFlowerGrey() // 显示小菊花
        // 获取话题详情信息
        TSUserNetworkingManager().getTopicInfo(groupId: groupId) { [weak self] (model, message, status) in
             self?.navView.indicator.dismiss()
            guard let model = model else {
                self?.loadFaild(type: .network)
                return
            }
            self?.endLoading()
            // 1.设置 model
            self?.topicModel = model
            self?.loadTopic(model: TopicListControllerModel(topicModel: model))
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? FeedListCell else { return }
        weak var wself = self
        let reactionHandler = cell.willDisplay(for: wself!.view)

        reactionHandler.onPresent = table.onPausePaging
        reactionHandler.onDismiss = table.onResumePaging
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? FeedListCell else { return }
        self.table.currentCell = cell
        let datacell = self.table.datasource[indexPath.row]
        if datacell.feedType == .picture {
            let tappedIndex: Int = ((cell.feedContentView.multiplePicturePageController.viewControllers?.first as? MultiplePictureViewController)?.index).orZero
            self.table.parentVC?.navigation(navigateType: .innerFeedList(data: [datacell], mediaType: .image, listType: .user(userId: (datacell.userInfo?.userIdentity).orZero), tappedIndex: tappedIndex, placeholderImage: nil, transitionId: UUID().uuidString, completeHandler: { index, id in
                cell.onReturnToTrellis(index: tappedIndex, transitionId: id)
            }, onToolbarUpdated: { [weak self] model in
                self?.table.updateToolbar(model, at: indexPath.row)
//                self?.table.reloadTable()
            }))
        } else if datacell.feedType == .miniVideo{
            //只打开当前的mini video 不需要loadMore
            let model = self.table.datasource[indexPath.row]
            let player = MiniVideoPageViewController(type: .detail(feedId: datacell.idindex), videos: [model], focus: 0, onToolbarUpdate: nil, tagVoucher: model.tagVoucher)
            self.present(TSNavigationController(rootViewController: player).fullScreenRepresentation, animated: true, completion: nil)
        }else{
            self.table.tapHandler(at: indexPath.row)
        }
    }
}

// MARK: - 导航栏视图代理事件
extension TopicPostListVC: TopicListNavViewDelegate {
    func navView(_ navView: TopicListNavView, didSelectedShareButton: UIButton) {

    }


    /// 返回按钮点击事件
    func navView(_ navView: TopicListNavView, didSelectedLeftButton: TSButton) {
        TSUtil.popViewController(currentVC: self, animated: true)
    }

    /// 更多按钮点击事件
    func navView(_ navView: TopicListNavView, didSelectedRightButton: TSButton) {
        let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
        if topicListModel.ownerUserId == CurrentUserSessionInfo?.userIdentity {
            let action = TSAlertAction(title: "edit".localized, style: TSAlertSheetActionStyle.default, handler: { [weak self] (_) in
                guard let model = self?.topicListModel else {
                    return
                }
                let creatVC = CreatTopicVC()
                creatVC.isEditPush = true
                creatVC.topicListModel = model
                self?.navigationController?.pushViewController(creatVC, animated: true)
            })
            alert.addAction(action)
        } else {
            let action = TSAlertAction(title: "report".localized, style: TSAlertSheetActionStyle.default, handler: { [weak self] (_) in
                guard TSCurrentUserInfo.share.isLogin == true else {
                    alert.dismiss {
                        TSRootViewController.share.guestJoinLandingVC()
                    }
                    return
                }
                guard let model = self?.topicModel else {
                    return
                }
                let informModel = ReportTargetModel(topic: model)
                let informVC = ReportViewController(reportTarget: informModel)
                if #available(iOS 11, *) {
                    self?.navigationController?.pushViewController(informVC, animated: true)
                } else {
                    self?.present(TSNavigationController(rootViewController: informVC).fullScreenRepresentation,
                                                  animated: true,
                                                  completion: nil)
                }
            })
            alert.addAction(action)
        }
        present(alert, animated: false, completion: nil)
        return
    }

}

// MARK: - header 代理事件
extension TopicPostListVC: TopicListHeaderViewDelegate {
    /// 跳转到话题参与者列表页面
    func jumpToMenberListVC(_ topicListHeaderView: TopicListHeaderView, topicId: Int) {
        let menberList = TopicMenberListVC(topicId: topicId)
        self.navigationController?.pushViewController(menberList, animated: true)
    }
}

// MARK: - 带有过滤列表了弹窗的 section view 代理
extension TopicPostListVC: FilterSectionViewDelegate {
    /// 选择了一种过滤类型
    func filterSectionView(_ view: FilterSectionViewType, didSeleteNewAtIndex index: Int)  {
    }

    /// 关注和取消关注
    func followButtonClick(_ view: FilterSectionView, button: UIButton) {
        if topicListModel.ownerUserId == CurrentUserSessionInfo?.userIdentity {
            return
        }
        TSUserNetworkingManager().followOrUnfollowTopic(topicId: groupId, follow: !view.model.followStatus) { (_ msg, _ status) in
            if status {
                if view.model.followStatus {
                    self.topicModel.followCount = self.topicModel.followCount - 1
                } else {
                    self.topicModel.followCount = self.topicModel.followCount + 1
                }
                self.topicModel.followStatus = !self.topicModel.followStatus
                self.loadTopic(model: TopicListControllerModel(topicModel: self.topicModel))
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTopicList"), object: nil, userInfo: ["topicId": "\(self.groupId)", "follow": view.model.followStatus ? "0" : "1"])
            }
        }
    }
}

// MARK: - 黑名单相关
extension TopicPostListVC {
    /// 黑名单处理
    fileprivate func blackProcess() -> Void {
        let alertVC = TSAlertController(title: "text_tips".localized, message: "tips_have_been_blacklisted".localized, style: .actionsheet)
        DispatchQueue.main.async {
            self.present(alertVC, animated: false, completion: nil)
        }
    }
}

// MARK: - 追加新发布的动态
extension TopicPostListVC {
    /// 添加用户发布的新动态
    @objc func addNewFeed(_ notification: Notification) {
        // 2.解析通知发送的信息
        let notiInfo = notification.userInfo
        // 如果信息里同时有 oldId 和 newId，说明某个动态发送成功了
        if let newId = notiInfo?["newId"] as? Int, let oldId = notiInfo?["oldId"] as? Int {
            self.updateNewFeedSendStatus(oldId: oldId, newId: newId)
            return
        }
        // 如果信息里只有 oldId，说明某个动态发送失败了
        if let oldFeedId = notiInfo?["oldId"] as? Int {
            self.updateNewFeedSendStatus(oldId: oldFeedId, newId: nil)
            return
        }
        // 如果信息里有 newFeedId，说明某个动态刚刚创建，正在发送中
        if let feedId = notification.userInfo?["newFeedId"] as? Int {
            self.addNewFeedToList(newFeedId: feedId)
            table.table.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            return
        }
    }

    /// 更新某个新发动态的发送状态，newId 为 nil 表示动态发送失败
    func updateNewFeedSendStatus(oldId: Int, newId: Int?) {
        // 1.最新列表
        if let newFeedModel = table.datasource.first(where: { $0.id["feedId"] == oldId }) {
            newFeedModel.userInfo = CurrentUser
            if let newId = newId {
                newFeedModel.id = .feed(feedId: newId)
            }
            table.table.reloadData()
        }
    }

    /// 添加新创建的动态到列表上
    @objc func addNewFeedToList(newFeedId feedId: Int) {
        // 1. 获取 feed object
//        guard let feedObject = TSDatabaseMoment().getList(feedId) else {
//            return
//        }
        // 2.获取用户信息
        guard let userInfo = CurrentUserSessionInfo else {
            return
        }
        // 3.创建新动态的数据模型 newFeedModel
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = userInfo.avatarUrl
        avatarInfo.verifiedType = (userInfo.verificationType).orEmpty
        avatarInfo.verifiedIcon = (userInfo.verificationIcon).orEmpty
//        let pictures = Array(feedObject.pictures).map { PaidPictureModel(imageObject: $0) }
//        let topicInfo = Array(feedObject.topics).map { TopicListModel(object: $0) }
//        let rightTime = TSDate().dateString(.normal, nsDate: feedObject.create as NSDate)
//        let newFeedModel = FeedListCellModel(feedId: feedId, userId: userInfo.userIdentity, userName: userInfo.name, avatarInfo: avatarInfo, content: feedObject.content, pictures: pictures, rightTime: rightTime, topicInfo: topicInfo)
//        if let shortVideoOutputUrl = feedObject.shortVideoOutputUrl {
//            newFeedModel.localVideoFileURL = shortVideoOutputUrl
//        }
//        if let videoURL = feedObject.videoURL {
//            newFeedModel.videoURL = videoURL
//        }
//        newFeedModel.userInfo = CurrentUserSessionInfo?.convert()
//        table.datas.insert(newFeedModel, at: 0)
//        table.processRefresh(data: table.datas, message: nil, status: true)
//        table.reloadData()
    }

    /// 获取数据库中发送失败的动态
    func getFaildTopicFeedModels() -> [FeedListCellModel] {
        var topicFeedList: [FeedListCellModel] = []
//        let faildMoments = DatabaseManager().moment.getFaildSendMoments().map { FeedListCellModel(faildMoment: $0) }
//        for item in faildMoments {
//            for topicItem in item.topics {
//                if topicItem.topicId == groupId {
//                    topicFeedList.insert(item, at: 0)
//                    continue
//                }
//            }
//        }
        return topicFeedList
    }

}
