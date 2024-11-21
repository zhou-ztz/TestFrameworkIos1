//
//  IMRPSAttachment.swift
//  Yippi
//
//  Created by Tinnolab on 08/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class IMRPSAttachment: NSObject, NIMCustomAttachment, IMMessageContentInfo {

    var value: Int = 0
    
    func encode() -> String {
        
        let dictContent: [String : Int] = [CMValue: self.value]
        let dict: [String : Any] = [CMType: CustomMessageType.RPS.rawValue,
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
        return StickerRPSMessageContentView(messageModel: message)
    }

    func canBeRevoked() -> Bool {
        return true
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
