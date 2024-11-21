//
//  TSHomepageGalleryCollageView.swift
//  Yippi
//
//  Created by CC Teoh on 24/07/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import SDWebImage


/// 图集类型
enum GalleryType {
    case post
    case tagged
    case saved
}


class TSHomepageGalleryCollageView: TSViewController, UICollectionViewDelegate, ProfileRefreshProtocol {
    private var trendingPhotos: [FeedListCellModel] = []
    
    var galleryType: GalleryType = .post
    
    private(set) var userId : Int
    weak var scrollDelegate: TSScrollDelegate?
    private var isNoMoreItem: Bool = false
    private var shouldReloadDataSource = false
    private var taggedOffset: Int = 0
    private var savedOffset: Int = 0
    lazy var collectionView: TSCollectionView = {
        let flowLayout = SquareFlowLayout()
        let collection = TSCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collection.backgroundColor = .white
        collection.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(profileDidRefresh))
        collection.mj_footer = TSRefreshFooter(refreshingBlock: { [weak self] in
            self?.loadMoreData()
        })
        collection.showsVerticalScrollIndicator = false
        collection.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        collection.dataSource = self
        collection.delegate = self
        collection.setPlaceholderBackgroundGrey()
        return collection
    }()
    
    enum CellType {
        case normal
        case expanded
    }
    
    var refreshData: EmptyClosure?
    
    init(userId: Int, galleryType: GalleryType = .post) {
        self.userId = userId
        self.galleryType = galleryType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(collectionView)
        collectionView.bindToEdges()
        
        loadDataSource()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePinnedCell(notice:)), name: NSNotification.Name(rawValue: "newPinnedFeed"), object: nil)
        
        //
        NotificationCenter.default.addObserver(self, selector: #selector(updateFeedDeleteCell(notice:)), name: NSNotification.Name(rawValue: "feedDelete"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldReloadDataSource {
            refreshData?()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func updatePinnedCell(notice: NSNotification) {
        guard let userInfo = notice.userInfo else { return }
        guard let feedId = userInfo["feedId"] as? Int, let isPinned = userInfo["isPinned"] as? Bool else { return }
        guard let index = trendingPhotos.firstIndex(where: { $0.id["feedId"] == feedId }) else { return }
        trendingPhotos[index].isPinned = isPinned
        shouldReloadDataSource = true
    }
    
    @objc func updateFeedDeleteCell(notice: NSNotification) {
        guard let userInfo = notice.userInfo else { return }
        guard let feedId = userInfo["feedId"] as? Int else { return }
        guard let index = trendingPhotos.firstIndex(where: { $0.idindex == feedId }), index < trendingPhotos.count else { return }
        self.trendingPhotos.remove(at: index)
        self.collectionView.reloadData()
    }

    
    func loadMoreData() {
        loadMoreDataSource()
    }
    
    public func loadDataSource() {
        
        self.trendingPhotos = []
        
        if userId > 0 {
            if galleryType == .post {
                FeedListNetworkManager.getUserTrendingPhotos(userId: userId, limit: 12, after: nil, completion: { [weak self] (data, status) in
                    DispatchQueue.main.async {
                        defer {
                            self?.collectionView.mj_header.endRefreshing()
                            self?.collectionView.mj_footer.endRefreshing()
                        }
                        guard status == true else {
                            self?.collectionView.show(placeholderView: .network)
                            return
                        }
                        
                        guard data.isEmpty == false else {
                            self?.collectionView.show(placeholderView: .empty)
                            return
                        }
                        self?.collectionView.removePlaceholderView()
                        self?.trendingPhotos = data
                        self?.collectionView.reloadData()
                    }
                })
            }
            
            if galleryType == .tagged {
                FeedListNetworkManager.getUserTaggedList(limit: 12, offset: 0, userId: userId, completion: { [weak self] (data, status) in
                    DispatchQueue.main.async {
                        defer {
                            self?.collectionView.mj_header.endRefreshing()
                            self?.collectionView.mj_footer.endRefreshing()
                        }
                        guard status == true else {
                            self?.collectionView.show(placeholderView: .network)
                            return
                        }
                        
                        guard data.isEmpty == false else {
                            self?.collectionView.show(placeholderView: .empty)
                            return
                        }
                        self?.collectionView.removePlaceholderView()
                        self?.trendingPhotos = data
                        self?.taggedOffset = data.count
                        self?.collectionView.reloadData()
                    }
                })
            }
            
            if galleryType == .saved {
                self.trendingPhotos = []
                FeedListNetworkManager.getCollectFeeds(offset: 0) { [weak self] (status, message, data) in
                    DispatchQueue.main.async {
                        defer {
                            self?.collectionView.mj_header.endRefreshing()
                            self?.collectionView.mj_footer.endRefreshing()
                        }
                        guard status == true, let data  = (data?.compactMap { FeedListCellModel(feedListModel: $0) }) else {
                            self?.collectionView.show(placeholderView: .network)
                            return
                        }
                        guard data.isEmpty == false else {
                            self?.collectionView.show(placeholderView: .empty)
                            return
                        }
                        self?.collectionView.removePlaceholderView()
                        self?.trendingPhotos = data
                        self?.savedOffset = data.count
                        self?.collectionView.reloadData()
                    }
                }
            }
        } else {
            self.collectionView.show(placeholderView: .empty)
        }
    }
    
    public func loadMoreDataSource() {
        let after = trendingPhotos.last?.id["feedId"]
        if galleryType == .post {
            guard let after = after, after > 0 else {
                return
            }
            FeedListNetworkManager.getUserTrendingPhotos(userId: userId, limit: 12, after: after, completion: { [weak self] (data, status) in
                guard let weakSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    weakSelf.trendingPhotos.append(contentsOf: data)
                    guard status == true, weakSelf.trendingPhotos.count > 0 else {
                        weakSelf.collectionView.mj_footer.endRefreshing()
                        return
                    }
                    
                    UIView.performWithoutAnimation {
                        let contentOffset = weakSelf.collectionView.contentOffset
                        weakSelf.collectionView.reloadData()
                        weakSelf.collectionView.contentOffset = contentOffset
                    }
                    
                    weakSelf.collectionView.mj_footer.endRefreshing()
                    
                    if data.count == 0 {
                        weakSelf.isNoMoreItem = true
                        weakSelf.collectionView.mj_footer.endRefreshingWithNoMoreData()
                    }
                }
            })
            
        }
        if galleryType == .tagged {
            
            FeedListNetworkManager.getUserTaggedList(limit: 12, offset: taggedOffset == 0 ? 12 :taggedOffset, userId: userId, completion: { [weak self] (data, status) in
                guard let weakSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    weakSelf.trendingPhotos.append(contentsOf: data)
                    weakSelf.taggedOffset = weakSelf.trendingPhotos.count
                    guard status == true, weakSelf.trendingPhotos.count > 0 else {
                        weakSelf.collectionView.mj_footer.endRefreshing()
                        return
                    }
                    
                    UIView.performWithoutAnimation {
                        let contentOffset = weakSelf.collectionView.contentOffset
                        weakSelf.collectionView.reloadData()
                        weakSelf.collectionView.contentOffset = contentOffset
                    }
                    
                    weakSelf.collectionView.mj_footer.endRefreshing()
                    
                    if data.count == 0 {
                        weakSelf.isNoMoreItem = true
                        weakSelf.collectionView.mj_footer.endRefreshingWithNoMoreData()
                    }
          
                }
            })
            
        }
        if galleryType == .saved {
            FeedListNetworkManager.getCollectFeeds(offset: savedOffset == 0 ? 12 : savedOffset) { [weak self] (status, message, data) in
                guard let weakSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    guard status == true, let data  = (data?.compactMap { FeedListCellModel(feedListModel: $0) }) else {
                        self?.collectionView.show(placeholderView: .network)
                        return
                    }
                    weakSelf.trendingPhotos.append(contentsOf: data)
                    weakSelf.savedOffset = weakSelf.trendingPhotos.count
                    UIView.performWithoutAnimation {
                        let contentOffset = weakSelf.collectionView.contentOffset
                        weakSelf.collectionView.reloadData()
                        weakSelf.collectionView.contentOffset = contentOffset
                    }
                    
                    weakSelf.collectionView.mj_footer.endRefreshing()
                    
                    if data.count == 0 {
                        weakSelf.isNoMoreItem = true
                        weakSelf.collectionView.mj_footer.endRefreshingWithNoMoreData()
                    }
                }
            }
            
        }
    }
    
    
    func url(at index: Int) -> URL? {
        return index < self.trendingPhotos.count ? URL(string: self.trendingPhotos[index].pictures.first?.url ?? "") : URL(string: "")
    }
    
    
    @objc private func momentDetailVCDelete(noti: Notification) {
        if let info = noti.userInfo, let feedId = info["feedId"] as? Int {
            if let photoIndexToBeRemove = self.trendingPhotos.firstIndex(where: { $0.id["feedId"] == feedId }) {
                trendingPhotos.remove(at: photoIndexToBeRemove)
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func profileDidRefresh() {
        loadDataSource()
    }
    
    func updateUserId(_ userId: Int) {
        self.userId = userId
    }
}
//
//extension TSHomepageGalleryCollageView: SquareFlowLayoutDelegate {
//    func shouldExpandItem(at indexPath: IndexPath) -> Bool {
//        return false
//    }
//
//}

extension TSHomepageGalleryCollageView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= trendingPhotos.count {
            return
        }
        let cellModel = trendingPhotos[indexPath.row]
        guard let feedId = cellModel.id["feedId"] else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell else {
            return
        }
        
        switch cellModel.feedType {
        case .miniVideo:
            var player = MiniVideoPageViewController(type: .user(userId: self.userId), videos: [cellModel], focus: 0, onToolbarUpdate: nil, tagVoucher: cellModel.tagVoucher)
            switch self.galleryType {
            case .post:
                player.needReloadHomaPageData = { [weak self] in
                    //此处更新数据
                    self?.profileDidRefresh()
                }
            case .tagged:
                
                player = MiniVideoPageViewController(type: .tagged(userId: self.userId), videos: [cellModel], focus: 0, onToolbarUpdate: nil, tagVoucher: cellModel.tagVoucher)
                
            case .saved:
                player = MiniVideoPageViewController(type: .save(userId: self.userId), videos: [cellModel], focus: 0, onToolbarUpdate: nil, tagVoucher: cellModel.tagVoucher)
                
            }
            player.isControllerPush = true
     
            if let navigationController = self.navigationController {
                self.navigationController?.pushViewController(player, animated: true)
            } else {
                let nav = TSNavigationController(rootViewController: player)
                nav.setCloseButton(backImage: true)
                self.present(nav.fullScreenRepresentation, animated: true, completion: nil)
            }
            //self.parent?.navigationController?.navigation(navigateType: .presentView(viewController: player.fullScreenRepresentation))
            //self.parent?.navigationController?.pushViewController(player, animated: true)
            // By Kit Foong (Use Navigation Controller instead of UIViewController)
            //self.present(TSNavigationController(rootViewController: player).fullScreenRepresentation, animated: true, completion: nil)
        case .picture:
            let detailVC = FeedInfoDetailViewController(feedId: cellModel.idindex, isTapMore: false, isClickCommentButton: false, isVideoFeed: false, onToolbarUpdated: nil)
            switch self.galleryType {
            case .post:
                detailVC.type = .user(userId: self.userId)
            case .tagged:
                detailVC.type = .tagged(userId: self.userId)
            case .saved:
                detailVC.type = .save(userId: self.userId)
            }
            detailVC.transitionId = cell.transitionId
            detailVC.afterTime = cellModel.afterTime
            detailVC.setCloseButton(backImage: true)
            detailVC.onDismiss = { [weak self] time in
        
            }
            detailVC.isHomePage = true
            
            if let navigationController = self.navigationController {
                self.navigationController?.pushViewController(detailVC, animated: true)
            } else {
                let nav = TSNavigationController(rootViewController: detailVC)
                nav.setCloseButton(backImage: true)
                self.present(nav, animated: true, completion: nil)
            }
            //self.parent?.navigationController?.pushViewController(detailVC, animated: true)
            
        default:
            self.parent?.navigationController?.pushToFeedDetail(feedId: feedId, isTapMore: false, isClickCommentButton: false, onToolbarUpdated: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.trendingPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
//        let imageUrl = SDWebImageManager.shared.cacheKey(for: url(at: indexPath.row))
//        if let imageData = SDImageCache.shared.diskImageData(forKey: imageUrl) {
//            // Load image from cache
//            let image = UIImage.sd_image(with: imageData)
//            cell.imageView?.image = image
//        } else {
//            // Load image from URL
//        }
        cell.imageView?.sd_setImage(with: url(at: indexPath.row), placeholderImage:nil)
        
        if let feed = self.trendingPhotos[safe: indexPath.row] {
            cell.playPlaceholderImageView.isHidden = feed.feedType == .video ? false : true
            
            switch feed.feedType {
            case .miniVideo:
                cell.typeIcon.isHidden = false
                cell.typeIcon.image = UIImage.set_image(named: "ic_feed_video_icon")
            case .picture:
                if (self.trendingPhotos[safe: indexPath.row]?.pictures.count ?? 0) > 1 {
                    cell.typeIcon.isHidden = false
                    cell.typeIcon.image = UIImage.set_image(named: "icGalleryMultiPhoto")
                } else {
                    cell.typeIcon.isHidden = true
                }
            default:
                cell.typeIcon.isHidden = true
            }
            
            cell.pinnedIconContainner.isHidden = !feed.isPinned
        } else {
            cell.playPlaceholderImageView.isHidden = true
            cell.typeIcon.isHidden = true
        }
        
        cell.addAction {
            self.collectionView(collectionView, didSelectItemAt: indexPath)
        }
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll(scrollView)
    }
    
}

