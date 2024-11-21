//
//  ChatFriendListViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 01/05/2019.
//  Copyright © 2019 ZhiYiCX. All rights reserved.
//

import UIKit
import NIMSDK
class ChatFriendListViewController: TSChatFriendListViewController {

    var existingMemberId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let id = existingMemberId {
            var object = UserInfoModel(JSON: [:])
            object?.username = id
            let user = object
            choosedDataSource.append(user)
            updateChoosedScrollViewUI(chooseArray: choosedDataSource)
        }
    }
    
    override func creatNewChat() {
        guard choosedDataSource.count > 0 else {
            return
        }
        
        if choosedDataSource.count == 1 {
            let model: UserInfoModel = choosedDataSource[0] as! UserInfoModel
            let session = NIMSession(model.username, type: .P2P)
            self.createChatRoom(with: session)

        } else {
            createTeam()
        }
    }

    // MARK: - 增加群成员
    override func addMembersForGroup(addOrDelete: String) {
        guard choosedDataSource.count > 0 else {
            return
        }
        
        if choosedDataSource.count > 0 {
            createTeam()
        } else {
            return
        }
    }
    
    private func createTeam() {

        guard let username = CurrentUserSessionInfo?.username else {
            return
        }
        
        let members = (choosedDataSource as! [UserInfoModel]).compactMap { $0.username } + [username]

        let createGroupController = DependencyContainer.shared.resolveViewControllerFactory().makeCreateGroupViewController(member: members, completion: { (teamId) in
            let session = NIMSession(teamId as String, type: .team)
            self.createChatRoom(with: session)
        })
        self.navigationController?.pushViewController(createGroupController, animated: true)
    }
    
    private func createChatRoom(with session: NIMSession) {
        let vc = IMChatViewController(session: session, unread: 0)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
