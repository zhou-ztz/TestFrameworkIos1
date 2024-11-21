//
//  IMReplyAttachment.swift
//  Yippi
//
//  Created by Tinnolab on 08/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
class IMReplyAttachment: NSObject, NIMCustomAttachment, IMMessageContentInfo {
    var content: String = ""
    var message: String = ""
    var name: String = ""
    var username: String = ""
    var image: String = ""
    var messageID: String = ""
    var messageType: String = ""
    var videoURL: String = ""
    var messageCustomType: String = ""
    
    func encode() -> String {
        let dictContent: [String : Any] = [CMReplyContent : self.content,
                                           CMReplyMessage : self.message,
                                           CMReplyName : self.name,
                                           CMReplyUserName : self.username,
                                           CMReplyImageURL : self.image,
                                           CMReplyMessageID : self.messageID,
                                           CMReplyMessageType : self.messageType,
                                           CMReplyThumbURL : self.videoURL,
                                           CMReplyMessageCustomType : self.messageCustomType]
        let dict: [String : Any] = [CMType: CustomMessageType.Reply.rawValue,
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
        return ReplyMessageContentView(messageModel: message)
    }
    
    func canBeRevoked() -> Bool {
        return false
    }
    
    func canBeForwarded() -> Bool {
        return false
    }
    
    func canBeTranslated() -> Bool {
        return true
    }
    
    func canBeReplied() -> Bool {
        return true
    }
}
