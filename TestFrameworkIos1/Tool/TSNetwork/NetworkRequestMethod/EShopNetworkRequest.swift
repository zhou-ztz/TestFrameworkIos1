//
//  EShopNetworkRequest.swift
//  Yippi
//
//  Created by Jerry Ng on 15/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

struct EShopNetworkRequest {
    
    enum requestListType {
        case shop, kol
        
        var stringValue:String {
            switch self {
            case .kol:
                return "kol"
            case .shop:
                return "shop"
            }
        }
    }
    
    let getLandingPageModel = TSNetworkRequestMethod(method: .get, path: "eshop/discovers", replace: nil)
    
    let getShopList = TSNetworkRequestMethod(method: .get, path: "eshop/discovers/lists?type={type}&limit={limit}&offset={offset}", replacers: ["{type}","{limit}","{offset}"])
}
