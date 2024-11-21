//
//  EShopLandingModel.swift
//  Yippi
//
//  Created by Jerry Ng on 15/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

public class EShopLandingPageModel: Mappable {
    var banners: [EShopLandingBannerModel] = [EShopLandingBannerModel]()
    var settings: Int = 0
    var shops: [UserInfoModel] = [UserInfoModel]()
    var kol: [UserInfoModel] = [UserInfoModel]()
    var categories: [EShopCategoryModel] = [EShopCategoryModel]()
    
    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        banners <- map["banners"]
        settings <- map["settings"]
        shops <- map["shops"]
        categories <- map["categories"]
    }
    
    init() {
    }
}

public class EShopLandingBannerModel: Mappable {
    var title: String = ""
    var language: String = ""
    var sequence: String = ""
    var image: String = ""
    var link: String = ""
    
    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        title <- map["title"]
        language <- map["language"]
        sequence <- map["sequence"]
        image <- map["image"]
        link <- map["link"]
    }
    
    init() {
    }
}

public class EShopLandingShopListModel: Mappable {
    
    var shopList: [UserInfoModel] = []
    
    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        shopList <- map["data"]
    }
    
    init() {
    }
}

public class EShopCategoryModel: Mappable {
    var title: String?
    var slug: String?
    var shops: [UserInfoModel] = []
    
    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        title <- map["title"]
        slug <- map["slug"]
        shops <- map["data"]
    }
    
    init() {
    }
}
