//
//  UserStatusEnum.swift
//  Yippi
//
//  Created by Francis on 23/03/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

enum PraiseButtonImageName: String {
    // 我没有关注对方，不管对方有没有关注我
    case unfollow = "IMG_ico_me_follow"
    // 相互关注
    case eachother = "IMG_ico_me_followed_eachother"
    // 我关注了对方，但是对方没有关注我
    case follow = "IMG_ico_me_followed"
}

/// 当前登录用户和该用户的关系
enum FollowStatus: String {
    /// 关注了对方
    case follow = "IMG_ico_me_followed"
    /// 未关注对方
    case unfollow = "IMG_ico_me_follow"
    /// 相互关注
    case eachOther = "IMG_ico_me_followed_eachother"
    /// 该用户是当前登录用户
    case oneself = ""
}

/// 当前登录用户和该用户的关系
enum FollowStatustext: String {
    /// 关注了对方
    case follow = "more_following"
    /// 未关注对方
    case unfollow = "add_follow"
    /// 相互关注
    case eachOther = "followed_eachother"
    /// 该用户是当前登录用户
    case oneself = ""

    var localizedString: String {
        return self.rawValue.localized
    }
}
