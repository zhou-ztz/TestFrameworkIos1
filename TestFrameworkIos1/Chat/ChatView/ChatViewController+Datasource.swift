//
//  ChatViewController+Datasource.swift
//  Yippi
//
//  Created by Yong Tze Ling on 13/09/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK

extension ChatViewController {
    
    func processTimeData(_ datas: [MessageData]) -> [MessageData] {
        let items = self.dataSource.snapshot().itemIdentifiers
        let lastTimeMessage = items.filter { $0.type == .time }.last
        
        var compareTime: TimeInterval =  lastTimeMessage?.messageTime ?? 0.0
        
        var newDatas: [MessageData] = []
        
        for (index, item) in datas.enumerated() {
            let currentTimestampInMilliseconds = Date().timeIntervalSince1970
            if item.shouldInsertTimestamp(compare: compareTime) && item.disableBeInviteAuthTipsMessage() {
                let timeData = MessageData(id: "\(index)-\(currentTimestampInMilliseconds)", type: .time, messageTime: item.messageTime)
                newDatas.append(timeData)
            }
            compareTime = item.messageTime ?? 0.0
            newDatas.append(item)
        }

        return newDatas
    }
    
    func add(_ messages: [MessageData]) {
        let data = processTimeData(messages)
        var snapshot = dataSource.snapshot()
        let itemsToAdd = data.filter { !snapshot.itemIdentifiers.contains($0) }
        if !itemsToAdd.isEmpty {
            snapshot.appendItems(data)
        }
        dataSource.defaultRowAnimation = .bottom
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func remove(_ message: MessageData, animate: Bool = true) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([message])
        dataSource.defaultRowAnimation = .fade
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
    
    func onReceiveMessage(_ messages: [NIMMessage]) {
        guard messages.last?.session?.sessionId == session.sessionId else {
            return
        }
        
        let datas = messages.compactMap { MessageData($0) }
        let newData = processTimeData(datas)
        var snapshot = dataSource.snapshot()
        if snapshot.numberOfSections == 0 { snapshot.appendSections([0]) }
        snapshot.appendItems(datas)
        dataSource.defaultRowAnimation = .bottom
        dataSource.apply(snapshot, animatingDifferences: true, completion: {
            // By Kit Foong (Send Receipt to inform yunxin message already read)
            if self.autoReadEnabled {
                let returnReceipt = NIMMessageReceipt(message: messages.last!)
                do {
                    if self.session.sessionType == .P2P {
                        try NIMSDK.shared().chatManager.send(returnReceipt)
                    } else {
                        try NIMSDK.shared().chatManager.sendTeamMessageReceipts([returnReceipt])
                    }
                } catch {
                    print("error---= \(error.localizedDescription)")
                }
            }
        })
    }
    
    func get(_ message: NIMMessage?) -> MessageData? {
        let item = dataSource.snapshot().itemIdentifiers.filter {
            $0.nimMessageModel?.messageId == message?.messageId
        }.last
        item?.nimMessageModel = message
        return item
    }
    
    func getMessageData(for id: String) -> MessageData? {
        let message = dataSource.snapshot().itemIdentifiers.first {
            $0.nimMessageModel?.messageId == id
        }
        return message
    }
    
    func getIndexPath(for message: MessageData) -> IndexPath? {
        return dataSource.indexPath(for: message)
    }
    
    func insert(message: MessageData, after ori: MessageData, completion: EmptyClosure? = nil) {
        do {
            var snapshot = dataSource.snapshot()
            snapshot.insertItems([message], afterItem: ori)
            dataSource.defaultRowAnimation = .bottom
            dataSource.apply(snapshot, animatingDifferences: true, completion: {
                completion?()
            })
        } catch {
            print("error---= \(error.localizedDescription)")
        }
    }
    
    func update(_ message: NIMMessage, animation: Bool = true) {
        var snapshot = dataSource.snapshot()
        if let data = snapshot.itemIdentifiers.last(where: { $0.nimMessageModel?.messageId == message.messageId }) {
            snapshot.reloadItems([data])
            dataSource.defaultRowAnimation = animation ? .fade : .none
            dataSource.apply(snapshot, animatingDifferences: animation)
            
            if let yidunAntiSpamRes = message.yidunAntiSpamRes, yidunAntiSpamRes.isEmpty == false {
                data.nimMessageModel = message
                message.localExt = ["yidunAntiSpamRes": message.yidunAntiSpamRes]
                NIMSDK.shared().conversationManager.update(message, for: message.session!, completion: nil)
            }
        }
    }
    
    func update(_ data: MessageData) {
        var snapshot = dataSource.snapshot()
        if snapshot.itemIdentifiers.contains(data) {
            snapshot.reloadItems([data])
        } else {
            if let data = snapshot.itemIdentifiers.last(where: { $0.nimMessageModel?.messageId == data.nimMessageModel?.messageId }) {
                snapshot.reloadItems([data])
            }
        }
        dataSource.defaultRowAnimation = .fade
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func unreadMessageIndexPath() -> IndexPath? {
        let msgs = dataSource.snapshot().itemIdentifiers.filter {
            $0.type == .outgoing || $0.type == .incoming
        }
        let index = msgs.count - unreadCount
        
        guard index >= 0 && index < msgs.count else {
            return nil
        }
        let model = msgs[index]
        return dataSource.indexPath(for: model)
    }
    
    func removeAll() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
}

class ChatDataSource: UITableViewDiffableDataSource<Int, MessageData> {
    
    var isForwarding: Bool = false
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let model = self.itemIdentifier(for: indexPath) else {
            return false
        }
        switch model.type {
        case .outgoing, .incoming:
            guard let message = model.nimMessageModel else { return false }
            if let ext = message.remoteExt, ext.keys.contains("secretChatTimer") { return false }
            if message.messageObject is NIMTipObject { return false }
            guard let messageObject = message.messageObject as? NIMCustomObject else { return true }
            if isForwarding && (messageObject.attachment is IMRPSAttachment || messageObject.attachment is IMEggAttachment) { return false }
            return true
        default:
            return false
        }
    }
    
}
