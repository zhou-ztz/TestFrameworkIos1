//
//  MeetingMessageHandler.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/2/9.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
//import NIMPrivate

protocol MeetingMessageHandlerDelegate: class {
    func onMembersEnterRoom(members: [NIMChatroomNotificationMember]?)
    func onMembersExitRoom(members: [NIMChatroomNotificationMember]?)
    func onMembersShowFullScreen(notifyExt: String)
//    func onReceiveMeetingCommand(attachment: NTESMeetingControlAttachment, from userId: String)
  
}

class MeetingMessageHandler: NSObject {
    
    var chatroom: NIMChatroom!

    weak var delegate: MeetingMessageHandlerDelegate?
    
    init(chatroom: NIMChatroom, delegate: MeetingMessageHandlerDelegate?) {
        super.init()
        self.chatroom = chatroom
        self.delegate = delegate
        NIMSDK.shared().chatManager.add(self)
        NIMSDK.shared().systemNotificationManager.add(self)
    }
   
    deinit {
        NIMSDK.shared().chatManager.remove(self)
        NIMSDK.shared().systemNotificationManager.remove(self)
    }
    
    func dealCustomMessage(message: NIMMessage )
    {
        let object: NIMCustomObject = message.messageObject as! NIMCustomObject
        //只处理会议控制自定义消息
        guard let attachment = object.attachment   else {
            return
        }
//        if attachment.isKind(of: NTESMeetingControlAttachment.self) {
//            let attachment = object.attachment as! NTESMeetingControlAttachment
//      
//            if attachment.roomID == chatroom?.roomId {
//                self.onMeetingCommand(attachment: attachment, from: message.from ?? "")
//            }
//            
//        }
        
        
    }

    func dealNotificationMessage(message: NIMMessage)
    {
        let object: NIMNotificationObject = message.messageObject as! NIMNotificationObject
        
        if (object.notificationType != .chatroom) {
            return
        }
        
        let content = object.content as! NIMChatroomNotificationContent

        switch (content.eventType) {
        case .enter:
            self.delegate?.onMembersEnterRoom(members: content.targets)
            break;
        case .exit:
            self.delegate?.onMembersExitRoom(members: content.targets)
            break;
        case .infoUpdated:
            self.delegate?.onMembersShowFullScreen(notifyExt: content.notifyExt ?? "")
            break;
        default:
            break;
        }
    }
    
//    func onMeetingCommand(attachment: NTESMeetingControlAttachment, from user: String)
//    {
//        guard let chatroom = chatroom else {
//            return
//        }
//        if (attachment.roomID != chatroom.roomId) {
//            return
//        }
//        self.delegate?.onReceiveMeetingCommand(attachment: attachment, from: user)
//       
//    }
//    
//    public func sendMeetingP2PCommand(attachment: NTESMeetingControlAttachment, to uid: String)
//    {
//        attachment.roomID = chatroom.roomId ?? ""
//        let content = attachment.encode()
//        let notification = NIMCustomSystemNotification(content: content)
//        notification.sendToOnlineUsersOnly = true
//        let setting = NIMCustomSystemNotificationSetting()
//        setting.shouldBeCounted = false
//        setting.apnsEnabled = false
//        notification.setting = setting
//        let session = NIMSession.init(uid, type: .P2P)
//        NIMSDK.shared().systemNotificationManager.sendCustomNotification(notification, to: session) { (error) in
//            
//        }
//      
//    }
//
//    public func sendMeetingBroadcastCommand(attachment: NTESMeetingControlAttachment){
//        attachment.roomID = chatroom.roomId ?? ""
//        let session = NIMSession.init(attachment.roomID, type: .chatroom)
////        let message = IMSessionMsgConverter.shared.msgWithMeetingControlAttachment(attachment: attachment)
////        if let msg = message {
////            do {
////                try NIMSDK.shared().chatManager.send(msg, to: session)
////            } catch  {
////                
////            }
////            
////        }
//        
//     
//       
//    }



}

extension MeetingMessageHandler: NIMChatManagerDelegate {
    func onRecvMessages(_ messages: [NIMMessage]) {
       
        for message in messages {
            if let session = message.session {
                if session.sessionType == .chatroom {
                    if(message.messageType == .custom) {
                        self.dealCustomMessage(message: message)
                    }
                    else if (message.messageType == .notification) {
                        self.dealNotificationMessage(message: message)
                    }
                    
                }
            }
            
        }
    }
}

extension MeetingMessageHandler: NIMSystemNotificationManagerDelegate {
    
    func onReceive(_ notification: NIMCustomSystemNotification) {
      
//        if notification.receiverType == .P2P {
//            let content = notification.content
//            let jsonData = content?.data(using: .utf8)
//            guard let data = jsonData else {
//                return
//            }
//            do {
//                if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
//                    if dict.jsonInt(CMType) == 103 {//CustomMessageTypeMeetingControl
//                        let data = dict.jsonDict(CMData)
//                        let attachment = NTESMeetingControlAttachment()
//                        attachment.roomID = data?.jsonString(CMRoomID) ?? ""
//                        attachment.command = CustomMeetingCommand(rawValue: (data?.jsonInt(CMCommand))!)!
//                        attachment.uids = data?.jsonArray(CMUIDs) as? [Any]
//                         
//                        if (attachment.roomID == chatroom!.roomId) {
//                            self.onMeetingCommand(attachment: attachment, from: notification.sender!)
//                        }
//                        
//                    }
//                    
//                }
//            } catch {
//                
//            }
//            
//            
//        }
    }
    
}

