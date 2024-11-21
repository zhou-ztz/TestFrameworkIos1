//
//  FeedListNetworkManager.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/9.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态列表网络请求方法

import UIKit

import ObjectMapper
// MARK: - 对外 API
class FeedListNetworkManager {

    class func getUserSuggestionList(limit: Int = 20) {

    }

    class func deleteSponsorFeed(feedId: Int, complete: @escaping ((Bool) -> Void)) {
        var request = FeedNetworkRequest().hideAds
        request.urlPath = request.fullPathWith(replacers: [feedId.stringValue])
        
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .success(let data):
                complete(data.statusCode == 204)
                
            default:
                complete(false)
            }
        }
    }
    /// 获取某个用户的动态列表
    ///
    /// - Parameters:
    ///   - userId: 用户 id
    ///   - screen: paid-付费动态 pinned - 置顶动态
    ///   - limit: Integer    可选，默认值 20 ，获取条数
    ///   - after: 上次获取到数据最后一条 ID，用于获取该 ID 之后的数据
    ///   - complete: 结果
    class func getUserFeed(userId: Int, screen: String?, limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, complete: @escaping (FeedListResultsModel?, String?, Bool) -> Void) {
        getFeedsAndRequestUserInfos(limit: limit, after: after, type: "users", search: nil, locationID: nil, user: userId, screen: screen, complete: complete)
    }
    class func getUserLiveFeed(userId: Int, screen: String?, limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, complete: @escaping (FeedListResultsModel?, String?, Bool) -> Void) {
        getFeedsAndRequestUserInfos(limit: limit, after: after, type: "profileLive", search: nil, locationID: nil, user: userId, screen: screen, complete: complete)
    }
    /// 获取首页动态列表
    ///
    /// - Parameters:
    ///   - type: String    可选，默认值 new，可选值 ‘new’, ‘hot’, ‘live’, ‘location’, ‘follow’, ‘users’,‘official’,‘profileLive’
    ///   - limit: Integer    可选，默认值 20 ，获取条数
    ///   - after: 上次获取到数据最后一条 ID，用于获取该 ID 之后的数据
    ///   - hot: 可选，仅 type=hot 时有效，用于热门数据翻页标记！上次获取数据最后一条的 hot 值
    ///   - complete: 结果
    class func getTypeFeeds(type: String, limit: Int = TSAppConfig.share.localInfo.limit, offset: Int, after: Int?, country: String?, complete: @escaping (FeedListResultsModel?, String?, Bool) -> Void) {
        getFeedsAndRequestUserInfos(limit: limit, offset: offset, after: after, type: type, search: nil, locationID: nil, user: nil, screen: nil, country: country, complete: complete)
    }

    
    class func getLocationFeeds(locationID: String, limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, complete: @escaping (FeedListResultsModel?, String?, Bool) -> Void) {
        getFeedsAndRequestUserInfos(limit: limit, after: after, type: "location", search: nil, locationID: locationID, user: nil, screen: nil, complete: complete)
    }
    
    class func translateFeed(feedId: String,
                             success: ((_ object: String) -> Void)?,
                             failure: ((_ message: String) -> Void)?) {
        var request = Request<Empty>(method: .get, path: "feeds/{feed_id}/translation", replacers: ["{feed_id}"])
        request.urlPath = request.fullPathWith(replacers: [feedId])
        
        try! RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                failure?("network_problem".localized)

            case .failure(let failureObj):
                failure?(failureObj.message.orEmpty)

            case .success(let data):
                success?(data.message.orEmpty)
            }
        }
    }

    class func getFeeds(mediaType: FeedMediaType = .image,
                        feedType: FeedListType = .hot,
                        limit: Int = TSAppConfig.share.localInfo.limit,
                        after: Int? = nil,
                        afterTime: String? = nil,
                        country: String? = LocationManager.shared.getCountryCode(),
                        language: String? = LocalizationManager.getISOLanguageCode(),
                        complete: @escaping ([FeedListCellModel]?, String?, Bool) -> Void) {
        var request = FeedNetworkRequest().feedList
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = [:]
        request.parameter?["limit"] = limit
        request.parameter?["content_type"] = mediaType.rawValue
        request.parameter?["type"] = feedType.rawValue
        if mediaType == .miniVideo {
            /// 每次返回不同的小视频
            let lid: Int = Int(arc4random() % 10)
            request.parameter?["lid"] = lid
        }

        switch feedType {
        case .user(let userId):
            request.parameter?["user_id"] = userId
        default:
            break
        }
        if let country = country {
            request.parameter?["country_code"] = country
        }
        if let language = language {
            request.parameter?["language"] = language
        }
        if let after = after {
            request.parameter?["after"] = after
        }
        if let afterTime = afterTime {
            request.parameter?["after_time"] = afterTime
        }

        RequestNetworkData.share.text(request: request) { result in
            switch result {
            case .error:
                complete(nil, "network_problem".localized, false)

            case .failure(let failure):
                complete(nil, failure.message, false)

            case .success(let data):
                
                if data.models.count > 0 {
                    requestUserInfo(to: data.models) { (result, message, status) in
                        
                        guard let result = result else {
                            complete(nil, message, true)
                            return
                        }
                        complete(data.models.compactMap { FeedListCellModel(feedListModel: $0) }, nil, true)
                    }
                } else {
                    complete(nil, "no_more_data_tips".localized, true)
                }
            }
        }
    }
    
    /// 关键字搜索获取动态列表
    ///
    /// - Parameters:
    ///   - type: String    可选，默认值 new，可选值 new 、hot 、 follow
    ///   - limit: Integer    可选，默认值 20 ，获取条数
    ///   - after: 上次获取到数据最后一条 ID，用于获取该 ID 之后的数据
    ///   - complete: 结果
    class func getSearchFeeds(keyword: String, type: String, limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, complete: @escaping (FeedListResultsModel?, String?, Bool) -> Void) {
        getFeedsAndRequestUserInfos(limit: limit, after: after, type: type, search: keyword, locationID: nil, user: nil, screen: nil, complete: complete)
    }

    /// 获取动态详情
    ///
    /// - Note: 这个方法只是临时使用的
    class func getFeed(id: Int, complete: @escaping(Bool, TSMomentListModel?) -> Void) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue + "/\(id)"
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (datas: NetworkResponse?, _) in
            if let data = datas as? [String: Any] {
                let model = TSMomentListModel(dataV2: data)
                complete(true, model)
                return
            }
            complete(false, nil)
        })
    }

    class func getMomentFeed(id: Int, complete: @escaping (FeedListModel?, String?, Bool, NetworkResult<Request<FeedListModel>>) -> Void) {
        var request = Request<FeedListModel>(method: .get, path: "feeds/{feedid}", replacers: ["{feedid}"])
        request.urlPath = request.fullPathWith(replacers: ["\(id)"])

        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
                case .error(_):
                    complete(nil, "network_problem".localized, false, networkResult)

                case .failure(let failure):
                    complete(nil, failure.message, false, networkResult)

                case .success(let data):
                    guard let originalModel = data.model else {
                        complete(nil, "No data".localized, false, networkResult)
                        return
                    }
                    let group = DispatchGroup()
                    group.enter()
                    requestUserInfo(to: [originalModel]) { (datas, message, status) in
                        group.leave()
                    }
                                        
                    if originalModel.repostId > 0 {
                        group.enter()
                        FeedListNetworkManager.requestRepostFeedInfo(feedIDs: [originalModel.repostId]) { models in
                            group.leave()
                        }
                    }
                    
                    originalModel.save()
                    group.notify(queue: .main) {
                        complete(originalModel, nil, true, networkResult)
                    }
            }
        }

    }

    /// 获取用户收藏的动态
    class func getCollectFeeds(limit: Int = TSAppConfig.share.localInfo.limit, offset: Int, complete: @escaping (Bool, String?, [FeedListModel]?) -> Void) {
        // 1.请求 url
        
        var request = FeedNetworkRequest().collection
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = ["limit": limit]
        if offset >= 0 {
            request.parameter!["offset"] = offset
        }
        var models: [FeedListModel]?
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "network_request_fail".localized, nil)
            case .failure(let faild):
                complete(false, faild.message, nil)
            case .success(let success):
                models = success.models
                // 乱序
                let respotFeedIds = models?.filter { $0.repostType == "feeds" && $0.repostId > 0 }.compactMap { $0.repostId }
                /// 通过模块逐个去请求转发的信息，动态需要的原作者的用户信息也返回了的开森
                let group = DispatchGroup()
                
                if let ids = respotFeedIds, ids.count > 0 {
                    group.enter()
                    FeedListNetworkManager.requestRepostFeedInfo(feedIDs: ids) { _ in
                        group.leave()
                    }
                }
                /// 全部请求完毕
                group.notify(queue: .main) {
                    complete(true, nil, models)
                }
            }
        }
    }
}

