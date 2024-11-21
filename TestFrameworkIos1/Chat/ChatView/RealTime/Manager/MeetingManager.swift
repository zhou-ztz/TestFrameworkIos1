//
//  MeetingManager.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/2/20.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
class MeetingManager: NSObject {
    
    static let shared = MeetingManager()
    
    var isMute: Bool!
    var myInfo: [String: NIMChatroomMember] = [:]
    
    override init() {
        super.init()
        NIMSDK.shared().chatManager.add(self)
       
    }

    deinit {
        NIMSDK.shared().chatManager.remove(self)
    }
    
    func myInfo(roomId: String) -> NIMChatroomMember?
    {
        let member = myInfo[roomId]
        return member
    }

    func cacheMyInfo(info: NIMChatroomMember, roomId: String)
    {
        myInfo[roomId] = info
    }

    func dealMessage(message: NIMMessage )
    {
        let object = message.messageObject as! NIMNotificationObject
        let content = object.content as! NIMChatroomNotificationContent
        var containsMe = false
        if let targets = content.targets {
            for member in targets {
                if member.userId  == NIMSDK.shared().loginManager.currentAccount(){
                    containsMe = true
                    break
                }

            }
        }
        
        if containsMe {
            let membe = self.myInfo[message.session!.sessionId]
            guard let member = membe else {
                return
            }
            switch (content.eventType) {
            case .addManager:
                member.type = .manager
                break
            case .removeManager:
                member.type = .normal
                break
            case .addCommon:
                member.type = .normal
                break
            case .addMute:
                member.type = .limit
                member.isMuted = true
                break
            case .removeCommon:
                member.type = .guest
                break
            case .removeMute:
                member.type = .guest
                member.isMuted = false
                break
            default:
                break
            }
        }
    }

}

extension MeetingManager: NIMChatManagerDelegate {
    
    func onRecvMessages(_ messages: [NIMMessage]) {
        
        for  message in messages {
            if (message.session!.sessionType == .chatroom
                    && message.messageType == .notification)
            {
                self.dealMessage(message: message)
            }
        }
        
    }
    
}
