//
//  ReferAndEarnMissionRequestType.swift
//  Yippi
//
//  Created by Jerry Ng on 21/07/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

struct ReferInviteShareRequestType: RequestType {
    var type: String
    var event: String
    
    typealias ResponseType = ReferInviteShareModel
    var data: YPRequestData {
        return YPRequestData(
            path: "/api/v2/external-share-acknowledgement",
            method: .post, params: ["type": type, "event": event])
    }
}

struct ReferInviteShareModel : Codable {
    
    let status: Bool
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try (values.decodeIfPresent(Bool.self, forKey: .status) ?? false)
    }
}

struct ReferAndEarnMissionRequestType: RequestType {
    typealias ResponseType = ReferAndEarnModel
    var data: YPRequestData {
        return YPRequestData(
            path: "/api/v2/refer-and-earn",
            method: .get, params: nil)
    }
}

//struct ReferAndEarnMissionClaimRequestType: RequestType {
//    typealias ResponseType = MessageOnlyResponseType
//    
//    var missionIndex: Int
//    
//    var data: YPRequestData {
//        return YPRequestData(
//            path: "/api/v2/refer-and-earn",
//            method: .post, params: ["mission_index":missionIndex])
//    }
//}

enum ReferAndEarnMissionStatusType: String, Codable {
    case inProgress = "in_progress"
    case pending = "pending"
    case completed = "claimable"
    case claimed = "claimed"
}

struct ReferAndEarnModel : Codable {
    
    let referLink: String
    let showYippsHunter: Bool
    let missions: [ReferAndEarnMissionModel]
    
    enum CodingKeys: String, CodingKey {
        case referLink = "refer-link"
        case showYippsHunter = "show-yipps-hunter"
        case missions = "missions"
    }
    
    init(referLink: String, missions: [ReferAndEarnMissionModel]) {
        self.referLink = referLink
        self.showYippsHunter = false
        self.missions = missions
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        referLink = try (values.decodeIfPresent(String.self, forKey: .referLink) ?? "")
        showYippsHunter = try (values.decodeIfPresent(Bool.self, forKey: .showYippsHunter) ?? false)
        missions = try (values.decodeIfPresent([ReferAndEarnMissionModel].self, forKey: .missions) ?? [])
    }
}

struct ReferAndEarnMissionModel : Codable {
    
    let status: ReferAndEarnMissionStatusType
    let message: String
    let subMissions: [SubMissionModel]
    let notes: String
    let rewards: Int
    let eligible: Bool

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case subMissions = "sub-missions"
        case notes = "notes"
        case rewards = "rewards"
        case eligible = "eligible"
    }
    
    init(status: ReferAndEarnMissionStatusType, message: String, progress: [SubMissionModel], notes: String, rewards: Int, eligible: Bool) {
        self.status = status
        self.message = message
        self.subMissions = progress
        self.notes = notes
        self.rewards = rewards
        self.eligible = eligible
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let statusString = try (values.decodeIfPresent(String.self, forKey: .status) ?? "")
        status = ReferAndEarnMissionStatusType(rawValue: statusString) ?? .pending
        message = try (values.decodeIfPresent(String.self, forKey: .message) ?? "")
        subMissions = try (values.decodeIfPresent([SubMissionModel].self, forKey: .subMissions) ?? [])
        notes = try (values.decodeIfPresent(String.self, forKey: .notes) ?? "")
        rewards = try (values.decodeIfPresent(Int.self, forKey: .rewards) ?? 0)
        eligible = try (values.decodeIfPresent(Bool.self, forKey: .eligible) ?? false)
    }
}

struct SubMissionModel : Codable {
    let title: String
    let done: Int
    let target: Int
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case done = "done"
        case target = "target"
    }
    
    init(title: String, done: Int, target: Int) {
        self.title = title
        self.done = done
        self.target = target
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try (values.decodeIfPresent(String.self, forKey: .title) ?? "")
        done = try (values.decodeIfPresent(Int.self, forKey: .done) ?? 0)
        target = try (values.decodeIfPresent(Int.self, forKey: .target) ?? 0)
    }
    
}

class InvitedFriendsListModel: Mappable {
    var data: [UserInfoModel] = []
    var total: Int = 0
    
    init () {}
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        data <- map["data"]
        total <- map["total"]
    }
}

struct MiniProgramBridgeModel: Codable {
    let extras: MiniProgramExtraModel
    let type: String
    let sync: Bool

    enum CodingKeys: String, CodingKey {
        case extras, type
        case sync = "_sync"
    }
}

// MARK: - Extras
struct MiniProgramExtraModel: Codable {
    let values: [MiniProgramExtraValuesModel]
    let type, msg: String
}

// MARK: - Value
struct MiniProgramExtraValuesModel: Codable {
    let value: String
    let type: String
}

