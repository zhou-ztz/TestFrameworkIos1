//
//  MessageModel.swift
//  Yippi
//
//  Created by Tinnolab on 14/05/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK
/// 讯息类型
enum ChatMessageType: Int {
    case incoming = 0
    case outgoing
    case headerTip
    case tip
    case time
}

class MessageData: Hashable {
    
    var id: String = ""
    let type: ChatMessageType
    let messageTime : TimeInterval?
    var nimMessageModel : NIMMessage?
    let showName : Bool?
    let showAvatar : Bool?
    let showReadLabel : Bool?
    let isSecretMsg : Bool?
    var isTranslated : Bool?
    let infoString : String?
    let secretMsgDuration : Int?
    var audioIsPaused : Bool?
    var audioTimeSeek : TimeInterval?
    var audioLeftDuration : TimeInterval?
    var audioTimeDifferent : TimeInterval?
    var isRedPacket : Bool?
    var message: String?
    var messageList: [MessageData] = []
    //是否置顶
    var isPinned: Bool = false
    
    init(id: String? = nil, type: ChatMessageType, messageTime: TimeInterval? = nil, nimMessageModel: NIMMessage? = nil, showName: Bool? = false, showAvatar: Bool? = false, showReadLabel: Bool? = false, isSecretMsg: Bool? = false, isTranslated: Bool? = false, infoString: String? = nil, audioIsPaused: Bool? = nil, audioTimeSeek: TimeInterval? = nil, audioLeftDuration: TimeInterval? = nil, audioTimeDifferent: TimeInterval? = nil, secretMsgDuration: Int? = 0, isRedPacket: Bool? = false, message: String? = nil, messageList: [MessageData] = []) {
        
        self.id = id ?? nimMessageModel?.messageId ?? ""
        self.type = type
        self.messageTime = messageTime
        self.nimMessageModel = nimMessageModel
        self.showName = showName
        self.showAvatar = showAvatar
        self.showReadLabel = showReadLabel
        self.isSecretMsg = isSecretMsg
        self.isTranslated = isTranslated
        self.infoString = infoString
        self.audioIsPaused = audioIsPaused
        self.audioTimeSeek = audioTimeSeek
        self.audioLeftDuration = audioLeftDuration
        self.audioTimeDifferent = audioTimeDifferent
        self.secretMsgDuration = secretMsgDuration
        self.isRedPacket = isRedPacket
        self.message = message
        self.messageList = messageList
    }
    
    convenience init(meetUser messageModel: NIMMessage) {
        var msgType: ChatMessageType = .incoming
        if messageModel.isOutgoingMsg { msgType = .outgoing }
        
        self.init(type: msgType, messageTime: messageModel.timestamp, nimMessageModel: messageModel, showName: false, showAvatar: !messageModel.isOutgoingMsg, showReadLabel: false, isSecretMsg: false, isTranslated: false)
    }
    
    convenience init(_ messageModel: NIMMessage) {
        if messageModel.messageType == .notification {
            let object = messageModel.messageObject as! NIMNotificationObject
            if object.notificationType == .team {
                let text = SessionUtil().teamNotificationFormatedMessage(messageModel)
                self.init(type: .tip, messageTime: messageModel.timestamp, nimMessageModel: messageModel, infoString: text)
                return
            }
        }
        
        var msgType: ChatMessageType = .incoming
        if messageModel.isOutgoingMsg { msgType = .outgoing }
        
        var showName = msgType == .incoming && messageModel.session?.sessionType == .team
        var showAvatar = !messageModel.isOutgoingMsg
        var showReadLabel = messageModel.isOutgoingMsg
        
        if let object = messageModel.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMTextTranslateAttachment {
            msgType = attachment.isOutgoingMsg ? .outgoing : .incoming
            showName = false
            showAvatar = false
            showReadLabel = false
        }
        var isSecretMsg = false
        var secretDuration : Int? = 0
        if let dict = messageModel.remoteExt {
            secretDuration = dict["secretChatTimer"] as? Int
            if secretDuration ?? 0 > 0 {
                isSecretMsg = true
            }
        }
        
        var isRedPacket = false
        var message = ""
        if let object = messageModel.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMEggAttachment {
            isRedPacket = true
            message = attachment.message
        }
        
        self.init(type: msgType, messageTime: messageModel.timestamp, nimMessageModel: messageModel, showName: showName, showAvatar: showAvatar, showReadLabel: showReadLabel, isSecretMsg: isSecretMsg, isTranslated: false, secretMsgDuration: secretDuration, isRedPacket: isRedPacket, message: message)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MessageData, rhs: MessageData) -> Bool {
        return lhs.id == rhs.id
//        lhs.audioIsPaused == rhs.audioIsPaused && lhs.audioLeftDuration == rhs.audioLeftDuration && lhs.audioTimeDifferent == lhs.audioTimeDifferent && lhs.audioTimeSeek == rhs.audioTimeSeek && lhs.infoString == rhs.infoString && lhs.isSecretMsg == rhs.isSecretMsg && lhs.isTranslated == rhs.isTranslated && lhs.messageTime == rhs.messageTime && lhs.nimMessageModel == rhs.nimMessageModel && lhs.secretMsgDuration == rhs.secretMsgDuration && lhs.showAvatar == rhs.showAvatar && lhs.showName == rhs.showName && lhs.showReadLabel == rhs.showReadLabel && lhs.type == rhs.type
    }
}

//extension Hashable where Self: AnyObject {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//}

extension MessageData {
    
    func shouldInsertTimestamp(compare time: TimeInterval) -> Bool {
        let compareTime = time.messageTime(showDetail: true)
        let messageTime = self.messageTime?.messageTime(showDetail: true)
        //做此checking是因为刚进chatroom是compare with在self.items里的最后一个item，当向上load的时候会compare with第一个item in self.items因为load message是把message加在self.items的第一个
        return compareTime != messageTime
    }
    
    func disableBeInviteAuthTipsMessage() -> Bool {
        if self.nimMessageModel?.messageType != .notification {
            return true
        }
        guard let object = self.nimMessageModel?.messageObject as? NIMNotificationObject, object.notificationType == .team else { return true }
        guard let content = object.content as? NIMTeamNotificationContent, content.operationType == .update else { return true }
        
        if content.attachment is NIMUpdateTeamInfoAttachment {
            guard let teamAttachment = content.attachment as? NIMUpdateTeamInfoAttachment, teamAttachment.values?.count == 1 else { return true }
            
            if let tag = NIMTeamUpdateTag(rawValue: Int(truncating: teamAttachment.values?.keys.first ?? 0)), tag == .beInviteMode {
                return false
            }
        }
        
        return true
    }
}
