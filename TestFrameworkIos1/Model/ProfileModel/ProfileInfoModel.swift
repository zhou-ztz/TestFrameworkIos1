//
//  ProfileInfoModel.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2022/8/16.
//  Copyright © 2022 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

class ProfileInfoModel: Mappable {
    /// 个人情感状态
    var relationshipsArray: [ProfileInfoListModel]?
    /// 语言
    var languagesArray: [ProfileInfoListModel]?
    /// 工作行业
    var workIndustriesArray: [ProfileInfoListModel]?
    
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        relationshipsArray <- map["relationship"]
        languagesArray <- map["language"]
        workIndustriesArray <- map["work_industry"]
        
    }

    
}
