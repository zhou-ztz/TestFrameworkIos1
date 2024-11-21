//
//  BaseFeedCollectionController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/10/10.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

import StoreKit

class BaseFeedCollectionController: ContentBaseFrameController {
    var feedType: FeedListType {
        return .recommend
    }
    
    var country: String? {
        return nil
    }
    var needShowTaskView: Bool = false
    var progressViewCount: Int = 1
    var networkError: Bool = false
    
    lazy var collectionView: TSCollectionView = {
        let flowLayout = FeedListCollectionLayout()
        flowLayout.delegate = self
        
        let collection = TSCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.backgroundColor = .white
        collection.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        collection.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        collection.mj_footer.makeHidden()
        collection.showsVerticalScrollIndicator = false
        collection.register(FeedListCollectionViewCell.self, forCellWithReuseIdentifier: FeedListCollectionViewCell.cellIdentifier)
        // 注册头部视图
        collection.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderViewIdentifier")
        collection.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FooterViewIdentifier")

        collection.dataSource = self
        collection.delegate = self
        collection.setPlaceholderBackgroundGrey()
        return collection
    }()
    
    var datasource = [FeedListCellModel]() {
        didSet {
            if datasource.isEmpty == true {
                if TSReachability.share.isReachable() && !networkError {
                    self.collectionView.show(placeholderView: .empty)
                } else {
                    self.collectionView.show(placeholderView: .network)
                }
            } else {
                self.collectionView.removePlaceholderView()
                self.placeholderView.removeFromSuperview()
            }
        }
    }
    
    var lastItemID: Int = 0
    var onToolbarUpdate: onToolbarUpdate?
    var isGlobalSearch: Bool = false
    var placeholderView: UIView = UIView(bgColor: .clear)
    let createPostButton = UIButton()
    let rejectedPostButton = UIButton()
    weak private var _parentVC: UIViewController? {
        return parentVC ?? self
    }
    
    deinit {
//        collectionView.dataSource = nil
//        collectionView.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    //是否正在下拉加载
    var isLoadMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareSkelViews()
        
        self.onToolbarUpdate = { [weak self] model in
            guard let index = self?.datasource.firstIndex(where: { $0.idindex == model.idindex }) else { return }
            self?.updateToolbar(model, at: index)
            
            self?.reloadCollection()
        }
        homeDashboardReload()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFeedDeleteCell(notice:)), name: NSNotification.Name(rawValue: "feedDelete"), object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeReactionHandler()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func prepareSkelViews() {
        super.prepareSkelViews()
        contentView.addSubview(collectionView)
        collectionView.bindToEdges()
        setFeedBarButtonButton()
    }
    
    // MARK: - 设置发起聊天按钮（设置右上角按钮）
    func setFeedBarButtonButton() {
        rejectedPostButton.setTitle("rejected_post".localized, for: .normal)
        rejectedPostButton.setTitleColor(UIColor(hex: FeedIMSDKManager.shared.param.themeColor), for: .normal)
        rejectedPostButton.set(font: .systemFont(ofSize: 14))
        createPostButton.setImage(UIImage.set_image(named: "iconsAddmomentBlack"), for: UIControl.State.normal)
        createPostButton.addAction { [weak self] in
            self?.postFeedButtonTapped()
        }
        rejectedPostButton.addAction { [weak self] in
            let vc = TSRejectListController()
            self?.navigationController?.pushViewController(vc, animated: true)
            if let nav = vc.navigationController as? TSNavigationController {
                nav.setCloseButton(backImage: true, titleStr: "rejected_post".localized, customView: nil)
            }
        }
        let createPost = UIBarButtonItem(customView: createPostButton)
        let rejectedPost = UIBarButtonItem(customView: rejectedPostButton)
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 12
        //        self.navigationItem.rightBarButtonItems = [createPost, space, searchView, space, filterView]
        self.navigationItem.rightBarButtonItems = [createPost, space, rejectedPost]
    }
    @objc private func postFeedButtonTapped() {
        guard TSCurrentUserInfo.share.isLogin == true else {
            TSRootViewController.share.guestJoinLandingVC()
            return
        }
        guard PostTaskManager.shared.isAbleToPost() else {
            self.showError(message: "feed_upload_max_error".localized)
            return
        }
        self.postFeedCenterButtonTapped(createPostButton)
    }
    @objc func refresh() {
        defer {
            self.collectionView.reloadData()
        }
        fetch()
    }
    
