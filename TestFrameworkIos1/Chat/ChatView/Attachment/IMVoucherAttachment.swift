//
//  IMVoucherAttachment.swift
//  RewardsLink
//
//  Created by Kit Foong on 17/07/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK
class IMVoucherAttachment: NSObject, NIMCustomAttachment, IMMessageContentInfo {
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
        
        let dict: [String : Any] = [CMType: CustomMessageType.Voucher.rawValue,
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
        return VoucherMessageContentView(messageModel: message)
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
    
    func voucherPostMessage(with model: TSmessagePopModel) {
        self.postUrl = model.contentUrl
        self.title = model.owner
        self.desc = model.content
        self.imageURL = model.coverImage
        self.contentType = "\(model.contentType.messageTypeID)"
    }
    
    func voucherPostMessage(linkUrl: String, contentUrl: String) {
        self.postUrl = linkUrl
        self.contentUrl = contentUrl
    }
}
