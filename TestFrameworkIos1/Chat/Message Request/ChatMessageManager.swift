//
//  ChatMessageManager.swift
//  Yippi
//
//  Created by Tinnolab on 28/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import UIKit
import NIMSDK

/// 讯息状态
@objc public enum MessageStatus: Int {
    case normal = 0
    case pending
    case failed
}

/// 讯息类型
@objc public enum MessageType: Int {
    case incoming = 0
    case outgoing
    case tip
    case time
}

protocol ChatMessageManagerDelegate: class {
    func onMessageLongPress(_ messageItem: MessageItem, on cellView: UIView)
    func onResendMessageClicked(_ sender: OutgoingChatTableViewCell)
}

class ChatMessageManager {
    
    static let shared = ChatMessageManager()
    
    weak var delegate: ChatMessageManagerDelegate?
    
    var requestId: Int?
    var toUserId: Int!
    var messageForMenu: MessageItem?
    
    let maxNotificationCount: Int = 100
    var filter: NIMSystemNotificationFilter {
        let filter = NIMSystemNotificationFilter()
        filter.notificationTypes = [NIMSystemNotificationType.teamInvite.rawValue, NIMSystemNotificationType.teamApply.rawValue] as [NSNumber]
        return filter
    }
    
    var onMessageListRefresh: ((Bool) -> ())?
    var onNoMoreMessageToRefresh: EmptyClosure?
    var onGetMessagesFailed: EmptyClosure?
    
    var requestList: [MessageRequestObject] {
        get {
            return MessageRequestRealmManager().getChatRequest()
        }
        
        set {
            self.requestList = newValue.filter {
                if $0.fromUserID == CurrentUserSessionInfo?.userIdentity {
                    return true
                } else {
                    return !$0.isBlock
                }
            }
        }
    }
    
    var messageList: [MessageItem] = [] {
        didSet {
            
            let groupList = Dictionary(grouping: messageList, by: { $0.time.DateToGroup() })

            for dateItem: String in groupList.keys {
                let date = dateItem.dateStringToDate()
                if !self.messageList.contains(where: {$0.time == date}) {
                    let timestamp = date.timeIntervalSince1970
                    let displayDate = TSDate().dateString(.tip, nDate: date)
                    let item = MessageItem.init(id: Int(timestamp), toUserId: self.toUserId, type: .time, content: displayDate, time: date, status: .normal)
                    self.messageList.append(item)
                }
            }
            
            self.messageList = messageList.sorted(by: { $0.time < $1.time })
        }
    }
    
    func setToUserId(toUserId: Int, requestId: Int?) {
        messageList = []
        self.toUserId = toUserId
        self.requestId = requestId
    }
    
    func getChatHistory(id: Int? = nil) {
        var messages: [MessageDetailObject] = []
        if let reqId = self.requestId {
            messages = MessageRequestRealmManager().getChatHistory(requestId: reqId)
        } else {
            messages = MessageRequestRealmManager().getChatHistory(userId: toUserId)
        }
        
        let errMessages = MessageRequestRealmManager().getPendingMessageHistory(toUserId: toUserId)
        self.messageList = []
        
        for object: MessageDetailObject in messages {
            self.messageList.append(object.messageItem())
        }
        
        for object: MessageItemObject in errMessages {
            self.messageList.append(object.messageItem())
        }
        
        if messages.count > 0 {
            guard let lastMsgId = messages.last?.id else { return }
            let lastSyncMsgId = MessageRequestRealmManager().getMessageSyncStatus(userId: self.toUserId)?.id ?? 0

            var limit = 50
            if lastMsgId > lastSyncMsgId {
                if let id = id { limit = id - lastSyncMsgId }
                self.loadNewMessages(id: lastSyncMsgId, limit: (limit <= 0) ? 50 : limit)
            } else if lastMsgId < lastSyncMsgId {
                self.loadNewMessages(id: lastMsgId)
            } else {
                guard let id = id else { return }
                
                if lastSyncMsgId < id {
                    limit = id - lastSyncMsgId
                    self.loadNewMessages(id: lastSyncMsgId, limit: (limit <= 0) ? 50 : limit)
                }
            }

        } else {
            if let id = id {
                self.loadOldMessages(id: (id + 1), scrollToBottom: true)
            } else {
                self.loadMessages()
            }
        }
    }
    
