//
// Created by Francis Yeap on 28/10/2020.
// Copyright (c) 2020 Toga Capital. All rights reserved.
//

import Foundation
import AVFoundation
import StoreKit

typealias onToolbarUpdate = ((FeedListCellModel) -> Void)
class BaseFeedController: ContentBaseFrameController {
    
    var lastTableOffset: CGFloat = 0
    var feedType: FeedListType {
        return .hot
    }
    var country: String? {
        return nil
    }
    //记录用户当前这一次的行为产生的曝光下标列表
    var behaviorIndexList = [NSInteger]()
    //记录用户当前这一次的行为产生的曝光数据列表 [{"feed_id":123456,"bhv_time":123123},{"feed_id":123456,"bhv_time":123123},{"feed_id":123456,"bhv_time":123123},{"feed_id":123456,"bhv_time":123123}]
    var behabiorDataList = [[String: String]]()
    
    //记录停留Feed ID
    var stayFeedId: String = ""
    
    weak var scrollDelegate: TSScrollDelegate?
    
    lazy var table: TSTableView = TSTableView(frame: .zero, style: .grouped)
    
    var datasource = [FeedListCellModel]() {
        didSet {
            
            if datasource.isEmpty == true {
                if TSReachability.share.isReachable() {
                    self.table.show(placeholderView: .empty)
                } else {
                    self.table.show(placeholderView: .network)
                }
            } else {
                self.table.removePlaceholderViews()
                self.placeholderView.removeFromSuperview()
            }
        }
    }
    var lastItemID: Int = 0
    var onPausePaging: EmptyClosure?
    var onResumePaging: EmptyClosure?
    var onToolbarUpdate: onToolbarUpdate?
    var placeholderView: UIView = UIView(bgColor: .clear)
    var isViewVideo: Bool = false
    var isGlobalSearch: Bool = false
    var currentCell: FeedListCell?
    public var needDynamicTable: Bool = false {
        didSet {
            table.needDynamic = needDynamicTable
        }
    }
    
    weak private var _parentVC: UIViewController? {
        return parentVC ?? self
    }
    
    deinit {
        table.dataSource = nil
        table.delegate = nil
    }
    
    //是否正在下拉加载
    var isLoadMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSkelViews()
        
        scrollview.delegate = self
        
