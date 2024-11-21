//
//  LiveTreasureAttachment.swift
//  Yippi
//
//  Created by Tinnolab on 14/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
class LiveTreasureAttachment: NSObject, NIMCustomAttachment {
    
    var treasureId: String = ""
    var senderId: String = ""
    var startTime: String = ""
    var endTime: String = ""
    var status: Int = 0
    var countdown: Double = 0.00
    var treasureTheme: NSDictionary? = nil
    var isSubscriberOnly: Bool = false
    
    func encode() -> String {
        let dictContent: [String : Any] = [CMTreasureId: self.treasureId,
                                           CMTreasureStartTime: self.startTime,
                                           CMTreasureEndTime: self.endTime,
                                           CMTreasureStatus: self.status,
                                           CMTreasureCountdown : self.countdown,
                                           CMTreasureTheme: self.treasureTheme ?? [:],
                                           CMTreasureSubscriberOnly: self.isSubscriberOnly]
        
        let dict: [String : Any] = [CMType: CustomMessageType.LiveTreasure.rawValue,
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

class LiveLuckyBagAttachment: NSObject, NIMCustomAttachment {
    
    var treasureId: String = ""
    var senderId: String = ""
    var startTime: String = ""
    var endTime: String = ""
    var status: Int = 0
    var countdown: Double = 0.00
    var treasureTheme: NSDictionary? = nil
    var isSubscriberOnly: Bool = false
    
    func encode() -> String {
        let dictContent: [String : Any] = [CMTreasureId: self.treasureId,
                                           CMTreasureStartTime: self.startTime,
                                           CMTreasureEndTime: self.endTime,
                                           CMTreasureStatus: self.status,
                                           CMTreasureCountdown : self.countdown,
                                           CMTreasureTheme: self.treasureTheme ?? [:],
                                           CMTreasureSubscriberOnly: self.isSubscriberOnly]
        
        let dict: [String : Any] = [CMType: CustomMessageType.LiveLuckyBag.rawValue,
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

class LivePinnedMessageAttachment: NSObject, NIMCustomAttachment {
    
    var feedId: Int = 0
    var commentId: Int = 0
    var contentType: String = ""
    var body: String = ""
    var msgIdClient: String = ""
    var pinned: Bool = false
    
    func encode() -> String {
        let dictContent: [String : Any] = [CMPinnedMessageFeedId: self.feedId,
                                           CMPinnedMessageCommentId: self.commentId,
                                           CMPinnedMessageContentType: self.contentType,
                                           CMPinnedMessageBody: self.body,
                                           CMPinnedMessageIdClient : self.msgIdClient,
                                           CMIsPinned: self.pinned]
        
        let dict: [String : Any] = [CMType: CustomMessageType.LivePinnedMessage.rawValue,
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

class LiveTipAttachment: NSObject, NIMCustomAttachment {
    var amount: String = ""
    var username: String = ""
    var displayname: String = ""
    var rewardImageUrl: String = ""
    var rewardAnimationUrl: String = ""
    var senderDisplayName: String = ""
    var type: Int = 0
    var rewardId: Int = 0

    func encode() -> String {
        let dictContent: [String : Any] = [CMLiveTipAmount    : self.amount,
                                           CMLiveUserName     : self.username,
                                           CMLiveDisplayname  : self.displayname,
                                           CMLiveTipType      : self.type,
                                           CMLiveRewardId     : self.rewardId,
                                           CMLiveRewardImage  : self.rewardImageUrl,
                                           CMLiveRewardAnimation: self.rewardAnimationUrl,
                                           CMLiveSenderDisplayname: self.senderDisplayName]
        
        let dict: [String : Any] = [CMType: CustomMessageType.LiveTip.rawValue,
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

