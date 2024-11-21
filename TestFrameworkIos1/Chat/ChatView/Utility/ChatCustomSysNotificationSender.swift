//
//  ChatCustomSysNotificationSender.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2020/11/17.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

let NTESNotifyID = "id"
let NTESCustomContent = "content"
let NTESTeamMeetingMembers = "members"
let NTESTeamMeetingTeamId  = "teamId"
let NTESTeamMeetingTeamName = "teamName"
let NTESTeamMeetingName = "room"
let NTESTeamMeetingCanceller = "canceller"
let NTESTeamMeetingCaller = "caller"
let NTESTeamMeetingExist = "noOnePlaying"

let NTESCommandTyping   = 1
let NTESCustom          = 2
let NTESTeamMeetingCall = 3
let NTESSecretChat      = 4
let NTESWhiteboard      = 5

let NTESPinnedStored    = 6
let NTESPinnedDeleted    = 7
let NTESPinnedUpdated    = 8
class ChatCustomSysNotificationSender: NSObject {
    
    var lastTime: Date!
    
    func sendCustomContent(content: String? = "", session: NIMSession){
       
        let dict : [String : Any] = [NTESNotifyID: NTESCustom, NTESCustomContent: content ?? ""]
        
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        guard let json = String(data: data!, encoding: .utf8) else {
            return
        }
        
        let notification = NIMCustomSystemNotification(content: json)
        notification.apnsContent = content
        notification.sendToOnlineUsersOnly = false
        let setting = NIMCustomSystemNotificationSetting()
        setting.apnsEnabled = true
        notification.setting = setting
        NIMSDK.shared().systemNotificationManager.sendCustomNotification(notification, to: session, completion: nil)
       
    }

    //MARK: - Secret chat
    func sendSecretChatRequest(session: NIMSession){
        let dict : [String : Any] = [NTESNotifyID: NTESSecretChat, "fromAccount": NIMSDK.shared().loginManager.currentAccount(), "toAccount": session.sessionId, NTESCustomContent: "INVITE"]
        let data = try? JSONSerialization.data(withJSONObject: dict , options: [])
        guard let json = String(data: data!, encoding: .utf8) else {
            return
        }
        let textNotification = String(NIMSDK.shared().loginManager.currentAccount()) + " " + "secret_chat_invite".localized
        
        let notification = NIMCustomSystemNotification(content: json)
        notification.apnsContent = textNotification
        notification.sendToOnlineUsersOnly = false
        let setting = NIMCustomSystemNotificationSetting()
        setting.apnsEnabled = true
        notification.setting = setting
        NIMSDK.shared().systemNotificationManager.sendCustomNotification(notification, to: session, completion: nil)
    }

    func cancelSecretChatRequest(session: NIMSession){
        let dict: [String : Any] = [NTESNotifyID: NTESSecretChat, "fromAccount": NIMSDK.shared().loginManager.currentAccount(), "toAccount": session.sessionId, NTESCustomContent: "CANCEL"]
        
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        guard let json = String(data: data!, encoding: .utf8) else {
            return
        }
        let textNotification = "[Secret Chat]"
        
        let notification = NIMCustomSystemNotification(content: json)
        notification.apnsContent = textNotification
        notification.sendToOnlineUsersOnly = false
        let setting = NIMCustomSystemNotificationSetting()
        setting.apnsEnabled = false
        notification.setting = setting
        NIMSDK.shared().systemNotificationManager.sendCustomNotification(notification, to: session, completion: nil)
    }

    func rejectSecretChatRequest(session: NIMSession){
        let dict: [String : Any] = [NTESNotifyID: NTESSecretChat, "fromAccount": NIMSDK.shared().loginManager.currentAccount(), "toAccount": session.sessionId, NTESCustomContent: "REJECT"]
          
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        guard let json = String(data: data!, encoding: .utf16) else {
            return
        }
        let textNotification = "[Secret Chat]"
        
        let notification = NIMCustomSystemNotification(content: json)
        notification.apnsContent = textNotification
        notification.sendToOnlineUsersOnly = false
        let setting = NIMCustomSystemNotificationSetting()
        setting.apnsEnabled = false
        notification.setting = setting
        NIMSDK.shared().systemNotificationManager.sendCustomNotification(notification, to: session, completion: nil)
    }