        self.onToolbarUpdate = { [weak self] model in
            guard let index = self?.datasource.firstIndex(where: { $0.idindex == model.idindex }) else { return }
            self?.updateToolbar(model, at: index)
            self?.reloadTable()
        }
        
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateVideoMute), name: Notification.Name.Video.muteAll, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateVideoAutoplay), name: Notification.Name.Video.disableAutoplay, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        table.visibleCells.forEach { cell in
            guard let cell = cell as? FeedListCell else { return }
            guard isViewVideo else {
                cell.feedContentView.videoPlayer.pause()
                return
            }
            if cell != currentCell {
                cell.feedContentView.videoPlayer.pause()
            }
        }
       
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        //上报曝光
        self.submitBehaviorData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //如果页面pop,确保视频停止播放处理
        if self.navigationController == nil {
            //            table.visibleCells.forEach { cell in
            //                guard let cell = cell as? FeedListCell else { return }
            //                cell.feedContentView.videoPlayer.pause()
            //            }
            var cells = [FeedListCell?]()
            let rows = table.numberOfRows(inSection: 0)
            for index in 0..<rows {
                let indexPath = IndexPath(row: index, section: 0)
                if let cell = table.cellForRow(at: indexPath) as? FeedListCell {
                    cells.append(cell)
                }
            }
            cells.forEach { cell in
                guard let cell = cell as? FeedListCell else { return }
                cell.feedContentView.videoPlayer.pause()
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isLoadMore = false
        //        if !isViewVideo {
        //            table.visibleCells.forEach { cell in
        //                guard let cell = cell as? FeedListCell else { return }
        //                let visibleVideoPoint = self.table.convert(cell.center, to: self.table.superview)
        //                if self.table.frame.contains(visibleVideoPoint) {
        //                    cell.feedContentView.videoPlayer.play()
        //                }
        //            }
        //            isViewVideo = false
        //        }
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(homeDashboardReload), name: NSNotification.Name(rawValue: "HotFeedsHomeDashboardRefresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(homeDashboardscrollToTop), name: NSNotification.Name(rawValue: "HotFeedsHomeDashboardscrollToTop"), object: nil)
        
        self.behaviorUserFeedStayData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TSBottomSafeAreaHeight + 80, right: 0)
    }
    
    override func prepareSkelViews() {
        super.prepareSkelViews()
        contentView.addSubview(table)
        table.bindToEdges()
        
        table.register(FeedListCell.self, forCellReuseIdentifier: FeedListCell.cellIdentifier)
        table.backgroundColor = .white
        table.separatorColor = .clear
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.0001))
        table.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        table.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        table.mj_footer.makeHidden()
        table.delegate = self
        table.dataSource = self
        
        NotificationCenter.default.add(observer: self, name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil) { [weak self] (noti) in
            guard let self = self else { return }
            if let userInfo = noti.userInfo, let followStatus = userInfo["follow"] as? FollowStatus, let uid = userInfo["userid"] as? String {
                for(index, model) in  self.datasource.enumerated() {
                    if model.userInfo?.userIdentity == uid.toInt() {
                        self.datasource[index].userInfo?.follower = followStatus == .follow ? true : false
                    }
                }
                
                self.table.visibleCells.forEach { cell in
                    if let indexPath = self.table.indexPath(for: cell), self.datasource[indexPath.row].userId == uid.toInt() {
                        (cell as? FeedListCell)?.feedContentView.updateFollowButton(followStatus)
                    }
                }
                
//                DispatchQueue.main.async {
//                    self.table.reloadData()
//                }
            }
        }
    }
    
    
    @objc func refresh() {
        defer {
            self.table.reloadData()
        }
        fetch()
    }
    @objc func homeDashboardscrollToTop(){
        if self.datasource.count > 0 {
            self.table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        
    }
    @objc func homeDashboardReload(){
        if let models = FeedsStoreManager().fetch(by: self.feedType), models.count > 0, let firstModel = HomedashBoardFeedStoreManager().fetch() , firstModel.count > 0 ,let model = models.first(where: {$0.id == firstModel[0].id}){
            var datas: [FeedListModel] = []
            datas = models
            if let index = datas.firstIndex(where: {$0.id == firstModel[0].id}) {
                datas.remove(at: index)
                datas.insert(model, at: 0)
            }
            
            self.datasource = datas.compactMap { FeedListCellModel(feedListModel: $0) }
            self.table.removePlaceholderViews()
            self.table.reloadData()
            self.table.mj_footer.makeVisible()
            //self.table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            
        }else{
            self.fetch()
        }
    }
    func fetch() {
        FeedListNetworkManager.getTypeFeeds(type: self.feedType.rawValue, offset: 0, after: nil, country: country) { [weak self] (results, message, status) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard status == true else {
                    self.table.mj_header.endRefreshing()
                    if let models = FeedsStoreManager().fetch(by: self.feedType), models.count > 0 {
                        self.datasource = models.compactMap { FeedListCellModel(feedListModel: $0) }
                        self.table.removePlaceholderViews()
                        self.table.reloadData()
                        self.table.mj_footer.makeVisible()
                        
                    } else {
                        self.datasource = []
                    }
                    return
                }
                
                guard let feeds = results?.feeds, feeds.count > 0 else {
                    self.table.mj_header.endRefreshing()
                    self.datasource = []
                    self.table.reloadData()
                    return
                }
                
                FeedsStoreManager().reset(feeds, for: self.feedType)
                
                let cellModels = (feeds.compactMap { FeedListCellModel(feedListModel: $0) })
                self.datasource = cellModels
                self.lastItemID = self.datasource.last?.idindex ?? 0
                
                self.table.removePlaceholderViews()
                self.table.reloadData()
                if self.table.mj_header != nil {
                    self.table.mj_header.endRefreshing()
                }
                self.table.mj_footer.makeVisible()
                if cellModels.count <= 0 {
                    self.table.mj_footer.endRefreshingWithNoMoreData()
                }
            }
        }
    }
    
    @objc func loadMore() {

        isLoadMore = true
        let visibleCells = table.visibleCells as? [FeedListCell]
        
        visibleCells?.forEach { (cell: FeedListCell) -> () in
            cell.feedContentView.videoPlayer.pause()
        }
        FeedListNetworkManager.getTypeFeeds(type: self.feedType.rawValue, offset: datasource.count, after: lastItemID, country: nil) { [weak self] (results, message, status) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard status else {
                    self.table.mj_footer.endRefreshingWithWeakNetwork()
                    self.isLoadMore = false
                    return
                }
                
                if let feeds = results?.feeds, feeds.count > 0 {
                    FeedsStoreManager().save(feeds, for: self.feedType)
                    let cellModels = feeds.compactMap { FeedListCellModel(feedListModel: $0) } ?? []
                    
                    // By Kit Foong (Insert row instead of reload data)
                    let startIndex = self.datasource.count
                    self.datasource.append(contentsOf: cellModels)
                    let endIndex = self.datasource.count
                    var indexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
                    self.table.beginUpdates()
                    self.table.insertRows(at: indexPaths, with: .automatic)
                    self.table.endUpdates()
                    
                    //self.datasource += cellModels
                    self.lastItemID = self.datasource.last?.idindex ?? 0
                    //self.table.reloadData()
                    self.table.mj_footer.endRefreshing()
                } else {
                    self.table.mj_footer.endRefreshingWithNoMoreData()
                }
                DispatchQueue.main.asyncAfter(deadline: Dispatch.DispatchTime.now() + 0.3) {
                    self.isLoadMore = false
                }
                
            }
        }
    }
    // MARK: - 上报用户停留数据
    func behaviorUserFeedStayData() {
        if stayBeginTimestamp != "" {
            stayEndTimestamp = Date().timeStamp
            let stay = stayEndTimestamp.toInt()  - stayBeginTimestamp.toInt()
            FeedListNetworkManager.behaviorUserFeed(bhv_type: "stay", scene_id: feedType.rawValue, feed_id: stayFeedId, bhv_value: stay.stringValue) { [weak self] (message, code, status) in
                guard let self = self else { return }
                if status == true {
                    print("停留行为上报成功")
                    self.stayBeginTimestamp = ""
                    self.stayEndTimestamp = ""
                    self.stayFeedId = ""
                }
            }
        }
    }
    // MARK: - 提交曝光行为上报
    func submitBehaviorData() {
        let json = TSUtil.jsonArray(res: self.behabiorDataList)
        if json != "" && self.behaviorIndexList.count != 0{
            FeedListNetworkManager.behaviorFeed(behaviorFeedJson: json, scene_id: self.feedType.rawValue) { [weak self] (results, message, status) in
                guard let self = self else { return }
                if status == true {
                    print("曝光提交成功")
                    self.behabiorDataList = []
                    self.behaviorIndexList = []
                }
           
            }
        }
    }
    func tapHandler(at index: Int) {
        let model = self.datasource[index]
        //记录详情停留开始时间
        stayBeginTimestamp = Date().timeStamp
        //记录详情Feed ID
        stayFeedId = model.idindex.stringValue
        
        switch model.feedType {
        case .miniVideo:
            isViewVideo = true
            currentCell?.feedContentView.videoPlayer.videoView.heroID = model.idindex.stringValue
            let currentPlayer = currentCell?.feedContentView.videoPlayer.videoView.player
            

//            let vc = MiniVideoPageViewController(type: self.feedType, videos: [model], focus: 0, onToolbarUpdate: self.onToolbarUpdate, avPlayer: currentPlayer,
//                                                 isTranslateText: model.isTranslateOn, translateHandler: { [weak self] isTranslate in
//                self?.currentCell?.feedContentView.updateTranslateText(isTranslate, model.idindex)
//            })

            let vc = MiniVideoPageViewController(type: self.feedType, videos: [model], focus: 0, onToolbarUpdate: self.onToolbarUpdate, avPlayer: currentPlayer, tagVoucher: model.tagVoucher)
            currentPlayer?.pause()
            vc.onPassPlayer = { [weak self] player, time in
                DispatchQueue.main.async {
                    guard let player = player, let time = time else { return }
                    self?.currentCell?.feedContentView.videoPlayer.setPlayer(player, at: time)
                    self?.isViewVideo = false
                }
            }
            if isGlobalSearch {
                _parentVC?.present(TSNavigationController(rootViewController: vc).fullScreenRepresentation, animated: true, completion: nil)
            } else {
                vc.isControllerPush = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case .video:
            isViewVideo = true
            currentCell?.feedContentView.videoPlayer.pause()
            let detailVC = FeedCommentDetailViewController(feedId: model.idindex, isTapMore: false, isClickCommentButton: false, isVideoFeed: true, onToolbarUpdated: self.onToolbarUpdate)
            detailVC.startPlayTime = currentCell?.feedContentView.videoPlayer.videoView.player?.currentTime() ?? .zero
            detailVC.setCloseButton(backImage: true)
            detailVC.model = model
            detailVC.type = self.feedType
            
            detailVC.onDismiss = { [weak self] time in
                DispatchQueue.main.async {
                    self?.currentCell?.feedContentView.videoPlayer.change(to: time)
                    self?.isViewVideo = false
                }
            }
            _parentVC?.present(TSNavigationController(rootViewController: detailVC).fullScreenRepresentation, animated: true, completion: nil)
        default:
            FeedListCellActionManager.shared.didClickCell(parentVC: _parentVC, model: model, atIndex: index, feedListType: feedType, onToolbarUpdated: self.onToolbarUpdate)
            break
        }
        
    }
    
    public func reloadTable() {
        UIView.performWithoutAnimation {
            self.table.reloadData()
        }
    }
    
    @objc private func appDidBecomeActive() {
        self.table.visibleCells.forEach { cell in
            guard let cell = cell as? FeedListCell else { return }
            let visibleVideoPoint = self.table.convert(cell.center, to: self.table.superview)
            if self.table.frame.contains(visibleVideoPoint) {
                cell.feedContentView.videoPlayer.play()
            }
        }
        self.isViewVideo = false
    }
    
    @objc private func appResignActive() {
        self.table.visibleCells.forEach { cell in
            guard let cell = cell as? FeedListCell else { return }
            guard self.isViewVideo else {
                cell.feedContentView.videoPlayer.pause()
                return
            }
            if cell != self.currentCell {
                cell.feedContentView.videoPlayer.pause()
            }
        }
    }
    
    @objc private func updateVideoMute() {
        self.table.visibleCells.forEach { cell in
            DispatchQueue.main.async {
                (cell as? FeedListCell)?.feedContentView.videoPlayer.updateMuteStatus()
            }
        }
    }
    
    @objc private func updateVideoAutoplay() {
        self.table.visibleCells.forEach { cell in
            DispatchQueue.main.async {
                (cell as? FeedListCell)?.feedContentView.videoPlayer.disableAutoPlay()
            }
        }
    }
}