    @objc func homeDashboardReload() {
        if let models = FeedsStoreManager().fetch(by: self.feedType)?.reversed().compactMap { $0 } , models.count > 0, self.datasource.count == 0 {
            var datas: [FeedListModel] = []
            datas = models
            self.datasource = datas.compactMap { FeedListCellModel(feedListModel: $0) }
            self.collectionView.reloadData()
        } else {
            self.fetch()
        }
    }
    
    func postFeedCenterButtonTapped(_ button: UIButton) {
    
        var data = [TSToolModel]()
        var titles: [String] = []
        var images: [String] = []
        var types: [TSToolType] = []
      
        //显示、图片、视频、小视频
        titles = ["photo".localized, "mini_video".localized]
        images = ["ic_rl_feed_photo", "ic_rl_feed_video"]
        types = [.photo, .miniVideo]
        
        for i in 0 ..< titles.count {
            let model = TSToolModel(title: titles[i], image: images[i], type: types[i])
            data.append(model)
        }
        let preference = ToolChoosePreferences()
        preference.drawing.bubble.color = .white
        preference.drawing.message.color = UIColor(hex: 0x242424)
        preference.drawing.button.color = UIColor(hex: 0x242424)
        button.showToolChoose(identifier: "", data: data, arrowPosition: .top, preferences: preference, delegate: self, isMessage: false)

    }
    
    
    func fetch() {
        FeedListNetworkManager.getTypeFeeds(type: self.feedType.rawValue, offset: 0, after: nil, country: country) { [weak self] (results, message, status) in
            guard let self = self else { return }
            self.networkError = false
            DispatchQueue.main.async {
                guard status == true else {
                    self.networkError = true
                    self.collectionView.mj_header.endRefreshing()
                    /// Old Logic when error will fetch feed cache
//                    if let models = FeedsStoreManager().fetch(by: self.feedType), models.count > 0 {
//                        self.datasource = models.compactMap { FeedListCellModel(feedListModel: $0) }
//                        self.collectionView.reloadData()
//                        self.collectionView.mj_footer.makeVisible()
//                    } else {
//                        self.datasource = []
//                    }
                    self.collectionView.mj_footer.makeHidden()
                    self.datasource = []
                    self.collectionView.reloadData()
                    return
                }
                
                guard let feeds = results?.feeds, feeds.count > 0 else {
                    self.collectionView.mj_header.endRefreshing()
                    self.collectionView.mj_footer.makeHidden()
                    self.datasource = []
                    self.collectionView.reloadData()
                    return
                }
                
                if UserDefaults.teenModeIsEnable && self.feedType.rawValue == "follow" {
                    self.collectionView.mj_footer.makeHidden()
                    self.datasource = []
                    self.collectionView.reloadData()
                    self.collectionView.mj_header.endRefreshing()
                } else {
                    FeedsStoreManager().reset(feeds, for: self.feedType)
                    let cellModels = (feeds.compactMap { FeedListCellModel(feedListModel: $0) })
                    self.datasource = cellModels
                    self.lastItemID = self.datasource.last?.idindex ?? 0
                    
                    self.collectionView.reloadData()
                    if self.collectionView.mj_header != nil {
                        self.collectionView.mj_header.endRefreshing()
                    }
                    self.collectionView.mj_footer.makeVisible()
                    if cellModels.count <= 0 {
                        self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                    }
                }
            }
        }
    }