    func acceptSecretChatRequest(session: NIMSession){
        let dict: [String : Any] = [NTESNotifyID: NTESSecretChat, "fromAccount": NIMSDK.shared().loginManager.currentAccount(), "toAccount": session.sessionId, NTESCustomContent: "ACCEPT"]
          
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        guard let json = String(data: data!, encoding: .utf8) else {
            return
        }
        let textNotification = "[Secret Chat]"
        
        let notification = NIMCustomSystemNotification(content: json)
        notification.apnsContent = textNotification
        notification.sendToOnlineUsersOnly = false
        let setting = NIMCustomSystemNotificationSetting()
        setting.apnsEnabled = false
        notification.setting = setting
        NIMSDK.shared().systemNotificationManager.sendCustomNotification(notification, to: session, completion: nil)
        
    }

    func sendSecretChatCreated(session: NIMSession, teamId: String) {
        let dict: [String : Any] = [NTESNotifyID: NTESSecretChat, "fromAccount": NIMSDK.shared().loginManager.currentAccount(), "toAccount": session.sessionId, "teamId": teamId, NTESCustomContent: "ACCEPT"]
        
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        guard let json = String(data: data!, encoding: .utf8) else {
            return
        }
        let textNotification = "[Secret Chat]"
        
        let notification = NIMCustomSystemNotification(content: json)
        notification.apnsContent = textNotification
        notification.sendToOnlineUsersOnly = false
        let setting = NIMCustomSystemNotificationSetting()
        setting.apnsEnabled = false
        notification.setting = setting
        NIMSDK.shared().systemNotificationManager.sendCustomNotification(notification, to: session, completion: nil)
    }

    func sendToOpponentSecretChatCreated(session: NIMSession, teamId: String) {
        let dict: [String : Any] = [NTESNotifyID: NTESSecretChat, "fromAccount": NIMSDK.shared().loginManager.currentAccount(), "toAccount": session.sessionId, "teamId": teamId, NTESCustomContent: "TEAM_CREATE"]
        
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        guard let json = String(data: data!, encoding: .utf8) else {
            return
        }
       
        let notification = NIMCustomSystemNotification(content: json)
        notification.sendToOnlineUsersOnly = true
        let setting = NIMCustomSystemNotificationSetting()
        setting.apnsEnabled = false
        notification.setting = setting
        NIMSDK.shared().systemNotificationManager.sendCustomNotification(notification, to: session, completion: nil)
       
    }

    func sendTypingState(session: NIMSession){
        let currentAccount = NIMSDK.shared().loginManager.currentAccount()
        if (session.sessionType != .P2P || session.sessionId == currentAccount)
        {
            return
        }
        
        let now = Date()
        if lastTime == nil || now.timeIntervalSince(lastTime) > 3
        {
            lastTime = now

            let dict = [NTESNotifyID : NTESCommandTyping]
            let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
            guard let json = String(data: data!, encoding: .utf8) else {
                return
            }

            let notification = NIMCustomSystemNotification(content: json)
            notification.sendToOnlineUsersOnly = true
            let setting = NIMCustomSystemNotificationSetting()
            setting.apnsEnabled = false
            notification.setting = setting
            NIMSDK.shared().systemNotificationManager.sendCustomNotification(notification, to: session, completion: nil)
           
        }

    }

