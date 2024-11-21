//
//  CertificateResponseModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import ObjectMapper

struct TSCertificateFileModel: Mappable {
    var file: Int = 0
    var size: CGSize = CGSize.zero
    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        file <- map["file"]
        size <- (map["size"], CGSizeTransform())
    }
}

struct CertificateResponseModel: Mappable {

    var id: Int = -1
    var userId: Int = -1
    var certificateName = ""
    var status = -1
    var name = ""
    var phone = ""
    var number = ""
    var desc = ""
    var bday = ""
    var files: [Int] = []
    var category: CertificateCategoryResponseModel? = nil
    var autoUpgradeDialog: Bool = false
    
    init?(map: Map) {}
    
//    init(object: EntityCertification) {
//        self.id = object.id
//        self.userId = object.userId
//        self.certificateName = object.certificationName
//        self.status = object.status
//        self.name = object.name
//        self.phone = object.phone
//        self.desc = object.desc
//        self.bday = object.bday
//        self.files = object.files.compactMap { $0 }
//    }

    mutating func mapping(map: Map) {
        certificateName <- map["certification_name"]
        userId <- map["user_id"]
        status <- map["status"]
        name <- map["data.name"]
        phone <- map["data.phone"]
        number <- map["data.number"]
        desc <- map["data.desc"]
        bday <- map["data.birthdate"]
        files <- map["data.files"]
        autoUpgradeDialog <- map["auto_upgrade_dialog"]
        category <- map["category"]
    }
}


class CertificateCategoryResponseModel : Mappable {
    
    var acceptReward : Int?
    var autoLivePinned : Int?
    var dailyLimit : String?
    var descriptionField : String?
    var displayName : String?
    var freeHotPost : Int?
    var hotPost : Int?
    var iconUrl : String?
    var isLiveEnable : Int?
    var name : String?
    var tokenInitialCount : Int?
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        acceptReward <- map["accept_reward"]
        autoLivePinned <- map["auto_live_pinned"]
        dailyLimit <- map["daily_limit"]
        descriptionField <- map["description"]
        displayName <- map["display_name"]
        freeHotPost <- map["free_hot_post"]
        hotPost <- map["hot_post"]
        iconUrl <- map["icon_url"]
        isLiveEnable <- map["is_live_enable"]
        name <- map["name"]
        tokenInitialCount <- map["token_initial_count"]
        
    }
    
}