extension BaseFeedController: UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == table {
            scrollDelegate?.scrollViewDidScroll(scrollView)
            if self.isLoadMore {
                return
            }
            let visibleCells = table.visibleCells as? [FeedListCell]
            
            visibleCells?.forEach { (cell: FeedListCell) -> () in
                let visibleVideoPoint = self.table.convert(cell.center, to: self.table.superview)
                if self.table.frame.contains(visibleVideoPoint) {
                    cell.feedContentView.videoPlayer.play()
                } else {
                    cell.feedContentView.videoPlayer.pause()
                }
            }
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == table {
            scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
            lastTableOffset = table.contentOffset.y
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableStack
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let datacell = datasource[indexPath.row]
        
        let cell = FeedListCell.cell(for: tableView, at: indexPath)
        cell.feedContentView.parentVC = parentVC
        cell.model = datacell
        if feedType == .hot || feedType == .new || feedType == .follow {
            cell.feedContentView.isNeedHideTime = true
        } else{
            cell.feedContentView.isNeedHideTime = false
        }
        
        cell.onPictureDidSelect = { [weak self] (trellis, tappedIndex, transitionId) in
            guard let self = self else { return }
            
            if datacell.feedType == .picture {
                self._parentVC?.navigation(navigateType: .innerFeedList(data: [datacell], mediaType: .image, listType: self.feedType, tappedIndex: tappedIndex, placeholderImage: trellis.picture, transitionId: transitionId, isTranslateText: self.datasource[indexPath.row].isTranslateOn, completeHandler: { index, id in
                    cell.onReturnToTrellis(index: index, transitionId: id)
                }, onToolbarUpdated: { [weak self] model in
                    self?.updateToolbar(model, at: indexPath.row)
                    self?.reloadTable()
                }, translateHandler: { [weak self] isTranslate in
                    guard let feedId = datacell.id["feedId"] else {
                        return
                    }
                    cell.feedContentView.updateTranslateText(isTranslate, feedId)
                }))
            } else {
                self.tapHandler(at: indexPath.row)
            }
            
        }
        
        cell.onUpdateTranslateText = { [weak self] text, isOn, feedId in
            if datacell.idindex == feedId {
                self?.datasource[indexPath.row].translateText = text
                self?.datasource[indexPath.row].isTranslateOn = isOn
                
                ///刷新cell的高度
                tableView.performBatchUpdates {

                }
            }
        }
        
        cell.onReactionSuccess = { [weak self] in
            FeedListNetworkManager.getMomentFeed(id: datacell.idindex) { [weak self] (model, message, status, networkResult) in
                guard let self = self, let model = model, status else { return }
                
                guard indexPath.row < self.datasource.count else {
                    return
                }
                let cellModel = FeedListCellModel(feedListModel: model)
                self.updateToolbar(cellModel, at: indexPath.row)
                DispatchQueue.main.async {
                    cell.feedContentView.loadToolbar(model: cellModel.toolModel, canAcceptReward: cellModel.canAcceptReward == 1, reactionType: cellModel.reactionType)
                    cell.feedContentView.updateReactionView(cellModel.topReactionList, total: (cellModel.toolModel?.diggCount).orZero, feedId: cellModel.idindex)
                }
            }
        }
        cell.onUpdateCellLayout = { [weak self] in
            self?.reloadTable()
        }
        cell.onToolbarItemDidSelect = { [weak self] index in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                if index == 1, datacell.feedType == .picture {
                    guard TSCurrentUserInfo.share.isLogin == true else {
                        TSRootViewController.share.guestJoinLandingVC()
                        return
                    }
                    self._parentVC?.navigation(navigateType: .innerFeedList(data: [datacell], mediaType: .image, listType: .user(userId: (datacell.userInfo?.userIdentity).orZero), tappedIndex: 0, placeholderImage: nil, transitionId: nil, isClickComment: true, isTranslateText: self.datasource[indexPath.row].isTranslateOn, completeHandler: { [weak self] index, id in
                        cell.onReturnToTrellis(index: index, transitionId: id)
                        self?.datasource[indexPath.row].toolModel?.isRewarded = true
                        self?.datasource[indexPath.row].toolModel?.rewardCount += 1
                        DispatchQueue.main.async {
                            cell.feedContentView.updateRewardItem(self?.datasource[indexPath.row].toolModel)
                        }
                    }, onToolbarUpdated: { [weak self] model in
                        self?.onToolbarUpdate?(model)
                        self?.updateToolbar(model, at: indexPath.row)
                        self?.reloadTable()
                    }, translateHandler: { [weak self] isTranslate in
                        guard let feedId = datacell.id["feedId"] else {
                            return
                        }
                        cell.feedContentView.updateTranslateText(isTranslate, feedId)
                    }))
                    return
                }
                
                guard let parentVC = self._parentVC else {
                    return
                }
                
                guard let feedId = datacell.id["feedId"], let toolModel = datacell.toolModel else {
                    parentVC.showError()
                    return
                }
                
                switch index {
                case 0:
                    break
                case 1:
                    guard TSCurrentUserInfo.share.isLogin == true else {
                        TSRootViewController.share.guestJoinLandingVC()
                        return
                    }
                    func getLiveModel(_ feedId: Int) {
                        parentVC.navigation(navigateType: .navigateLive(feedId: feedId))
                    }
                    
                    switch datacell.feedType {
                    case .miniVideo:
                        self.currentCell = cell
                        self.tapHandler(at: indexPath.row)
                        break
                    case .live:
                        getLiveModel(feedId)
                    case .share:
                        if let sharedModel = datacell.sharedModel, let attachment = sharedModel.customAttachment, sharedModel.type == .live {
                            getLiveModel(attachment.attachId)
                        } else {
                            fallthrough
                        }
                    default:
                        parentVC.navigation(navigateType: .feedDetail(feedId: feedId, isTapMore: false, isClickCommentButton: true, isVideoFeed: true, feedType: self.feedType, afterTime: datacell.afterTime, onToolbarUpdated: self.onToolbarUpdate))
                    }
                    
                case 2:
                    guard TSCurrentUserInfo.share.isLogin == true else {
                        TSRootViewController.share.guestJoinLandingVC()
                        return
                    }
//                    if datacell.userInfo?.isMe() == true {
//                        let vc = PostTipHistoryTVC(feedId: feedId)
//                        parentVC.navigation(navigateType: .pushView(viewController: vc))
//                    } else {
//                        UIApplication.topViewController()?.presentTipping(target: feedId, type: .moment) { [weak self] (sourceId, _) in
//                            guard let feedId = sourceId as? Int else { return }
//                            self?.showSuccess(message: "tip_successful_title".localized)
//                            self?.datasource[indexPath.row].toolModel?.isRewarded = true
//                            self?.datasource[indexPath.row].toolModel?.rewardCount += 1
//                            DispatchQueue.main.async {
//                                cell.feedContentView.updateRewardItem(self?.datasource[indexPath.row].toolModel)
//                            }
//                        }
//                    }
                    
                case 3:
                    var shareUrl = ShareURL.feed.rawValue + "\(feedId)"
                    if let username = CurrentUserSessionInfo?.username {
                        shareUrl += "?r=\(username)"
                    }
                    
                    let messageModel = TSmessagePopModel(momentModel: datacell)
                    let pictureView = PicturesTrellisView()
                    pictureView.models = datacell.pictures
                    // 当分享内容为空时，显示默认内容
                    let image = (pictureView.pictures.first ?? nil) ?? UIImage.set_image(named: "IMG_icon")
                    let title = TSAppSettingInfoModel().appDisplayName + " " + "post".localized
                    var defaultContent = "default_share_content".localized
                    defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
                    let description = datacell.content.isEmpty ? defaultContent : datacell.content
                    if datacell.userId == CurrentUserSessionInfo?.userIdentity {
                        let shareView = ShareListView(isMineSend: true, isCollection: toolModel.isCollect, isDisabledCommentFeed: toolModel.isCommentDisabled, isEdited: datacell.isEdited, isSponsored: datacell.isSponsored, shareType: ShareListType.momentList)
                        shareView.delegate = self
                        shareView.messageModel = messageModel
                        shareView.feedIndex = indexPath
                        
                        shareView.show(URLString: shareUrl, image: image, description: description, title: title)
                    } else {
                        let shareView = ShareListView(isMineSend: false, isCollection: toolModel.isCollect, isDisabledCommentFeed: toolModel.isCommentDisabled, isEdited: datacell.isEdited, isSponsored: datacell.isSponsored, shareType: ShareListType.momentList)
                        shareView.delegate = self
                        shareView.messageModel = messageModel
                        shareView.feedIndex = indexPath
                        shareView.show(URLString: shareUrl, image: image, description: description, title: title)
                    }
                    
                default: break
                }
            }
        }
        