// MARK: - 基于服务器提供的原始接口，增加了获取用户信息逻辑，而封装的 API
extension FeedListNetworkManager {

    /// 批量获取动态，及动态中相关用户信息
    fileprivate class func getFeedsAndRequestUserInfos(limit: Int = TSAppConfig.share.localInfo.limit, offset: Int? = nil, after: Int? = nil, type: String = "new", search: String?, locationID: String? ,user: Int?, screen: String?, country: String? = nil, complete: @escaping (FeedListResultsModel?, String?, Bool) -> Void) {
        getFeeds(limit: limit, offset: offset, after: after, type: type, search: search, locationID: locationID, user: user, screen: screen, country: country) { (data: FeedListResultsModel?, message: String?, status: Bool) in
            guard let data = data else {
                complete(nil, message, status)
                return
            }
            let allFeeds = data.pinned + data.feeds
            if allFeeds.isEmpty {
                complete(data, message, status)
                return
            }

            if AppEnvironment.current.featureFlags.shouldFeedListloadUserInfo {
                // 请求用户信息
                requestUserInfo(to: allFeeds, complete: { (datas, message, userStatus) in
                    guard let datas = datas else {
                        complete(nil, message, false)
                        return
                    }
                    let model = FeedListResultsModel()
                    model.pinned = Array(datas[0..<data.pinned.count])
                    model.feeds = Array(datas[data.pinned.count..<datas.count])
                    complete(model, message, status && userStatus)
                })
            } else {
                let model = FeedListResultsModel()
                model.pinned = Array(allFeeds[0..<data.pinned.count])
                model.feeds = Array(allFeeds[data.pinned.count..<allFeeds.count])
                complete(model, nil, status)
            }
        }
    }

