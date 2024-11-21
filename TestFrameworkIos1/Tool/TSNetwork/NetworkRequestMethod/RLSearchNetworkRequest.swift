//
//  RLSearchNetworkRequest.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司-zhi on 2023/10/18.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

struct RLSearchNetworkRequest {
    //获取热门标签
    let getPopularList = Request<RLPopularDataModel>(method: .get, path: "feeds/hashtag/popular?limit={limit}", replacers: ["{limit}"])
    //搜索商家
    let searchMechantList = Request<RLMerchantModel>(method: .get, path: "search?limit={limit}&offset={offset}&only={only}&country_code={country_code}", replacers: ["{limit}", "{offset}", "{only}", "{country_code}"])
    //收藏商家
    let favoriteMerchant = Request<RLFavoriteMerchantModel>(method: .post, path: "user/merchant/favorite", replacers: [])
    
}

struct RLPopularDataModel: Mappable {
    var data: [RLPopularModel]?
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        data <- map["data"]
    }
}

struct RLPopularModel: Mappable {
    
    var name: String = ""
    var id: Int = 0
    var count: String = ""
    var hasFollow: String = ""
   
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
        count <- map["count"]
        hasFollow <- map["has_follow"]
    }
}

struct RLMerchantModel: Mappable {
    
    var merchantId: Int = 0 // biz商户id
    var title: String = ""
    var image: String = ""
    var category: String = ""
    var address: String = ""
    var rating: String = ""
    var yippiUserId : String = ""
    var rebate: String = ""
    var path: String? 
    var favorite: Int = 0
    var yippsWantedMerchantId: Int = 0 //跳转yippsWanted id
    var yippsWantedBranchId: Int = 0
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        merchantId <- map["merchant_id"]
        title <- map["title"]
        image <- map["image"]
        category <- map["category"]
        address <- map["address"]
        rating <- map["rating"]
        yippiUserId <- map["yippi_user_id"]
        rebate <- map["rebate"]
        path <- map["path"]
        favorite <- map["favorite"]
        yippsWantedBranchId <- map["yipps_wanted_branch_id"]
        yippsWantedMerchantId <- map["yipps_wanted_merchant_id"]
    }
}

struct RLFavoriteMerchantModel: Mappable {
    var data: RLFavoriteModel?
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        data <- map["data"]
    }
}

struct RLFavoriteModel: Mappable {
    var favorite: Int = 0
    
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        favorite <- map["favorite"]
    }
}
