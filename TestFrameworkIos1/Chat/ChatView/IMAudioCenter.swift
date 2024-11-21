//
//  IMAudioCenter.swift
//  Yippi
//
//  Created by Tinnolab on 19/10/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class IMAudioCenter: NSObject {
    
    var currentMessage: NIMMessage? = nil
    var retryCount: Int = 3
    
    static let shared = IMAudioCenter()
    
    override init() {
        super.init()
        NIMSDK.shared().mediaManager.add(self)
        resetRetryCount()
    }

    func resetRetryCount() {
        retryCount = 3
    }
    
    func play(for message: NIMMessage) {
        if let audioObject = message.messageObject as? NIMAudioObject, let path = audioObject.path {
            currentMessage = message
            message.isPlayed = true
            NIMSDK.shared().mediaManager.play(path)
        }
    }
    
    func resume(for message: MessageData) {
        if let msg = message.nimMessageModel {
            self.play(for: msg)
            NIMSDK.shared().mediaManager.seek(message.audioTimeSeek ?? 0.0)
            message.audioIsPaused = false
        }
    }

}

extension IMAudioCenter: NIMMediaManagerDelegate {
    func playAudio(_ filePath: String, didBeganWithError error: Error?) {
        if error != nil {
            if retryCount > 0 {
                self.retryCount -= 1
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    NIMSDK.shared().mediaManager.play(filePath)
                })
                
            } else {
                currentMessage = nil
                self.resetRetryCount()
            }
        } else {
            self.resetRetryCount()
        }
    }
    
    func playAudio(_ filePath: String, didCompletedWithError error: Error?) {
        currentMessage = nil
    }
}
