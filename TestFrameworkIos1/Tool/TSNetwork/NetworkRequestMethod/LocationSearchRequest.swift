//
//  LocationSearchRequest.swift
//  Yippi
//
//  Created by francis on 07/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation

struct LocationSearchRequest {
    let searchList = TSNetworkRequestMethod(method: .get, path: "feeds/location", replace: nil)
}
