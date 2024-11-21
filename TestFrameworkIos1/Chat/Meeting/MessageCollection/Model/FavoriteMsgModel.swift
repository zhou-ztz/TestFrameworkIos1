//
//  FavoriteMsgModel.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/9.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class FavoriteMsgModel: NSObject {
    var Id: Int = 0
    var type: MessageCollectionType
    var data: String = ""
    var ext: String = ""
    var uniqueId: String = ""
    var createTime: TimeInterval = 0
    var updateTime: TimeInterval = 0
    
    init(Id: Int = 0, type: MessageCollectionType, data: String = "", ext: String = "", uniqueId: String = "", createTime: TimeInterval = 0, updateTime: TimeInterval = 0) {
        self.Id = Id
        self.type = type
        self.data = data
        self.ext = ext
        self.uniqueId = uniqueId
        self.createTime = createTime
        self.updateTime = updateTime
        super.init()
    }
}

struct SessionDictModel: Codable {

    var sessionId: String = ""
    var sessionType: String = "P2P" // P2P  Team
    var content: String?
    var attachment: String?
    var fromAccount: String = ""
    var time: TimeInterval?
    
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "sessionId"
        case sessionType = "sessionType"
        case content = "content"
        case attachment = "attachment"
        case fromAccount = "fromAccount"
        case time = "time"
    }
    
    
}

struct PinnedDictModel: Codable {
    var sessionId: String = ""
    var sessionType: String = "P2P" // P2P  Team
    var content: String?
    var attachment: String?
    var fromAccount: String = ""
    var time: TimeInterval?
    var type: Int? = 0
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "sessionId"
        case sessionType = "sessionType"
        case content = "content"
        case attachment = "attachment"
        case fromAccount = "fromAccount"
        case time = "time"
        case type = "type"
    }
    
    
}

class CategoryMsgModel: NSObject {

    var type: MessageCollectionType
    var name: String = ""
    var image: UIImage
    
    init(type: MessageCollectionType, name: String, image: UIImage) {
        self.type = type
        self.name = name
        self.image = image
        super.init()
    }
}
