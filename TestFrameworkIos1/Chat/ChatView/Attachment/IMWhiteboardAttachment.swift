//
//  IMWhiteboardAttachment.swift
//  RewardsLink
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/3/15.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class IMWhiteboardAttachment: NSObject, NIMCustomAttachment, IMMessageContentInfo  {

    var channel: String = ""
    var creator: String = ""
    func encode() -> String {
        let dictContent: [String : Any] = [CMWhiteBoardChannel : self.channel,
                                           CMWhiteBoardCreator: self.creator]
        
        let dict: [String : Any] = [CMType: CustomMessageType.WhiteBoard.rawValue,
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
        return WhiteboardContentView(messageModel: message)
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