        let followButton = cell.feedContentView.followButton
        if var userModel = datacell.userInfo {
            followButton?.addTap { (btn) in
                guard TSCurrentUserInfo.share.isLogin == true else {
                    TSRootViewController.share.guestJoinLandingVC()
                    return
                }
                (btn as? FollowButton)?.showLoader(userInteraction: false)
                
                userModel.updateFollow { success in
                    DispatchQueue.main.async {
                        (btn as? FollowButton)?.hideLoader({
                            if success {
                                followButton?.makeHidden()
                                cell.feedContentView.layoutIfNeeded()
                            }
                        })
                    }
                }
            }
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? FeedListCell else { return }
        weak var wself = self
        let reactionHandler = cell.willDisplay(for: wself!.view)
        
        reactionHandler.onPresent = wself?.onPausePaging
        reactionHandler.onDismiss = wself?.onResumePaging
        cell.feedContentView.remakeAvatarViewContraint()
        // 相关位置添加如下代码，循环遍历可见cell数组
        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
            self.exposureBuriedPoint(indexPath: indexPath)
        }
    }
    
    // By Kit Foong (When table cell end diplay will pause video)
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? FeedListCell else { return }
        DispatchQueue.main.async {
            cell.feedContentView.videoPlayer.pause()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FeedListCell else { return }
        currentCell = cell
        let datacell = datasource[indexPath.row]
        if datacell.feedType == .picture {
            let tappedIndex: Int = ((cell.feedContentView.multiplePicturePageController.viewControllers?.first as? MultiplePictureViewController)?.index).orZero
            self._parentVC?.navigation(navigateType: .innerFeedList(data: [datacell], mediaType: .image, listType: self.feedType, tappedIndex: tappedIndex, placeholderImage: nil, transitionId: UUID().uuidString, isTranslateText: self.datasource[indexPath.row].isTranslateOn, completeHandler: { index, id in
                cell.onReturnToTrellis(index: tappedIndex, transitionId: id)
            }, onToolbarUpdated: { [weak self] model in
                self?.updateToolbar(model, at: indexPath.row)
                self?.reloadTable()
            }, translateHandler: { [weak self] isTranslate in
                guard let feedId = datacell.id["feedId"] else {
                    return
                }
                cell.feedContentView.updateTranslateText(isTranslate, feedId)
            }))
        } else {
            self.tapHandler(at: indexPath.row)
        }
        FeedListNetworkManager.behaviorUserFeed(bhv_type: "click", scene_id: feedType.rawValue, feed_id: datacell.idindex.stringValue) { [weak self] (message, code, status) in
            guard let self = self else { return }
            if status == true {
                print("点击行为上报成功")
            }
        }
    }
    
    public func updateToolbar(_ model: FeedListCellModel, at index: Int) {
        self.datasource[index].reactionType = model.reactionType
        self.datasource[index].topReactionList = model.topReactionList
        self.datasource[index].toolModel = model.toolModel
    }
    // 曝光上报埋点，显示超过50%进行上报
    private func exposureBuriedPoint(indexPath: IndexPath) {
        
        let previousCellRect = table.rectForRow(at: indexPath)
        if previousCellRect.isEmpty == false {
            let cellRect = table.convert(previousCellRect, to: self.view.superview)
            let currentY = cellRect.origin.y + cellRect.size.height

            if cellRect.origin.y < 0 {
                let percentage = currentY / cellRect.size.height

                if percentage >= 0.5 {
                    // 上报埋点
                    //  ********* 进行曝光埋点相关统计处理代码写在这里 *********
                    self.setBehaviorData(cell_index: indexPath.row)
                }
            } else {
                if currentY > ScreenHeight {
                    let percentage = (currentY - ScreenHeight) / cellRect.size.height

                    if percentage < 0.5 {
                        //  上报埋点
                        //  ********* 进行曝光埋点相关统计处理代码写在这里 *********
                        self.setBehaviorData(cell_index: indexPath.row)
                    }
                } else {
                    //  上报埋点
                    //  ********* 进行曝光埋点相关统计处理代码写在这里 *********
                    self.setBehaviorData(cell_index: indexPath.row)
                }
            }
        }
    }
    // MARK: - 处理行为曝光上报的数据
    private func setBehaviorData(cell_index: NSInteger){
        let datacell = datasource[cell_index]
        if !behaviorIndexList.contains(datacell.idindex){
            behaviorIndexList.append(datacell.idindex)
            behabiorDataList.append(["feed_id":datacell.idindex.stringValue, "bhv_time": Date().timeStamp])
        }
    }
    
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return tableStack.arrangedSubviews.count > 0 ? tableStack.height : .leastNormalMagnitude
    //    }
}