    /// 根据 [FeedListModel] 中的 userId，请求用户信息，并返回带有用户信息的 [FeedListModel]
    public class func requestUserInfo(to feeds: [FeedListModel], complete: @escaping ([FeedListModel]?, String?, Bool) -> Void) {
        // 1.取出所有用户信息，过滤重复信息
        let userIds = Array(Set(feeds.flatMap { $0.userIds() }))
        // 2.发起网络请求
        TSUserNetworkingManager().getUserInfo(userIds) { (_, models, _) in
            guard let models = models else {
                // TODO: 错误信息应该使用后台返回信息，但由于这个 API 没有处理用户信息接口错误信息。
                // 当然更不应该在调用 API 的地方处理后台返回错误信息。
                // 就先写一个假的数据，等这 API 更新后再替换
                complete(nil,  "network_problem".localized, false)
                return
            }
            // 3.将用户信息和动态信息匹配
            let userDic = models.toDictionary { $0.userIdentity }
            for feed in feeds {
                feed.set(userInfos: userDic)
            }
            
            DispatchQueue.global().async {
                models.forEach { user in
                    user.save()
                }
            }
            
            complete(feeds, nil, true)
        }
    }
    
    class func forwardFeed(feedId: Int, completion: @escaping (String, Int, Bool?) -> Void) {
        var request = FeedNetworkRequest().forwardFeed
        request.urlPath = request.fullPathWith(replacers: ["\(feedId)"])
        LogManager.Log(" request : \(request)", loggingType: .apiRequestData)
        
