//
//  TSChatDatabaseManager.swift
//  Thinksns Plus
//
//  Created by lip on 2017/2/23.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import RealmSwift

class TSChatDatabaseManager {
    fileprivate let realm: Realm = FeedIMSDKManager.shared.param.realm!

    /// 可以替换掉内部数据的初始化方法,用于测试
    ///
    /// - Parameter realm: 数据库
    init() { }

    func deleteAll() {
        
        do {
            let conversations = realm.objects(TSConversationObject.self)
            let messages = realm.objects(TSMessageObject.self)
            let conversationUtils = realm.objects(TSConversationUtilDataObject.self)
            try realm.safeWrite {
                realm.delete(conversations)
                realm.delete(messages)
                realm.delete(conversationUtils)
            }
        } catch let err { handleException(err) }
        self.deleteAllConversationUtilData()
    }

    // MARK: - message
    func allMessages() -> Results<TSMessageObject> {
        return realm.objects(TSMessageObject.self).sorted(byKeyPath: "responseTimeStamp")
    }

    func getMessageObject(with time: NSDate) -> TSMessageObject? {
        let predicate = NSPredicate(format: "timeStamp == %@", time)
        let messageObjects = realm.objects(TSMessageObject.self).filter(predicate)
        if messageObjects.isEmpty {
            return nil
        }
        return messageObjects.first
    }

    func getMaxSerialNumber(with cid: Int) -> Int? {
        let messageObjects = realm.objects(TSMessageObject.self).filter("conversationID == \(cid) AND serialNumber != nil").sorted(byKeyPath: "serialNumber", ascending: false)
        if messageObjects.isEmpty {
            return nil
        }
        return messageObjects.first?.serialNumber.value
    }

    func getUnreadCount(with conversationId: Int) -> Int {
        let predicate = NSPredicate(format: "conversationID = \(conversationId) AND isRead = false")
        return realm.objects(TSMessageObject.self).filter(predicate).count
    }

    /// 标记该消息为已读
    func readMessage(time: NSDate) {
        guard let messageObject = getMessageObject(with: time) else {
            fatalError("数据库无该数据")
        }
        do {
            try realm.safeWrite {
                messageObject.isRead = true
            }
        } catch let err { handleException(err) }
    }

    /// 标记该会话所有消息为已读
    func read(messages conversationId: Int) {
        let messages = getUnreadMessages(with: conversationId)
        if messages.isEmpty {
            return
        }
        
        do {
            try realm.safeWrite {
                for message in messages {
                    message.isRead = true
                }
            }
        } catch let err { handleException(err) }
    }

    func delete(message: TSMessageObject) {
        do {
            try realm.safeWrite {
                realm.delete(message)
            }
        } catch let err { handleException(err) }
    }

    /// 获取会话所有消息
    ///
    /// - Parameters:
    ///   - conversationID: 会话标识,必须为正整数
    ///   - messageID: 消息标识,当传入该值后,获取比该值更小(也就是发送时间更早)的消息,没有传入该值时,获取所有消息
    /// - Returns: 查询后的数据
    func getMessages(with conversationID: Int!, messageDate: NSDate?) -> Results<TSMessageObject> {
        let predicate: NSPredicate
        if let realMessageDate = messageDate {
            predicate = NSPredicate(format: "conversationID = \(conversationID!) AND responseTimeStamp < %@", realMessageDate)
        } else {
            predicate = NSPredicate(format: "conversationID = \(conversationID!)")
        }
        return realm.objects(TSMessageObject.self).filter(predicate).sorted(byKeyPath: "responseTimeStamp", ascending: false)
    }

    /// 获取会话所有未读消息
    func getUnreadMessages(with conversationID: Int!) -> Results<TSMessageObject> {
        let predicate = NSPredicate(format: "conversationID = \(conversationID!) AND isRead = false")
        return realm.objects(TSMessageObject.self).filter(predicate).sorted(byKeyPath: "responseTimeStamp", ascending: false)
    }

    func save(message: TSMessageObject!) {
        do {
            try realm.safeWrite {
                realm.add(message)
            }
        } catch let err { handleException(err) }
    }

    // MARK: - conversation
    /// 返回根据最新消息时间排序的会话对象
    func getLatestConversationinfo() -> Results<TSConversationObject> {
        return realm.objects(TSConversationObject.self).filter("latestMessage != nil").sorted(byKeyPath: "latestMessageDate", ascending: false)
    }

