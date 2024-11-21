//
//  TSUserInfoCertificationModel.swift
//  Yippi
//
//  Created by Jerry Ng on 18/02/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

//sourcery: RealmEntityConvertible
class TSUserInfoCertificationModel: Mappable {

    var autoUpgradeDialog:Bool = false
    

    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        autoUpgradeDialog <- map["auto_upgrade_dialog"]
    }
}
