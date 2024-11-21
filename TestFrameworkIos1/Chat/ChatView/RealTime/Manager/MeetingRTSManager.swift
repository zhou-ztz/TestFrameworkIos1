//
//  MeetingRTSManager.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/2/9.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
//AVChat



protocol MeetingRTSManagerDelegate: class {
    
    func onReserve(name: String, result: Error?)
    func onJoin(name: String, result: Error?)
    func onLeft(name: String, error: Error?)
    func onUserJoined(uid: String, conference name: String)
    func onUserLeft(uid: String, conference name: String)
}

protocol MeetingRTSDataHandler: class {
    func handleReceivedData(data: Data, sender: String)
}
class MeetingRTSManager: NSObject {
    
//    var currentConference: NIMRTSConference?
    
//    weak var delegate: MeetingRTSManagerDelegate?
//    weak var dataHandler: NTESWhiteboardCmdHandler?
    
    static let shared = MeetingRTSManager()
//    let rtsConferenceManager: NIMRTSConferenceManager? = NIMAVChatSDK.shared().rtsConferenceManager
    
//    override init() {
//        super.init()
//        rtsConferenceManager?.add(self)
//    }
//
//    deinit {
//        rtsConferenceManager?.remove(self)
//    }
//    
//    func reserveConference(name: String) -> Error?
//    {
//        let conference = NIMRTSConference()
//        conference.name = name
//        conference.ext = "test extend rts conference messge"
//        return  rtsConferenceManager?.reserve(conference)
//    }
//
//    func joinConference(name: String) -> Error?
//    {
//        leaveCurrentConference()
//        
//        let conference = NIMRTSConference()
//        conference.name = name
//        conference.serverRecording = BundleSetting.sharedConfig().serverRecordWhiteboardData()
//        conference.dataHandler = { [weak self] (data)  in
//            self?.handleReceivedData(data: data)
//        }
//        return rtsConferenceManager?.join(conference)
//    }
//   
//    func leaveCurrentConference()
//    {
//        if (currentConference != nil) {
//            let _ = rtsConferenceManager?.leave(currentConference!)
//            currentConference = nil
//        }
//    }
//
//    func sendRTSData(data: Data, toUser uid: String?) -> Bool
//    {
//        var accepted = false
//        
//        if (currentConference != nil) {
//            let conferenceData = NIMRTSConferenceData()
//            conferenceData.conference = currentConference!
//            conferenceData.data = data
//            conferenceData.uid = uid
//            accepted = ((rtsConferenceManager?.sendRTSData(conferenceData)) != nil)
//        }
//        
//        return accepted
//    }
//
//    func isJoined() ->Bool
//    {
//        return currentConference != nil
//    }
//
//
//    func handleReceivedData(data: NIMRTSConferenceData)
//    {
//        dataHandler?.handleReceivedData(data.data, sender: data.uid ?? "")
//    }
}

//extension MeetingRTSManager: NIMRTSConferenceManagerDelegate {
//    
//    func onReserve(_ conference: NIMRTSConference, result: Error?) {
//       
//        //本demo使用聊天室id作为了多人实时会话的名称，保证了其唯一性，如果分配时发现已经存在了，认为是该聊天室的主播之前分配的，可以直接使用
////        if result.code ==  417 { //NIMRemoteErrorCodeExist
////            result = nil
////        }
//        delegate?.onReserve(name: conference.name, result: result)
//     
//    }
//    
//    func onJoin(_ conference: NIMRTSConference, result: Error?) {
//        
//        if result == nil || currentConference == nil {
//            currentConference = conference
//        }
//        self.delegate?.onJoin(name: conference.name, result: result)
//    }
//
//    func onLeftConference(_ conference: NIMRTSConference, error: Error) {
//        if currentConference?.name == conference.name {
//            currentConference = nil
//            self.delegate?.onLeft(name: conference.name, error: error)
//        }
//    }
//
//    func onUserJoined(_ uid: String, conference: NIMRTSConference) {
//        if currentConference?.name == conference.name {
//            self.delegate?.onUserJoined(uid: uid, conference: conference.name)
//        }
//    }
//
//    func onUserLeft(_ uid: String, conference: NIMRTSConference, reason: NIMRTSConferenceUserLeaveReason) {
//        if currentConference?.name == conference.name {
//            self.delegate?.onUserLeft(uid: uid, conference: conference.name)
//        }
//    }
//
//    
//}
