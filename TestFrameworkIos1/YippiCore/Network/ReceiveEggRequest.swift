//
//  ReceiveEggRequest.swift
//  NIM
//
//  Created by Francis Yeap on 5/28/19.
//  Copyright © 2019 Chew. All rights reserved.
//

import Foundation

var JSONRequest: URLRequest {
    var urlReq = URLRequest(url: URL(string: FeedIMSDKManager.shared.param.apiBaseURL)!)
    
    if let token = UserDefaults.standard.object(forKey: "TSAccountTokenSaveKey") as? String {
        urlReq.allHTTPHeaderFields = [
            "Authorization" : "Bearer \(token)"
        ]
    }
    urlReq.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    urlReq.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
    
    return urlReq
}
