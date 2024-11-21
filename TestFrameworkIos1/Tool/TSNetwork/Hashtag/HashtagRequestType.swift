//
//  HashtagRequestType.swift
//  Yippi
//
//  Created by Jerry Ng on 22/03/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper
import ObjectBox

fileprivate class HashtagRequestType {
    
    let getHashtagList = Request<HashtagListModel>(method: .get, path: "feeds/hashtag/lists?country={country}", replacers: ["{country}"])
    
    let getHashtagDetails = Request<HashtagDetailModel>(method: .get, path: "feeds/hashtag/details?type={type}&hashtag_id={hashtag_id}&limit={limit}&after={after}", replacers: ["{type}", "{hashtag_id}", "{limit}", "{after}"])
}

public class HashtagRequest {
    
    func getHashtagList(countryCode: String = "", onSuccess: @escaping (HashtagListModel?) -> Void, onFailure: @escaping (String?) -> Void) {
        var request = HashtagRequestType().getHashtagList
        request.urlPath = request.fullPathWith(replacers: ["\(countryCode)"])
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
    
    func getHashtagDetail(type: String = "all", hashtagId: Int, limit: Int = 15, after: Int = 0, onSuccess: @escaping (HashtagDetailModel?) -> Void, onFailure: @escaping (String?) -> Void) {
        var request = HashtagRequestType().getHashtagDetails
        request.urlPath = request.fullPathWith(replacers: ["\(type)", "\(hashtagId)", "\(limit)", "\(after)"])
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .success(let response):
                
                if let model = response.model {
                    let repostFeedsListModelIDs: [Int] = model.feeds.filter { $0.repostId > 0 && $0.repostType != nil }.compactMap { $0.repostId }
                    
                    let group = DispatchGroup()
                    if repostFeedsListModelIDs.count > 0 {
                        group.enter()
                        FeedListNetworkManager.requestRepostFeedInfo(feedIDs: repostFeedsListModelIDs) { _ in
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) {
                        FeedListNetworkManager.requestUserInfo(to: model.feeds, complete: { (datas, message, status) in
                            if let datas = datas {
                                model.feeds = datas
                            }
                            onSuccess(model)
                        })
                    }
                } else {
                    onSuccess(response.model)
                }
            case .error(_):
                onFailure("network_problem".localized)
            case .failure(let response):
                onFailure(response.message)
            }
        }
    }
    
}

class HashtagModel: Decodable, Mappable, Entity {
    var entityId: Id = 0
    var id : Int = 0
    var name : String?
    var hashtagId: Int? = 0
    
    required init() { }
    
    required init?(map: Map){}

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        hashtagId <- map["hashtag_id"]
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case hashtagId = "hashtag_id"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        hashtagId = try values.decodeIfPresent(Int.self, forKey: .hashtagId)
    }
}

class HashtagListModel: Decodable, Mappable {
    var data : [HashtagModel] = []
    var types : [String] = []

    init () {}

    required init?(map: Map){}

    func mapping(map: Map) {
        data <- map["data"]
        types <- map["types"]
    }

    enum CodingKeys: String, CodingKey {
        case data
        case types
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decode(Array<HashtagModel>.self, forKey: .data)
        types = try values.decode(Array.self, forKey: .types)
    }
}

class HashtagBannerModel: Mappable {
    var name : String?
    var description : String?
    var country : String?
    var sequence : Int = 0
    var bannerUrl : String?
    var count : Int = 0
    var link : String?
    
    required init?(map: Map){}

    func mapping(map: Map) {
        name <- map["name"]
        description <- map["description"]
        country <- map["country"]
        sequence <- map["sequence"]
        bannerUrl <- map["banner_url"]
        count <- map["count"]
        link <- map["link"]
    }

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case country
        case sequence
        case bannerUrl = "banner_url"
        case count
        case link
    }
}

class HashtagDetailModel: Mappable {
    var data : HashtagBannerModel?
    var feeds : [FeedListModel] = []
    
    required init?(map: Map){}

    func mapping(map: Map) {
        data <- map["data"]
        feeds <- map["feeds"]
    }
}
