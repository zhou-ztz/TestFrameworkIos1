//
//  EShopNetworkManager.swift
//  Yippi
//
//  Created by Jerry Ng on 15/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

class EShopNetworkManager {
    
    func getEShopDiscoverData(onSuccess: @escaping (EShopLandingPageModel?) -> Void, onFailure: @escaping (String?) -> Void) {
        let url = EShopNetworkRequest().getLandingPageModel.fullPath()
        var request = Request<EShopLandingPageModel>(method: .get, path: url, replacers: [""])
        request.urlPath = url
        RequestNetworkData.share.text(request: request, shouldProcessParameter: true) { (result) in
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
    
    func getShopList(slug: String = "all", limit: Int = 15, offset: Int = 0 ,onSuccess: @escaping ([UserInfoModel]?) -> Void, onFailure: @escaping (String?) -> Void) {
        let url = EShopNetworkRequest().getShopList.fullPathWith(replacers: [slug, "\(limit)", "\(offset)"])
        var request = Request<EShopLandingShopListModel>(method: .get, path: url, replacers: [""])
        request.urlPath = url
        RequestNetworkData.share.text(request: request, shouldProcessParameter: true) { (result) in
            switch result {
            case .success(let response):
                onSuccess(response.model?.shopList)
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
