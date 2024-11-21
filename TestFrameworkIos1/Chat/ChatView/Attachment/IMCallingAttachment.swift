//
//  IMCallingAttachment.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/1/30.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class IMCallingAttachment: NSObject, NIMCustomAttachment, IMMessageContentInfo {
    
    var callType: NIMSignalingChannelType = .audio
    var eventType: CallingEventType = .miss
    var duration: TimeInterval = 0
    
    func encode() -> String {
        let dictContent: [String : Any] = [CMCallType : self.callType.rawValue,
                                           CMEventType: self.eventType.rawValue,
                                           CMCallDuration: self.duration]
        
        let dict: [String : Any] = [CMType: CustomMessageType.VideoCall.rawValue,
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
        return VideoCallingContentView(messageModel: message)
    }
    
    func canBeRevoked() -> Bool {
        return false
    }
    
    func canBeForwarded() -> Bool {
        return false
    }
    
    func canBeTranslated() -> Bool {
        return false
    }
    
    func canBeReplied() -> Bool {
        return false
    }

}
