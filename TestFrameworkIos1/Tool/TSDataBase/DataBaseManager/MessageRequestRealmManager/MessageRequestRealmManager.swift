//
//  MessageRequestRealmManager.swift
//  Yippi
//
//  Created by Tinnolab on 04/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import RealmSwift

class MessageRequestRealmManager {
    fileprivate let realm: Realm = FeedIMSDKManager.shared.param.realm!
    
    // MARK: - Lifecycle
    init() { }
    
    /// 删除整个表
    func deleteAll() {
        self.deleteAllData()
    }
}

extension MessageRequestRealmManager {
    
    func deleteAllData() -> Void {
        let reqCount = realm.objects(MessageRequestCountObject.self)
        let reqList = realm.objects(MessageRequestObject.self)
        let msgDetails = realm.objects(MessageDetailObject.self)
        let previewMsgDetails = realm.objects(PreviewMessageObject.self)
        let syncDetails = realm.objects(MessageSyncObject.self)
        let pendingMessages = realm.objects(MessageItemObject.self)
        
        do {
            try realm.safeWrite {
                realm.delete(reqCount)
                realm.delete(reqList)
                realm.delete(msgDetails)
                realm.delete(previewMsgDetails)
                realm.delete(syncDetails)
                realm.delete(pendingMessages)
            }
        } catch let error {
            LogManager.Log("\(#function) \(#file):\(#line): Delete All Data Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
        }
    }
    
    //MARK: - Request Count action
    
    func getRequestCount() -> Int? {
        var count = 0
        
        do {
            let result = realm.objects(MessageRequestCountObject.self)
            if result.isInvalidated == false {
                count = result.first?.count ?? 0
            }
        } catch let error {
            debugPrint(error.localizedDescription)
        }

        return count
    }
    
    func saveRequestCount(_ data:MessageRequestCountModel) -> Void {
        do {
            try realm.safeWrite {
                realm.add(data.object())
            }
        } catch let error {
            LogManager.Log("\(#function) \(#file):\(#line): Save Request Count Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
        }
    }
    
    func deleteRequestCount() -> Void {
        let reqCount = realm.objects(MessageRequestCountObject.self)
        do {
            try realm.safeWrite {
                realm.delete(reqCount)
            }
        } catch let error {
            LogManager.Log("\(#function) \(#file):\(#line): Delete Request Count Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
        }
    }
    
    //MARK: - Request List action
    
    func getChatRequest() -> [MessageRequestObject] {
        var messageRequest: [MessageRequestObject] = []
        
        do {
            let result = realm.objects(MessageRequestObject.self)
            if result.isInvalidated == false {
                messageRequest = Array(result.sorted(byKeyPath: "updatedAt", ascending: false))
            }
        } catch let error {
            debugPrint(error.localizedDescription)
        }

        return messageRequest
    }
    
    func saveRequestList(_ requestList:[MessageRequestModel], onComplete: EmptyClosure?) {
        let usernames = requestList.compactMap { model in
            return model.user?.username
        }
        
        TSUserNetworkingManager().getUsersInfo(usersId: [], userNames: usernames) { _, _, status in
            if status {
                
                for object in requestList {
                    let reqObj = object.object()
                    
                    let obj = UserInfoModel.retrieveUser(userId: (reqObj.userId).orEmpty.toInt())
                    
                    self.updateUserFromMessageRequest(userObj: obj)
                    self.updatePreviewMessageFromMessageRequest(messageReqObject: reqObj)
                    self.updateMessageRequest(messageReqObject: reqObj)
                }
                
            }
            
            onComplete?()
        }
        
        
    }
    
    func deleteSingleMessageRequest(requestId: Int) {
        let objects = realm.objects(MessageRequestObject.self).filter("requestID == \(requestId)")
        do {
            try realm.safeWrite {
                for obj in objects {
                    realm.delete(obj)
                }
            }
        } catch let error {
            LogManager.Log("\(#function) \(#file):\(#line): Delete Single Message Request Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
        }
        self.deletePreviewMessage(requestId: requestId)
    }
    
    func deleteRequestList() -> Void {
        let reqList = realm.objects(MessageRequestObject.self)
        let previewMsg = realm.objects(PreviewMessageObject.self)
        
        do {
            try realm.safeWrite {
                realm.delete(reqList)
                realm.delete(previewMsg)
            }
        } catch let error {
            LogManager.Log("\(#function) \(#file):\(#line): Delete Request List Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
        }
    }
    
    func deleteAllRequest() -> Void {
        let reqList = realm.objects(MessageRequestObject.self)
        let previewMsg = realm.objects(PreviewMessageObject.self)
        let msgDetails = realm.objects(MessageDetailObject.self)
        let pendingMessages = realm.objects(MessageItemObject.self)
        let syncDetails = realm.objects(MessageSyncObject.self)
        
        do {
            try realm.safeWrite {
                realm.delete(reqList)
                realm.delete(previewMsg)
                realm.delete(msgDetails)
                realm.delete(pendingMessages)
                realm.delete(syncDetails)
            }
        } catch let error {
            LogManager.Log("\(#function) \(#file):\(#line): Delete All Message Request Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
        }
    }
    
    private func updateMessageRequest(messageReqObject: MessageRequestObject) {
        let msgObject = realm.objects(MessageRequestObject.self).filter("requestID == \(messageReqObject.requestID)")
        var message = MessageRequestObject()

        if !msgObject.isEmpty {
            message = msgObject.first!
        }
        message = messageReqObject
        
        do {
            try realm.safeWrite {
                realm.add(message, update: .all)
            }
        } catch let error {
            LogManager.Log("\(#function) \(#file):\(#line): Update Message Request Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
        }
    }
    
    //MARK: - Chat History action
    
    func getChatHistory(requestId: Int) -> [MessageDetailObject] {
        let result = realm.objects(MessageDetailObject.self).filter("requestID == \(requestId)")
        return Array(result.sorted(byKeyPath: "createdAt", ascending: true))
    }
    
    func getChatHistory(userId: Int) -> [MessageDetailObject] {
        let result = realm.objects(MessageDetailObject.self).filter("toUserID == \(userId) || fromUserID == \(userId)")
        return Array(result.sorted(byKeyPath: "createdAt", ascending: true))
    }
    
    func saveMessageHistory(_ requestList:[MessageDetailModel]) {
        
        for object in requestList {
            let reqObj = object.object()
            
            let obj = UserInfoModel.retrieveUser(username: reqObj.username)
            
            self.updateUserFromMessageRequest(userObj: obj)
            self.updateMessageDetail(messageObject: reqObj)
        }
    }
    
    func deleteMessageHistory(requestId: Int) {
        let objects = realm.objects(MessageDetailObject.self).filter("requestID == \(requestId)")
        do {
            try realm.safeWrite {
                for obj in objects {
                    realm.delete(obj)
                }
            }
        } catch let error {
            LogManager.Log("\(#function) \(#file):\(#line): Delete Message History Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
        }
    }
    
    private func updateMessageDetail(messageObject: MessageDetailObject) {
        let msgObject = realm.objects(MessageDetailObject.self).filter("id == \(messageObject.id)")
        var message = MessageDetailObject()
        if !msgObject.isEmpty {
            message = msgObject.first!
        }
        
        message = messageObject

        do {
            try realm.safeWrite {
                realm.add(message, update: .all)
            }
        } catch let error {
            LogManager.Log("\(#function) \(#file):\(#line): Update Message Detail Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
        }
    }
    
    //MARK: - Others action
    private func updateUserFromMessageRequest(userObj: UserInfoModel?) {
        if let object = userObj {
            let userObject = UserInfoModel.retrieveUser(userId: object.userIdentity)
            userObject?.save()
        }
    }
    
    //MARK: - Pending Message History action
    func getPendingMessageHistory(toUserId: Int) -> [MessageItemObject] {
        let result = realm.objects(MessageItemObject.self).filter("toUserId == \(toUserId)")
        return Array(result.sorted(byKeyPath: "time", ascending: false))
    }
    
    func savePendingMessage(messageObj: MessageItemObject) {
        let msgObject = realm.objects(MessageItemObject.self).filter("id == \(messageObj.id)")
        var message = MessageItemObject()
        if !msgObject.isEmpty {
            message = msgObject.first!
        }
        message = messageObj
        
        do {
            try realm.safeWrite {
                realm.add(message, update: .all)
            }
        } catch let error {
            LogManager.Log("\(#function) \(#file):\(#line): Save Pending Message From Message Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
        }
    }
    
    func deletePendingMessage(id: Int) {
        let objects = realm.objects(MessageItemObject.self).filter("id == \(id)")
        
        do {
            try realm.safeWrite {
                for obj in objects {
                    realm.delete(obj)
                }
            }
        } catch let error {
            LogManager.Log("\(#function) \(#file):\(#line): Delete Pending Message From Message Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
        }
        
    }
    
    func deletePendingMessage(toUserId: Int) {
        let objects = realm.objects(MessageItemObject.self).filter("toUserId == \(toUserId)")
        
        do {
            try realm.safeWrite {
                for obj in objects {
                    realm.delete(obj)
                }
            }
        } catch let error {
            LogManager.Log("\(#function) \(#file):\(#line): Delete Pending Message From Message Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
        }
    }
    
    //MARK: - preview message actions
    
    func deletePreviewMessage(requestId: Int) {
        let objects = realm.objects(PreviewMessageObject.self).filter("requestID == \(requestId)")
        
        do {
            try realm.safeWrite {
                for obj in objects {
                    realm.delete(obj)
                }
            }
        } catch let error {
            LogManager.Log("\(#function) \(#file):\(#line): Delete Preview Message From Message Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
        }
    }
    
    func updatePreviewMessageFromMessageRequest(messageReqObject: MessageRequestObject) {
        if let object = messageReqObject.messageDetail {
            let msgObject = realm.objects(PreviewMessageObject.self).filter("id == \(object.id)")
            var message = PreviewMessageObject()
            if !msgObject.isEmpty {
                message = msgObject.first!
            }
            message = object
            realm.beginWrite()
            realm.add(message, update: .all)
            do {
                try realm.commitWrite()
            } catch let error {
                LogManager.Log("\(#function) \(#file):\(#line): Update Preview Message From Message Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
            }
        }
    }
    
    //MARK: - syncup status actions
    
    func updateMessageSync(userId: Int, msgId: Int, requestId: Int) {
        var msgObject = self.getMessageSyncStatus(userId: userId)
        
        var update = false
        if msgObject != nil {
            do {
                try realm.safeWrite {
                    msgObject?.requestID = requestId
                    msgObject?.id = msgId
                    msgObject?.syncAt = Date()
                }
            } catch let error {
                LogManager.Log("\(#function) \(#file):\(#line): Update Message Sync Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
            }
        } else {
            do {
                try realm.safeWrite {
                    let message = MessageSyncObject()
                    message.toUserID = userId
                    message.requestID = requestId
                    message.id = msgId
                    message.syncAt = Date()

                    realm.add(message)
                }
            } catch let error {
                LogManager.Log("\(#function) \(#file):\(#line): Update Message Sync Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
            }
        }
    }
    
    func getMessageSyncStatus(userId: Int) -> MessageSyncObject? {
        let msgObject = realm.objects(MessageSyncObject.self).filter("toUserID == \(userId)")
        return Array(msgObject.sorted(byKeyPath: "syncAt", ascending: false)).last
    }
    
    func deleteMessageSyncStatus(userId: Int) {
        let objects = realm.objects(MessageSyncObject.self).filter("toUserID == \(userId)")
        do {
            try realm.safeWrite {
                for obj in objects {
                    realm.delete(obj)
                }
            }
        } catch let error {
            LogManager.Log("\(#function) \(#file):\(#line): Delete Message Sync Request Fail: \(error.localizedDescription)\n", loggingType: .exception)
        }
    }
}