extension BaseFeedController: ShareListViewDelegate {
    //编辑
    func didClickEditButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        let model = datasource[feedIndex.row]
        guard let avatarInfo = model.avatarInfo, let feedId = model.id["feedId"] else { return }
        let isHot = model.hot == 0 ? false : true
        let editPostVC = EditPostViewController(feedId: feedId ,name: (model.userInfo?.name).orEmpty, avatarInfo: avatarInfo, postContent: model.content, pictures: model.pictures, videoUrl: model.videoURL, localVideoFileUrl: model.localVideoFileURL, liveModel: model.liveModel, repostID: model.repostId, repostType: model.repostType, repostModel: model.repostModel, sharedModel: model.sharedModel, locationModel: model.location, topicList: model.topics, isHotFeed: isHot, privacy: model.privacy, feedType: model.feedType, tagVoucher: model.tagVoucher)
        editPostVC.onSucessEdit = { [weak self] (newFeedId, repostModel, sharedModel, feedContent) in
            guard let self = self else { return }
            for (index, data) in self.datasource.enumerated() {
                if data.id["feedId"] == newFeedId {
                    data.content = feedContent
                    data.repostModel = repostModel
                    data.sharedModel = sharedModel
                    data.isEdited = true
                    self.table.reloadRow(at: IndexPath(row: index, section: 0), with: .none)
                }
            }
        }
        
