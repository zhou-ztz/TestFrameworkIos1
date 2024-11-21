//
//  TSMomentNetworkManager.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态相关网络请求

import UIKit
import ObjectMapper

import RealmSwift

class TSMomentNetworkManager: NSObject {
    
    func reactionList(id: Int, reactionType: ReactionTypes?, limit: Int = 20, after: String? = nil, completion: ((FeedReactionsModel?, _ success: Bool, _ message: String?) -> Void)?) {
        var path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.reactions.rawValue
        path = path.replacingOccurrences(of: "{feed_id}", with: id.stringValue)
        
        var parameters: [String: Any] = ["limit": limit]
        if let after = after {
            parameters.updateValue(after, forKey: "after")
        }
        
        if let type = reactionType?.apiName {
            parameters.updateValue(type, forKey: "reaction_type")
        }

        try? RequestNetworkData.share.textRequest(method: .get, path: path, parameter: parameters) { response, result in

            guard result == true else {
                completion?(nil, false, TSCommonNetworkManager.getNetworkErrorMessage(with: response) ?? "error_network".localized)
                return
            }
            let data = Mapper<FeedReactionsModel>().map(JSONObject: response)
            completion?(data, true, nil)
            
        }
    }

    func reactToFeed(id: Int, reaction: ReactionTypes?, complete: @escaping((_ message: String?, _ result: Bool) -> Void)) {
        var path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.react.rawValue
        path = path.replacingOccurrences(of: "{feed_id}", with: id.stringValue)
        if let reaction = reaction {
            var parameters: [String: Any] = [
                "reaction_type": reaction.apiName
            ]
        
            try? RequestNetworkData.share.textRequest(method: .post, path: path, parameter: parameters) { response, result in
                var message: String?
                // 请求失败处理
                guard result else {
                    message = TSCommonNetworkManager.getNetworkErrorMessage(with: response) ?? "error_network".localized
                    complete(message, false)
                    return
                }
                // 请求成功处理
                message = TSCommonNetworkManager.getNetworkSuccessMessage(with: response)
                complete(message, true)
            }

        } else {
            try? RequestNetworkData.share.textRequest(method: .delete, path: path, parameter: nil) { response, result in
                var message: String?
                // 请求失败处理
                guard result else {
                    message = TSCommonNetworkManager.getNetworkErrorMessage(with: response) ?? "error_network".localized
                    complete(message, false)
                    return
                }
                // 请求成功处理
                message = TSCommonNetworkManager.getNetworkSuccessMessage(with: response)
                complete(message, true)
            }
        }

    }

    // MARK: - 打赏
    // 打赏某条动态
    func reward(price: Double, momentId: Any, complete: @escaping((_ message: String?, _ result: Bool) -> Void)) {
        guard price > 0 else {
            assert(false, "打赏金额小于0")
            return
        }
        let requestMethod = TSMomentNetworkRequest().reward
        var parameter: [String : Any] = ["amount": price]
        if TSAppConfig.share.localInfo.shouldShowRewardAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parameter.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }
        if let user = CurrentUserSessionInfo {
            parameter["request_id"] = user.requestKey
        }

        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(momentId)"), parameter: parameter, complete: { (networkResponse, result) in
            var message: String?
            // 请求失败处理
            guard result else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse) ?? "error_network".localized
                complete(message, false)
                return
            }
            // 请求成功处理
            message = TSCommonNetworkManager.getNetworkSuccessMessage(with: networkResponse) ??  "reward_success".localized
            complete(message, true)
        })
    }

    // 打赏列表
    func rewardList(momentID: Int, maxID: Int?, complete: @escaping((_ data: [TSNewsRewardModel]?, _ result: Bool) -> Void)) {
        guard momentID > 0 else {
            assert(false, "打赏金额小于0")
            return
        }
        let requestMethod = TSMomentNetworkRequest().rewardList
        var parameter: Dictionary<String, Any> = ["limit": TSAppConfig.share.localInfo.limit]
        if let maxID = maxID {
            parameter["since"] = maxID
        }
        parameter["order"] = "desc"
        parameter["order_type"] = "date"
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(momentID)"), parameter: parameter, complete: { (networkResponse, result) in
            guard result == true else {
                complete(nil, false)
                return
            }
            let data = Mapper<TSNewsRewardModel>().mapArray(JSONObject: networkResponse)
            complete(data, true)
        })
    }

    /// 设置动态置顶
    ///
    /// - Parameters:
    ///   - feedId: 动态 id
    ///   - days: 置顶天数
    ///   - amount: 置顶金额
    ///   - complete: 结果
    func set(feed feedId: Int, toTopDuring days: Int, withMoney amount: Int, complete: @escaping((Bool, String?) -> Void)) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue + "/\(feedId)" + TSURLPathV2.Feed.pinneds.rawValue
        var parametars: [String : Any] = ["day": days, "amount": amount]
        if TSAppConfig.share.localInfo.shouldShowRewardAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parametars.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: parametars, complete: { (datas: NetworkResponse?, status: Bool) in
            var message: String?
            if status {
                message = TSCommonNetworkManager.getNetworkSuccessMessage(with: datas)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: datas)
            }
            complete(status, message)
        })
    }

    /// 删除动态
    func deleteMoment(_ feedIdentity: Int, complete: @escaping ((_ success: Bool) -> Void)) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue + "/\(feedIdentity)/currency"

        try! RequestNetworkData.share.textRequest(method: .delete, path: path, parameter: nil) { (data: NetworkResponse?, _) in
            if data is NetworkError {
                complete(false)
            } else {
                complete(true)
            }
        }
    }

    /// 收藏/取消收藏某条动态
    func colloction(_ newState: Int, feedIdentity: Int, feedItem: FeedListCellModel?, _ complete: @escaping((Bool) -> Void)) {
        
        let collectPath = newState == 1 ? TSURLPathV2.Feed.collection.rawValue : TSURLPathV2.Feed.uncollect.rawValue
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue + "/\(feedIdentity)" + collectPath
        
        
        try! RequestNetworkData.share.textRequest(method: newState == 1 ? .post : .delete, path: path, parameter: nil) { (data: NetworkResponse?, _) in
            guard TSReachability.share.isReachable() else {
                UIViewController.topMostController?.showError(message: "network_is_not_available".localized)
                complete(false)
                return
            }
            if data is NetworkError {
                complete(false)
            } else {
                complete(true)
                //上报动态收藏事件
                EventTrackingManager.instance.trackEvent(
                    itemId: feedIdentity.stringValue,
                    itemType: feedItem?.feedType == .miniVideo ? ItemType.shortvideo.rawValue   : ItemType.image.rawValue,
                    behaviorType: newState == 1 ? BehaviorType.collect : BehaviorType.uncollect,
                    sceneId: "",
                    moduleId: ModuleId.feed.rawValue,
                    pageId: PageId.feed.rawValue)
            }
        }
    }
    
    /// disable comment/enable comment 某条动态
    func commentPrivacy(_ newCommentState: Int, feedIdentity: Int, _ complete: @escaping((Bool) -> Void)) {

        let commentPath = TSURLPathV2.Feed.disableComment.rawValue
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue + "/\(feedIdentity)" + commentPath
        let parametars: [String : Any] = ["disable": newCommentState == 1 ? "1" : "0"]
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: parametars) { (data: NetworkResponse?, _) in
            if data is NetworkError {
                complete(false)
            } else {
                complete(true)
            }
        }
    }

