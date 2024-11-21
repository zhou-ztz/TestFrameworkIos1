//
//  UserInfoType.swift
//  Yippi
//
//  Created by Francis Yeap on 11/06/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftUI

protocol UserInfoType: Mappable  {
    var userIdentity: Int { get set }
    var name: String { get set }
    var phone: String? { get set }
    var email: String? { get set }
    var sex: Int { get set }
    var bio: String? { get set }
    var location: String? { get set }
    var createDate: Date? { get set }
    var updateDate: Date? { get set }
    var avatarUrl: String? { get set }
    var avatarMime: String? { get set }
    var coverUrl: String? { get set }
    var coverMime: String? { get set }
    var following: Bool { get set }
    var follower: Bool { get set }
    var friendsCount: Int { get set }
    var otpDevice: Bool { get set }
    
    // verification
    var verificationIcon: String? { get set }
    var verificationType: String? { get set }
    
    // extras
    var likesCount: Int { get set }
    var commentsCount: Int { get set }
    var followersCount: Int { get set }
    var followingsCount: Int { get set }
    var feedCount: Int { get set }
    var checkInCount: Int { get set }
    var isRewardAcceptEnabled: Bool { get set }
    var canSubscribe: Bool { get set }
    var activitiesCount: Int { get set }
    
    var whiteListType: String? { get set }
    var country: String { get set }
    
    // certification
    var birthdate: String { get set }
    var username: String { get set }
    var shortDesc: String { get }
    
    var profileFrameIcon: String? { get set }
    var profileFrameColorHex: String? { get set }
    var liveFeedId: Int? { get set }
}

extension UserInfoType {
    
    func isMe() -> Bool {
        guard CurrentUserSessionInfo != nil else { return false }
        return userIdentity == CurrentUserSessionInfo?.userIdentity
    }
    
    func avatarInfo() -> AvatarInfo {
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = self.avatarUrl
        avatarInfo.verifiedIcon = self.verificationIcon.orEmpty
        avatarInfo.verifiedType = self.verificationType.orEmpty
        avatarInfo.type = .normal(userId: self.userIdentity)
        avatarInfo.frameIcon = self.profileFrameIcon
        avatarInfo.frameColor = self.profileFrameColorHex
        avatarInfo.liveId = self.liveFeedId
        return avatarInfo
    }
}

extension UserInfoType {
    func toType<A>(type: A.Type) -> A? where A: Mappable {
        if self is UserInfoModel, let res = self as? A, res is UserInfoModel {
            return res
        }

        if self is UserSessionInfo, let res = self as? A, res is UserSessionInfo {
            return res
        }
        
        let model = Mapper<A>().map(JSONString: self.toJSONString().orEmpty)
        return model
    }
}