    @objc func loadMore() {
        isLoadMore = true
        FeedListNetworkManager.getTypeFeeds(type: self.feedType.rawValue, offset: datasource.count, after: lastItemID, country: country) { [weak self] (results, message, status) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard status else {
                    self.collectionView.mj_footer.endRefreshingWithWeakNetwork()
                    self.isLoadMore = false
                    return
                }
                if let feeds = results?.feeds, feeds.count > 0 {
                    FeedsStoreManager().save(feeds, for: self.feedType)
                    let cellModels = feeds.compactMap { FeedListCellModel(feedListModel: $0) } ?? []
                    var filteredCells = self.datasource
                    filteredCells.append(contentsOf: cellModels)
                    filteredCells = filteredCells.filterDuplicates({ $0.idindex })
                    
                    self.datasource = filteredCells
                    
                    // By Kit Foong (Insert item instead of reload data)
                    
                    //self.datasource.append(contentsOf: cellModels)
                    self.reloadCollection()
                    
                    self.lastItemID = self.datasource.last?.idindex ?? 0
                    self.collectionView.mj_footer.endRefreshing()
                } else {
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }
                DispatchQueue.main.asyncAfter(deadline: Dispatch.DispatchTime.now() + 0.3) {
                    self.isLoadMore = false
                }
            }
        }
    }
    
    @objc func updateFeedDeleteCell(notice: NSNotification) {
        guard let userInfo = notice.userInfo else { return }
        guard let feedId = userInfo["feedId"] as? Int else { return }
        guard let index = self.datasource.firstIndex(where: { $0.idindex == feedId }), index < self.datasource.count else { return }
        self.datasource.remove(at: index)
        self.collectionView.reloadData()
    }
    
    public func updateToolbar(_ model: FeedListCellModel, at index: Int) {
        self.datasource[index].reactionType = model.reactionType
        self.datasource[index].topReactionList = model.topReactionList
        self.datasource[index].toolModel = model.toolModel
    }
    
    func tapHandler(at index: Int) {
        let model = self.datasource[index]
        switch model.feedType {
        case .miniVideo:
            let vc = MiniVideoPageViewController(type: self.feedType, videos: [model], focus: 0, onToolbarUpdate: self.onToolbarUpdate, tagVoucher: model.tagVoucher)
            if isGlobalSearch {
                _parentVC?.present(TSNavigationController(rootViewController: vc).fullScreenRepresentation, animated: true, completion: nil)
            }else{
                vc.isControllerPush = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case .video:
            let detailVC = FeedInfoDetailViewController(feedId: model.idindex, isTapMore: false, isClickCommentButton: false, isVideoFeed: true, onToolbarUpdated: self.onToolbarUpdate)
            detailVC.setCloseButton(backImage: true)
            detailVC.model = model
            detailVC.type = self.feedType
            detailVC.afterTime = model.afterTime
            detailVC.onDismiss = { [weak self] time in
           
            }
            _parentVC?.present(TSNavigationController(rootViewController: detailVC).fullScreenRepresentation, animated: true, completion: nil)
        default:
            FeedListCellActionManager.shared.didClickCell(parentVC: _parentVC, model: model, atIndex: index, feedListType: feedType, onToolbarUpdated: self.onToolbarUpdate)
            break
        }
        
        //上报动态点击事件
        EventTrackingManager.instance.trackEvent(
            itemId: model.idindex.stringValue,
            itemType: model.feedType == .miniVideo ? ItemType.shortvideo.rawValue   : ItemType.image.rawValue,
            behaviorType: BehaviorType.click,
            sceneId: "",
            moduleId: ModuleId.feed.rawValue,
            pageId: PageId.feed.rawValue)
    }
    
    public func reloadCollection() {
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
    }
    
    /// 上报动态曝光事件
    func submitExposeEventWithFeedModel(_ model: FeedListCellModel) {
        EventTrackingManager.instance.trackEvent(
            itemId: model.idindex.stringValue,
            itemType: model.feedType == .miniVideo ? ItemType.shortvideo.rawValue   : ItemType.image.rawValue,
            behaviorType: BehaviorType.expose,
            sceneId: "",
            moduleId: ModuleId.feed.rawValue,
            pageId: PageId.feed.rawValue)
    }
    
    func removeReactionHandler() {
        self.collectionView.visibleCells.forEach { cell in
            if let indexPath = self.collectionView.indexPath(for: cell) {
                guard let cell = cell as? FeedListCollectionViewCell else { return }
                cell.resetReactHandler()
            }
        }
    }
}

extension BaseFeedCollectionController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedListCollectionViewCell.cellIdentifier, for: indexPath) as? FeedListCollectionViewCell, let model = datasource[safe: indexPath.item] {
            cell.model = model
            
