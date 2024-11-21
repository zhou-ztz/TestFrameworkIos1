//
//  AvatarModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/17.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class AvatarInfo {

    /// 用户头像类型
    enum UserAvatarType {
        /// 未知用户
        case unknow
        /// 普通用户，如果 userId 不为 nil 点击头像会 push 到对应用户的个人主页
        case normal(userId: Int?)

        var userId: Int? {
            switch self {
            case .normal(let userId):
                return userId
            default:
                return nil
            }
        }
    }

    /// 头像类型
    var type = UserAvatarType.normal(userId: nil)
    /// 头像 url
    var avatarURL: String?
    /// 认证信息，为空表示没有
    var verifiedType = ""
    /// 认证图标，为空表示没有
    var verifiedIcon = ""
    /// 头像占位图类型,性别相关
    var avatarPlaceholderType = AvatarView.PlaceholderType.unknown
    /// 性别 0 - Unknown, 1 - Man, 2 - Woman.
    var sex: Int = 0
    
    var username: String?
    
    var nickname: String?

    var frameIcon: String?
    var frameColor: String?
    var liveId: Int?
    
    init() {
    }

    /// 初始化
    init(userModel model: UserInfoModel) {
        avatarURL =  model.avatarUrl.orEmpty.smallPicUrl(showingSize: CGSize(width: 150, height: 150))
        verifiedType = model.verificationIcon.orEmpty
        verifiedIcon = model.verificationIcon.orEmpty
        sex = model.sex
        avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: sex)
        type = .normal(userId: model.userIdentity)
        username = model.username
        nickname = model.name
        frameIcon = model.profileFrameIcon
        frameColor = model.profileFrameColorHex
        liveId = model.liveFeedId
    }

    init(avatarURL: String, verifiedInfo: TSUserVerifiedModel?) {
        self.avatarURL = avatarURL
        verifiedType = verifiedInfo?.type ?? ""
        verifiedIcon = verifiedInfo?.icon ?? ""
    }
    
    init(model: UserInfoType) {
        avatarURL =  model.avatarUrl.orEmpty.smallPicUrl(showingSize: CGSize(width: 150, height: 150))
        verifiedType = model.verificationType.orEmpty
        verifiedIcon = model.verificationIcon.orEmpty
        sex = model.sex
        avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: sex)
        type = .normal(userId: model.userIdentity)
        username = model.username
        nickname = model.name
        frameIcon = model.profileFrameIcon
        frameColor = model.profileFrameColorHex
        liveId = model.liveFeedId
    }
}

extension AvatarInfo {
    
    func hasLive() -> Bool {
        return liveId != nil
    }
}
