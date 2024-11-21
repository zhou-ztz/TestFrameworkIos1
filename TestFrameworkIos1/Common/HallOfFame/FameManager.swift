//
//  FameManager.swift
//  Yippi
//
//  Created by ChuenWai on 14/02/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit


enum badgeType {
    case event
    case nonEvent
}

class FameManager {

    static let shared = FameManager()

//    func setFameObject(data: UserBadgeResponse.BadgeItem, type: badgeType) -> FameObject {
//        guard let detail = data.badgeDetail else {
//            return FameObject()
//        }
//        var object: FameObject = FameObject()
//        var info: [FameInfo] = []
//        for(_, item) in detail.enumerated() {
//            info.append(FameInfo(badgeTitle: item.badgeTitle, badgeDesc: item.badgeDesc, badgeDetailInfo: item.detailBadgeInfo, badgeID: item.badgeID, badgeStatus: item.badgeStatus, badgeIconUrl: item.badgeIconUrl, detailBadgeIconUrl: item.detailBadgeIconUrl, detailPageBackgroundUrl: item.detailBadgeBackgroundUrl, achieved: item.getBadge, badgeType: type))
//        }
//        object = FameObject(sectionTitle: data.lokaliseKey, totalBadgeGotten: data.totalBadgeGet, totalBadgeCount: data.totalBadgeCount, info: info)
//
//        return object
//    }
}

class FameObject: NSObject {
    let sectionTitle: String
    let totalBadgeGotten, totalBadgeCount: Int
    let info: [FameInfo]

    init(sectionTitle: String = "", totalBadgeGotten: Int = 0, totalBadgeCount: Int = 0, info: [FameInfo] = []) {
        self.sectionTitle = sectionTitle
        self.totalBadgeGotten = totalBadgeGotten
        self.totalBadgeCount = totalBadgeCount
        self.info = info
    }
}

class FameInfo: NSObject {
    let badgeTitle, badgeDesc, badgeDetailInfo: String
    let badgeID, badgeStatus: Int
    let badgeIconUrl, detailBadgeIconUrl, detailPageBackgroundUrl: String
    let achieved: Int
    var isAchieved: Bool {
        return achieved != 0
    }
    let badgeType: badgeType

    init(badgeTitle: String = "", badgeDesc: String = "", badgeDetailInfo: String = "", badgeID: Int = 0, badgeStatus: Int = 0, badgeIconUrl: String = "", detailBadgeIconUrl: String = "", detailPageBackgroundUrl: String = "", achieved: Int = 0, badgeType: badgeType = .nonEvent) {
        self.badgeTitle = badgeTitle
        self.badgeDesc = badgeDesc
        self.badgeDetailInfo = badgeDetailInfo
        self.badgeID = badgeID
        self.badgeStatus = badgeStatus
        self.badgeIconUrl = badgeIconUrl
        self.detailBadgeIconUrl = detailBadgeIconUrl
        self.detailPageBackgroundUrl = detailPageBackgroundUrl
        self.achieved = achieved
        self.badgeType = badgeType
    }
}
