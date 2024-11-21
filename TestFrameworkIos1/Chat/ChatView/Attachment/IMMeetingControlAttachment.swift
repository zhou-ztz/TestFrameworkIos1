//
//  IMMeetingControlAttachment.swift
//  Yippi
//
//  Created by Tinnolab on 09/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
class IMMeetingControlAttachment: NSObject, NIMCustomAttachment {

    var roomID: String = ""   
    var command: IMCustomMeetingCommand = .Unknown
    var uids: NSArray = []
    
    func encode() -> String {
        var dictContent: [String : Any] = [CMRoomID : self.roomID,
                                           CMCommand: self.command.rawValue]
        if self.uids.count > 0 {
            dictContent[CMUIDs] = self.uids
        }
        
        let dict: [String : Any] = [CMType: CustomMessageType.SocialPost.rawValue,
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
}
