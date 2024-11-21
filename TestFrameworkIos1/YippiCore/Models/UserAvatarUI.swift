//
//  UserInfoModel.swift
//  YippiCore
//
//  Created by Kit Foong on 15/03/2023.
//  Copyright © 2023 Chew. All rights reserved.
//

import Foundation

@objcMembers
public class UserAvatarUI: NSObject, Codable {
    public let username: String
    public let avatarUrl: String?
    public let displayname: String
    
    // verification
    public var verificationIcon: String?
    public var verificationType: String?

    public init(username: String, avatarUrl: String?, displayname: String, verificationIcon: String?, verificationType: String?) {
        self.username = username
        self.avatarUrl = avatarUrl
        self.displayname = displayname
        self.verificationIcon = verificationIcon
        self.verificationType = verificationType
    }
}
