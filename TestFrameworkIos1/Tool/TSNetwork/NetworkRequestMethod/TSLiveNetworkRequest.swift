//
//  TSLiveNetworkRequest.swift
//  Yippi
//
//  Created by Yong Tze Ling on 31/07/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit

struct TSLiveNetworkRequest {
    /// 创造直播
    let create = TSNetworkRequestMethod(method: .post, path: "feeds/live", replace: nil)
    /// 停止直播
    let stop = TSNetworkRequestMethod(method: .post, path: "feeds/live/destroy/{feed}", replace: "{feed}")
    /// 直播信息，后台负责云信信息，前台只做好回调管理就行。
    let comment = TSNetworkRequestMethod(method: .post, path: "feeds/live/comment/{feed}", replace: "{feed}")
    /// summary when live ended
    let summary = TSNetworkRequestMethod(method: .post, path: "feeds/live/summary/{feed}", replace: "{feed}")
    /// List of tippers
    let tippingList = TSNetworkRequestMethod(method: .get, path: "feeds/live/summary/tip/{feed}", replace: "{feed}")
    /// viewers
    let viewers = TSNetworkRequestMethod(method: .post, path: "feeds/live/viewer/{feed}", replace: "{feed}")
    /// room info
    let roomInfo = TSNetworkRequestMethod(method: .get, path: "feeds/live/roomInfo/{feed}", replace: "{feed}")
    /// viewer join
    let joinViewer = TSNetworkRequestMethod(method: .post, path: "feeds/live/viewer/{feed}/join", replace: "{feed}")
    /// viewer leave
    let leaveViewer = TSNetworkRequestMethod(method: .post, path: "feeds/live/viewer/{feed}/leave", replace: "{feed}")
    
    let getUserLive = TSNetworkRequestMethod(method: .get, path: "feeds/live/user/{user_id}", replace: "{user_id}")
    
    let getListOfLive = TSNetworkRequestMethod(method: .get, path: "live/stream", replace: nil)
    
    let getLiveAddresses = TSNetworkRequestMethod(method: .get, path: "live/getaddress/{username}/{roomid}", replacers: ["{username}","{roomid}"])
    
    let getLiveBanner = TSNetworkRequestMethod(method: .get, path: "feeds/live/banner/{feed_id}", replace: "{feed_id}")
    
    let treasurePackages = TSNetworkRequestMethod(version: "wallet/api/", method: .get, path: "eggs/live/packages", replace: nil)
    
    let replySupporter = TSNetworkRequestMethod(method: .post, path: "user/message", replace: nil)
    
    let getSlotList = TSNetworkRequestMethod(method: .get, path: "feeds/live/slotInfo/{feed_id}", replace: "{feed_id}")
    
    let getSlotListWithoutId = TSNetworkRequestMethod(method: .get, path: "feeds/live/slotInfo", replace: nil)
    
    let getTimePeriodSlotList = TSNetworkRequestMethod(method: .get, path: "feeds/live/{days}/daysRanking/{feed_id}", replacers: ["{days}","{feed_id}"])
    
    let getTimePeriodSlotListWithoutId = TSNetworkRequestMethod(method: .get, path: "feeds/live/{days}/daysRanking", replacers: ["{days}"])

    let getLiveList = TSNetworkRequestMethod(method: .get, path: "live/list", replace: nil)
    
    let getEventRank = TSNetworkRequestMethod(method: .get, path: "feeds/live/eventRank/{feed_id}", replace: "{feed_id}")

    let getLiveCategoryList = TSNetworkRequestMethod(method: .get, path: "personalisedcontent/setting/live/categories", replace: nil)
    
    let createGroupLive = TSNetworkRequestMethod(method: .post, path: "subscription/group/live", replace: nil)
    
    let stopGroupLive = TSNetworkRequestMethod(method: .post, path: "subscription/group/live/destroy/{feed}", replace: "{feed}")
}
