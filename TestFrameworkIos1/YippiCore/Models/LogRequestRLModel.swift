//
//  LogRequestCheckModel.swift
//  YippiCore
//
//  Created by Kit Foong on 24/09/2024.
//  Copyright © 2024 Chew. All rights reserved.
//

import Foundation
import ObjectMapper

public class LogRequestRLModel {
    var requestId: Int
    var startDate: String
    var endDate: String
    var type: String
    
    public init (requestId: Int, startDate: String, endDate: String, type: String) {
        self.requestId = requestId
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
    }
}