    func getIMUnreadCount() -> Int {
        return NIMSDK.shared().conversationManager.allUnreadCount()
    }
    
    func getRequestCount(getGroupCount: Bool = false) -> Int {
        var count = 0

        for var sub in requestList {
            if sub.isInvalidated == false {
                let msgContent = sub
                let messageData = MessageRequestModel.init(object: msgContent)
     
                if let userInfo = messageData.user {
                    count += 1
                }
            }
        }
        
        if getGroupCount {
            if var notis = NIMSDK.shared().systemNotificationManager.fetchSystemNotifications(nil, limit: maxNotificationCount, filter: filter), notis.count > 0 {
                var uniqueValues = Set<String>()
                notis = notis.filter{ uniqueValues.insert("\($0.targetID)&\($0.sourceID)").inserted }
                
                count += notis.count
            }
        }
        
        return count
    }
    
    private func sort(messageData:[MessageDetailModel]) -> [MessageDetailModel] {
        return messageData.sorted(by: { $0.createdAt < $1.createdAt })
    }
    
    func addNewMessage(id:Int, content: String) {
        let newMessage = MessageItem.init(id: id, toUserId: self.toUserId, type: .outgoing, content: content, time: Date(), status: .pending)
        self.messageList.append(newMessage)
        MessageRequestRealmManager().savePendingMessage(messageObj: newMessage.object())
        
    }
    
    func updateMessageList(id: Int, messageModel: MessageDetailModel) {
        self.removePendingMessage(id: id)
        self.messageList.append(messageModel.object().messageItem())
    }
    
    func updateFailedPendingMessage(id:Int, isBlock: Bool? = nil) {
        if let index = self.messageList.firstIndex(where: {$0.id == id}) {
            let obj = self.messageList[index]
            
            var addBlockAlert = true
            let nextIndex = index + 1
            if self.messageList.count > nextIndex {
                let nextObj = self.messageList[(index + 1)]
                if (nextObj.type == .tip && nextObj.content == "msg_get_reject".localized) {
                    addBlockAlert = false
                }
            }
            
            self.messageList.remove(at: index)
            
            let newMessage = MessageItem.init(id: id, toUserId: obj.toUserId, type: .outgoing, content: obj.content, time: obj.time, status: .failed)
            self.messageList.append(newMessage)
            
            MessageRequestRealmManager().savePendingMessage(messageObj: newMessage.object())
            
            if let blocked = isBlock, blocked, addBlockAlert {
                let errorTipMessage = MessageItem.init(id: -1, toUserId: self.toUserId, type: .tip, content: "msg_get_reject".localized, time: obj.time.addingTimeInterval(0.1), status: .normal)
                self.messageList.append(errorTipMessage)
            }
        }
    }
    
    func removePendingMessage(id: Int) {
        if let index = self.messageList.firstIndex(where: {$0.id == id}) {
            let preIndex = index - 1
            let nextIndex = index + 1
            if preIndex >= 0 && nextIndex < self.messageList.count {
                let preObj = self.messageList[preIndex]
                let nextObj = self.messageList[nextIndex]
                if (preObj.type == .time && nextObj.type == .time) {
                    self.messageList.remove(at: preIndex)
                }
                if nextObj.type == .tip && nextObj.content == "msg_get_reject".localized {
                    self.messageList.remove(at: nextIndex)
                }
            }
        }
        self.messageList.removeAll(where: {$0.id == id})
        MessageRequestRealmManager().deletePendingMessage(id: id)
    }
    
    func requestCount() -> Int {
        let count = MessageRequestRealmManager().getRequestCount() ?? 0
        return count
    }
    
    func loadMoreMessage() {
        let msgItem = self.messageList.first(where: {($0.status == .normal && $0.type != .tip && $0.type != .time)})
        guard let msgId = msgItem?.id else {
            self.onNoMoreMessageToRefresh?()
            return
        }
        self.loadOldMessages(id: msgId, scrollToBottom: false)
    }
    
    func deleteAllRequestList() {
        self.requestList = []
        self.messageList = []
        MessageRequestRealmManager().deleteAllRequest()
    }
    
