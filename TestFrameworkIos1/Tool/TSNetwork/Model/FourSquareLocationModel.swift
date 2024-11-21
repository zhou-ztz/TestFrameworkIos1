//
//  FourSquareLocationModel.swift
//  Yippi
//
//  Created by francis on 07/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

struct FourSquareLocationModel : Mappable {
    var locations : [TSPostLocationObject]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        locations <- map["locations"]
    }

}
