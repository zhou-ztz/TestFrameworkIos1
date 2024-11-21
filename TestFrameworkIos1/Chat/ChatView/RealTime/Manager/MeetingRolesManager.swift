//
//  MeetingRolesManager.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2020/11/18.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

//protocol MeetingRolesManagerDelegate: class {
//    
//    func meetingRolesUpdate()
//    func meetingMemberRaiseHand()
//    func meetingActorBeenEnabled()
//    func meetingActorBeenDisabled()
//    func meetingActorsNumberExceedMax()
//    func meetingVolumesUpdate()
//    func chatroomMembersUpdated(members: [NIMChatroomNotificationMember]?, entered: Bool?)
//    func meetingRolesShowFullScreen(notifyExt: String?)
//}
//
//class MeetingRolesManager: NTESService {
//    static let shared = MeetingRolesManager()
//    weak var delegate: MeetingRolesManagerDelegate?
//    var chatRoom: NIMChatroom!
//    var meetingRoles: [String: MeetingRole] = [:]
//    var messageHandler: MeetingMessageHandler!
//
//    var receivedRolesFromManager: Bool = false
//
//    var pendingJoinUsers: [String] = []
//    
//    public func startNewMeeting(me: NIMChatroomMember, chatroom: NIMChatroom, newCreated: Bool){
//        print("userId = \(me.userId!), roomAvatar = \(me.roomAvatar)")
//        chatRoom = chatroom
//        let _ = self.addNewRole(uid: me.userId!, actor: true, roomAvatar: me.roomAvatar)
//        messageHandler = MeetingMessageHandler(chatroom: chatRoom, delegate: self)
//
//        receivedRolesFromManager = false
//        if (!newCreated) {
//            let timerHolder = NTESTimerHolder()
//            timerHolder.startTimer(2, delegate: self, repeats: false)
//        }
//
//        
//    }
//    
//    public func kick(user: String) -> Bool {
//
//        let role = self.role(user: user)
//        if role != nil {
//            meetingRoles.removeValue(forKey: user)
//            self.notifyMeetingRolesUpdate()
//            return true
//        }
//        else {
//            return false
//        }
//    }
//    
//    public func isActorMemberReachFour() -> Bool{
//        var isActorCount = 0
//        for role in meetingRoles.values {
//            if (role.isActor) {
//                isActorCount = isActorCount + 1
//            }
//        }
//        if isActorCount >= 4 {
//            return true
//        }else{
//            return false
//        }
//    }
//    
//    public func role(user: String) -> MeetingRole? {
//        return meetingRoles[user]
//    }
//
//    func memberRole(member: NIMChatroomMember) ->MeetingRole? {
//        var role = self.role(user: member.userId!)
//        if let role1 = role {
//            return role1
//        }
//        role = self.addNewRole(uid: member.userId!, actor: true, roomAvatar: member.roomAvatar)
//        return role
//    }
//
//    func myRole() -> MeetingRole? {
//        let myUid = NIMSDK.shared().loginManager.currentAccount()
//        
//        return self.role(user: myUid)
//    }
//
//    func setMyVideo(on: Bool){
//        guard let role = self.myRole() else {
//            return
//        }
////        if NIMAVChatSDK.shared().netCallManager.setCameraDisable(!on) {
////            role.videoOn = on
////        }
//        self.notifyMeetingRolesUpdate()
//    
//    }
//
//    func setMyAudio(on: Bool){
//        guard let role = self.myRole() else {
//            return
//        }
////        if NIMAVChatSDK.shared().netCallManager.setMute(!on) {
////            role.audioOn = on
////        }
//        self.notifyMeetingRolesUpdate()
//    }
//
//    func setMyWhiteBoard(on: Bool){
//        guard let role = self.myRole() else {
//            return
//        }
//        role.whiteboardOn = on
//        self.notifyMeetingRolesUpdate()
//    }
//
//    func allActors() -> [String] {
//        var actors: [String] = []
//        for role in meetingRoles.values {
//            let actor = role.uid
//            if (role.isActor) {
//                actors.append(actor!)
//            }
//        }
//        return actors
//    }
//
//    func changeRaiseHand(){
//        
//        let myRole = self.myRole()
//        if myRole != nil {
//            myRole!.isRaisingHand = !myRole!.isRaisingHand
//            self.sendRaiseHand(raiseOrCancel: (myRole?.isRaisingHand)!)
//            self.notifyMeetingRolesUpdate()
//        }
//        
//        
//    }
//
//    func changeMemberActorRole(user: String){
//        
//        var role = self.role(user: user)
//        if role == nil {
//            role = self.addNewRole(uid: user, actor: false, roomAvatar: role?.roomAvatar)
//        }
//       
//        //判断互动人数是否达到4人，若达到弹出toast 互动人数已满
//        if (!role!.isActor && self.exceedMaxActorsNumber()) {
//            self.notifyMeetingActorsNumberExceedMax()
//            return
//        }
//        
//        role!.isActor = !role!.isActor
//        role!.isRaisingHand = false
//        self.notifyMeetingRolesUpdate()
//        self.sendControlActor(enable: role!.isActor, uid: user)
//       
//    }
//
//    func updateMeetingUser(user: String, isJoined: Bool){
//        var  role = self.role(user: user)
//        
//        if (role == nil) {
//            role = self.addNewRole(uid: user, actor: true, roomAvatar: nil)
//        }
//        
//        if (role!.isJoined != isJoined) {
//            role!.isJoined = isJoined
//            if (!isJoined) {
//                if (user != chatRoom.creator) {
//                    role!.isActor = true
//                }
//            }
//            self.notifyMeetingRolesUpdate()
//        }
//    }
//
//    func updateVolumes(volumes: [String: NSNumber]){
//        
//        for meetingUser in meetingRoles.keys {
//            let volumeNumber = volumes[meetingUser]
//            let volume = (volumeNumber != nil)  ? volumeNumber!.int16Value : 0
//            let role = self.role(user: meetingUser)
//            role!.audioVolume = volume
//        }
//        self.notifyMeetingVolumesUpdate()
//       
//    }
//    
//    func exceedMaxActorsNumber() -> Bool
//    {
//        return self.allActors().count >= 4
//    }
//
//  
//    func isManager(uid: String) -> Bool
//    {
//        var manager = false
//        manager = chatRoom.creator == uid ? true : false
//        return manager
//    }
//    
//    
//    private func addNewRole(uid: String, actor: Bool, roomAvatar: String?)  -> MeetingRole?
//    {
//        let newRole = MeetingRole(uid: uid, isManager: self.isManager(uid: uid), isJoined: false, isRaisingHand: false, isActor: actor, audioOn: actor, videoOn: false, whiteboardOn: actor, audioVolume: 0, roomAvatar: roomAvatar)
//        newRole.uid = uid
//        newRole.isManager = self.isManager(uid: uid)
//        newRole.isActor = newRole.isManager ? true : actor //主持人默认都是actor
//        newRole.audioOn = actor
//        newRole.videoOn = false
//        newRole.whiteboardOn = actor
//        
//        if (self.pendingJoinUsers.contains(uid)) {
//            newRole.isJoined = true
//            if let index = self.pendingJoinUsers.index(of: uid) {
//                self.pendingJoinUsers.remove(at: index)
//            }
//            
//        }
//        meetingRoles[uid] = newRole
//        self.notifyMeetingRolesUpdate()
//      
//        return newRole;
//    }
//    
//    func actorsListAttachment() -> NTESMeetingControlAttachment
//    {
//        let attachment = NTESMeetingControlAttachment()
//        attachment.command = .notifyActorsList
//        attachment.uids = self.allActors()
//        return attachment
//    }
//    
//    func changeToActor()
//    {
//        guard let role = self.myRole() else {
//            return
//        }
//        if role.isActor {
//            self.notifyMeetingActorBeenEnabled()
//            role.isActor = true
//            role.isRaisingHand = false
//            role.audioOn = true
//            role.videoOn = false
//            role.whiteboardOn = true
//            
////            NIMAVChatSDK.shared().netCallManager.setMeetingRole(true)
////            NIMAVChatSDK.shared().netCallManager.setMute(role.audioOn)
////            NIMAVChatSDK.shared().netCallManager.setCameraDisable(!role.videoOn)
//            self.notifyMeetingRolesUpdate()
//        }
//    }
//    
//    //MARK: - notify
//    func notifyMeetingRolesUpdate()
//    {
//        self.delegate?.meetingRolesUpdate()
//    }
//    
//    func notifyMeetingActorsNumberExceedMax()
//    {
//        self.delegate?.meetingActorsNumberExceedMax()
//    }
//    func notifyMeetingActorBeenEnabled()
//    {
//        self.delegate?.meetingActorBeenEnabled()
//    }
//    func notifyMeetingVolumesUpdate()
//    {
//        self.delegate?.meetingVolumesUpdate()
//    }
//    
//    func notifyChatroomMembersUpdate(members: [NIMChatroomNotificationMember]?, entered: Bool)
//    {
//        self.delegate?.chatroomMembersUpdated(members: members, entered: entered)
//    }
//    
//    func notifyMeetingRolesShowFullScreen(notifyExt: String)
//    {
//        self.delegate?.meetingRolesShowFullScreen(notifyExt: notifyExt)
//
//    }
//    
//    func notifyMeetingMemberRaiseHand()
//    {
//        self.delegate?.meetingMemberRaiseHand()
//    }
//
//    
//    //MARK: - send message
//    func sendRaiseHand(raiseOrCancel: Bool)
//    {
//        let attachment = NTESMeetingControlAttachment()
//        attachment.command = raiseOrCancel ? .raiseHand  : .cancelRaiseHand
//        messageHandler.sendMeetingP2PCommand(attachment: attachment, to: chatRoom.creator ?? "")
//       
//    }
//
//    func sendControlActor(enable: Bool, uid: String)
//    {
//        let attachment = NTESMeetingControlAttachment()
//        attachment.command = enable ? .enableActor : .disableActor
//        messageHandler.sendMeetingP2PCommand(attachment: attachment, to: uid)
//    }
//
//    func sendActorsListBroadcast()
//    {
//        messageHandler.sendMeetingBroadcastCommand(attachment: self.actorsListAttachment())
//    }
//
//    func sendAskForActors()
//    {
//        let attachment = NTESMeetingControlAttachment()
//        attachment.command = .askForActors
//        messageHandler.sendMeetingBroadcastCommand(attachment:attachment)
//        
//    }
//    
//    func reportActor(user: String)
//    {
//        guard let role = self.myRole() else {
//            return
//        }
//        if role.isActor {
//            self.sendReportActor(user: user)
//        }
//    }
//
//    func sendReportActor(user: String)
//    {
//        let attachment = NTESMeetingControlAttachment()
//        attachment.command = .actorReply
//        attachment.uids = [NIMSDK.shared().loginManager.currentAccount()]
//        messageHandler.sendMeetingP2PCommand(attachment: attachment, to: user)
//
//    }
//    
//    func updateRolesFromManager(actorsMember: [Any]?)
//    {
//        receivedRolesFromManager = false
//        self.changeToActor()
//        guard let actorsMembers = actorsMember else {
//            return
//        }
//        for actorId in actorsMembers {
//            let role = self.role(user: actorId as! String)
//            if role == nil {
//                let _ = self.addNewRole(uid: actorId as! String, actor: true, roomAvatar: "")
//            }
//            else {
//                role!.isActor = true
//            }
//        }
//        
//        self.notifyMeetingRolesUpdate()
//    }
//    
//    func recoverActor(user: String) -> Bool
//    {
//        if let role = self.role(user: user)  {
//            return false
//        }
//        else {
//            let role = self.addNewRole(uid: user, actor: true, roomAvatar: nil)
//            if self.exceedMaxActorsNumber() {
//                role?.isActor = true
//                self.notifyMeetingRolesUpdate()
//            }
//            
//            
//            return true
//        }
//        
//    }
//    
//    func dealRaiseHandRequest(raise: Bool, user: String)
//    {
//        var role1 : MeetingRole!
//        if let role = self.role(user: user)  {
//            role1 = role
//            role1.isActor = false
//        }
//        else {
//            role1 = self.addNewRole(uid: user, actor: false, roomAvatar: nil)
//        }
//        
//     
//        role1.isRaisingHand = raise
//
//        self.notifyMeetingRolesUpdate()
//        if raise {
//            self.notifyMeetingMemberRaiseHand()
//        }
//    }
//
//}
//
//extension MeetingRolesManager: MeetingMessageHandlerDelegate {
//    func onMembersEnterRoom(members: [NIMChatroomNotificationMember]?) {
//        self.notifyChatroomMembersUpdate(members: members, entered: true)
//        var sendNotify = false
//        var managerEnterRoom = false
//        
//        guard let memberArr = members  else {
//            return
//        }
//        
//        for  member in memberArr {
//            guard let role = self.myRole() else {
//                return
//            }
//            if role.isManager {
//                if member.userId == self.myRole()?.uid {
//                    messageHandler.sendMeetingP2PCommand(attachment: self.actorsListAttachment(), to: member.userId!)
//                    sendNotify = true
//                }
//            }else {
//                if member.userId == chatRoom.creator {
//                    managerEnterRoom = true
//                }
//            }
//            
//        }
//        if (sendNotify) {
//            self.notifyMeetingRolesUpdate()
//        }
//    }
//    
//    func onMembersExitRoom(members: [NIMChatroomNotificationMember]?) {
//        self.notifyChatroomMembersUpdate(members: members, entered: false)
//        guard let memberArr = members  else {
//            return
//        }
//        guard let role = self.myRole() else {
//            return
//        }
//        if role.isManager {
//            var needNotify = false
//            for  member in memberArr {
//                let role = self.role(user: member.userId!)
//                if let role = role {
//                    if role.isActor {
//                        role.isActor = false
//                        needNotify = true
//                    }
//                }
//                
//              
//                
//            }
//        }else{
//            for  member in memberArr {
//                if member.userId == chatRoom.creator {
//                    self.myRole()?.isRaisingHand = false
//                }
//              
//                
//            }
//        }
//        self.notifyMeetingRolesUpdate()
//      
//    }
//
//    func onMembersShowFullScreen(notifyExt: String){
//        self.notifyMeetingRolesShowFullScreen(notifyExt: notifyExt)
//    }
//
//    func onReceiveMeetingCommand(attachment: NTESMeetingControlAttachment, from userId: String){
//
//        switch (attachment.command) {
//        case .notifyActorsList:
//            if let role = self.myRole(){
//                if role.isManager {
//                    self.updateRolesFromManager(actorsMember: attachment.uids)
//                }
//            }
//            break
//        case .askForActors:
//            self.reportActor(user: userId)
//            break
//        case .actorReply:
//            if let role = self.myRole(){
//                if role.isManager || !receivedRolesFromManager {
//                    self.recoverActor(user: userId)
//                }
//            }
//            break
//            
//        case .raiseHand:
//            if let role = self.myRole(){
//                if role.isManager  {
//                    self.dealRaiseHandRequest(raise: true, user: userId)
//                }
//            }
//            break
//            
//        case .cancelRaiseHand:
//            if let role = self.myRole(){
//                if role.isManager  {
//                    self.dealRaiseHandRequest(raise: false, user: userId)
//                }
//            }
//            break
//            
//        case .enableActor:
//            self.changeToActor()
//            break
//            
//        case .disableActor:
//           
//            break
//            
//        default:
//            break
//        }
//    }
//
//}
//
//
//extension MeetingRolesManager: NTESTimerHolderDelegate {
//    func onNTESTimerFired(_ holder: NTESTimerHolder!) {
//        
//    }
//    
//    
//
//}