//
//    func postShortVideo(momentListObject: TSMomentListModel,
//                        shortVideoID: Int, coverImageID: Int,
//                        feedContent: String?,
//                        complete: @escaping((_ feedId: Int?, _ error: NSError?) -> Void)) {
//        var param: [String : Any] = Dictionary()
//        if let content = feedContent {
//            param["feed_content"] = content
//        }
//        param["feed_from"] = 3
//        param["video"] = ["video_id": shortVideoID, "cover_id": coverImageID]
//        param["feed_mark"] = momentListObject.feedIdentity
//        if !momentListObject.topics.isEmpty {
//            let topicArr = NSMutableArray()
//            for item in momentListObject.topics {
//                topicArr.append(item.topicId)
//            }
//            param["topics"] = topicArr
//        }
//
//        /// Privacy
//        param["privacy"] = momentListObject.privacy
//
//        if let location = momentListObject.location {
//            let locationObj: [String: Any] = [
//                "lid" : location.locationID,
//                "name": location.locationName,
//                "lat": location.locationLatitude,
//                "lng": location.locationLongtitude,
//                "address": location.address.orEmpty
//            ]
//            param["location"] = locationObj
//        }
//
//        param["hot_feed"] = "\(momentListObject.hotFeed)"
//
//        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue
//        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: param, complete: { (networkResponse, result) in
//            // 请求失败处理
//            guard result else {
//                // 解析错误原因
//                guard let responseDic = networkResponse as? Dictionary<String, Any> else {
//                    complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
//                    return
//                }
//                // 正常数据解析
//                let message = responseDic["message"] as? String
//                complete(nil, NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ??  "send_fail".localized]))
//                return
//            }
//            // 服务器数据异常处理
//            guard let responseDic = networkResponse as? Dictionary<String, Any> else {
//                complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
//                return
//            }
//            // 正常数据解析
//            let feedId = responseDic["id"] as? Int
//            complete(feedId, nil)
//        })
//    }

    func postShortVideo(shortVideoID: Int, coverImageID: Int, feedMark: Int, feedContent: String?, privacy: String, feedFrom: Int, topics: [TopicCommonModel]?, location: TSPostLocationObject?, isHotFeed: Bool, soundId: String?, videoType: VideoType, tagUsers: [UserInfoModel]?, tagMerchants: [UserInfoModel]?, tagVoucher: TagVoucherModel?, complete: @escaping((_ feedId: Int?, _ error: NSError?) -> Void)) {
        var param: [String: Any] = Dictionary()

        if let content = feedContent {
            param["feed_content"] = content
            param["language"] = content.detectLanguages()
        }

        param["feed_from"] = feedFrom
        param["feed_mark"] = feedMark
        param["privacy"] = privacy
        param["hot_feed"] = "\(isHotFeed)"

        var videoParam: [String: Any] = ["video_id": shortVideoID, "cover_id": coverImageID]
        if let soundId = soundId {
            videoParam["sound_id"] = soundId
        }
        param["video"] = videoParam

        if let topics = topics {
            let topicArr = NSMutableArray()
            for item in topics {
                topicArr.append(item.id)
            }
            param["topics"] = topicArr
        }

        if let location = location {
            let locationObj: [String: Any] = [
                "lid" : location.locationID,
                "name": location.locationName,
                "lat": location.locationLatitude,
                "lng": location.locationLongtitude,
                "address": location.address.orEmpty
            ]
            param["location"] = locationObj
        }
        
        //拿到关联的用户信息
        var atStrings = TSUtil.findTSAtStrings(inputStr: feedContent ?? "")
        atStrings = atStrings.map({$0.replacingOccurrences(of: "@", with: "")})
        
        if let users = tagUsers, users.count > 0 {
            var userIDs = TSUtil.generateMatchingUserIDs(tagUsers: users, atStrings: atStrings)
            param["tag_users"] = userIDs
        }
        if let merchants = tagMerchants, merchants.count > 0 {
            var merchantIDs = TSUtil.generateMatchingUserIDs(tagUsers: merchants, atStrings: atStrings)
            param["feed_rewards_link_yippi_user_ids"] = merchantIDs
        }
        if let tagVoucher = tagVoucher {
            let tagVoucherObjc: [String: Any] = [
                "tagged_voucher_id" : tagVoucher.taggedVoucherId,
                "tagged_voucher_title": tagVoucher.taggedVoucherTitle,
            ]
            param["tag_voucher"] = tagVoucherObjc
        }
        let path = videoType.path
        
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: param, complete: { (networkResponse, result) in
            // 请求失败处理
            guard result else {
                // 解析错误原因
                guard let responseDic = networkResponse as? Dictionary<String, Any> else {
                    complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
                    //complete(nil, "network_problem".localized)
                    return
                }
                // 正常数据解析
                let message = responseDic["message"] as? String
                LogManager.Log("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ??  "send_fail".localized]))\n", loggingType: .apiResponseData)

                complete(nil, NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ??  "send_fail".localized]))
                //complete(nil, message ?? "send_fail".localized)
                return
            }
            // 服务器数据异常处理
            guard let responseDic = networkResponse as? Dictionary<String, Any> else {
                complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
                //complete(nil, "network_problem".localized)
                return
            }
            // 正常数据解析
            let feedId = responseDic["id"] as? Int
            complete(feedId, nil)
        })

    }

    func release(feedContent: String, feedId: Int, privacy: String, images: [Int]?, feedFrom: Int, topics: [TopicCommonModel]?, repostType: String?, repostId: Int?, customAttachment: SharedViewModel?, location: TSPostLocationObject?, isHotFeed: Bool, tagUsers: [UserInfoModel]?, tagMerchants: [UserInfoModel]?, tagVoucher: TagVoucherModel?, complete: @escaping((_ feedId: Int?, _ error: NSError?) -> Void)) {
        var param: [String: Any] = Dictionary()

        param["feed_content"] = feedContent
        param["language"] = feedContent.detectLanguages()
        param["feed_mark"] = feedId
        param["privacy"] = privacy
        param["feed_from"] = 3
        param["hot_feed"] = "\(isHotFeed)"
        var arrayImages: Array<Dictionary<String, Any>> = []
        if let arrImg = images, arrImg.isEmpty == false {
            for id in arrImg {
                var dic: Dictionary<String, Any> = [:]
                dic["id"] = id
                arrayImages.append(dic)
            }
            param["images"] = arrayImages
        }

        if let topics = topics {
            let topicArr = NSMutableArray()
            for item in topics {
                topicArr.append(item.id)
            }
            param["topics"] = topicArr
        }

        if let repostType = repostType, let repostId = repostId, repostId > 0 {
            param["repostable_type"] = repostType
            param["repostable_id"] = repostId
        }

        if let location = location {
            let locationObj: [String: Any] = [
                "lid" : location.locationID,
                "name": location.locationName,
                "lat": location.locationLatitude,
                "lng": location.locationLongtitude,
                "address": location.address.orEmpty
            ]
            param["location"] = locationObj
        }

        if let attachment = customAttachment {
            param["custom_attachment"] = attachment.generateDictionary()
        }
        
        //拿到关联的用户信息
        var atStrings = TSUtil.findTSAtStrings(inputStr: feedContent)
        atStrings = atStrings.map({$0.replacingOccurrences(of: "@", with: "")})
        
        if let users = tagUsers, users.count > 0 {
            var userIDs = TSUtil.generateMatchingUserIDs(tagUsers: users, atStrings: atStrings)
            param["tag_users"] = userIDs
        }
        if let merchants = tagMerchants, merchants.count > 0 {
            var merchantIDs = TSUtil.generateMatchingUserIDs(tagUsers: merchants, atStrings: atStrings)
            param["feed_rewards_link_yippi_user_ids"] = merchantIDs
        }
        
        if let tagVoucher = tagVoucher {
            let tagVoucherObjc: [String: Any] = [
                "tagged_voucher_id" : tagVoucher.taggedVoucherId,
                "tagged_voucher_title": tagVoucher.taggedVoucherTitle,
            ]
            param["tag_voucher"] = tagVoucherObjc
        }
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: param, complete: { (networkResponse, result) in
            // 请求失败处理
            // 解析错误原因
            guard let responseDic = networkResponse as? Dictionary<String, Any> else {
                LogManager.Log("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(TSErrorCenter.create(With: TSErrorCode.networkError))\n", loggingType: .exception)
                complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
                return
            }
            // 正常数据解析
            let feedId = responseDic["id"] as? Int
            if let message = responseDic["message"] as? String {
                if feedId == nil {
                    LogManager.Log("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ??  "send_fail".localized]))\n", loggingType: .apiResponseData)
                    
                    complete(nil, NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ??  "send_fail".localized]))
                    return
                }
            }
            
            // 服务器数据异常处理
            guard let responseDic = networkResponse as? Dictionary<String, Any> else {
                LogManager.Log("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(TSErrorCenter.create(With: TSErrorCode.networkError))\n", loggingType: .exception)
                complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
                return
            }
            // 正常数据解析
            complete(feedId, nil)
        })

    }

    func update(feedContent: String, feedId: Int, privacy: String, images: [Int]?, feedFrom: Int, topics: [TopicCommonModel]?, repostType: String?, repostId: Int?, customAttachment: SharedViewModel?, location: TSPostLocationModel?, isHotFeed: Bool, tagVoucher: TagVoucherModel?, complete: @escaping((_ feedId: Int?, _ error: NSError?) -> Void)) {
        var param: [String: Any] = Dictionary()

        param["feed_content"] = feedContent
        param["language"] = feedContent.detectLanguages()
        param["feed_mark"] = feedId
        param["privacy"] = privacy
        param["feed_from"] = 3
        param["hot_feed"] = "\(isHotFeed)"
        var arrayImages: Array<Dictionary<String, Any>> = []
        if let arrImg = images, arrImg.isEmpty == false {
            for id in arrImg {
                var dic: Dictionary<String, Any> = [:]
                dic["id"] = id
                arrayImages.append(dic)
            }
            param["images"] = arrayImages
        }

        if let topics = topics {
            let topicArr = NSMutableArray()
            for item in topics {
                topicArr.append(item.id)
            }
        }

        if let repostType = repostType, let repostId = repostId, repostId > 0 {
            param["repostable_type"] = repostType
            param["repostable_id"] = repostId
        }

        if let location = location {
            let locationObj: [String: Any] = [
                "lid" : location.locationID,
                "name": location.locationName,
                "lat": location.locationLatitude,
                "lng": location.locationLongtitude,
                "address": location.address.orEmpty
            ]
            param["location"] = locationObj
        }

        if let attachment = customAttachment {
            param["custom_attachment"] = attachment.generateDictionary()
        }
        if let tagVoucher = tagVoucher {
            let tagVoucherObjc: [String: Any] = [
                "tagged_voucher_id" : tagVoucher.taggedVoucherId,
                "tagged_voucher_title": tagVoucher.taggedVoucherTitle,
            ]
            param["tag_voucher"] = tagVoucherObjc
        }
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.editFeed.rawValue + "\(feedId)"
        try! RequestNetworkData.share.textRequest(method: .patch, path: path, parameter: param, complete: { (networkResponse, result) in
            // 请求失败处理
            guard result else {
                // 解析错误原因
                guard let responseDic = networkResponse as? Dictionary<String, Any> else {
                    LogManager.Log("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(TSErrorCenter.create(With: TSErrorCode.networkError))\n", loggingType: .exception)
                    complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
                    return
                }
                // 正常数据解析
                let message = responseDic["message"] as? String
                LogManager.Log("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ??  "send_fail".localized]))\n", loggingType: .apiResponseData)

                complete(nil, NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ??  "send_fail".localized]))
                return
            }
            // 服务器数据异常处理
            guard let responseDic = networkResponse as? Dictionary<String, Any> else {
                LogManager.Log("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(TSErrorCenter.create(With: TSErrorCode.networkError))\n", loggingType: .exception)
                complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
                return
            }
            // 正常数据解析
            let feedId = responseDic["id"] as? Int
            complete(feedId, nil)
        })
    }
    
    func editRejectFeed(feedID: String, feedContent: String, feedId: Int, privacy: String, images: [Int]?, feedFrom: Int, topics: [TopicCommonModel]?, repostType: String?, repostId: Int?, customAttachment: SharedViewModel?, location: TSPostLocationObject?, isHotFeed: Bool, tagUsers: [UserInfoModel]?, tagMerchants: [UserInfoModel]?, tagVoucher: TagVoucherModel?, complete: @escaping((_ feedId: Int?, _ error: NSError?) -> Void)) {
        var param: [String: Any] = Dictionary()

        param["feed_content"] = feedContent
        param["language"] = feedContent.detectLanguages()
        param["feed_mark"] = feedId
        param["privacy"] = privacy
        param["feed_from"] = 3
        param["hot_feed"] = "\(isHotFeed)"
        if let arrImg = images, arrImg.isEmpty == false {
            param["images"] = arrImg
        }

        if let topics = topics {
            let topicArr = NSMutableArray()
            for item in topics {
                topicArr.append(item.id)
            }
            param["topics"] = topicArr
        }

        if let repostType = repostType, let repostId = repostId, repostId > 0 {
            param["repostable_type"] = repostType
            param["repostable_id"] = repostId
        }

        if let location = location {
            let locationObj: [String: Any] = [
                "lid" : location.locationID,
                "name": location.locationName,
                "lat": location.locationLatitude,
                "lng": location.locationLongtitude,
                "address": location.address.orEmpty
            ]
            param["location"] = locationObj
        }

        if let attachment = customAttachment {
            param["custom_attachment"] = attachment.generateDictionary()
        }
        if let tagVoucher = tagVoucher {
            let tagVoucherObjc: [String: Any] = [
                "tagged_voucher_id" : tagVoucher.taggedVoucherId,
                "tagged_voucher_title": tagVoucher.taggedVoucherTitle,
            ]
            param["tag_voucher"] = tagVoucherObjc
        }
        //拿到关联的用户信息
        var atStrings = TSUtil.findTSAtStrings(inputStr: feedContent)
        atStrings = atStrings.map({$0.replacingOccurrences(of: "@", with: "")})
        
        if let users = tagUsers, users.count > 0 {
            var userIDs = TSUtil.generateMatchingUserIDs(tagUsers: users, atStrings: atStrings)
            param["tag_users"] = userIDs
        }
        if let merchants = tagMerchants, merchants.count > 0 {
            var merchantIDs = TSUtil.generateMatchingUserIDs(tagUsers: merchants, atStrings: atStrings)
            param["feed_rewards_link_yippi_user_ids"] = merchantIDs
        }
        var path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.editRejectFeeds.rawValue
        path = path.replacingOccurrences(of: "{feed_id}", with: feedID)
        
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: param, complete: { (networkResponse, result) in
            // 请求失败处理
            guard result else {
                // 解析错误原因
                guard let responseDic = networkResponse as? Dictionary<String, Any> else {
                    LogManager.Log("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(TSErrorCenter.create(With: TSErrorCode.networkError))\n", loggingType: .exception)
                    complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
                    return
                }
                // 正常数据解析
                let message = responseDic["message"] as? String
                LogManager.Log("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ??  "send_fail".localized]))\n", loggingType: .apiResponseData)

                complete(nil, NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ??  "send_fail".localized]))
                return
            }
            // 服务器数据异常处理
            guard let responseDic = networkResponse as? Dictionary<String, Any> else {
                LogManager.Log("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(TSErrorCenter.create(With: TSErrorCode.networkError))\n", loggingType: .exception)
                complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
                return
            }
            // 正常数据解析
            complete(feedID.toInt(), nil)
        })

    }
    
    func editRejectShortVideo(feedID: String, shortVideoID: Int, coverImageID: Int, feedMark: Int, feedContent: String?, privacy: String, feedFrom: Int, topics: [TopicCommonModel]?, location: TSPostLocationObject?, isHotFeed: Bool, soundId: String?, videoType: VideoType, tagUsers: [UserInfoModel]?, tagMerchants: [UserInfoModel]?, tagVoucher: TagVoucherModel?, complete: @escaping((_ feedId: Int?, _ error: NSError?) -> Void)) {
        var param: [String: Any] = Dictionary()

        if var content = feedContent {
            param["feed_content"] = content
            param["language"] = content.detectLanguages()
        }
        param["feed_from"] = feedFrom
        param["feed_mark"] = feedMark
        param["privacy"] = privacy
        param["hot_feed"] = "\(isHotFeed)"
        if shortVideoID != 0 && coverImageID != 0 {
            param["video_id"] = "\(shortVideoID)"
            param["video_cover_id"] = "\(coverImageID)"
        }
        if let topics = topics {
            let topicArr = NSMutableArray()
            for item in topics {
                topicArr.append(item.id)
            }
            param["topics"] = topicArr
        }

        if let location = location {
            let locationObj: [String: Any] = [
                "lid" : location.locationID,
                "name": location.locationName,
                "lat": location.locationLatitude,
                "lng": location.locationLongtitude,
                "address": location.address.orEmpty
            ]
            param["location"] = locationObj
        }
        //拿到关联的用户信息
        var atStrings = TSUtil.findTSAtStrings(inputStr: feedContent ?? "")
        atStrings = atStrings.map({$0.replacingOccurrences(of: "@", with: "")})
        
        if let users = tagUsers, users.count > 0 {
            var userIDs = TSUtil.generateMatchingUserIDs(tagUsers: users, atStrings: atStrings)
            param["tag_users"] = userIDs
        }
        if let merchants = tagMerchants, merchants.count > 0 {
            var merchantIDs = TSUtil.generateMatchingUserIDs(tagUsers: merchants, atStrings: atStrings)
            param["feed_rewards_link_yippi_user_ids"] = merchantIDs
        }
        if let tagVoucher = tagVoucher {
            let tagVoucherObjc: [String: Any] = [
                "tagged_voucher_id" : tagVoucher.taggedVoucherId,
                "tagged_voucher_title": tagVoucher.taggedVoucherTitle,
            ]
            param["tag_voucher"] = tagVoucherObjc
        }
        var path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.editRejectFeeds.rawValue
        path = path.replacingOccurrences(of: "{feed_id}", with: feedID)
        
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: param, complete: { (networkResponse, result) in
            // 请求失败处理
            guard result else {
                // 解析错误原因
                guard let responseDic = networkResponse as? Dictionary<String, Any> else {
                    complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
                    //complete(nil, "network_problem".localized)
                    return
                }
                // 正常数据解析
                let message = responseDic["message"] as? String
                LogManager.Log("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ??  "send_fail".localized]))\n", loggingType: .apiResponseData)

                complete(nil, NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ??  "send_fail".localized]))
                //complete(nil, message ?? "send_fail".localized)
                return
            }
            // 服务器数据异常处理
            guard let responseDic = networkResponse as? Dictionary<String, Any> else {
                complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
                //complete(nil, "network_problem".localized)
                return
            }
            // 正常数据解析
            complete(feedID.toInt(), nil)
        })

    }
    
    
