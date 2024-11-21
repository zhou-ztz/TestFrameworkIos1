//
//  IMStickerCardAttachment.swift
//  Yippi
//
//  Created by Tinnolab on 08/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
class IMStickerCardAttachment: NSObject, NIMCustomAttachment, IMMessageContentInfo {

    var bundleID: String = ""
    var bundleIcon: String = ""
    var bundleName: String = ""
    var bundleDescription: String = ""
    var bundleUrl: String = ""
    
    func encode() -> String {
        let dictContent: [String : Any] = [CMStickerBundleId : self.bundleID,
                                           CMStickerIconImage : self.bundleIcon,
                                           CMStickerName : self.bundleName,
                                           CMStickerDiscription : self.bundleDescription,
                                           CMRStickerURL : self.bundleUrl]
        
        let dict: [String : Any] = [CMType: CustomMessageType.StickerCard.rawValue,
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
        return StickerCardMessageContentView(messageModel: message)
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
    
    func stickerCardAttachment(with sticker: TSmessagePopModel) {
        self.bundleID = String(sticker.feedId)
        self.bundleIcon = sticker.coverImage
        self.bundleName = sticker.owner
        self.bundleDescription = sticker.content
        self.bundleUrl = sticker.contentUrl
    }
}
