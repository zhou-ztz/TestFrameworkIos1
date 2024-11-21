//
//  IMSessionHistoryViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/5/20.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class IMSessionHistoryViewController: IMChatViewController {
    
    var message: NIMMessage!
    init(session: NIMSession, message: NIMMessage) {
        self.message = message
        super.init(session: session, unread: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
    }
    
    func getData(){
        let messageFetchServiceGroup = DispatchGroup.init()
        messageFetchServiceGroup.enter()
        let option1 = NIMMessageSearchOption()
        option1.limit = 20
        option1.endTime = self.message.timestamp
        option1.allMessageTypes = true
        option1.order = .desc
        NIMSDK.shared().conversationManager.searchMessages(self.session, option: option1) { [weak self] (error, array) in
            
            messageFetchServiceGroup.leave()
            if let messages = array {
                let msgDataList = messages.map { return MessageData($0) }
                let tem : [NIMMessage] = [self!.message]
                let temList = tem.map { return MessageData($0) }
                
                self?.add(msgDataList)
                self?.add(temList)
            }
            
        }
        
        messageFetchServiceGroup.enter()
        let option2 = NIMMessageSearchOption()
        option2.limit = 40
        option2.startTime = self.message.timestamp
        option2.allMessageTypes = true
        option2.order = .asc
        NIMSDK.shared().conversationManager.searchMessages(self.session, option: option2) { [weak self] (error, array) in
            
            messageFetchServiceGroup.leave()
            if let messages = array {
                let msgDataList = messages.map { return MessageData($0) }
                self?.add(msgDataList)
            }
        }
        
        messageFetchServiceGroup.notify(queue: DispatchQueue.main) {
            self.tableview.reloadData()
            self.scrollToFirstMsg()
        }
    }
    
    func scrollToFirstMsg() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) { [weak self] in
            guard let self = self else { return }
            if let model = self.get(self.message), let indexPath = self.getIndexPath(for: model) {
                self.tableview.scrollToRow(at: indexPath, at: .top, animated: false)
                self.perform(#selector(self.cellAnimation(indexpath:)), with: indexPath, afterDelay: 0.3)
            }
        }
    }
}
