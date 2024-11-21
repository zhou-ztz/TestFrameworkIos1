//
//  IMTextTranslateAttachment.swift
//  Yippi
//
//  Created by Khoo on 24/06/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK

class IMTextTranslateAttachment: NSObject, NIMCustomAttachment, IMMessageContentInfo {

    var oriMessageId: String = ""
    var originalText: String = ""
    var translatedText: String = ""
    var isOutgoingMsg: Bool = true
    
    func encode() -> String {
        let dictContent: [String : Any] = [ CMOriginalMessageId: self.oriMessageId,
                                            CMOriginalMessage: self.originalText,
                                            CMTranslatedMessage : self.translatedText,
                                            CMTranslatedMessageIsOutgoing : self.isOutgoingMsg]
        let dict: [String : Any] = [CMType: CustomMessageType.Translate.rawValue,
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
        return TranslateMessageContentView(messageModel: message)
    }
    
    func shouldShowAvatar() -> Bool {
        return false
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