        var parameters : [String : Any] = [:]
        request.parameter = parameters
        
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                completion("network_problem".localized, 0, false)
            case .failure(let error):
                var statusCode = error.statusCode
                if let sourceDictionary = error.sourceData as? [String: Any], let resultCode = sourceDictionary["code"] as? Int {
                    statusCode = resultCode
                }
                completion(error.message ?? "network_problem".localized, statusCode, false)
            case .success(let data):
                completion("", 0, true)
            }
        }
    }
    
    class func pinFeed(feedId: Int, completion: @escaping (String, Int, Bool?) -> Void) {
        var request = FeedNetworkRequest().pinFeed
        request.urlPath = request.fullPathWith(replacers: ["\(feedId)"])
        LogManager.Log(" request : \(request)", loggingType: .apiRequestData)
        
        var parameters : [String : Any] = [:]
        request.parameter = parameters
        
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                completion("network_problem".localized, 0, false)
            case .failure(let error):
                var statusCode = error.statusCode
                if let sourceDictionary = error.sourceData as? [String: Any], let resultCode = sourceDictionary["code"] as? Int {
                    statusCode = resultCode
                }
                completion(error.message ?? "network_problem".localized, statusCode, false)
            case .success(let data):
                completion("", 0, true)
            }
        }
    }
    
    class func unpinFeed(feedId: Int, completion: @escaping (String, Int, Bool?) -> Void) {
        var request = FeedNetworkRequest().unpinFeed
        request.urlPath = request.fullPathWith(replacers: ["\(feedId)"])
        LogManager.Log(" request : \(request)", loggingType: .apiRequestData)
        
        var parameters : [String : Any] = [:]
        request.parameter = parameters
        
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                completion("network_problem".localized, 0, false)
            case .failure(let error):
                completion(error.message ?? "network_problem".localized, error.statusCode, false)
            case .success(let data):
                completion("", 0, true)
            }
        }
    }
    
    /// 曝光行为上报
    /// - Parameters:
    ///   - behaviorFeedJson: 动态id以及行为发生时间戳json数据
    ///   - scene_id: 场景ID，动态热门：hot，首页为：index
    ///   - completion: -
    class func behaviorFeed(behaviorFeedJson: String, scene_id: String, completion: @escaping (String, Int, Bool?) -> Void) {
        // 1. url
        var request = FeedNetworkRequest().behaviorFeed
        request.urlPath = request.fullPathWith(replacers: [])
        //经纬度值为空，设定默认值
        var longitude = Device.appLoction.coordinate.longitude.toFloat == 0 ? 101.61245365502157 : Device.appLoction.coordinate.longitude
        var latitude = Device.appLoction.coordinate.latitude.toFloat == 0 ? 3.1679279092002086 : Device.appLoction.coordinate.latitude
        // 2. params
        var params: [String: Any] = [String: Any]()
        params.updateValue(behaviorFeedJson, forKey: "json_data")
        params.updateValue("hot", forKey: "scene_id")
        params.updateValue("1", forKey: "bhv_value")
        params.updateValue(Device.appVersion(), forKey: "app_version")
        params.updateValue(Device.modelName, forKey: "device_model")
        params.updateValue(TSReachability.share.getNetStatus(), forKey: "net_type")
        params.updateValue("\(longitude)", forKey: "longitude")
        params.updateValue("\(latitude)", forKey: "latitude")
        params.updateValue("ios", forKey: "platform")

        request.parameter = params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                completion("network_problem".localized, 0, false)
            case .failure(let error):
                completion(error.message ?? "network_problem".localized, error.statusCode, false)
            case .success(let response):
                completion("", 0, true)
            }
        }
    }
    
    /// 用户行为上报 
    /// - Parameters:
    ///   - bhv_type: 行为类型，expose：曝光 click：点击 like：点赞 comment：评论 collect：收藏 stay：停留时长 share：分享 tip：打赏 dislike：负反馈
    ///   - scene_id: 场景ID，动态热门：hot，首页为：index
    ///   - feed_id: 动态id
    ///   - completion: -
    class func behaviorUserFeed(bhv_type: String, scene_id: String, feed_id: String, bhv_value: String = "1", completion: @escaping (String, Int, Bool?) -> Void) {
        // 1. url
        var request = FeedNetworkRequest().behaviorUserFeed
        request.urlPath = request.fullPathWith(replacers: [])
        // 2. params
        var params: [String: Any] = [String: Any]()
        //经纬度值为空，设定默认值
        var longitude = Device.appLoction.coordinate.longitude.toFloat == 0 ? 101.61245365502157 : Device.appLoction.coordinate.longitude
        var latitude = Device.appLoction.coordinate.latitude.toFloat == 0 ? 3.1679279092002086 : Device.appLoction.coordinate.latitude
        params.updateValue(bhv_type, forKey: "bhv_type")
        params.updateValue("hot", forKey: "scene_id")
        params.updateValue(feed_id, forKey: "feed_id")
        params.updateValue(bhv_value, forKey: "bhv_value")
        params.updateValue(Device.appVersion(), forKey: "app_version")
        params.updateValue(Device.modelName, forKey: "device_model")
        params.updateValue(TSReachability.share.getNetStatus(), forKey: "net_type")
        params.updateValue("\(longitude)", forKey: "longitude")
        params.updateValue("\(latitude)", forKey: "latitude")
        params.updateValue("ios", forKey: "platform")

        request.parameter = params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                completion("network_problem".localized, 0, false)
            case .failure(let error):
                completion(error.message ?? "network_problem".localized, error.statusCode, false)
            case .success(let response):
                completion("", 0, true)
            }
        }
    }
}

