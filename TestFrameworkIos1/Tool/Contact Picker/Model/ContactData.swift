//
//  ShareModel.swift
//  Yippi
//
//  Created by Yong Tze Ling on 06/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
//import NIMPrivate

extension ContactData {
    convenience init(model: AvatarInfo) {
        self.init(userId: -1, userName: model.username.orEmpty, imageUrl: model.avatarURL.orEmpty, isTeam: true, displayname: model.nickname.orEmpty, isBannedUser: false, verifiedType: model.verifiedType, verifiedIcon: model.verifiedIcon)
    }
    
    convenience init(team: NIMTeam) {
        self.init(userId: -1, userName: team.teamId.orEmpty, imageUrl: team.avatarUrl.orEmpty, isTeam: true, displayname: team.teamName.orEmpty, isBannedUser: false, verifiedType: "", verifiedIcon: "")
    }
    
    convenience init(model: UserInfoModel) {
        self.init(userId: model.userIdentity, userName: model.username, imageUrl: model.avatarUrl.orEmpty, isTeam: false, displayname: model.name, isBannedUser: model.isBannedUser, verifiedType: model.verificationType.orEmpty, verifiedIcon: model.verificationIcon.orEmpty)
    }
    
    convenience init(model: UserInfoModel, remarkName: String) {
        self.init(userId: model.userIdentity, userName: model.username, imageUrl: model.avatarUrl.orEmpty, isTeam: false, displayname: model.name, remarkName: remarkName, isBannedUser: model.isBannedUser, verifiedType: model.verificationType.orEmpty, verifiedIcon: model.verificationIcon.orEmpty)
    }
    
    convenience init(userName: String) {
//        let userInfo = NIMBridgeManager.sharedInstance().getUserInfo(userName)
        self.init(userId: -1, userName: "", imageUrl: "", isTeam: false, displayname: "", isBannedUser: false, verifiedType: "", verifiedIcon: "")
    }
    
    convenience init(userName: String, remarkName:String) {
//        let userInfo = NIMBridgeManager.sharedInstance().getUserInfo(userName)
        self.init(userId: -1, userName: "", imageUrl: "", isTeam: false, displayname: "", isBannedUser: false, verifiedType: "", verifiedIcon: "")
    }
}

class ContactSection {
    
    var sectionName: String = ""
    var objects: [ContactData]
    
    init(sectionName: String, objects: [ContactData]) {
        self.sectionName = sectionName
        self.objects = objects
    }
}