    func getConversationInfo(with identity: Int) -> TSConversationObject? {
        let conversationObjects = realm.objects(TSConversationObject.self).filter("identity == \(identity)")
        if conversationObjects.isEmpty {
            return nil
        }
        return conversationObjects.first
    }

    func getConversationInfo(withUserInfoId: Int) -> TSConversationObject? {
        let currentUserInfoId = CurrentUserSessionInfo?.userIdentity
        assert(currentUserInfoId != withUserInfoId, "只能查询他人的会话ID")
        let conversationObjects = realm.objects(TSConversationObject.self).filter("incomingUserIdentity == \(withUserInfoId)")
        if conversationObjects.isEmpty {
            return nil
        }
        return conversationObjects.first
    }

    func update(conversation: TSConversationObject, latestMessage: TSMessageObject) {

        do {
            try realm.safeWrite {
                conversation.latestMessage = latestMessage.messageContent
                conversation.latestMessageDate = latestMessage.responseTimeStamp
                if let sendResult = latestMessage.isOutgoing.value {
                    conversation.isSendingLatestMessage.value = sendResult
                }
                realm.add(conversation, update: .all)
            }
            
        } catch let err { handleException(err) }
    }

    func save(chatConversation: TSConversationObject) {
        do {
            try realm.safeWrite {
                realm.add(chatConversation, update: .all)
            }
        } catch let err { handleException(err) }
    }

    /// 会话未读数加1
    func addOneUnreadCount(_ conversationId: Int) {
        do {
            if let conversation = getConversationInfo(with: conversationId) {
                conversation.unreadCount += 1
                realm.add(conversation, update: .all)
            }
            
        } catch let err { handleException(err) }
    }

    /// 删除会话,同时删除会话对应的所有消息数据
    func delete(conversation: TSConversationObject) {
        do {
            try realm.safeWrite {
                let results = getMessages(with: conversation.identity, messageDate: nil)
                realm.delete(results)
                realm.delete(conversation)
            }
        } catch let err { handleException(err) }
    }

    func countAllConversationUnreadCount() {
        let results = getLatestConversationinfo()
        if results.isEmpty {
            return
        }
        DispatchQueue.main.async(execute: {
            for conversationObject in results {
                let unreadCount = self.getUnreadCount(with: conversationObject
                        .identity)
                self.realm.beginWrite()
                conversationObject.unreadCount = unreadCount
                self.realm.add(conversationObject, update: .all)
                try! self.realm.commitWrite()
            }
        })
    }

    // 写入数据
    func processAndWrite(_ conversationModels: [TSConversationModel], _ userInfoObjectlDic: [Int: UserInfoModel], complete: @escaping ((_ error: NSError?) -> Void)) {
        for conversationModel in conversationModels {
            let oldConversationObjects = realm.objects(TSConversationObject.self).filter("identity = %d", conversationModel.identity)
            var newConversationObject = TSConversationObject()
            guard let userInfoObject = userInfoObjectlDic[conversationModel.getIncomingUserId()] else {
                fatalError("返回的会话信息和用户信息无法对应")
            }
            if oldConversationObjects.isEmpty {
                newConversationObject.identity = conversationModel.identity
                newConversationObject.incomingUserIdentity = conversationModel.getIncomingUserId()
                newConversationObject.incomingUserName = userInfoObject.name

                self.realm.beginWrite()
                self.realm.add(newConversationObject, update: .all)
                try! self.realm.commitWrite()
            } else {
                // 更新所有的值
                self.realm.beginWrite()
                newConversationObject = oldConversationObjects.first!
                newConversationObject.incomingUserIdentity = conversationModel.getIncomingUserId()
                newConversationObject.incomingUserName = userInfoObject.name
                self.realm.add(newConversationObject, update: .all)
                try! self.realm.commitWrite()
            }
        }
        complete(nil)
    }

}

// MARK: - 消息列表页section0的杂项数据
extension TSChatDatabaseManager {
    /// 删除所有的杂项数据
    func deleteAllConversationUtilData() -> Void {
        do {
            try realm.safeWrite {
                let objects = realm.objects(TSConversationUtilDataObject.self)
                realm.delete(objects)
            }
        } catch let err { handleException(err) }
    }

    /// id数组元素去重
    fileprivate func removeRepetedUserId(usersId: [Int]) -> [Int] {
        var newUsersId = [Int]()
        for id in usersId {
            if !newUsersId.contains(id) {
                newUsersId.append(id)
            }
        }
        return newUsersId
    }

}
