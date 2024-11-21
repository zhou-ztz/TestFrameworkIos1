//
//  MessagegRequestChatConfig.swift
//  Yippi
//
//  Created by Tinnolab on 24/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
//import NIMPrivate
import NIMSDK


@objcMembers
class MessageRequestChatConfig: NSObject {

//    @objc func inputBarItemTypes() -> [NSNumber] {
//        return [NSNumber(value: NIMInputBarItemType.textAndRecord.rawValue),
//                NSNumber(value: NIMInputBarItemType.sendButton.rawValue)]
//    }
//    
//    @objc func mediaItems() -> [NIMMediaItem] {
//        return []
//    }
//    
//    @objc func charlets() -> [NIMInputEmoticonCatalog] {
//        return []
//    }
    
    @objc func autoFetchWhenOpenSession() -> Bool {
        return false
    }
    
    @objc func shouldHandleReceipt() -> Bool {
        return false
    }
    
    @objc func enableRobot() -> Bool {
        return false
    }
    
    @objc func disableAt() -> Bool {
        return true
    }
    
    @objc func sendButtonImage() -> UIImage {
        return UIImage.set_image(named: "icASendBlue")!
    }
    
}
