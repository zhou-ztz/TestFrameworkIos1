//
//  IMAnnouncementAttachment.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/5/17.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class IMAnnouncementAttachment: NSObject, NIMCustomAttachment, IMMessageContentInfo {
    
    var imageUrl: String = ""
    var linkUrl: String = ""
    var message: String = ""
    var showCoverImage: UIImage?
    
    
    func encode() -> String {
        let dictContent: [String : Any] = [ CMAnnoucementName: self.message,
                                            CMAnnoucementImageUrl: self.imageUrl,
                                            CMAnnoucementLinkUrl : self.linkUrl]
        let dict: [String : Any] = [CMType: CustomMessageType.Announcement.rawValue,
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
        return AnnouncementContentView(messageModel: message)
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
