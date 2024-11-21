//
//  HashtagGalleryViewController.swift
//  Yippi
//
//  Created by Jerry Ng on 22/03/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation
import SDWebImage

class HashtagGalleryViewController: TSViewController, UICollectionViewDelegate {
    
    private var feeds: [FeedListModel] = []
    private var trendingPhotos: [TrendingPhotoModel] = []
    
    private(set) var hashtagId : Int
    weak var scrollDelegate: TSScrollDelegate?
    
    lazy var collectionView: TSCollectionView = {
        let flowLayout = SquareFlowLayout()
        let collection = TSCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collection.backgroundColor = TSColor.inconspicuous.background
        collection.mj_header = nil
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
    
    public var onChildFetched: ((HashtagDetailModel?)->())? = nil
    public var onBannerLoaded: ((HashtagBannerModel)->())? = nil
    
    init(hashtagId: Int) {
        self.hashtagId = hashtagId
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
    }
    
    func loadMoreData() {
        loadMoreDataSource()
    }
    
    public func loadDataSource() {
        HashtagRequest().getHashtagDetail(type: "photo", hashtagId: self.hashtagId) { [weak self] (responseModels) in
            DispatchQueue.main.async {
                guard let self = self, let models = responseModels, models.feeds.isEmpty == false else {
                    self?.collectionView.show(placeholderView: .empty)
                    self?.collectionView.mj_footer.endRefreshing()
                    self?.onChildFetched?(nil)
                    return
                }
                self.collectionView.removePlaceholderView()
                if let bannerModel = models.data {
                    self.onBannerLoaded?(bannerModel)
                }
                self.feeds = models.feeds
                let images = models.feeds.compactMap { feed in
                    feed.images?.compactMap { TrendingPhotoModel(feedId: feed.id, imageId: $0.file) }
                }.flatMap { $0 }
                self.trendingPhotos = images
                GalleryStoreManager().reset(objects: images, for: .hashtag(id: self.hashtagId))
                
                self.collectionView.reloadData()
                self.onChildFetched?(models)
                
                if models.feeds.count < TSAppConfig.share.localInfo.limit {
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.collectionView.mj_footer.endRefreshing()
                }
            }
        } onFailure: { [weak self] (errorMessage) in
            DispatchQueue.main.async {
                defer {
                    self?.onChildFetched?(nil)
                    self?.collectionView.mj_footer.endRefreshingWithWeakNetwork()
                }
                guard let self = self else { return }
                self.trendingPhotos = GalleryStoreManager().get(for: .hashtag(id: self.hashtagId))
                if self.trendingPhotos.count > 0 {
                    self.collectionView.removePlaceholderView()
                } else {
                    self.collectionView.show(placeholderView: .network)
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    private func loadMoreDataSource() {
        guard let lastFeedId = self.feeds.last?.id else { return }
        HashtagRequest().getHashtagDetail(type: "photo", hashtagId: self.hashtagId, limit: TSAppConfig.share.localInfo.limit, after: lastFeedId) { [weak self] (responseModels) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let models = responseModels else {
                    self?.collectionView.mj_footer.endRefreshing()
                    return
                }
                self.collectionView.removePlaceholderView()
                let images = models.feeds.compactMap { feed in
                    feed.images?.compactMap { TrendingPhotoModel(feedId: feed.id, imageId: $0.file) }
                }.flatMap { $0 }
                GalleryStoreManager().save(gallery: images, for: .hashtag(id: self.hashtagId))
                self.trendingPhotos.append(contentsOf: images)
                
                guard self.trendingPhotos.count > 0 else {
                    self.collectionView.mj_footer.endRefreshing()
                    self.collectionView.show(placeholderView: .empty)
                    return
                }
                UIView.performWithoutAnimation {
                    let contentOffset = self.collectionView.contentOffset
                    self.collectionView.reloadData()
                    self.collectionView.contentOffset = contentOffset
                }
                            
                if models.feeds.count < TSAppConfig.share.localInfo.limit {
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.collectionView.mj_footer.endRefreshing()
                }
            }
        } onFailure: { [weak self] (errorMessage) in
            DispatchQueue.main.async {
                self?.collectionView.mj_footer.endRefreshingWithWeakNetwork()
                self?.collectionView.removePlaceholderView()
            }
        }
    }
    
    
    func url(at index: Int) -> URL? {
        guard let url = self.trendingPhotos[index].imageURL else {
            return nil
        }
        return URL(string: url)
    }
    
    
    @objc private func momentDetailVCDelete(noti: Notification) {
        if let info = noti.userInfo, let feedId = info["feedId"] as? Int {
            if let photoIndexToBeRemove = self.trendingPhotos.firstIndex(where: { $0.feedId == feedId }) {
                trendingPhotos.remove(at: photoIndexToBeRemove)
                self.collectionView.reloadData()
            }
        }
    }
    
}

extension HashtagGalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = trendingPhotos[indexPath.row]
        
        self.showLoading()
        
        FeedListNetworkManager.getMomentFeed(id: data.feedId) { [weak self] model, errorMessage, status, networkResult in
            
            defer {
                DispatchQueue.main.async {
                    self?.dismissLoading()
                }
            }
            
            guard let self = self, let listModel = model, status == true else {
                return
            }
            
            let cellModel = FeedListCellModel(feedListModel: listModel)
            
            DispatchQueue.main.async {
                switch cellModel.feedType {
                case .miniVideo:
                    let player = MiniVideoPageViewController(type: .hot, videos: [cellModel], focus: 0, onToolbarUpdate: nil, tagVoucher: cellModel.tagVoucher)
                    self.parent?.navigationController?.navigation(navigateType: .presentView(viewController: player.fullScreenRepresentation))
                case .picture:
                    self.parent?.navigationController?.navigation(navigateType: .innerFeedSingle(feedId: cellModel.idindex, placeholderImage: nil, transitionId: UUID().uuidString, imageId: 0))
                default:
                    self.parent?.navigationController?.pushToFeedDetail(feedId: data.feedId, isTapMore: false, isClickCommentButton: false, onToolbarUpdated: nil)
                }
            }
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
        cell.imageView.sd_setImage(with: url(at: indexPath.row), placeholderImage: nil, options: [SDWebImageOptions.lowPriority, .decodeFirstFrameOnly], completed: nil)
        cell.playPlaceholderImageView.isHidden = true
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
