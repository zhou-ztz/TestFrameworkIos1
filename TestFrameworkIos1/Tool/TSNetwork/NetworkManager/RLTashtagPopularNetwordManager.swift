//
//  RLTashtagPopularNetwordManager.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司-zhi on 2023/10/18.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

class RLTashtagPopularNetwordManager: NSObject  {
    
    /// 热门标签
    class func getPopularList(limit: Int = 15, onSuccess: @escaping (RLPopularDataModel?) -> Void, onFailure: @escaping (String?) -> Void){
        var request = RLSearchNetworkRequest().getPopularList
        request.urlPath = request.fullPathWith(replacers: ["\(limit)"])
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .success(let response):
                onSuccess(response.model)
            case .error(_):
                onFailure("network_problem".localized)
            case .failure(let response):
                onFailure(response.message)
            }
        }
    }
    ///全局搜索-商家
    class func searchMechantList(limit: Int = 15, offset: Int = 1, keyword: String, only: String = "shop", country_code: String = "MY", onSuccess: @escaping ([RLMerchantModel]?) -> Void, onFailure: @escaping (String?) -> Void){
        
        var request = RLSearchNetworkRequest().searchMechantList
        request.urlPath = request.fullPathWith(replacers: ["\(limit)", "\(offset)", only, country_code])
        request.parameter = ["keyword": keyword] 
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .success(let response):
                onSuccess(response.models)
            case .error(_):
                onFailure("network_problem".localized)
            case .failure(let response):
                onFailure(response.message)
            }
        }
    }
    
    class func favoriteMerchant(merchantId: String, onSuccess: @escaping (RLFavoriteMerchantModel?) -> Void, onFailure: @escaping (String?) -> Void) {
        var request = RLSearchNetworkRequest().favoriteMerchant
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = ["merchantId":merchantId]
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .success(let response):
                onSuccess(response.model)
            case .error(_):
                onFailure("network_problem".localized)
            case .failure(let response):
                onFailure(response.message)
            default:
                onFailure("")
            }
        }
    }
    
}