    //发送呼叫通知
    func sendCallNotification(teamId: String, roomName: String, members: [String]) {
        let user = NIMSDK.shared().loginManager.currentAccount()
        let team = NIMSDK.shared().teamManager.team(byId: teamId)
        let nick = SessionUtil.showNick(user, in: nil)
        let dict: [String: Any] = [NTESNotifyID: NTESTeamMeetingCall, NTESTeamMeetingMembers: members, NTESTeamMeetingTeamId: teamId, NTESTeamMeetingTeamName: team?.teamName ?? "groups".localized, NTESTeamMeetingName: roomName, NTESTeamMeetingCaller: user]
        
        if let data = try? JSONSerialization.data(withJSONObject: dict), let content = String(data: data, encoding: .utf8) {
            
            let notification = NIMCustomSystemNotification(content: content)
            notification.sendToOnlineUsersOnly = false
            notification.apnsContent = String(format: "calling_you".localized, nick ?? "")
            let setting = NIMCustomSystemNotificationSetting()
            notification.setting = setting
            for userId in members {
                if userId == user {
                    continue
                }
                let session = NIMSession(userId, type: .P2P)
                NIMSDK.shared().systemNotificationManager.sendCustomNotification(notification, to: session, completion: nil)
            }

        }
    }
    //发送取消呼叫通知
    func sendCancelNotification(teamId: String, roomName: String, member: String, noOnePlaying: Bool, canceller: String) {
        let user = NIMSDK.shared().loginManager.currentAccount()
        let team = NIMSDK.shared().teamManager.team(byId: teamId)
        let nick = SessionUtil.showNick(user, in: nil)
        let dict: [String: Any] = [NTESNotifyID: NTESTeamMeetingCall, NTESTeamMeetingTeamId: teamId, NTESTeamMeetingTeamName: team?.teamName ?? "groups".localized, NTESTeamMeetingName: roomName, NTESTeamMeetingCanceller: canceller, NTESTeamMeetingExist: noOnePlaying]
        
        if let data = try? JSONSerialization.data(withJSONObject: dict), let content = String(data: data, encoding: .utf8) {
            
            let notification = NIMCustomSystemNotification(content: content)
            notification.sendToOnlineUsersOnly = false
            let setting = NIMCustomSystemNotificationSetting()
            setting.apnsEnabled  = false
            notification.setting = setting
            let session = NIMSession(member, type: .P2P)
            NIMSDK.shared().systemNotificationManager.sendCustomNotification(notification, to: session, completion: nil)
            

        }
    }

//    - (void)sendCallNotification:(NSString *)teamId
//                        roomName:(NSString *)roomName
//                         members:(NSArray *)members
//    {
//
//        NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
//        option.session = [NIMSession session:teamId type:NIMSessionTypeTeam];
//        NIMKitInfo *me = [[NIMKit sharedKit] infoByUser:[NIMSDK sharedSDK].loginManager.currentAccount option:option];
//
//        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:teamId];
//
//        NSDictionary *dict = @{
//                               NTESNotifyID : @(NTESTeamMeetingCall),
//                               NTESTeamMeetingMembers : members,
//                               NTESTeamMeetingTeamId  : teamId,
//                               NTESTeamMeetingTeamName  : team.teamName? team.teamName : String(@"groups"),
//                               NTESTeamMeetingName    : roomName,
//                               NTESTeamMeetingCaller    : [NIMSDK sharedSDK].loginManager.currentAccount
//                              };
//        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
//                                                       options:0
//                                                         error:nil];
//        NSString *content = [[NSString alloc] initWithData:data
//                                               encoding:NSUTF8StringEncoding];
//        NIMCustomSystemNotification *notification = [[NIMCustomSystemNotification alloc] initWithContent:content];
//        notification.sendToOnlineUsersOnly = NO;
//
//        notification.apnsContent = [NSString stringWithFormat:String(@"calling_you"),me.showName];
//        NIMCustomSystemNotificationSetting *setting = [[NIMCustomSystemNotificationSetting alloc] init];
//        notification.setting = setting;
//
//
//        for (NSString *userId in members) {
//            if ([userId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount])
//            {
//                continue;
//            }
//            NIMSession *session = [NIMSession session:userId type:NIMSessionTypeP2P];
//            [[NIMSDK sharedSDK].systemNotificationManager sendCustomNotification:notification toSession:session completion:nil];
//        }
//
//    }
//
//    - (void)sendCancelNotification:(NSString *)teamId
//                        roomName:(NSString *)roomName
//                           members:(NSString *)members
//                         noOnePlaying:(BOOL)noOnePlaying
//                         canceller:(NSString *)canceller
//    {
//        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:teamId];
//        NSDictionary *dict = @{
//                               NTESNotifyID : @(NTESTeamMeetingCall),
//                               NTESTeamMeetingTeamId  : teamId,
//                               NTESTeamMeetingTeamName  : team.teamName? team.teamName : String(@"groups"),
//                               NTESTeamMeetingName    : roomName,
//                               NTESTeamMeetingCanceller : canceller,
//                               NTESTeamMeetingExist : noOnePlaying ? @"true" : @"false"
//                               };
//        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
//                                                       options:0
//                                                         error:nil];
//        NSString *content = [[NSString alloc] initWithData:data
//                                                  encoding:NSUTF8StringEncoding];
//        NIMCustomSystemNotification *notification = [[NIMCustomSystemNotification alloc] initWithContent:content];
//        notification.sendToOnlineUsersOnly = NO;
//        NIMCustomSystemNotificationSetting *setting = [[NIMCustomSystemNotificationSetting alloc] init];
//        setting.apnsEnabled  = NO;
//        notification.setting = setting;
//
//        NIMSession *session = [NIMSession session:members type:NIMSessionTypeP2P];
//        [[NIMSDK sharedSDK].systemNotificationManager sendCustomNotification:notification toSession:session completion:nil];
//    }

