//
//  RejectNetworkRequest.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/7/26.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import ObjectMapper

import SwiftDate

class RejectNetworkRequestTypes {
    /// 被拒列表
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: Integer, 获取条数，默认 20
    ///    - offset: Integer, 数据偏移量，默认 0
    ///    - type: String, 获取通知类型，可选 all,read,unread 默认 all
    ///    - notification: String|Array, 检索具体通知，可以是由 , 拼接的 IDs 组，也可以是 Array
    let rejectList = Request<RejectModel>(method: .get, path: "feeds/reject/list", replacers: [])
    /// 标记所有消息已读
    ///
    /// - RouteParameter: None
    /// - RequestParameter: None
    let readAllNoti = Request<Empty>(method: .patch, path: "user/notifications", replacers: [])
    
    /// 被拒动态详情
    ///
    /// - RouteParameter: None
    /// - RequestParameter: None
    let rejectDetail = Request<RejectDetailModel>(method: .get, path: "feeds/reject/{feed_id}", replacers: ["{feed_id}"])
    
}

public class RejectNetworkRequest: NSObject {
    
    func getRejectDetail(feedId: String = "", onSuccess: @escaping (RejectDetailModel?) -> Void, onFailure: @escaping (String?) -> Void) {
        var request = RejectNetworkRequestTypes().rejectDetail
        request.urlPath = request.fullPathWith(replacers: ["\(feedId)"])
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .success(let response):
                onSuccess(response.model)
            case .error(_):
                onFailure("network_problem".localized)
            case .failure(let response):
                onFailure(response.message)
            }
        }
    }
    
    func readAllNoti(onSuccess: @escaping (Empty?) -> Void, onFailure: @escaping (String?) -> Void) {
        var request = RejectNetworkRequestTypes().readAllNoti
        request.urlPath = request.fullPathWith(replacers: [])
        request.urlPath = request.urlPath + "?type=feed_reject"
        let parameter: [String : Any] = ["type": "feed_reject"]
        
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .success(let response):
                onSuccess(response.model)
            case .error(_):
                onFailure("network_problem".localized)
            case .failure(let response):
                onFailure(response.message)
            }
        }
    }
    
}



struct RejectModel: Mappable {
    var data:[RejectListModel] = []
    var links:[String:Any] = [:]
    var meta:[String:Any] = [:]
    
    init?(map: Map) {
    }
    init() {
    }
    mutating func mapping(map: Map) {
        data <- map["data"]
        links <- map["links"]
        meta <- map["meta"]
    }
}

struct RejectListModel: Mappable {
    
    var id: Int = 0
    var createdAt: Date = Date()
    var data: [String:Any] = [:]
    var sensitiveContent: String = ""
    var cover: String = ""
    var isVideo: Bool = false
    
    init?(map: Map) {
    }
    init() {
    }
    mutating func mapping(map: Map) {
        id <- map["id"]
        createdAt <- (map["created_at"], DateTransformer)
        sensitiveContent <- map["sensitiveContent"]
        cover <- map["cover"]
        isVideo <- map["is_video"]
    }
}


struct RejectDetailModel: Mappable {
    var images = [RejectDetailModelImages]()
    var textModel: RejectDetailModelText?
    var video: RejectDetailModelVideo?
    var at = [String]()
    var location: RejectDetailModelLocation?
    var privacy: String?
    var topics = [RejectDetailModelTopics]()
    var tagUsers: [UserInfoModel]?
    var rewardsLinkMerchantUsers : [UserInfoModel]?
    var tagVoucher: TagVoucherModel?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        at     <- map["at"]
        images <- map["images"]
        textModel   <- map["text"]
        video  <- map["video"]
        location <- map["location"]
        privacy  <- map["privacy"]
        topics   <- map["topics"]
        tagUsers   <- map["tag_users"]
        rewardsLinkMerchantUsers   <- map["rewards_link_merchant_yippi_users"]
        tagVoucher   <- map["tag_voucher"]
    }
}

struct RejectDetailModelText: Mappable {
    var feedContent: String?
    var isSensitive: Bool = false
    var sensitiveType: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        feedContent   <- map["feedContent"]
        isSensitive   <- map["isSensitive"]
        sensitiveType <- map["sensitiveType"]
    }
}

struct RejectDetailModelImages: Mappable {
    var fileId: Int = 0
    var imagePath: String?
    var isSensitive: Bool = false
    var sensitiveType: String?
    
    init?(map: Map) {}
    
    init(fileId: Int, imagePath: String?, isSensitive: Bool, sensitiveType: String?) {
         self.fileId = fileId
         self.imagePath = imagePath
         self.isSensitive = isSensitive
         self.sensitiveType = sensitiveType
    }
    mutating func mapping(map: Map) {
        fileId        <- map["imageId"]
        imagePath     <- map["imagePath"]
        isSensitive   <- map["isSensitive"]
        sensitiveType <- map["sensitiveType"]
    }
}

struct RejectDetailModelVideo: Mappable {
    var coverId: Int = 0
    var coverPath: String?
    var isSensitive: Bool = false
    var sensitiveType: String?
    var videoId: Int = 0
    var videoPath: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        coverId       <- map["coverId"]
        coverPath     <- map["coverPath"]
        isSensitive   <- map["isSensitive"]
        sensitiveType <- map["sensitiveType"]
        videoId       <- map["videoId"]
        videoPath     <- map["videoPath"]
    }
}

struct RejectDetailModelLocation: Mappable {
    var address: String?
    var lat: Float = 0.0
    var lid: String?
    var lng: Float = 0.0
    var name: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        address <- map["address"]
        lat     <- map["lat"]
        lid     <- map["lid"]
        lng     <- map["lng"]
        name    <- map["name"]
    }
}

struct RejectDetailModelTopics: Mappable {
    var createdAt: String?
    var creatorUserId: Int = 0
    var desc: String?
    var feedsCount: Int = 0
    var followersCount: Int = 0
    var hotAt: String?
    var id: Int = 0
    var logo: RejectDetailModelTopicsLogo?
    var name: String?
    var pivot: RejectDetailModelTopicsPivot?
    var status: String?
    var updatedAt: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        createdAt       <- map["created_at"]
        creatorUserId   <- map["creator_user_id"]
        desc            <- map["desc"]
        feedsCount      <- map["feeds_count"]
        followersCount  <- map["followers_count"]
        hotAt           <- map["hot_at"]
        id              <- map["id"]
        logo            <- map["logo"]
        name            <- map["name"]
        pivot           <- map["pivot"]
        status          <- map["status"]
        updatedAt       <- map["updated_at"]
    }
}

struct RejectDetailModelTopicsPivot: Mappable {
    var feedId: Int = 0
    var topicId: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        feedId   <- map["feed_id"]
        topicId  <- map["topic_id"]
    }
}

struct RejectDetailModelTopicsLogo: Mappable {
    var dimension: RejectDetailModelTopicsLogoDimension?
    var mime: String?
    var size: String?
    var url: String?
    var vendor: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        dimension <- map["dimension"]
        mime      <- map["mime"]
        size      <- map["size"]
        url       <- map["url"]
        vendor    <- map["vendor"]
    }
}

struct RejectDetailModelTopicsLogoDimension: Mappable {
    var height: Int = 0
    var width: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        height <- map["height"]
        width  <- map["width"]
    }
}


