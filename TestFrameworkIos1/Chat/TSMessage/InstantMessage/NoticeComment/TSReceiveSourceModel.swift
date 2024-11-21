//
//  TSReceiveSourceModel.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2019/3/22.
//  Copyright © 2019年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class TSReceiveSourceModel: Mappable {

    var receiveCommentList: [TSReceiveCommentListModel] = []
    required init?(map: Map) {
    }

    func mapping(map: Map) {
        receiveCommentList <- map["data"]
    }

}
