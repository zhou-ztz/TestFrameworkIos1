//
//  MeetAttachment.swift
//  Yippi
//
//  Created by Tinnolab on 14/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
class MeetAttachment: NSObject, NIMCustomAttachment {
    
    var expireTime: Double = 0.00
    var sourceId: String = ""
    var targetId: String = ""
    var eventType: MeetNewFriendEventType = .unknown
    var avatarURL: String = ""
    var badgeURL: String = ""
    var nickname: String = ""
    var roomId: String = ""
    
    func encode() -> String {
        let dictContent: [String : Any] = [CMMeetEventType: self.eventType.rawValue,
                                           CMMeetTargetId: self.targetId,
                                           CMMeetSourceId: self.sourceId,
                                           CMMeetExpireTime: self.expireTime,
                                           CMMeetNickname : self.nickname,
                                           CMMeetBadgeURL: self.badgeURL,
                                           CMMeetAvatarURL: self.avatarURL,
                                           CMMeetRoomId: self.roomId]
        
        let dict: [String : Any] = [CMType: CustomMessageType.Meet.rawValue,
                                    CMData: dictContent]
        var stringToReturn = "{}"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            stringToReturn = String(data: jsonData, encoding: .utf8) ?? ""
        } catch let error {
            print(error.localizedDescription)
        }
        return stringToReturn
    }
}
