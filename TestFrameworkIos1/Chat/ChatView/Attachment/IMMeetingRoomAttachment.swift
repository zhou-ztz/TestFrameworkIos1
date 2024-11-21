//
//  IMMeetingRoomAttachment.swift
//  Yippi
//
//  Created by Kit Foong on 31/10/2022.
//  Copyright © 2022 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
class IMMeetingRoomAttachment: NSObject, NIMCustomAttachment, IMMessageContentInfo {

    var meetingId: String = ""
    var meetingNum: String = ""
    var meetingShortNum: String = ""
    var meetingPassword: String = ""
    var meetingStatus: String = ""
    var meetingSubject: String = ""
    var meetingType: Int = 0
    var roomArchiveId: String = ""
    var roomUuid: String = ""
    
    func encode() -> String {
        let dictContent: [String : Any] = [CMMeetingId : self.meetingId,
                                           CMMeetingNum : self.meetingNum,
                                           CMMeetingShortNum : self.meetingShortNum,
                                           CMMeetingPassword : self.meetingPassword,
                                           CMMeetingStatus : self.meetingStatus,
                                           CMMeetingSubject : self.meetingSubject,
                                           CMMeetingType : self.meetingType,
                                           CMRoomArchiveId : self.roomArchiveId,
                                           CMRoomUuid : self.roomUuid]
        
        let dict: [String : Any] = [CMType: CustomMessageType.MeetingRoom.rawValue,
                                    CMData: dictContent]
        var stringToReturn = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            stringToReturn = String(data: jsonData, encoding: .utf8) ?? ""
        } catch let error {
            print(error.localizedDescription)
        }
        return stringToReturn
    }
    
    func cellContent(_ message: MessageData) -> BaseContentView {
        return MeetingMessageContentView(messageModel: message)
    }
    
    func canBeRevoked() -> Bool {
        return true
    }
    
    func canBeForwarded() -> Bool {
        return true
    }
    
    func canBeTranslated() -> Bool {
        return false
    }
    
    func canBeReplied() -> Bool {
        return false
    }
}

