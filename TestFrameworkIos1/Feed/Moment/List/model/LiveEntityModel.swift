//
//  LiveEntityModel.swift
//  Yippi
//
//  Created by CC Teoh on 29/11/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import ObjectMapper
import ObjectBox


class LiveEntityModel: Entity, Mappable {
    
    // objectbox: id = { "assignable": true }
    var feedId: Id = 0
    var streamName: String? = nil
    var liveDescription: String = ""
    var pushUrl = ""
    var rtmp = ""
    var status = -1
    var roomId: String = ""
    
    var rtmpSD = ""
    var rtmpLD = ""
    var rtmpHD = ""
    var flvSD = ""
    var flvLD = ""
    var flvHD = ""
    
    var frameIcon: String?
    var frameTint: String?
    var sorting: Int = 0
    
    var rtmpHost: String = ""
    var rtmpAuth: String = ""
    
    var host: String?
    var hostName: String?
    var hostIconUrl: String?
    var hostUsername: String?
    var hostAvatarUrl: String?

    var profileFrameIcon: String?
    var profileFrameTint: String?
    
    required init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        var key: Int? 
        key <- map["feed_id"]
        
        feedId = UInt64(key.orZero)
        
        streamName <- map["stream_name"]
        liveDescription <- map["description"]
        pushUrl <- map["push_url"]
        rtmp <- map["rtmp"]
        status <- map["status"]
        roomId <- map["room_id"]
        
        rtmpSD <- map["rtmp_sd"]
        rtmpHD <- map["rtmp_hd"]
        rtmpLD <- map["rtmp_ld"]
        flvSD <- map["flv_sd"]
        flvHD <- map["flv_hd"]
        flvLD <- map["flv_ld"]
        
        frameIcon <- map["live_frame.icon_url"]
        frameTint <- map["live_frame.color_code"]
        sorting <- map["live_frame.sort"]
        
        host <- map["users.user_id"]
        hostIconUrl <- map["users.verified.icon"]
        hostAvatarUrl <- map["users.avatar.url"]
        hostUsername <- map["users.username"]
        hostName <- map["users.name"]
        
        profileFrameIcon <- map["users.profile_frame.frame.icon_url"]
        profileFrameTint <- map["users.profile_frame.frame.color_code"]
        
        rtmpHost <- map["rtmp_host"]
        rtmpAuth <- map["rtmp_auth"]
    }
}


extension LiveEntityModel {    
    static func convert(_ object: LiveEntityModel?) -> String? {
        guard let object = object else { return nil }
        return object.toJSONString()
    }
    
    static func convert(_ json: String?) -> LiveEntityModel? {
        guard let json = json else { return nil }
        return LiveEntityModel(JSONString: json)
    }

    func avatarInfo() -> AvatarInfo {
        let verifiedInfo = TSUserVerifiedModel(type: hostIconUrl, icon: hostIconUrl)
        let info = AvatarInfo(avatarURL: hostAvatarUrl.orEmpty, verifiedInfo: verifiedInfo)
        info.frameColor = self.frameTint ?? self.profileFrameTint
        info.frameIcon = self.frameIcon ?? self.profileFrameIcon
        info.liveId = self.feedId.intValue
        return info
    }
}
