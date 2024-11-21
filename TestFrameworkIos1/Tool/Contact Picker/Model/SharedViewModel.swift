//
//  SharedViewModel.swift
//  Yippi
//
//  Created by Yong Tze Ling on 30/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

enum SharedType: String {
    case link = "link"
    case sticker = "sticker_collection"
    case user = "user"
    case live = "live"
    case miniVideo = "minivideo"
    case metadata = "metadata"
    case miniProgram = "mini_program"
}

/// share
class SharedViewModel: Mappable {
    var thumbnail: String?
    var url: String?
    var title: String?
    var sharedType: String = ""
    var desc: String?
    var extra: String?
    var type: SharedType {
        return SharedType(rawValue: sharedType) ?? .link
    }
    var customAttachment: BaseAttachment? {
        switch type {
        case .sticker:
            return StickerAttachment(extra: extra)
        case .user, .live, .metadata, .miniProgram:
            return LinkAttachment(url: url.orEmpty)
        default:
            return nil
        }
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        thumbnail <- map["thumbnail"]
        url <- map["url"]
        title <- map["title"]
        sharedType <- map["type"]
        extra <- map["extra"]
        desc <- map["description"]
    }
}

extension SharedViewModel {
    
    func generateDictionary() -> Dictionary<String, Any> {
        return ["title": title,
                "thumbnail": thumbnail,
                "url": url,
                "type": sharedType,
                "extra": extra.orEmpty,
                "description": desc.orEmpty]
    }

//    static func getMPModel(data: MiniProgramShareModel) -> SharedViewModel {
//        let model = SharedViewModel()
//        model.title = data.title.orEmpty
//        model.desc = data.desc.orEmpty
//        model.thumbnail = data.thumbnail.orEmpty
//        model.url = data.path.orEmpty
//        let dictionary = ["appId": data.appId.orEmpty,
//                          "path": data.path.orEmpty] as Dictionary
//        model.extra = dictionary.toJSON
//        model.sharedType = SharedType.miniProgram.rawValue

//        return model
//    }
    
//    static func getModel(_ sticker: BundleInfo) -> SharedViewModel {
//        let model = SharedViewModel()
//        model.title = sticker.bundleName.orEmpty
//        model.thumbnail = sticker.bundleIcon.orEmpty
//        model.url = TSAppConfig.share.rootServerAddress + ShareURL.sticker.rawValue + sticker.bundleId
//        model.sharedType = SharedType.sticker.rawValue
//        let dictionary = ["bundle_id": sticker.bundleId,
//                          "bundle_name": sticker.bundleName.orEmpty,
//                          "bundle_description": sticker.description.orEmpty] as Dictionary
//        model.extra = dictionary.toJSON
//        return model
//    }
//    
//    static func getModel(_ model: HomepageModel) -> SharedViewModel {
//        let attachment = SharedViewModel()
//        attachment.title = model.userInfo.name
//        attachment.thumbnail = model.userInfo.avatarUrl.orEmpty
//        attachment.url = TSAppConfig.share.rootServerAddress + ShareURL.user.rawValue + model.userInfo.userIdentity.stringValue
//        attachment.sharedType = SharedType.user.rawValue
//        attachment.desc = model.userInfo.shortDesc
//        return attachment
//    }
    static func getModel(title: String?, description: String?, thumbnail: String?, url: String?, type:SharedType) -> SharedViewModel{
        let attachment = SharedViewModel()
        attachment.title = title ?? ""
        attachment.desc = description ?? ""
        attachment.thumbnail = thumbnail ?? ""
        attachment.url = url ?? ""
        attachment.sharedType = type.rawValue
        return attachment
    }
    static func getModel(_ live: LiveEntityModel, feedId: Int, hostImageURL: String?) -> SharedViewModel {
        let model = SharedViewModel()
        model.title = live.liveDescription
        model.desc = live.liveDescription
        model.thumbnail = hostImageURL ?? ""
        model.extra = feedId.stringValue
        
        if let username = CurrentUserSessionInfo?.username {
            model.url = TSAppConfig.share.rootServerAddress + ShareURL.feed.rawValue + "\(feedId)" + "/r=\(username)"
        } else {
            model.url = TSAppConfig.share.rootServerAddress + ShareURL.feed.rawValue + "\(feedId)"
        }
        
        model.url = TSAppConfig.share.rootServerAddress + ShareURL.feed.rawValue + "\(feedId)"
        model.sharedType = SharedType.live.rawValue
        return model
    }
    
    static func convert(_ object: SharedViewModel?) -> String? {
        guard let object = object else { return nil }
        return object.toJSONString()
    }
    static func convert(_ json: String?) -> SharedViewModel? {
        guard let json = json else { return nil }
        return SharedViewModel(JSONString: json)
    }
}

class BaseAttachment {

    var attachId: Int {
        return -1
    }
}

class StickerAttachment: BaseAttachment {
    
//    override var attachId: Int {
//        return object?.bundleId.toInt() ?? 0
//    }
//    
//    var object: BundleInfo? {
//        guard let extra = extra, let data = extra.data(using: .utf8) else { return nil }
//        let json = try? JSONSerialization.jsonObject(with: data, options: [])
//        if let jsonDict = json as? Dictionary<String, Any> {
//            return BundleInfo(unsafeResultMap: jsonDict)
//        }
//        return nil
//    }
    
    var extra: String?
    
    init(extra: String?) {
        self.extra = extra
    }
}

class LinkAttachment: BaseAttachment {
    
    override var attachId: Int {
        return URL(string: url)?.lastPathComponent.toInt() ?? 0
    }
    
    var url: String = ""
    
    init(url: String) {
        self.url = url
    }
}