//MARK: - Trending
extension FeedListNetworkManager {
    
    class func getTrendingPhotos(limit: Int? = nil, after: Int? = nil, completion: @escaping ([FeedListCellModel], Bool?) -> Void) {
        var request = FeedNetworkRequest().trendingGallery
        request.urlPath = request.fullPathWith(replacers: [])
        LogManager.Log(" request : \(request)", loggingType: .apiRequestData)
        
        var parameters : [String : Any] = [:]
        if let limit = limit {
            parameters["limit"] = limit
        }
        if let after = after {
            parameters["after"] = after
        }
        request.parameter = parameters
        
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                completion([], false)
            case .failure(_):
                completion([], false)
            case .success(let data):
                guard let model = data.model else {
                    completion([], false)
                    return
                }
                let feedList = model.feeds.compactMap { FeedListCellModel(feedListModel: $0) }
                completion(feedList, true)
            }
        }
    }
    
    
    class func getUserTrendingPhotos(userId: Int, limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, completion: @escaping ([FeedListCellModel], Bool?) -> Void) {
        
        var request = UserNetworkRequest().gallery
        request.urlPath = request.fullPathWith(replacers: ["\(userId)"])
        var parameters : [String : Any] = [:]
        
        if let after = after {
            parameters = ["limit": limit, "after": after]
        }
        else {
            parameters = ["limit": limit]
        }
       
        request.parameter = parameters
  
        print(" request : \(request)")
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                completion([], false)
            case .failure(_):
                completion([], false)
            case .success(let data):
                guard let resultModel = data.model else {
                    completion([], false)
                    return
                }
                var feedList:[FeedListCellModel] = []
                if after == nil {
                    feedList = resultModel.pinned.compactMap { FeedListCellModel(feedListModel: $0) }
                    for pinnedFeed in feedList {
                        pinnedFeed.isPinned = true
                    }
                }
                let filteredFeeds = resultModel.feeds.filter { (feed) -> Bool in
                    return !resultModel.pinned.contains(where: { $0.id == feed.id })
                }
                feedList.append(contentsOf: filteredFeeds.compactMap { FeedListCellModel(feedListModel: $0) })
                
                completion(feedList, true)
            }
        }
    }
    
    class func getUserTaggedList(limit: Int = TSAppConfig.share.localInfo.limit, offset: Int, userId: Int, completion: @escaping ([FeedListCellModel], Bool?) -> Void) {
        
        var request = UserNetworkRequest().tagged
        request.urlPath = request.fullPathWith(replacers: [])
        var parameters : [String : Any] = [:]
        
        parameters = ["limit": limit, "offset": offset , "user_id": userId]
       
        request.parameter = parameters
  
        print(" request : \(request)")
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                completion([], false)
            case .failure(_):
                completion([], false)
            case .success(let data):
                guard let resultModel = data.model else {
                    completion([], false)
                    return
                }
                var feedList:[FeedListCellModel] = []
                if offset == 0 {
                    feedList = resultModel.pinned.compactMap { FeedListCellModel(feedListModel: $0) }
                    for pinnedFeed in feedList {
                        pinnedFeed.isPinned = true
                    }
                }
                let filteredFeeds = resultModel.feeds.filter { (feed) -> Bool in
                    return !resultModel.pinned.contains(where: { $0.id == feed.id })
                }
                feedList.append(contentsOf: filteredFeeds.compactMap { FeedListCellModel(feedListModel: $0) })
                
                completion(feedList, true)
            }
        }
    }
    
    class func getUserMiniVideo(userId: Int, limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, completion: @escaping ([FeedListCellModel], Bool) -> Void) {
        
        var request = UserNetworkRequest().miniVideo
        request.urlPath = request.fullPathWith(replacers: ["\(userId)"])
        var parameters : [String : Any] = [:]
        
        if let after = after {
            parameters = ["limit": limit, "after": after]
        }
        else {
            parameters = ["limit": limit]
        }
       
        request.parameter = parameters
  
        print(" request : \(request)")
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                completion([], false)
            case .failure(_):
                completion([], false)
            case .success(let data):
                guard let resultModel = data.model else {
                    completion([], false)
                    return
                }
                var feedList:[FeedListCellModel] = []
                if after == nil {
                    feedList = resultModel.pinned.compactMap { FeedListCellModel(feedListModel: $0) }
                    for pinnedFeed in feedList {
                        pinnedFeed.isPinned = true
                    }
                }
                let filteredFeeds = resultModel.feeds.filter { (feed) -> Bool in
                    return !resultModel.pinned.contains(where: { $0.id == feed.id })
                }
                feedList.append(contentsOf: filteredFeeds.compactMap { FeedListCellModel(feedListModel: $0) })
                
                completion(feedList, true)
            }
        }
    }
    
    class func getLiveVideos(after: Int? = nil, completion: @escaping ([TrendingPhotoModel], Bool?) -> Void) {
        var request = TrendingPhotoNetworkRequest().trendingPhotos
        request.urlPath = request.fullPathWith(replacers: [])
        var parameters: [String: Any] = ["type": "profileLive", "limit": TSAppConfig.share.localInfo.limit]
        
        if let after = after {
            parameters["after"] = after
        }
        request.parameter = parameters
        
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                completion([], false)
            case .failure(_):
                completion([], false)
            case .success(let data):
                let photos = data.models
                completion(photos, true)
            }
        }
    }
}

