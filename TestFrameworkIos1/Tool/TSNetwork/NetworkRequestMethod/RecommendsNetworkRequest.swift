//
//  RecommendsNetworkRequest.swift
//  Yippi
//
//  Created by John Wong on 02/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

struct RecommendsNetworkRequest {
    
    enum requestType {
        case keyword, recommended, publicFigure, businessAccount
        
        var stringValue:String {
            switch self {
            case .keyword:
                return "keyword"
            case .recommended:
                return "recommended"
            case .publicFigure:
                return "public-figure"
            case .businessAccount:
                return "business-account"
            }
        }
    }
    
    
    let getRecommendedList = TSNetworkRequestMethod(method: .get, path: "recommends", replacers: [])
}