    //Whiteboard
    func sendWhiteboardRequest(session: NIMSession, roomID: String, invitedContacts: [String]) {
 
        if invitedContacts.count > 0 {
            for userId in invitedContacts {
                let dict: [String : Any] = [NTESNotifyID: NTESWhiteboard, "fromAccount": NIMSDK.shared().loginManager.currentAccount(), "toAccount": userId, "roomID": roomID, NTESCustomContent: "INVITE", "sessionID" : session.sessionId, "invitedContacts" : invitedContacts]
               
                let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
                guard let json = String(data: data!, encoding: .utf8) else {
                    return
                }
                let textNotification = String(NIMSDK.shared().loginManager.currentAccount()) + " " + "whiteboard invite".localized
                
                let notification = NIMCustomSystemNotification(content: json)
                notification.apnsContent = textNotification
                notification.sendToOnlineUsersOnly = false
                let setting = NIMCustomSystemNotificationSetting()
                setting.apnsEnabled = true
                notification.setting = setting
                NIMSDK.shared().systemNotificationManager.sendCustomNotification(notification, to: session, completion: nil)
               
            }
            
        } else {
            let dict: [String : Any] = [NTESNotifyID: NTESWhiteboard, "fromAccount": NIMSDK.shared().loginManager.currentAccount(), "toAccount": session.sessionId, "roomID": roomID, NTESCustomContent: "INVITE", "sessionID" : session.sessionId]
            
            let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
            guard let json = String(data: data!, encoding: .utf8) else {
                return
            }
            let textNotification = String(NIMSDK.shared().loginManager.currentAccount()) + " " + "whiteboard invite".localized
            let parameters = ["sound": Constants.YippiNetCallRingtone]
            let notification = NIMCustomSystemNotification(content: json)
            notification.apnsPayload = parameters
            notification.apnsContent = textNotification
            notification.sendToOnlineUsersOnly = false
            let setting = NIMCustomSystemNotificationSetting()
            setting.apnsEnabled = true
            notification.setting = setting
            NIMSDK.shared().systemNotificationManager.sendCustomNotification(notification, to: session) { (erro) in
                if erro == nil {
                    
                }else {
                    
                }
            }
            
        }
        
        
    }

    func busyWhiteboardRequest(session: NIMSession){
        let dict: [String : Any] = [NTESNotifyID: NTESWhiteboard, "fromAccount": NIMSDK.shared().loginManager.currentAccount(), "toAccount": session.sessionId, NTESCustomContent: "BUSY"]
        
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        guard let json = String(data: data!, encoding: .utf8) else {
            return
        }
        let textNotification = "[Whiteboard]"
        
        let notification = NIMCustomSystemNotification(content: json)
        notification.apnsContent = textNotification
        notification.sendToOnlineUsersOnly = false
        let setting = NIMCustomSystemNotificationSetting()
        setting.apnsEnabled = true
        notification.setting = setting
        NIMSDK.shared().systemNotificationManager.sendCustomNotification(notification, to: session, completion: nil)
        
    }

    func rejectWhiteboardRequest(session: NIMSession){
        let dict: [String : Any] = [NTESNotifyID: NTESWhiteboard, "fromAccount": NIMSDK.shared().loginManager.currentAccount(), "toAccount": session.sessionId, NTESCustomContent: "REJECT"]
        
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        guard let json = String(data: data!, encoding: .utf8) else {
            return
        }
        let textNotification = "[Whiteboard]"
        
        let notification = NIMCustomSystemNotification(content: json)
        notification.apnsContent = textNotification
        notification.sendToOnlineUsersOnly = false
        let setting = NIMCustomSystemNotificationSetting()
        setting.apnsEnabled = true
        notification.setting = setting
        NIMSDK.shared().systemNotificationManager.sendCustomNotification(notification, to: session, completion: nil)
        
    }


}
