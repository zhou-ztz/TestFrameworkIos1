//
//  IMStickerAttachment.swift
//  Yippi
//
//  Created by Tinnolab on 08/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
class IMStickerAttachment: NSObject, NIMCustomAttachment, IMMessageContentInfo {
    var chartletId: String = "" // id
    var stickerId: String = ""
    var chartletCatalog: String = ""
    
    func encode() -> String {
        let dictContent: [String : Any] = [CMChartlet: self.chartletId,
                                           CMCatalog: self.chartletCatalog,
                                           CMStickerId: self.stickerId]
        let dict: [String : Any] = [CMType: CustomMessageType.Sticker.rawValue,
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
        return true
    }
    
    func canBeTranslated() -> Bool {
        return false
    }
    
    func canBeReplied() -> Bool {
        return true
    }
}
