//
//  FeedRequestNetwork.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态网络请求

import UIKit

struct FeedNetworkRequest {

    /// 批量获取动态
    let feeds = Request<FeedListResultsModel>(method: .get, path: "feeds", replacers: [])
    
    let feedList = Request<FeedListModel>(method: .get, path: "feeds/media", replacers: [])

    /// 收藏动态
    let collect = Request<Empty>(method: .post, path: "feeds/:feed/collections", replacers: [":feed"])
    /// 取消收藏
    let uncollect = Request<Empty>(method: .delete, path: "feeds/:feed/uncollect", replacers: [":feed"])
    /// 收藏列表
    let collection = Request<FeedListModel>(method: .get, path: "feeds/collections", replacers: [])
    
    let translate = Request<Empty>(method: .get, path: "feeds/:feed/translation", replacers: [":feed"])

    /// 点赞动态
    let digg = Request<Empty>(method: .post, path: "feeds/:feed/like", replacers: [":feed"])
    /// 取消点赞
    let undigg = Request<Empty>(method: .delete, path: "feeds/:feed/unlike", replacers: [":feed"])

    /// 删除动态
    let delete = Request<Empty>(method: .delete, path: "feeds/:feed/currency", replacers: [":feed"])
    
    let hideAds = Request<Empty>(method: .delete, path: "sponsored-feed/:feed", replacers: [":feed"])
    
    let trendingGallery = Request<FeedListResultsModel>(method: .get, path: "feeds/trending-gallery", replacers: [])
    
    let forwardFeed = Request<Empty>(method: .post, path: "feeds/:feed/forward/record", replacers: [":feed"])
    
    let pinFeed = Request<Empty>(method: .post, path: "feeds/:feed/pinned", replacers: [":feed"])
    
    let unpinFeed = Request<Empty>(method: .delete, path: "feeds/:feed/unpinned", replacers: [":feed"])
    
    //曝光行为上报
    let behaviorFeed = Request<Empty>(method: .post, path: "behavior/expose", replacers: [""])
    
    //用户行为上报
    let behaviorUserFeed = Request<Empty>(method: .post, path: "behavior/escalation", replacers: [""])
}


//MARK: - Network Request for Trending Photos
struct TrendingPhotoNetworkRequest {
    
    let trendingPhotos = Request<TrendingPhotoModel>(method: .get, path: "trending", replacers: [])
}

// TODO: 旧版动态遗留接口
struct TSFeedsNetworkRequest {
    // MARK: - 赞
    /// 获取资讯点赞列表
    ///
    /// - RouteParameter:
    ///    - feed: 资讯标识
    /// - RequestParameter:
    ///    - limit: Integer. 获取条数，默认 20
    ///    - after: Integer. 资讯id,传入后获取该id之后数据，默认 0
    let likesList = TSNetworkRequestMethod(method: .get, path: "feeds/:feed/likes", replace: ":feed")
}
