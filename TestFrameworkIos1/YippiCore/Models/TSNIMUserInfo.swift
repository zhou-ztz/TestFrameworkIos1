//
//  TSNIMUserInfo.swift
//  Yippi
//
//  Created by CC Teoh on 07/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
// MARK: - TSNIMUserInfo
public struct TSNIMUserInfo: Codable {
    public var id : Int?
    public var name : String?
    public var avatar : Avatar?
    public var verified : Verified?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case avatar = "avatar"
        case verified
    }
}

// MARK: - Avatar
public struct Avatar: Codable {
    public let url : String?
    
    enum CodingKeys: String, CodingKey {
        case url = "url"
    }
}

// MARK: - Verified
public struct Verified: Codable {
    public let type : String?
    public let icon : String?
    public let description : String?
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case icon = "icon"
        case description = "description"
    }
}


