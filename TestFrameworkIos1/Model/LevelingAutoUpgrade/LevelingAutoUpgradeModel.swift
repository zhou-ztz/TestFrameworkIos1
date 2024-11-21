//
//  LevelingAutoUpgradeModel.swift
//  Yippi
//
//  Created by Jerry Ng on 20/02/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper


public class DisplayAutoUpgradeDialogModel: Mappable {
    var displayMsg: DisplayAutoUpgradeDialogMessageModel?
    
    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        displayMsg <- map["display_msg"]
    }
}

public class DisplayAutoUpgradeDialogMessageModel: Mappable {
    var title: String?
    var description: String?
    var imageURL: String?
    
    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        title <- map["title"]
        description <- map["description"]
        imageURL <- map["dialog_icon_url"]
    }
}