            cell.onReactionSuccess = { [weak self] in
                FeedListNetworkManager.getMomentFeed(id: model.idindex) { [weak self] (model, message, status, networkResult) in
                    guard let self = self, let model = model, status else { return }
                    
                    guard indexPath.row < self.datasource.count else {
                        return
                    }
                    let cellModel = FeedListCellModel(feedListModel: model)
                    self.updateToolbar(cellModel, at: indexPath.row)
                }
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.tapHandler(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderViewIdentifier", for: indexPath)
            tableStack.frame = CGRectMake(0, 0, UIScreen.main.bounds.width, needShowTaskView ? CGFloat(self.progressViewCount * 50) : 0)
            headerView.addSubview(tableStack)
            return headerView
        }
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterViewIdentifier", for: indexPath)
            return footerView
        }
        return UICollectionReusableView()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 获取collectionView的可见区域
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        
        // 获取可见区域内的所有cell的indexPaths
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        for indexPath in visibleIndexPaths {
            // 获取cell对应的布局属性
            guard let attributes = collectionView.layoutAttributesForItem(at: indexPath) else { continue }
            
            // 计算cell在可见区域内的交集
            let intersection = visibleRect.intersection(attributes.frame)
            
            // 计算cell在可见区域内的可见比例
            let visibleRatio = intersection.width * intersection.height / (attributes.frame.width * attributes.frame.height)
            
            // 如果可见比例超过50%，则记录该cell
            if visibleRatio >= 0.5 {
                guard indexPath.item < datasource.count else {
                    return
                }
                let model =  datasource[indexPath.item]
                printIfDebug("Cell at indexPath \(indexPath) is at least 50% visible")
                self.submitExposeEventWithFeedModel(model)
            }
        }
    }
}

extension BaseFeedCollectionController: FeedListCollectionLayoutDelegate {
    func heightForRowAtIndexPath(collectionView collection: UICollectionView, layout: FeedListCollectionLayout, indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
        let datacell = datasource[indexPath.row]
        
        if datacell.pictures.count == 0 {
            return CGFloat(100)
        }
        let originalWidth: CGFloat = datacell.pictures[0].originalSize.width
        let originalHeight: CGFloat = datacell.pictures[0].originalSize.height
        let fixedWidth: CGFloat = (UIScreen.main.bounds.width - 10) / 2
        let scaleFactor = fixedWidth / originalWidth
        //底部视图高度
        let bottomViewHeight = 70.0
        //计算出最新高度
        let newHeight = originalHeight * scaleFactor + bottomViewHeight
        //默认高度
        let normalImageHeight = fixedWidth + bottomViewHeight
        
        return newHeight > normalImageHeight ? newHeight : normalImageHeight
    }
    
    func columnNumber(collectionView collection: UICollectionView, layout: FeedListCollectionLayout, section: Int) -> Int {
        return 2
    }
    
    func insetForSection(collectionView collection: UICollectionView, layout: FeedListCollectionLayout, section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func lineSpacing(collectionView collection: UICollectionView, layout: FeedListCollectionLayout, section: Int) -> CGFloat {
        return 5
    }
    
    func interitemSpacing(collectionView collection: UICollectionView, layout: FeedListCollectionLayout, section: Int) -> CGFloat {
        return 5
    }
    
    func referenceSizeForHeader(collectionView collection: UICollectionView, layout: FeedListCollectionLayout, section: Int) -> CGSize {
        return CGSizeMake(UIScreen.main.bounds.width, needShowTaskView ? CGFloat(self.progressViewCount * 50) : 0)
    }
}

extension BaseFeedCollectionController:  ToolChooseDelegate{
    public func didSelectedItem(type: TSToolType, title: String) {
        switch type {
        case .photo:
            self.presentPostPhoto()
    
        case .miniVideo:
            self.presentMiniVideo()
        default:
            break
        }
    }
    func presentPostPhoto() {
        guard TSCurrentUserInfo.share.isLogin == true else { return }
        self.showCameraVC(true, onSelectPhoto: { [weak self] (assets, _, _, _, _) in
            let releasePulseVC = TSReleasePulseViewController(isHiddenshowImageCollectionView: false)
            releasePulseVC.selectedPHAssets = assets
            let navigation = TSNavigationController(rootViewController: releasePulseVC).fullScreenRepresentation
            if let presentedView = self?.presentedViewController {
                presentedView.dismiss(animated: false, completion: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (TSRootViewController.share.launchScreenDismissWithDelay())) {
                self?.present(navigation, animated: true, completion: nil)
            }
        })
    }
    func presentMiniVideo() {
        DispatchQueue.main.async {
            let nav = TSNavigationController(rootViewController: MiniVideoRecorderViewController()).fullScreenRepresentation
            self.present(nav, animated: true, completion: nil)
        }
    }
}