    func deleteChatHistory(requestId: Int, userId: Int) {
        MessageRequestRealmManager().deleteSingleMessageRequest(requestId: requestId)
        MessageRequestRealmManager().deleteMessageHistory(requestId: requestId)
        MessageRequestRealmManager().deleteMessageSyncStatus(userId: userId)
        MessageRequestRealmManager().deletePendingMessage(toUserId: userId)
        
        self.messageList = []
    }
}

extension ChatMessageManager {
    private func loadNewMessages(id:Int, limit: Int? = nil) {
        MessageRequestNetworkManager().getChatHistory(id: self.toUserId, limit: limit ?? 50, after: id, complete: {(response, status, message) in
            if status {
                guard let messages = response else { return }
                if messages.count > 0 {
                    
                    if let lastMsg = messages.last {
                        MessageRequestRealmManager().updateMessageSync(userId: self.toUserId, msgId: lastMsg.id, requestId: lastMsg.requestID)
                    }
                    self.getChatHistory()
                    self.onMessageListRefresh?(true)
                }
            } else {
                self.onGetMessagesFailed?()
            }
        })
    }
    
    private func loadOldMessages(id:Int, scrollToBottom: Bool) {
        MessageRequestNetworkManager().getChatHistory(id: self.toUserId, limit: 10, before: id, complete: {(response, status, message) in
            if status {
                guard let messages = response else { return }
                if messages.count > 0 {
                    for model in messages {
                        let object = model.object()
                        self.messageList.append(object.messageItem())
                    }
                    self.onMessageListRefresh?(scrollToBottom)
                    
                    if let lastMsg = messages.last {
                        if let lastStatus = MessageRequestRealmManager().getMessageSyncStatus(userId: self.toUserId) {
                            if lastStatus.id < lastMsg.id {
                                MessageRequestRealmManager().updateMessageSync(userId: self.toUserId, msgId: lastMsg.id, requestId: lastMsg.requestID)
                            }
                        } else {
                            MessageRequestRealmManager().updateMessageSync(userId: self.toUserId, msgId: lastMsg.id, requestId: lastMsg.requestID)
                        }
                    }
                } else {
                    if !scrollToBottom {
                        self.onNoMoreMessageToRefresh?()
                    }
                }
            } else {
                self.onGetMessagesFailed?()
            }
        })
    }
    
    private func loadMessages(limit: Int? = nil) {
        MessageRequestNetworkManager().getChatHistory(id: self.toUserId, limit: limit ?? 10, complete: {(response, status, message) in
            if status {
                guard let messages = response else { return }
                if messages.count > 0 {
                    for model in messages {
                        let object = model.object()
                        self.messageList.append(object.messageItem())
                    }
                    if let lastMsg = messages.last {
                        MessageRequestRealmManager().updateMessageSync(userId: self.toUserId, msgId: lastMsg.id, requestId: lastMsg.requestID)
                    }
                    self.onMessageListRefresh?(true)
                }
            } else {
                self.onGetMessagesFailed?()
            }
        })
    }
}

class MessageItem: NSObject {
    let id: Int
    let toUserId: Int
    let content: String
    let time: Date
    let type: MessageType
    var status: MessageStatus
    let username: String?
    
    init(id: Int, toUserId: Int, type: MessageType,  content: String, time: Date, status: MessageStatus, username: String? = nil) {
        self.id = id
        self.toUserId = toUserId
        self.content = content
        self.time = time
        self.type = type
        self.status = status
        self.username = username
    }
    
    func object() -> MessageItemObject {
        let object = MessageItemObject()
        object.id = self.id
        object.content = self.content
        object.toUserId = self.toUserId
        object.time = self.time
        return object
    }
}

extension String {
    func dateStringToDate() -> Date {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.timeZone = TimeZone(identifier: "UTC")
        dateFormatterGet.dateFormat = "yyyy/MM/dd"
        
        let dateFormatterReverseDate = DateFormatter()
        dateFormatterReverseDate.timeZone = TimeZone(identifier: "UTC")
        dateFormatterReverseDate.dateFormat = "dd-MM-yyyy"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.timeZone = TimeZone(identifier: "UTC")
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatterGet.date(from: self) {
            return (date)
        } else if let date = dateFormatterReverseDate.date(from: self) {
            return (date)
        } else {
            return (Date())
        }
    }
}

extension Date {
    func DateToGroup() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy/MM/dd"
        return dateFormatterPrint.string(from: self)
    }
}
