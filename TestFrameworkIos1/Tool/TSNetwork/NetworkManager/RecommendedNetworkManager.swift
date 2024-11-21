//
//  RecommendedNetworkManager.swift
//  Yippi
//
//  Created by John Wong on 02/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

class RecommendedNetworkManager {
    func getRecommendedList(type: String = "keyword", limit: Int = TSAppConfig.share.localInfo.limit, offset: Int = 0, isPaginate: Bool?, onSuccess: @escaping ([UserInfoModel]?) -> Void, onFailure: @escaping (String?) -> Void) {
        let url = RecommendsNetworkRequest().getRecommendedList.fullPath()
        var request = Request<UserInfoModel>(method: .get, path: url, replacers: [""])
        request.urlPath = url
        var params: [String:Any] = [:]
        params["limit"] = limit
        params["offset"] = offset
        params["type"] = type
        if let pagination = isPaginate {
            params["is_paginate"] = pagination
        }
        request.parameter = params
        RequestNetworkData.share.text(request: request, shouldProcessParameter: true) { (result) in
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
}