//    /// 发布动态
//    ///
//    /// - Parameters:
//    ///   - feed_content: 动态内容
//    ///   - feed_title: 动态标题
//    ///   - coordinate: 坐标
//    ///   - storageTaskIds: 图片id(服务器返回)
//    ///   - feedMark: 用户Id 拼接 时间戳
//    ///   - complete: 返回是否成功
//    func release(momentListObject: TSMomentListModel, storageTaskIds: Array<Int>?, complete: @escaping((_ feedId: Int?, _ error: NSError?) -> Void)) {
//        var param: [String : Any] = Dictionary()
//        param["feed_content"] = momentListObject.content
//        param["language_code"] = momentListObject.content.findLanguage()
//        param["feed_mark"] = momentListObject.feedIdentity
//        // [长期注释] 暂时没有发布动态时候，发布位置的需求
////        if let coordinate = coordinate {
////            param["latitude"] = coordinate.latitude
////            param["longtitude"] = coordinate.longtitude
////            param["geohash"] = Geohash.encode(latitude: Double(coordinate.latitude)!, longitude: Double(coordinate.longtitude)!)
////        }
//
//        /// Privacy
//        param["privacy"] = momentListObject.privacy.lowercased()
//
//        if momentListObject.textPrice > 0 {
//            // 价格 单位积分
//            param["amount"] = momentListObject.textPrice
//        }
//
////        结构：{ id: <id>, amount: <amount>, type: <read|download> }，amount 为可选，id 必须存在，amount 为收费金额，单位分, type 为收费方式
//        var images: Array<Dictionary<String, Any>> = []
//        if storageTaskIds != nil {
//            for id in storageTaskIds! {
//                var dic: Dictionary<String, Any> = [:]
//                dic["id"] = id
//                images.append(dic)
//            }
//        }
//        // 图片是否付费
//        var isImagePay = false
//        for picture in momentListObject.pictures {
//            if picture.payType != 0 {
//                isImagePay = true
//                continue
//            }
//        }
//        if isImagePay == true {
//            for (index, picture) in momentListObject.pictures.enumerated() {
//                if picture.price != 0 {
//                    var image = images[index]
//                    image["type"] = (picture.payType == 1) ? "download" : "read"
//
//                    // 图片价格，由之前的金额更正为积分
//                    image["amount"] = picture.price
//                    images[index] = image
//                }
//            }
//        }
//
//        if !images.isEmpty {
//            param["images"] = images
//        }
//
//        param["feed_from"] = 3
//
//        if !momentListObject.topics.isEmpty {
//            let topicArr = NSMutableArray()
//            for item in momentListObject.topics {
//                topicArr.append(item.topicId)
//            }
//            param["topics"] = topicArr
//        }
//        /// 转发
//        if let repostType = momentListObject.repostType, momentListObject.repostID > 0 {
//            param["repostable_type"] = repostType
//            param["repostable_id"] = momentListObject.repostID
//        }
//
//        if let sharedModel = momentListObject.sharedModel {
//            param["custom_attachment"] = sharedModel.generateDictionary()
//        }
//
//        if let location = momentListObject.location {
//            let locationObj: [String: Any] = [
//                "lid" : location.locationID,
//                "name": location.locationName,
//                "lat": location.locationLatitude,
//                "lng": location.locationLongtitude,
//                "address": location.address.orEmpty
//            ]
//            param["location"] = locationObj
//        }
//
//        param["hot_feed"] = "\(momentListObject.hotFeed)"
//
//        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue
//        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: param, complete: { (networkResponse, result) in
//            // 请求失败处理
//            guard result else {
//                // 解析错误原因
//                guard let responseDic = networkResponse as? Dictionary<String, Any> else {
//                    bfprint("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(TSErrorCenter.create(With: TSErrorCode.networkError))\n")
//                    complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
//                    return
//                }
//                // 正常数据解析
//                let message = responseDic["message"] as? String
//                bfprint("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ??  "send_fail".localized]))\n")
//
//                complete(nil, NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ??  "send_fail".localized]))
//                return
//            }
//            // 服务器数据异常处理
//            guard let responseDic = networkResponse as? Dictionary<String, Any> else {
//                bfprint("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(TSErrorCenter.create(With: TSErrorCode.networkError))\n")
//                complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
//                return
//            }
//            // 正常数据解析
//            let feedId = responseDic["id"] as? Int
//            complete(feedId, nil)
//        })
//    }
//
//    func update(momentListObject: TSMomentListModel, storageTaskIds: Array<Int>?, feedIdentity: Int? = 0, complete: @escaping((_ feedId: Int?, _ error: NSError?) -> Void)) {
//        guard let id = feedIdentity else { return }
//        var param: [String : Any] = Dictionary()
//        param["feed_content"] = momentListObject.content
//        param["language_code"] = momentListObject.content.findLanguage()
//        param["feed_mark"] = momentListObject.feedIdentity
//        param["privacy"] = momentListObject.privacy.lowercased()
//        var images: Array<Dictionary<String, Any>> = []
//        if storageTaskIds != nil {
//            for id in storageTaskIds! {
//                var dic: Dictionary<String, Any> = [:]
//                dic["id"] = id
//                images.append(dic)
//            }
//        }
//        if !images.isEmpty {
//            param["images"] = images
//        }
//        param["feed_from"] = 3
//        if !momentListObject.topics.isEmpty {
//            let topicArr = NSMutableArray()
//            for item in momentListObject.topics {
//                topicArr.append(item.topicId)
//            }
//            param["topics"] = topicArr
//        }
//        if let repostType = momentListObject.repostType, momentListObject.repostID > 0 {
//            param["repostable_type"] = repostType
//            param["repostable_id"] = momentListObject.repostID
//        }
//
//        if let sharedModel = momentListObject.sharedModel {
//            param["custom_attachment"] = sharedModel.generateDictionary()
//        }
//
//        if let location = momentListObject.location {
//            let locationObj: [String: Any] = [
//                "lid" : location.locationID,
//                "name": location.locationName,
//                "lat": location.locationLatitude,
//                "lng": location.locationLongtitude,
//                "address": location.address.orEmpty
//            ]
//            param["location"] = locationObj
//        }
//
//        param["hot_feed"] = "\(momentListObject.hotFeed)"
//
//        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.editFeed.rawValue + "\(id)"
//        try! RequestNetworkData.share.textRequest(method: .patch, path: path, parameter: param, complete: { (networkResponse, result) in
//            // 请求失败处理
//            guard result else {
//                // 解析错误原因
//                guard let responseDic = networkResponse as? Dictionary<String, Any> else {
//                    bfprint("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(TSErrorCenter.create(With: TSErrorCode.networkError))\n")
//                    complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
//                    return
//                }
//                // 正常数据解析
//                let message = responseDic["message"] as? String
//                bfprint("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ??  "send_fail".localized]))\n")
//
//                complete(nil, NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ??  "send_fail".localized]))
//                return
//            }
//            // 服务器数据异常处理
//            guard let responseDic = networkResponse as? Dictionary<String, Any> else {
//                bfprint("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username ?? "") \(TSErrorCenter.create(With: TSErrorCode.networkError))\n")
//                complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
//                return
//            }
//            // 正常数据解析
//            let feedId = responseDic["id"] as? Int
//            complete(feedId, nil)
//        })
//    }
//
    /// 获取动态点赞数据,服务器根据时间排序
    ///
    /// - Parameters:
    ///   - feedId: 动态id
    ///   - after: 动态id, 获取该值之后的动态
    ///   - limit: 获取动态条数
    ///   - complete:
    ///     - data: 点赞用户数据
    ///     - error: 网络请求相关错误信息
    func getLikeList(feedId: Int, after: Int = 0, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping((_ data: [TSLikeUserModel]?, _ error: NetworkError?) -> Void)) {
        let requestMethod = TSFeedsNetworkRequest().likesList
        var parameter = [String: Any]()
        parameter["limit"] = limit
        parameter["after"] = after

        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(feedId)"), parameter: parameter) { (datas: NetworkResponse?, status: Bool) in
            guard status == true else {
                complete(nil, .networkErrorFailing)
                return
            }

            guard let likeList = datas as? [Dictionary<String, Any>] else {
                complete(nil, .networkErrorFailing)
                return
            }
            let users = Mapper<TSLikeUserModel>().mapArray(JSONArray: likeList)
            complete(users, nil)
        }
    }
