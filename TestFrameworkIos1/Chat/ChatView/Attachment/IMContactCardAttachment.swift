//
//  IMContactCardAttachment.swift
//  Yippi
//
//  Created by Tinnolab on 08/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
class IMContactCardAttachment: NSObject, NIMCustomAttachment, IMMessageContentInfo {

    var memberId: String = ""
    
    func encode() -> String {
        
        let dictContent: [String : String] = [CMContactCard: self.memberId]
        let dict: [String : Any] = [CMType: CustomMessageType.ContactCard.rawValue,
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
        return ContactMessageContentView(messageModel: message)
    }
    
    func canBeRevoked() -> Bool {
        return false
    }
    
    func canBeForwarded() -> Bool {
        return true
    }
    
    func canBeTranslated() -> Bool {
        return false
    }
    
    func canBeReplied() -> Bool {
        return true
    }

}
