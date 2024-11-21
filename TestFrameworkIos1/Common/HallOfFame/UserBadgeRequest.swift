//
//  UserBadgeRequest.swift
//  YippiCore
//
//  Created by ChuenWai on 13/02/2020.
//  Copyright © 2020 Chew. All rights reserved.
//

import Foundation


struct UserBadgeRequest: RequestType {
    typealias ResponseType = UserBadgeResponse

    let ID: Int

    var data: YPRequestData {
        return YPRequestData(
            path: "/api/v2/fame/\(ID)",
            method: .get,
            params: nil
        )
    }
}

struct UserBadgeResponse: Codable {
    let eventBadges: BadgeItem
    let dailyBadges: BadgeItem

    enum CodingKeys: String, CodingKey {
        case eventBadges = "event_badges"
        case dailyBadges = "non_event_badges"
    }
}

struct BadgeItem: Codable {
    let lokaliseKey: String
    let totalBadgeGet: Int
    let totalBadgeCount: Int
    let badgeDetail: [BadgeDetail]

    enum CodingKeys: String, CodingKey {
        case lokaliseKey = "localise_key"
        case totalBadgeGet = "total_achieved"
        case totalBadgeCount = "total_badges"
        case badgeDetail = "data"
    }
}

enum badgeStatus: Int, Codable {
    case inactive = 0
    case active = 1
    case comingSoon = 2

    init(from decoder: Decoder) throws {
        self = try badgeStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .active
    }
}

struct MedalRankItem: Codable {
    let id, status, sequence: Int
    let lastTriggerAt: String?
    let quantifier: String
    let badgeIcon, badgeIconSmall, detailBadge, detailBackground: String?
    let achieved: Int
    let achievedDate: String
    let currentCount, minimumCount, maximumCount: Int?
    let title, medalRankDescription, detailInfo: String

    enum CodingKeys: String, CodingKey {
        case id, status, sequence
        case lastTriggerAt = "last_trigger_at"
        case quantifier
        case badgeIcon = "badge_icon"
        case badgeIconSmall = "badge_icon_small"
        case detailBadge = "detail_badge"
        case detailBackground = "detail_background"
        case achieved
        case achievedDate = "achieved_date"
        case currentCount = "current_count"
        case minimumCount = "minimum_count"
        case maximumCount = "maximum_count"
        case title
        case medalRankDescription = "description"
        case detailInfo = "detail_info"
    }
}

struct BadgeDetail: Codable {
    let badgeID: Int
    let badgeStatus: badgeStatus
    let badgeIconUrl: String?
    let detailBadgeIconUrl: String?
    let detailBadgeBackgroundUrl: String?
    let getBadge: Int
    let getBadgeDate: String
    let badgeTitle: String
    let badgeDesc: String
    let detailBadgeInfo: String
    let multirank: Int
    let medalrank: [MedalRankItem]

    enum CodingKeys: String, CodingKey {
        case badgeID = "id"
        case badgeStatus = "status"
        case badgeIconUrl = "badge_icon"
        case detailBadgeIconUrl = "detail_badge"
        case detailBadgeBackgroundUrl = "detail_background"
        case getBadge = "achieved"
        case getBadgeDate = "achieved_date"
        case badgeTitle = "title"
        case badgeDesc = "description"
        case detailBadgeInfo = "detail_info"
        case multirank = "multi_rank"
        case medalrank = "medal_ranks"
    }
}


