//
//  NewFriendsNetworkRequest.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  找人

import UIKit

class NewFriendsNetworkRequest: NSObject {

    /// 获取热门用户
    ///
    /// - RouteParameter: None
    /// - RequestParameter: None
    let hotUsers = Request<UserInfoModel>(method: .get, path: "user/populars", replacers: [])

    /// 获取后台推荐用户
    ///
    /// - RouteParameter: None
    /// - RequestParameter: None
    let recommendsUsers = Request<UserInfoModel>(method: .get, path: "user/recommends", replacers: [])

    /// 获取最新用户
    ///
    /// - RouteParameter: None
    /// - RequestParameter: None
    let newUsers = Request<UserInfoModel>(method: .get, path: "user/latests", replacers: [])

    /// 获取标签推荐用户
    ///
    /// - RouteParameter: None
    /// - RequestParameter: None
    let tagRecommendsUsers = Request<UserInfoModel>(method: .get, path: "user/find-by-tags", replacers: [])

    /// 获取附近用户
    ///
    /// - RouteParameter: None
    /// - RequestParameter: None
    let nearbyUsers = Request<TSNearbyUserModel>(method: .post, path: "user/getNearbyUser", replacers: [])

    /// 提交用户的位置
    ///
    /// - RouteParameter: None
    /// - RequestParameter: None
    let submitLocation = Request<Empty>(method: .post, path: "user/updateUserLocation", replacers: [])

    /// 搜索用户
    ///
    /// - RouteParameter: None
    /// - RequestParameter: None
    let search = Request<UserInfoModel>(method: .get, path: "user/search", replacers: [])

    /// 搜索已经加入 TS+ 的用户
    let searchContacts = Request<UserInfoModel>(method: .post, path: "user/find-by-phone", replacers: [])
}