// MARK: - 服务器提供的原始接口
extension FeedListNetworkManager {

    /// 服务器提供方法 批量获取动态
    ///
    /// - Parameters:
    ///   - limit: Integer    可选，默认值 20 ，获取条数
    ///   - after: Integer    可选，上次获取到数据最后一条 ID，用于获取该 ID 之后的数据。
    ///   - type: String    可选，默认值 new，可选值 new 、hot 、 follow 、users
    ///   - search: String    type = new时可选，搜索关键字
    ///   - user: Integer    type = users 时可选，默认值为当前用户id
    ///   - screen: string    type = users 时可选，paid-付费动态 pinned - 置顶动态
    ///   - complete: 结果
    fileprivate class func getFeeds(limit: Int = TSAppConfig.share.localInfo.limit, offset: Int? = nil, after: Int? = nil, type: String = "new", search: String?, locationID:String?, user: Int?, screen: String?, country: String?, complete: @escaping (FeedListResultsModel?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = FeedNetworkRequest().feeds
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        
        var parameters : [String : Any] = [:]
        
        if let locationID = locationID {
            parameters = ["type": type, "limit": limit, "lid":locationID]
        } else {
            parameters = ["type": type, "limit": limit]
        }
        
        if let offset = offset {
            parameters.updateValue(offset, forKey: "offset")
        }
        
        if let after = after, type != "hot" {
            parameters.updateValue(after, forKey: "after")
        }
        // 热门的分页分页标示不一样服务器要求的
        if let after = after, type == "hot" {
            parameters.updateValue(after, forKey: "hot")
        }
        if let search = search {
            parameters.updateValue(search, forKey: "search")
        }
        if let user = user {
            parameters.updateValue(user, forKey: "user")
        }
        if let screen = screen {
            parameters.updateValue(screen, forKey: "screen")
        }
        if let country = country, country.isEmpty == false {
            parameters.updateValue(country, forKey: "country_code")
        }
        request.parameter = parameters
        LogManager.Log("Request - ", request, loggingType: .apiRequestData)
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "network_problem".localized, false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                // 需要组装转发的数据
                // 分类整理
                let originalModel = data.model
                // 乱序
                var repostFeedsListModelIDs: [Int] = []
                
                if let pinned = originalModel?.pinned {
                    repostFeedsListModelIDs = pinned.filter { $0.repostId > 0 }.compactMap { $0.repostId }
                }
                
                if let feeds = originalModel?.feeds {
                    repostFeedsListModelIDs.append(contentsOf: feeds.filter { $0.repostId > 0 }.compactMap { $0.repostId })
                }
                
                /// 通过模块逐个去请求转发的信息，动态需要的原作者的用户信息也返回了的开森
                let group = DispatchGroup()
                
                if repostFeedsListModelIDs.count > 0 {
                    group.enter()
                    FeedListNetworkManager.requestRepostFeedInfo(feedIDs: repostFeedsListModelIDs) { _ in
                        group.leave()
                    }
                }
                /// 全部请求完毕
                group.notify(queue: .main) {
                    complete(originalModel, nil, true)
                }
            }
        }
    }
    
    fileprivate class func getLiveFeeds(limit: Int = TSAppConfig.share.localInfo.limit, after: Int? = nil, type: String = "new", search: String?, locationID:String?, user: Int?, screen: String?, complete: @escaping (FeedListResultsModel?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = FeedNetworkRequest().feeds
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        
        var parameters : [String : Any] = [:]
        
        if let locationID = locationID {
            parameters = ["type": type, "limit": limit, "lid":locationID]
        } else {
            parameters = ["type": type, "limit": limit]
        }
        
        if let after = after, type != "hot" {
            parameters.updateValue(after, forKey: "after")
        }
        // 热门的分页分页标示不一样服务器要求的
        if let after = after, type == "hot" {
            parameters.updateValue(after, forKey: "hot")
        }
        if let search = search {
            parameters.updateValue(search, forKey: "search")
        }
        if let user = user {
            parameters.updateValue(user, forKey: "user")
        }
        if let screen = screen {
            parameters.updateValue(screen, forKey: "screen")
        }
        request.parameter = parameters
        print("Request - ",request)
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "network_problem".localized, false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                // 需要组装转发的数据
                // 分类整理
                let originalModel = data.model
                // 乱序
                var repostFeedsListModelIDs: [Int] = []
                if let pinned = originalModel?.pinned {
                    repostFeedsListModelIDs = pinned.filter { $0.repostId > 0 }.compactMap { $0.repostId }
                }
                if let feeds = originalModel?.feeds {
                    repostFeedsListModelIDs.append(contentsOf: feeds.filter { $0.repostId > 0}.compactMap { $0.repostId })
                }
                /// 通过模块逐个去请求转发的信息，动态需要的原作者的用户信息也返回了的开森
                let group = DispatchGroup()
                if repostFeedsListModelIDs.count > 0 {
                    group.enter()
                    FeedListNetworkManager.requestRepostFeedInfo(feedIDs: repostFeedsListModelIDs) { _ in
                        group.leave()
                    }
                }
                /// 全部请求完毕
                group.notify(queue: .main) {
                    complete(originalModel, nil, true)
                }
            }
        }
    }
}
extension FeedListNetworkManager {
    /// 获取动态信息
    class func requestRepostFeedInfo(feedIDs: [Int], complete: @escaping ([FeedListModel]?) -> Void) {
        var request = Request<FeedListResultsModel>(method: .get, path: "feeds", replacers: [])
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = ["id": feedIDs.compactMap { String($0) }.joined(separator: ",")]
        
