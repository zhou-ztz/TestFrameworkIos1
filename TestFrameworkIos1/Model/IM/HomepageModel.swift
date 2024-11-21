//
//  HomepageModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/10/30.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  个人主页 数据处理模型

import UIKit

class HomepageModel {

    /// 用户 id
    var userIdentity = 0
    /// 用户名称
    var userName: String?
    /// nickname
    var nickName: String?
    /// 用户信息
    var userInfo = UserInfoModel()
    /// 用户标签信息
    var userTags: [TSTagModel] = []
    
    var shopId: Int?
    
    var shopUrl: String?

    init() {
    }

    /// 初始化方法
    init(userIdentity: Int, userName: String? = nil, nickName: String? = nil) {
        self.userInfo.userIdentity = userIdentity
        self.userIdentity = userIdentity
        self.userName = userName
        self.nickName = nickName
    }
}

extension HomepageModel {

    /// 刷新个人主页数据
    func reloadHomepageInfo(complete: @escaping (Bool) -> Void) {
        
        func fetchUserFromLocal() {
            if let username = userName, let user = UserInfoModel.retrieveUser(username: username) {
                self.userInfo = user
                self.userName = username
                self.userIdentity = user.userIdentity
                complete(true)
            } else if let name = nickName, let user = UserInfoModel.retrieveUser(nickname: name) {
                self.userInfo = user
                self.userName = user.username
                self.userIdentity = user.userIdentity
                complete(true)
            } else if userIdentity > 0, let user = UserInfoModel.retrieveUser(userId: userIdentity) {
                self.userInfo = user
                self.userName = user.username
                complete(true)
            } else {
                complete(false)
            }
        }
        
        TSUserNetworkingManager().getUsersInfo(usersId: [userIdentity], names: [nickName.orEmpty], userNames: [userName.orEmpty]) { [weak self] (results, msg, status) in
            guard status else {
                fetchUserFromLocal()
                return
            }
            if let model = results?.first {
                self?.userInfo = model
                self?.userName = model.username
                self?.userIdentity = model.userIdentity
                self?.shopId = model.miniProgramShopId
                self?.shopUrl = model.miniProgramShopUrl
                complete(true)
            } else {
                complete(false)
            }
        }
    }
}