        self.navigationController?.pushViewController(editPostVC, animated: true)
    }
    
    func didClickDisableCommentButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        let model = datasource[feedIndex.row]
        guard let feedId = model.id["feedId"] else {
            return
        }
        let isCommentDisabled = (model.toolModel?.isCommentDisabled)! ? false : true
        // 刷新界面
        
        TSMomentNetworkManager().commentPrivacy(isCommentDisabled == false ? 0 : 1, feedIdentity: feedId) { [weak self] (result) in
            if result == true {
                self?.datasource[feedIndex.row].toolModel?.isCommentDisabled = isCommentDisabled
                DispatchQueue.main.async {
                    self?.table.reloadRow(at: feedIndex, with: .none)
                    
                    if isCommentDisabled == true {
                        self?.showTopFloatingToast(with: "disable_comment_success".localized, desc: "")
                    } else {
                        self?.showTopFloatingToast(with: "enable_comment_success".localized, desc: "")
                    }
                }
            }
        }
    }
    
    /// 私信
    func didClickMessageButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, model: TSmessagePopModel) {
        let chooseFriendVC = ContactsPickerViewController(model: model, configuration: ContactsPickerConfig.shareToChatConfig(), finishClosure: nil)
        let nav = TSNavigationController(rootViewController: chooseFriendVC).fullScreenRepresentation
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    /// 举报
    func didClickReportButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        let model = datasource[feedIndex.row]
        let reportTarget = ReportTargetModel(feedModel: model)
        let reportVC: ReportViewController = ReportViewController(reportTarget: reportTarget!)
        let nav = TSNavigationController(rootViewController: reportVC).fullScreenRepresentation
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    /// 收藏
    func didClickCollectionButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        let model = datasource[feedIndex.row]
        guard let feedId = model.id["feedId"] else {
            return
        }
        let isCollect = (model.toolModel?.isCollect).orFalse ? false : true
        TSMomentNetworkManager().colloction(isCollect ? 1 : 0, feedIdentity: feedId, feedItem: model) { [weak self] (result) in
            if result == true {
                // 刷新界面
                self?.datasource[feedIndex.row].toolModel?.isCollect = isCollect
                
                DispatchQueue.main.async {
                    self?.table.reloadRow(at: feedIndex, with: .none)
                    shareView.updateView(tag: fatherViewTag, iscollect: isCollect)
                    if isCollect {
                        self?.showTopFloatingToast(with: "success_save".localized, desc: "")
                    }
                }
            }
        }
        FeedListNetworkManager.behaviorUserFeed(bhv_type: "collect", scene_id: feedType.rawValue, feed_id: feedId.stringValue) { [weak self] (message, code, status) in
            guard let self = self else { return }
            if status == true {
                print("收藏行为上报成功")
            }
        }
    }
    
    /// 删除
    func didClickDeleteButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        let model = datasource[feedIndex.row]
        guard let feedId = model.id["feedId"] else {
            return
        }
        if model.isPinned {
            self.showDialog(image: nil, title: "pin_confirm_to_delete_title".localized, message: "pin_confirm_to_delete_desc".localized, dismissedButtonTitle: "delete".localized, onDismissed: { [weak self] in
                guard let self = self else { return }
                TSMomentNetworkManager().deleteMoment(feedId) { [weak self] (result) in
                    guard let self = self else { return }
                    
                    if feedIndex.row >= 0 && feedIndex.row < self.datasource.count && result == true {
                        self.datasource.remove(at: feedIndex.row)
                        DispatchQueue.main.async {
                            self.table.reloadData()
                        }
                    }
                }
            }, onCancelled: nil, cancelButtonTitle: "cancel".localized)
        } else {
            let alertVC = TSAlertController.deleteConfirmAlert(deleteActionTitle: "delete_feed".localized) {
                TSMomentNetworkManager().deleteMoment(feedId) { [weak self] (result) in
                    guard let self = self else { return }
                    
                    if feedIndex.row >= 0 && feedIndex.row < self.datasource.count && result == true {
                        self.datasource.remove(at: feedIndex.row)
                        DispatchQueue.main.async {
                            self.table.reloadData()
                        }
                    }
                }
            }
            UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: false, completion: nil)
        }
    }
    
    /// 转发
    func didClickRepostButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?) {
        let model = datasource[feedIndex!.row]
        
        let repostModel = TSRepostModel(model: model)
        let releaseVC = TSReleasePulseViewController(isHiddenshowImageCollectionView: true, isReposting:true)
        releaseVC.repostModel = repostModel
        let navigation = TSNavigationController(rootViewController: releaseVC).fullScreenRepresentation
        self.navigationController?.present(navigation, animated: true, completion: nil)
    }
    
    func didClickShareExternal(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, items: [Any]) {
        if let model = datasource[safe: fatherViewTag] {
            guard let feedId = model.id["feedId"] else {
                return
            }
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.parent?.view
            self.navigationController?.present(activityVC, animated: true, completion: nil)
      
            FeedListNetworkManager.behaviorUserFeed(bhv_type: "share", scene_id: feedType.rawValue, feed_id: feedId.stringValue) { [weak self] (message, code, status) in
                guard let self = self else { return }
                if status == true {
                    print("分享行为上报成功")
                }
            }
        }
    }
    
    func didClickShareQr(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, items: [Any]) {
    }
    
    func didClickBlackListButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?) {
        guard let feedIndex = feedIndex else { return }
        self.datasource.remove(at: feedIndex.row)
        self.table.deleteRow(at: feedIndex, with: .automatic)
        let model = datasource[feedIndex.row]
        
        FeedListNetworkManager.behaviorUserFeed(bhv_type: "dislike", scene_id: feedType.rawValue, feed_id: model.idindex.stringValue) { [weak self] (message, code, status) in
            guard let self = self else { return }
            if status == true {
                print("负反馈行为上报成功")
            }
        }
    }
    
    func didClickHideAdsButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?) {
        guard let feedIndex = feedIndex, feedIndex.row < datasource.count else { return }
        let model = datasource[feedIndex.row]
        
        EventTrackingManager.instance.track(event: .hideSponsoredAds, with: ["Feed ID": model.idindex])
        
        FeedListNetworkManager.deleteSponsorFeed(feedId: model.idindex) { [weak self] isSuccess in
            DispatchQueue.main.async {
                if isSuccess {
                    self?.datasource.remove(at: feedIndex.row)
                    self?.table.deleteRow(at: feedIndex, with: .fade)
                } else {
                    self?.showError()
                }
            }
        }
        
    }
    
    func didClickPinButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        let model = datasource[feedIndex.row]
        guard let feedId = model.id["feedId"] else {
            return
        }
        FeedListNetworkManager.pinFeed(feedId: feedId) { [weak self] (errMessage, statusCode, status) in
            guard let self = self else { return }
            guard status == true else {
                if statusCode == 241 {
                    self.showDialog(image: nil, title: "fail_to_pin_title".localized, message: "fail_to_pin_desc".localized, dismissedButtonTitle: "ok".localized, onDismissed: nil, onCancelled: nil)
                } else {
                    self.showError(message: errMessage)
                }
                return
            }
            model.isPinned = true
            self.showError(message: "feed_pinned".localized)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPinnedFeed"), object: nil, userInfo: ["isPinned": true, "feedId": feedId])
        }
    }
    
    func didClickUnpinButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        let model = datasource[feedIndex.row]
        guard let feedId = model.id["feedId"] else {
            return
        }
        FeedListNetworkManager.unpinFeed(feedId: feedId) { [weak self] (errMessage, statusCode, status) in
            guard let self = self else { return }
            guard status == true else {
                self.showError(message: errMessage)
                return
            }
            model.isPinned = false
            self.showError(message: "feed_unpinned".localized)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPinnedFeed"), object: nil, userInfo: ["isPinned": false, "feedId": feedId])
        }
    }
}

