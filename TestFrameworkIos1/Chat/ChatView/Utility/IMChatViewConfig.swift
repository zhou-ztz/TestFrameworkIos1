//
//  IMChatViewConfig.swift
//  Yippi
//
//  Created by Tinnolab on 28/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
class IMChatViewConfig: ChatViewConfig {
    
    func messageInterval() -> TimeInterval {
        return 300.0
    }
    
    func messageLimit() -> Int {
        return 20
    }
    
    // By Kit Foong (Added Big limit for Search)
    func messageSearchLimit() -> Int {
        return 300
    }

    func recordMaxDuration() -> TimeInterval {
        return 60.0
    }

    func placeholder() -> String? {
        return ""
    }
    
    func inputMaxLength() -> Int {
        return 5000
    }
    
    ///  输入按钮类型，请填入 NIMInputBarItemType 枚举，按顺序排列。不实现则按默认排列。
//    func inputBarItemTypes() -> [NSNumber]?

    // TODO: apple

    func mediaItems() -> [MediaItem]? {
        return [.album, .camera, .file, .redpacket, .videoCall, .voiceCall, .sendCard, .whiteBoard, .sendLocation, .collectMessage, .voiceToText, .rps]
    }
    
    ///  禁用贴图表情
//    func charlets() -> [NIMInputEmoticonCatalog]?
    
    func disableInputView() -> Bool {
        return false
    }
    
    func disableAutoPlayAudio() -> Bool {
        return false
    }
    
    func disableProximityMonitor() -> Bool {
        return BundleSetting().disableProximityMonitor()
    }
        
    func autoFetchWhenOpenSession() -> Bool {
        return true
    }
    
    func autoFetchAttachment() -> Bool {
        return BundleSetting().autoFetchAttachment()
    }
    
    func disableReceiveNewMessages() -> Bool {
        return false
    }
        
    func shouldHandleReceipt(for message: NIMMessage?) -> Bool {
        guard let message = message else { return false }
        let type = message.messageType as? NIMMessageType
        if type == NIMMessageType.custom {
            let object = message.messageObject as? NIMCustomObject
            let attachment = object?.attachment

//            if attachment is NTESWhiteboardAttachment {
//                return false
//            }
        }

        return type == NIMMessageType.text || type == NIMMessageType.audio || type == NIMMessageType.image || type == NIMMessageType.video || type == NIMMessageType.file || type == NIMMessageType.location || type == NIMMessageType.custom

    }
    
    func disableAutoMarkMessageRead() -> Bool {
        return true
    }
        
    func disableAt() -> Bool {
        return false
    }
        
    func recordType() -> NIMAudioType {
        return BundleSetting().usingAmr() ? NIMAudioType.AMR : NIMAudioType.AAC
    }
        
    func sessionBackgroundImage() -> UIImage? {
        let defaults = UserDefaults.standard

        let imagedata = defaults.object(forKey: Constants.GlobalChatWallpaperImageKey) as? Data
        var image: UIImage? = nil
        if let imagedata = imagedata {
            return UIImage(data: imagedata)
        }
        return nil
    }
    
    func sendButtonImage() -> UIImage? {
        return UIImage.set_image(named:"icASendBlue")
    }
}
