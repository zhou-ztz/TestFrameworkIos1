//
//  IMMessageContentConfig.swift
//  Yippi
//
//  Created by Tinnolab on 09/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class IMTextMessageContent: NSObject, IMMessageContentInfo {
    func cellContent(_ message: MessageData) -> BaseContentView {
        return TextContentView(messageModel: message)
    }
    
    func canBeRevoked() -> Bool {
        return true
    }
    
    func canBeForwarded() -> Bool {
        return true
    }
    
    func canBeTranslated() -> Bool {
        return true
    }
    
    func canBeReplied() -> Bool {
        return true
    }
}

class IMAudioMessageContent: NSObject, IMMessageContentInfo {
    func cellContent(_ message: MessageData) -> BaseContentView {
        return VoiceMessageContentView(messageModel: message)
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

class IMImageMessageContent: NSObject, IMMessageContentInfo {
    func cellContent(_ message: MessageData) -> BaseContentView {
        return VideoImageMessageContentView(messageModel: message)
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
        return false
    }
}

class IMVideoMessageContent: NSObject, IMMessageContentInfo {
    func cellContent(_ message: MessageData) -> BaseContentView {
        return VideoImageMessageContentView(messageModel: message)
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

class IMLocationMessageContent: NSObject, IMMessageContentInfo {
    func cellContent(_ message: MessageData) -> BaseContentView {
        return LocationContentView(messageModel: message)
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

class IMFileMessageContent: NSObject, IMMessageContentInfo {
    func cellContent(_ message: MessageData) -> BaseContentView {
        return FilesMessageContentView(messageModel: message)
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

class IMNotificationContent: NSObject, IMMessageContentInfo {
    func cellContent(_ message: MessageData) -> BaseContentView {
        return InfoMessageContentView(messageModel: message)
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

