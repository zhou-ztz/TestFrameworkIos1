//
//  TSNewsNetworkManager.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

import Alamofire

class TSNewsNetworkManager: NSObject {

    // MARK: - 资讯栏目
    /// 从接口获取所有的栏目数据
    ///
    /// - Parameter complate: 结果
    func getNewsAllTags(complete: @escaping((_ data: TSNewsAllTagsModel?, _ result: Bool?) -> Void)) {
        /// 无参数
        let requestPath = TSURLPathV2.path.rawValue + TSURLPathV2.newsCates.rawValue
        try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: nil, complete: { (networkResponse, result) in
            // 请求失败
            guard result else {
                //let message = TSCommonNetworkManager.getNetworkSuccessMessage(with: networkResponse)
                complete(nil, false)
                return
            }
            // 服务器数据异常
            guard let dic = networkResponse as? [String:Any] else {
                complete(nil, false)
                return
            }
            // 正常数据解析
            let model = TSNewsAllTagsModel()
            model.setData(json: dic)
            complete(model, nil)
        })
    }



    // MARK: - 收藏
    /// 收藏/取消收藏某条动态
    ///
    /// - Parameters:
    ///   - status: true 收藏, false 取消收藏
    ///   - newsId: 资讯标识
    ///   - complete: 响应结果
    func colloction(_ newState: Bool, newsID id: Int, _ complete: @escaping((_ message: String?, _ error: NSError?) -> Void)) {
        let requestPath = TSNewsNetworkRequest().collection
        let type = newState == true ? HTTPMethod.post : HTTPMethod.delete
        try! RequestNetworkData.share.textRequest(method: type, path: requestPath.fullPathWith(replace: "\(id)"), parameter: nil, complete: { (networkResponse, result) in
            if result == true, let response = networkResponse as? String {
                complete(response, nil)
                return
            }
            complete(nil, TSErrorCenter.create(With: .networkError))
        })
    }


    // MARK: - 点赞/取消点赞
    /// 点赞,取消赞接口
    ///
    /// - Parameters:
    ///   - status: true 点赞, false 取消赞
    ///   - newsId: 资讯标识
    ///   - complete: 响应结果
    func like(_ status: Bool, newsId: Int, complete: @escaping((_ success: Bool) -> Void)) {
        let request = TSNewsNetworkRequest().like
        let method: HTTPMethod = status == true ? .post : .delete
        try! RequestNetworkData.share.textRequest(method: method, path: request.fullPathWith(replacers: ["\(newsId)"]), parameter: nil, complete: { (_, result) in
            complete(result)
        })
    }

    func likeList(newsId: Int, after: Int = 0, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping((_ data: [TSLikeUserModel]?, _ error: NetworkError?) -> Void)) {
        let requestMethod = TSNewsNetworkRequest().likeList
        var parameter = [String: Any]()
        parameter["limit"] = limit
        parameter["after"] = after

        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replacers: ["\(newsId)"]), parameter: parameter) { (datas: NetworkResponse?, status: Bool) in
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

    // MARK: - 打赏
    func reward(price: Double, newsId: Any, complete: @escaping((_ message: String?, _ result: Bool) -> Void)) {
        guard price > 0 else {
            assert(false, "打赏金额小于0")
            return
        }
        let requestMethod = TSNewsNetworkRequest().reward
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
        
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(newsId)"), parameter: parameter, complete: { (networkResponse, result) in
            // 请求失败处理
            guard result else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                complete(message, result)
                return
            }
            // 请求成功处理
            let message = TSCommonNetworkManager.getNetworkSuccessMessage(with: networkResponse) ??  "reward_success".localized
            complete(message, result)
        })
    }

    // 打赏列表
    func rewardList(newsID: Int, maxID: Int?, complete: @escaping((_ data: [TSNewsRewardModel]?, _ result: Bool) -> Void)) {
        guard newsID > 0 else {
            assert(false, "打赏金额小于0")
            return
        }
        let requestMethod = TSNewsNetworkRequest().rewardList
        var parameter: Dictionary<String, Any> = ["limit": 10]
        if let maxID = maxID {
            parameter["since"] = maxID
        }
        parameter["order"] = "desc"
        parameter["order_type"] = "date"
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(newsID)"), parameter: parameter, complete: { (networkResponse, result) in
            guard result == true else {
                complete(nil, false)
                return
            }
            let data = Mapper<TSNewsRewardModel>().mapArray(JSONObject: networkResponse)
            complete(data, true)
        })
    }

    // 打赏统计
    func rewardCount(newsID: Int, complete: @escaping((_ data: TSNewsRewardCountModel?, _ result: Bool) -> Void)) {
        guard newsID > 0 else {
            assert(false, "打赏金额小于0")
            return
        }
        let requestMethod = TSNewsNetworkRequest().rewardsCount
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(newsID)"), parameter: nil, complete: { (networkResponse, result) in
            guard result == true else {
                complete(nil, false)
                return
            }
            let data = Mapper<TSNewsRewardCountModel>().map(JSONObject: networkResponse)
            complete(data, true)
        })
    }
}