//
//    /// 获取一条动态
//    ///
//    /// - Parameters:
//    ///   - feedId: 动态id
//    ///   - complete: 完成后的回调
//    class func getOneMoment(feedId: Int, complete: @escaping((_ momentObject: TSMomentListModel?, _ error: NSError?, _ resposeInfo: Any?, _ statusCode: Int?) -> Void)) {
//        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue + "/\(feedId)"
//        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status, code) in
//            // 1.网络请求失败处理
//            guard status else {
//                complete(nil, NSError(), data, code)
//                return
//            }
//            // 2.服务器数据异常处理
//            guard let moment = data as? Dictionary<String, Any> else {
//                complete(nil, NSError(), data, code)
//                return
//            }
//            // 3.正常数据解析
//            var model = TSMomentListModel(dataV2: moment)
//            /// 需要根据返回的转发ID和type去单独获取转发资源
//            if model.moment.repostType == "feeds" {
//                // 动态
//                let requestPath = TSURLPathV2.path.rawValue + "feeds"
//                let parameter: [String: Any] = ["id": model.moment.repostId]
//                try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (data, status, code) in
//                    // 1.网络请求失败处理
//                    guard status else {
//                        /// 这个地方需要判断一下是否是已经被删除
//                        /// 由于是批量获取的动态内容，所以如果被删除的原文，也会请求成功，但是data里边是两个空数组
//                        complete(nil, NSError(), data, code)
//                        return
//                    }
//                    // 2.服务器数据异常处理
//                    guard let moment = data as? Dictionary<String, Any>, let originalFeeds = moment["feeds"] as? Array<Dictionary<String, Any>> else {
//                        /// 说明原文不存在了
//                        /// 转发的动态的model
//                        let repostModel = TSRepostModel()
//                        repostModel.id = 0
//                        repostModel.type = .delete
//                        repostModel.typeStr = repostModel.type.rawValue
//                        model.moment.repostModel = repostModel
//                        complete(model, nil, data, 200)
//                        return
//                    }
//                    // 3.正常数据解析
//                    if originalFeeds.isEmpty {
//                        complete(nil, NSError(), data, 404)
//                    }else {
//                        let resourceModel = TSMomentListModel(dataV2: originalFeeds[0])
//                        var avatarURL = ""
//                        if let user = originalFeeds[0]["user"] as? [String:Any], let avatar = user["avatar"] as? [String:Any], let url = avatar["url"] as? String {
//                            avatarURL = url
//                        }
//                        // 请求原作者的信息
//                        TSTaskQueueTool.getAndSave(userIds: [resourceModel.userIdentity]) { (users, msg, status) in
//                            guard let users = users, users.isEmpty == false else {
//                                /// 已经删除的原文
//                                let repostModel = TSRepostModel()
//                                repostModel.id = 0
//                                repostModel.type = .delete
//                                repostModel.typeStr = repostModel.type.rawValue
//                                model.moment.repostModel = repostModel
//                                complete(model, nil, data, 200)
//                                return
//                            }
//                            // UserInfoModel
//                            let repostModel = TSRepostModel()
//                            repostModel.id = resourceModel.moment.feedIdentity
//                            repostModel.title = users[0].name
//                            repostModel.content = resourceModel.moment.content
//                            if let live = resourceModel.moment.liveModel, live.status != YPLiveStatus.finishProcess.rawValue {
//                                repostModel.type = .postLive
//                                if let coverID = resourceModel.coverID {
//                                    repostModel.coverImage = "\(coverID)".imageUrl()
//                                }
//                            } else if let videoID = resourceModel.videoID, videoID > 0 {
//                                repostModel.type = .postVideo
//                                if let coverID = resourceModel.coverID {
//                                    repostModel.coverImage = "\(coverID)".imageUrl()
//                                }
//                            } else if resourceModel.moment.pictures.count > 0 {
//                                repostModel.type = .postImage
//                                repostModel.coverImage = "\(resourceModel.moment.pictures[0].storageIdentity)".imageUrl()
//                            } else if let sharedModel = resourceModel.moment.sharedModel {
//                                if sharedModel.sharedType == SharedType.sticker.rawValue {
//                                    repostModel.type = .postSticker
//                                    repostModel.title = sharedModel.title
//                                    repostModel.content = sharedModel.desc
//                                    repostModel.coverImage = sharedModel.thumbnail
//                                } else if sharedModel.sharedType == SharedType.user.rawValue {
//                                    repostModel.type = .postUser
//                                    repostModel.title = sharedModel.title
//                                    repostModel.content = sharedModel.desc
//                                    repostModel.coverImage = sharedModel.thumbnail
//                                } else if sharedModel.sharedType == SharedType.metadata.rawValue {
//                                    repostModel.type = .postURL
//                                    repostModel.title = sharedModel.title
//                                    repostModel.content = sharedModel.url
//                                    repostModel.coverImage = sharedModel.thumbnail
//                                } else if sharedModel.sharedType == SharedType.live.rawValue {
//                                    repostModel.type = .postLive
//                                    repostModel.content = sharedModel.title
//                                    repostModel.coverImage = sharedModel.thumbnail
//                                }
//                            } else {
//                                repostModel.type = .postWord
//                                repostModel.coverImage = avatarURL
//                            }
//                            repostModel.typeStr = repostModel.type.rawValue
//                            /// 转发的动态的model
//                            model.moment.repostModel = repostModel
//                            complete(model, nil, data, code)
//                        }
//                    }
//                })
//            } else if model.moment.repostType == "news" {
//                let requestPath = TSURLPathV2.path.rawValue + "news"
//                var parameter: [String: Any] = [:]
//                parameter["id"] = model.moment.repostId
//                try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
//                    // 请求失败
//                    guard result else {
//                        /// 这个地方需要判断一下是否是已经被删除
//                        if let code = code, code == 404 {
//                            /// 转发的动态的model
//                            let repostModel = TSRepostModel()
//                            repostModel.id = 0
//                            repostModel.type = .delete
//                            repostModel.typeStr = repostModel.type.rawValue
//                            model.moment.repostModel = repostModel
//                            complete(model, nil, data, 200)
//                        } else {
//                            complete(nil, NSError(), data, code)
//                        }
//                        return
//                    }
//                    // 服务器数据异常
//                    guard let datas = networkResponse as? [[String : Any]], datas.isEmpty == false else {
//                        /// 已经删除的原文
//                        let repostModel = TSRepostModel()
//                        repostModel.id = 0
//                        repostModel.type = .delete
//                        repostModel.typeStr = repostModel.type.rawValue
//                        model.moment.repostModel = repostModel
//                        let objcet = model.converToObject()
//                        DatabaseManager().moment.save(moments: [objcet])
//                        complete(objcet, nil, data, 200)
//                        return
//                    }
//                    let info = datas[0]
//                    let repostModel = TSRepostModel()
//                    repostModel.id = info["id"] as! Int
//                    repostModel.title = info["title"] as? String
//                    repostModel.content = info["subject"] as? String
//                    repostModel.type = .news
//                    repostModel.typeStr = repostModel.type.rawValue
//                    if info["image"] != nil {
//                        let images = info["image"] as? Dictionary<String, Any>
//                        if images != nil {
//                            let imgUrl = TSURLPath.imageV2URLPath(storageIdentity: images?["id"] as? Int, compressionRatio: 20, cgSize: nil)
//                            repostModel.coverImage = imgUrl?.absoluteString
//                        }
//                    }
//                    /// 转发的动态的model
//                    model.moment.repostModel = repostModel
//                    complete(model, nil, data, code)
//                })
//            } else if model.moment.repostType == "questions" {
//                let requestPath = TSURLPathV2.path.rawValue + "questions"
//                var parameter: [String: Any] = [:]
//                parameter["id"] = model.moment.repostId
//                try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
//                    // 请求失败
//                    guard result else {
//                        /// 这个地方需要判断一下是否是已经被删除
//                        if let code = code, code == 404 {
//                            /// 转发的动态的model
//                            let repostModel = TSRepostModel()
//                            repostModel.id = 0
//                            repostModel.type = .delete
//                            repostModel.typeStr = repostModel.type.rawValue
//                            model.moment.repostModel = repostModel
//                            complete(model, nil, data, 200)
//                        } else {
//                            complete(nil, NSError(), data, code)
//                        }
//                        return
//                    }
//                    // 服务器数据异常
//                    guard let datas = networkResponse as? [[String : Any]], datas.isEmpty == false else {
//                        /// 已经删除的原文
//                        let repostModel = TSRepostModel()
//                        repostModel.id = 0
//                        repostModel.type = .delete
//                        repostModel.typeStr = repostModel.type.rawValue
//                        model.moment.repostModel = repostModel
//                        complete(model, nil, data, 200)
//                        return
//                    }
//                    let dataDic = datas[0]
//                    let repostModel = TSRepostModel()
//                    repostModel.id = dataDic["id"] as! Int
//                    repostModel.title = dataDic["subject"] as? String
//                    repostModel.content = dataDic["body"] as? String
//                    repostModel.type = .question
//                    repostModel.typeStr = repostModel.type.rawValue
//                    /// 转发的动态的model
//                    model.moment.repostModel = repostModel
//                    complete(model, nil, data, code)
//                })
//            } else if model.moment.repostType == "question-answers" {
//                let requestPath = TSURLPathV2.path.rawValue + "qa/reposted-answers"
//                var parameter: [String: Any] = [:]
//                parameter["id"] = model.moment.repostId
//                try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
//                    // 请求失败
//                    guard result else {
//                        /// 这个地方需要判断一下是否是已经被删除
//                        if let code = code, code == 404 {
//                            /// 转发的动态的model
//                            let repostModel = TSRepostModel()
//                            repostModel.id = 0
//                            repostModel.type = .delete
//                            repostModel.typeStr = repostModel.type.rawValue
//                            model.moment.repostModel = repostModel
//                            complete(model, nil, data, 200)
//                        } else {
//                            complete(nil, NSError(), data, code)
//                        }
//                        return
//                    }
//                    // 服务器数据异常
//                    guard let datas = networkResponse as? [[String : Any]], datas.isEmpty == false else {
//                        /// 已经删除的原文
//                        let repostModel = TSRepostModel()
//                        repostModel.id = 0
//                        repostModel.type = .delete
//                        repostModel.typeStr = repostModel.type.rawValue
//                        model.moment.repostModel = repostModel
//                        complete(model, nil, data, 200)
//                        return
//                    }
//                    let dataDic = datas[0]
//                    let repostModel = TSRepostModel()
//                    repostModel.id = dataDic["id"] as! Int
//                    let questionDic = dataDic["question"] as? Dictionary<String, Any>
//                    repostModel.title = questionDic!["subject"] as? String
//                    repostModel.content = dataDic["body"] as? String
//                    repostModel.type = .questionAnswer
//                    repostModel.typeStr = repostModel.type.rawValue
//                    /// 转发的动态的model
//                    model.moment.repostModel = repostModel
//                    complete(model, nil, data, code)
//                })
//            } else {
//                complete(model, nil, data, code)
//            }
//        })
//    }
}
