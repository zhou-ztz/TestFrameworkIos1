//
//  HashtagLiveViewController.swift
//  Yippi
//
//  Created by Jerry Ng on 22/03/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation

protocol BaseFeedDelegate: class {
    func reloadLive(feedId: Int)
    func dismiss()
}

class HashtagLiveViewController: BaseFeedController {
    
    private var hashtagId: Int
    var delegate: BaseFeedDelegate?
    
    public var onChildFetched: ((HashtagDetailModel?)->())? = nil
    public var onBannerLoaded: ((HashtagBannerModel)->())? = nil

    init(hashtagId: Int) {
        self.hashtagId = hashtagId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.mj_header = nil
        table.placeholder.customBackgroundColor = TSColor.inconspicuous.background

//        self.view.addSubview(feedShimmerView)
//        feedShimmerView.bindToEdges()
        
        fetch()
    }
    
    override func fetch() {
        HashtagRequest().getHashtagDetail(type: "live", hashtagId: self.hashtagId) { [weak self] (responseModels) in
            DispatchQueue.main.async {
                
                defer {
//                    feedShimmerView.removeFromSuperview()
                    self?.table.mj_footer.makeVisible()
                }
                
                guard let wself = self, let models = responseModels else {
                    self?.table.show(placeholderView: .network)
                    self?.datasource.removeAll()
                    self?.table.reloadData()
                    return
                }
                
                if let bannerModel = models.data {
                    self?.onBannerLoaded?(bannerModel)
                }
                
                if models.feeds.count > 0 {
                    wself.datasource = models.feeds.compactMap { FeedListCellModel(feedListModel: $0) }
                    wself.lastItemID = wself.datasource.last?.idindex ?? 0
                    wself.table.removePlaceholderViews()
                } else {
                    wself.table.show(placeholderView: .empty)
                }
                self?.onChildFetched?(models)
                wself.table.reloadData()
            }
        } onFailure: { [weak self] (errorMessage) in
//            feedShimmerView.removeFromSuperview()
            self?.table.show(placeholderView: .network)
            self?.datasource.removeAll()
            self?.table.reloadData()
            self?.onChildFetched?(nil)
        }
    }
    
    override func loadMore() {
        guard let lastFeedId = self.datasource.last?.idindex else { return }
        HashtagRequest().getHashtagDetail(type: "live", hashtagId: self.hashtagId, limit: TSAppConfig.share.localInfo.limit, after: lastFeedId) { [weak self] (responseModels) in
            DispatchQueue.main.async {
                guard let wself = self, let result = responseModels else {
                    self?.table.mj_footer.endRefreshingWithWeakNetwork()
                    return
                }
                guard result.feeds.count > 0 else {
                    wself.table.mj_footer.endRefreshingWithNoMoreData()
                    return
                }
                
                let datas = result.feeds.compactMap { FeedListCellModel(feedListModel: $0) }
                wself.datasource.append(contentsOf: datas)
                wself.lastItemID = wself.datasource.last?.idindex ?? 0
                wself.table.reloadData()
                
                if result.feeds.count == TSAppConfig.share.localInfo.limit {
                    wself.table.mj_footer.endRefreshing()
                } else {
                    wself.table.mj_footer.endRefreshingWithNoMoreData()
                }
            }
        } onFailure: { (errorMessage) in
        }
    }
}
