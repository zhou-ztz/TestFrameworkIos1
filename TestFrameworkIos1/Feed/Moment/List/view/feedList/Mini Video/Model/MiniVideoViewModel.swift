//
//  MiniVideoViewModel.swift
//  Yippi
//
//  Created by Yong Tze Ling on 07/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

final class MiniVideoViewModel: NSObject {

    var type: FeedListType = .recommend
    var videos: [FeedListCellModel] = []
    private var currentPage = 1
    private var total = 0
    private var isFetchInProgress = false
    
    var currentCount: Int {
        return videos.count
    }
    
    init(type: FeedListType) {
        self.type = type
        super.init()
    }
    
    func setUserId(id: Int) {
        self.type = .user(userId: id)
    }
    
    func fetchData(completion: ((_ hasData: Bool) -> Void)?, onNetworkFail: ((_ hasData: Bool) -> Void)? = nil) {
        
        guard !isFetchInProgress else { return }
        
        isFetchInProgress = true

        switch self.type {
        case .user(let userId):
            FeedListNetworkManager.getUserMiniVideo(userId: userId, limit: 12, after:nil, completion: { [weak self] (models, status) in
                DispatchQueue.main.async {
                    self?.isFetchInProgress = false
                    
                    guard status else {
                        onNetworkFail?(models.count > 0)
                        return
                    }
                    self?.videos = models
                    completion?(models.count > 0)
                }
            })
        default:
            FeedListNetworkManager.getFeeds(mediaType: .miniVideo, feedType: type) { [weak self] (models, errorMessage, status) in
                DispatchQueue.main.async {
                    defer {
                        self?.isFetchInProgress = false
                    }
                    guard let self = self else {
                        return
                    }
                    guard status else {
                        onNetworkFail?(self.currentCount > 0)
                        return
                    }
                    guard let models = models else {
                        completion?(false)
                        return
                    }
                    self.videos = models
                    completion?(models.count > 0)
                }
            }
        }
    }
    
    func loadMore(completion: ((_ hasData: Bool) -> Void)?, onFail: EmptyClosure?) {
        guard let lastVideoId = videos.last?.idindex, !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        switch self.type {
        case .user(let userId):
            FeedListNetworkManager.getUserMiniVideo(userId: userId, limit: 12, after: lastVideoId, completion: { [weak self] (models, status) in
                DispatchQueue.main.async {
                    self?.isFetchInProgress = false
                    
                    guard status else {
                        onFail?()
                        return
                    }
                    self?.videos.append(contentsOf: models)
                    completion?(models.count > 0)
                }
            })
        default:
            FeedListNetworkManager.getFeeds(mediaType: .miniVideo, feedType: type, after: lastVideoId) { [weak self] (models, errorMessage, status) in
                DispatchQueue.main.async {
                    self?.isFetchInProgress = false
                    
                    guard let models = models else {
                        onFail?()
                        return
                    }
                    
                    self?.videos.append(contentsOf: models)
                    completion?(models.count > 0)
                }
            }
        }
    }
}
