//
//  MeetNewUserChatManager.swift
//  Yippi
//
//  Created by Tinnolab on 19/05/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK

protocol MeetNewUserChatManagerDelegate: class {
}

class MeetNewUserChatManager {
    
    static let shared = MeetNewUserChatManager()
    
    weak var delegate: MeetNewUserChatManagerDelegate?
    
    var messageList: [MessageData] = [MessageData(type: .headerTip)]
    
    func clearMessage() {
        self.messageList = [MessageData(type: .headerTip)]
    }
    
    func addMessageData(messages:[MessageData]) -> [IndexPath] {
        let msgDataList = messages
        
        let count = messageList.count
        var insert: [IndexPath] = []
        
        if msgDataList.count > 0 {
            messageList.append(contentsOf: msgDataList)
            
            for index in count..<count + msgDataList.count {
                insert.append(IndexPath(row: index, section: 0))
            }
        }
        
        return insert
    }
    
    func addMessage(messages:[NIMMessage]) -> [IndexPath] {
        let msgDataList = messages.map { return MessageData(meetUser: $0) }
        
        let count = messageList.count
        var insert: [IndexPath] = []
        
        if msgDataList.count > 0 {
            messageList.append(contentsOf: msgDataList)
            
            for index in count..<count + msgDataList.count {
                insert.append(IndexPath(row: index, section: 0))
            }
        }
        
        return insert
    }
    
    func updateMessage(message: NIMMessage) -> Int? {
        if let oldMsg = self.findMessage(message: message), let index = self.messageList.index(of: oldMsg) {
            self.messageList[index] = MessageData(meetUser: message)
            return index
        }
        return nil
    }
    
    func findMessage(message: NIMMessage) -> MessageData? {
        if let obj = self.messageList.first(where:{ $0.nimMessageModel?.messageId == message.messageId }) {
            return obj
        } else {
            return nil
        }
    }
}
