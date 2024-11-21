//
//  HashtagMiniVideoModel.swift
//  Yippi
//
//  Created by Jerry Ng on 23/03/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

final class HashtagMiniVideoViewModel: NSObject {
    
    private(set) var hashtagId : Int
    var videos: [FeedListCellModel] = []
    private var currentPage = 1
    private var total = 0
    private var isFetchInProgress = false
    
    var currentCount: Int {
        return videos.count
    }
    
    var onFailFetchData: EmptyClosure?
    
    init(hashtagId: Int) {
        self.hashtagId = hashtagId
        super.init()
    }
    
    func fetchData(completion: ((_ hasData: Bool) -> Void)?) {
        guard !isFetchInProgress else { self.onFailFetchData?(); return }
        
        isFetchInProgress = true
        
        HashtagRequest().getHashtagDetail(type: "mini_video", hashtagId: self.hashtagId) {  (responseModels) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.isFetchInProgress = false
                
                guard let models = responseModels else {
                    self.onFailFetchData?()
                    return
                }
                self.videos = models.feeds.compactMap { FeedListCellModel(feedListModel: $0) }
                completion?(self.videos.count > 0)
            }
        } onFailure: { (errorMessage) in
            self.onFailFetchData?()
        }
    }
    
    func loadMore(completion: ((_ hasData: Bool) -> Void)?) {
        guard let lastVideoId = videos.last?.idindex, !isFetchInProgress else { return }
        isFetchInProgress = true
        HashtagRequest().getHashtagDetail(type: "mini_video", hashtagId: self.hashtagId, limit: TSAppConfig.share.localInfo.limit, after: lastVideoId) { (responseModels) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.isFetchInProgress = false
                
                guard let models = responseModels else {
                    self.onFailFetchData?()
                    return
                }
                let feedListCellModels = models.feeds.compactMap { FeedListCellModel(feedListModel: $0) }
                
                self.videos.append(contentsOf: feedListCellModels)
                completion?(self.videos.count > 0)
            }
        } onFailure: { (errorMessage) in
            self.onFailFetchData?()
        }
    }
}