        RequestNetworkData.share.text(request: request, complete: { (networkResult) in
            switch networkResult {
            case .success(let success):
                success.model?.feeds.forEach { model in
                    model.save()
                }
                complete(success.model?.feeds)
            default:
                complete(nil)
                break
            }
        })
    }
    
    /// 圈子信息
     class func requestGroupInfo(IDs: [Int], complete: @escaping ([[String: Any]]?, _ errorInfo: String?) -> Void) {
        let requestPath = TSURLPathV2.path.rawValue + "plus-group/groups"
        var parameter: [String: Any] = [:]
        var idStr = ""
        for idInt in IDs {
            idStr = idStr.isEmpty ? String(idInt) : idStr + "," +  String(idInt)
        }
        parameter["id"] = idStr
        try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
            // 请求失败
            guard result else {
                complete([], nil)
                return
            }
            // 服务器数据异常
            guard let datas = networkResponse as? [[String : Any]] else {
                complete([], nil)
                return
            }
            complete(datas, nil)
        })
    }
    /// 帖子详情
     class func requestPostInfo(IDs: [Int], complete: @escaping ([[String: Any]]?, _ errorInfo: String?) -> Void) {
        let requestPath = TSURLPathV2.path.rawValue + "group/simple-posts"
        var parameter: [String: Any] = [:]
        var idStr = ""
        for idInt in IDs {
            idStr = idStr.isEmpty ? String(idInt) : idStr + "," +  String(idInt)
        }
        parameter["id"] = idStr
        try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
            // 请求失败
            guard result else {
                complete([], nil)
                return
            }
            // 服务器数据异常
            guard let datas = networkResponse as? [[String : Any]] else {
                complete([], nil)
                return
            }
            complete(datas, nil)
        })
    }
    /// 资讯信息
     class func requestNewsInfo(IDs: [Int], complete: @escaping ([[String: Any]]?, _ errorInfo: String?) -> Void) {
        let requestPath = TSURLPathV2.path.rawValue + "news"
        var parameter: [String: Any] = [:]
        var idStr = ""
        for idInt in IDs {
            idStr = idStr.isEmpty ? String(idInt) : idStr + "," +  String(idInt)
        }
        parameter["id"] = idStr
        try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
            // 请求失败
            guard result else {
                complete([], nil)
                return
            }
            // 服务器数据异常
            guard let datas = networkResponse as? [[String : Any]] else {
                complete([], nil)
                return
            }
            complete(datas, nil)
        })
    }
    /// 问题信息
     class func requestQuestionInfo(IDs: [Int], complete: @escaping ([[String: Any]]?, _ errorInfo: String?) -> Void) {
        let requestPath = TSURLPathV2.path.rawValue + "questions"
        var parameter: [String: Any] = [:]
        var idStr = ""
        for idInt in IDs {
            idStr = idStr.isEmpty ? String(idInt) : idStr + "," +  String(idInt)
        }
        parameter["id"] = idStr
        try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
            // 请求失败
            guard result else {
                complete([], nil)
                return
            }
            // 服务器数据异常
            guard let datas = networkResponse as? [[String : Any]] else {
                complete([], nil)
                return
            }
            complete(datas, nil)
        })
    }
    /// 回答信息
     class func requestAnswerInfo(IDs: [Int], complete: @escaping ([[String: Any]]?, _ errorInfo: String?) -> Void) {
        let requestPath = TSURLPathV2.path.rawValue + "qa/reposted-answers"
        var parameter: [String: Any] = [:]
        var idStr = ""
        for idInt in IDs {
            idStr = idStr.isEmpty ? String(idInt) : idStr + "," +  String(idInt)
        }
        parameter["id"] = idStr
        try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
            // 请求失败
            guard result else {
                complete([], nil)
                return
            }
            // 服务器数据异常
            guard let datas = networkResponse as? [[String : Any]] else {
                complete([], nil)
                return
            }
            complete(datas, nil)
        })
    }

    class func requestUserInfo(userIds: [Int], complete: @escaping ([UserInfoModel]?, _ errorInfo: String?) -> Void) {
       TSUserNetworkingManager().getUsersInfo(usersId: userIds) { (userlist, msg, status) in
           guard let users = userlist else {
               complete(nil, msg)
               return
           }
           complete(users, nil)
       }
   }
}
extension Sequence {
    func toDictionary<Key: Hashable>(_ key: (Iterator.Element) -> Key) -> [Key: Iterator.Element] {
        var dict: [Key: Iterator.Element] = [:]
        for element in self {
            dict[key(element)] = element
        }
        return dict
    }
}

// MARK: - Yippi 6 new API
extension FeedListNetworkManager {
    class func getRecommendUsers(complete: @escaping ([UserInfoModel]?, String?, Bool) -> Void) {
        var recommendUser = Request<UserInfoModel>(method: .get, path: "recommends/onboarding-user", replacers: [])
        recommendUser.urlPath = recommendUser.fullPathWith(replacers: [])

        RequestNetworkData.share.text(request: recommendUser, complete: { (networkResult) in
            switch networkResult {
                case .error(_):
                    complete(nil, "network_request_fail".localized, false)
                case .failure(let faild):
                     complete(nil, faild.message, false)
                case .success(let success):
                    let models = success.models
                    complete(models, nil, true)
            }
        })

    }
}
