//
//  IMSocialPostAttachment.swift
//  Yippi
//
//  Created by Tinnolab on 08/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class IMSocialPostAttachment: NSObject, NIMCustomAttachment, IMMessageContentInfo {
    var postUrl: String = ""
    var title: String = ""
    var desc: String = ""
    var imageURL: String = ""
    var contentType: String = ""
    var contentUrl: String = ""
    
    func encode() -> String {
        let dictContent: [String : Any] = [CMShareURL : self.postUrl,
                                           CMShareTitle: self.title,
                                           CMShareDescription: self.desc,
                                           CMShareImage: self.imageURL,
                                           CMShareContentType: self.contentType,
                                           CMShareContentUrl: self.contentUrl]
        
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
    
    func cellContent(_ message: MessageData) -> BaseContentView {
        return SocialPostMessageContentView(messageModel: message)
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
        return true
    }
    
    func socialPostMessage(with model: TSmessagePopModel) {
        self.postUrl = model.contentUrl
        self.title = model.owner
        self.desc = model.content
        self.imageURL = model.coverImage
        self.contentType = "\(model.contentType.messageTypeID)"
    }
    
    func socialPostMessage(linkUrl: String, contentUrl: String) {
        self.postUrl = linkUrl
        self.contentUrl = contentUrl
    }
}
