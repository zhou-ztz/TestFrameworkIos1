//
//  MessageRequestViewController.swift
//  Yippi
//
//  Created by Kit Foong on 21/02/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import UIKit
import NIMSDK

class MessageRequestViewController: TSViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: TSTableView!
    
    var filterNotifications: [NIMSystemNotification] = []
    let maxNotificationCount: Int = 100
    var filter: NIMSystemNotificationFilter {
        let filter = NIMSystemNotificationFilter()
        filter.notificationTypes = [NIMSystemNotificationType.teamInvite.rawValue, NIMSystemNotificationType.teamApply.rawValue] as [NSNumber]
        return filter
    }
    var currentIndex = 0
    var tabs: [TabHeaderdModal] = []
    var notifications: [NIMSystemNotification] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavTitle()
        setupCollectionView()
        setupTableView()
        addObserver()
        
        tableView.mj_header.beginRefreshing()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(TabCollectionViewCell.nib(), forCellWithReuseIdentifier: TabCollectionViewCell.cellIdentifier)
        tabs = [TabHeaderdModal(titleString: "rw_text_individual".localized, messageCount: 0, bubbleColor: TSColor.main.theme, isSelected: true), TabHeaderdModal(titleString: "group_invitation_title".localized, messageCount: 0, bubbleColor: TSColor.main.theme, isSelected: false)]
        collectionView.reloadData()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(MessageRequestTableViewCell.nib(), forCellReuseIdentifier: MessageRequestTableViewCell.cellReuseIdentifier)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
    }
    
    private func addObserver() {
        NIMSDK.shared().systemNotificationManager.add(self)
    }
    
    private func removeObserver() {
        NIMSDK.shared().systemNotificationManager.remove(self)
        NIMSDK.shared().systemNotificationManager.markAllNotificationsAsRead()
    }
    
    private func setupNavTitle() {
        var count = ChatMessageManager.shared.getRequestCount() + filterNotifications.count
        self.setCloseButton(backImage: true, titleStr: count == 0 ? "title_requests".localized : "\("title_requests".localized) (\(count))")
    }
    
    @objc func refresh() {
        self.loadData()
    }
    
    @objc func loadMore() {
        self.loadMoreData()
    }
}

// MARK: - Web Service
extension MessageRequestViewController {
    private func loadData() {
        // Group Request
        if var notis = NIMSDK.shared().systemNotificationManager.fetchSystemNotifications(nil, limit: maxNotificationCount, filter: filter), notis.count > 0 {
            
            notifications = notis
        
            var uniqueValues = Set<String>()
            notis = notis.filter{ uniqueValues.insert("\($0.targetID)&\($0.sourceID)").inserted }
            filterNotifications = notis
        } else {
            filterNotifications.removeAll()
        }
        
        // Personal Request
        MessageRequestNetworkManager().getMessageReqList(specialRequest: true, complete: { [weak self] (result, status) in
            DispatchQueue.main.async {
                self?.tableView.mj_header.endRefreshing()
                self?.tableView.mj_footer.resetNoMoreData()
            }
            
            self?.tableRefresh()
        })
    }
    
    private func loadMoreData() {
        if currentIndex == 0 {
            var lastRequest = ChatMessageManager.shared.requestList.last
            
            if lastRequest?.isInvalidated == false {
                let id = lastRequest?.after

                MessageRequestNetworkManager().getMessageReqList(after: id, complete: {(result, status) in
                    DispatchQueue.main.async {
                        if status {
                            if ChatMessageManager.shared.requestList.count >= ChatMessageManager.shared.requestCount() {
                                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                            } else {
                                self.tableView.mj_footer.endRefreshing()
                            }
                        } else {
                            self.tableView.mj_footer.endRefreshing()
                        }

                        self.tableRefresh()
                    }
                })
            }
        } else {
//            guard var notis = NIMSDK.shared().systemNotificationManager.fetchSystemNotifications(notifications.last, limit: maxNotificationCount, filter: filter), notis.count > 0 else {
//                DispatchQueue.main.async {
//                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
//                }
//                return
//            }
//            DispatchQueue.main.async {
//                var uniqueValues = Set<String>()
//                notis = notis.filter{ uniqueValues.insert("\($0.targetID)").inserted }
//                self.notifications.append(contentsOf: notis)
//                self.tableView.mj_footer.endRefreshing()
//                self.tableRefresh()
//            }
        }
    }
    
    private func tableRefresh() {
        DispatchQueue.main.async {
            if self.currentIndex == 0 {
                self.tableView.mj_footer.makeVisible()
                if ChatMessageManager.shared.requestList.count <= 0  {
                    self.tableView.show(placeholderView: .empty)
                } else {
                    self.tableView.removePlaceholderViews()
                }
            } else {
                self.tableView.mj_footer.makeHidden()
                if self.filterNotifications.count <= 0  {
                    self.tableView.show(placeholderView: .empty)
                } else {
                    self.tableView.removePlaceholderViews()
                }
            }
            
            for (index, element) in self.tabs.enumerated() {
                if (index == 0) {
                    element.messageCount = ChatMessageManager.shared.getRequestCount()
                } else {
                    element.messageCount = self.filterNotifications.count
                }
            }
            
            self.collectionView.reloadData()
            self.tableView.reloadData()
            self.setupNavTitle()
        }
    }
    
    private func handleMessageRowFunction(indexPath: IndexPath) {
        if indexPath.row >= ChatMessageManager.shared.requestList.count { return }
        let msgContent = ChatMessageManager.shared.requestList[indexPath.row]
        guard msgContent.isInvalidated == false else { return }
        let vc = MsgRequestChatViewController()
        vc.messageInfo = MessageRequestModel.init(object: msgContent)
        // By Kit Foong (Will refresh table after perform action)
        vc.refreshList = { [weak self] in
            self?.loadData()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func getMessageRequestUserId(isAccept: Bool, data: MessageRequestModel) -> Int {
        if isAccept {
            return data.fromUserID == CurrentUserSessionInfo?.userIdentity ? data.toUserID : data.fromUserID
        }
        
        return (data.toUserID == CurrentUserSessionInfo?.userIdentity) ? data.fromUserID : data.toUserID
    }
    
    private func acceptFriendRequest(data: MessageRequestModel) {
        self.loading()

        MessageRequestNetworkManager().addFriend(id: getMessageRequestUserId(isAccept: true, data: data), complete: {
            DispatchQueue.main.async {
                self.endLoading()
                ChatMessageManager.shared.deleteChatHistory(requestId: data.requestID, userId:  self.getMessageRequestUserId(isAccept: true, data: data))
                self.tableRefresh()
            }
        })
    }
    
    private func rejectFriendRequest(data: MessageRequestModel) {
        self.loading()

        MessageRequestNetworkManager().deleteSingleMessageRequest(requestId: data.requestID, complete: {
            DispatchQueue.main.async {
                self.endLoading()
                ChatMessageManager.shared.deleteChatHistory(requestId: data.requestID, userId: self.getMessageRequestUserId(isAccept: false, data: data))
                self.tableRefresh()
            }
        })
    }
    
    private func acceptGroupInvitation(indexPath: IndexPath, notification: NIMSystemNotification) {
        NIMSDK.shared().systemNotificationManager.markNotifications(asRead: notification)
        
        switch notification.type {
        case .teamApply:
            NIMSDK.shared().teamManager.passApply(toTeam: notification.targetID.orEmpty, userId: notification.sourceID.orEmpty) { (error, status) in
                
                if let error = error as NSError? {
                    if error.code == NIMRemoteErrorCode.codeTimeoutError.rawValue {
                        self.showTopIndicator(status: .faild, "network_problem".localized)
                    } else {
                        notification.handleStatus = NotificationHandleType.outOfDate.rawValue
                        self.showTopIndicator(status: .faild, "text_expired".localized)
                        self.tableRefresh()
                    }
                    return
                }
                
                notification.handleStatus = NotificationHandleType.ok.rawValue
                self.showTopIndicator(status: .success, "text_approved_success".localized)
                
                for item in self.notifications {
                    if item.targetID == notification.targetID && item.sourceID == notification.sourceID {
                        NIMSDK.shared().systemNotificationManager.delete(item)
                    }
                    
                }
                self.filterNotifications.remove(at: indexPath.row)
                self.tableRefresh()
            }
        case .teamInvite:
            NIMSDK.shared().teamManager.acceptInvite(withTeam: notification.targetID.orEmpty, invitorId: notification.sourceID.orEmpty) { error in
                
                if let error = error as NSError? {
                    if error.code == NIMRemoteErrorCode.codeTeamNotExists.rawValue {
                        self.showTopIndicator(status: .faild, "team_not_exist".localized)
                    } else if error.code == NIMRemoteErrorCode.codeTimeoutError.rawValue {
                        self.showTopIndicator(status: .faild, "network_problem".localized)
                    } else {
                        notification.handleStatus = NotificationHandleType.outOfDate.rawValue
                        self.showTopIndicator(status: .faild, "text_expired".localized)
                        self.tableRefresh()
                    }
                    return
                }
                
                notification.handleStatus = NotificationHandleType.ok.rawValue
                self.showTopIndicator(status: .success, "text_accepted_success".localized)
                
                for item in self.notifications {
                    if item.targetID == notification.targetID && item.sourceID == notification.sourceID {
                        NIMSDK.shared().systemNotificationManager.delete(item)
                    }
                }
                self.filterNotifications.remove(at: indexPath.row)
                self.tableRefresh()
            }
        default:
            break
        }
    }
    
    private func rejectGroupInvitaton(indexPath: IndexPath, notification: NIMSystemNotification) {
        for item in self.notifications {
            if item.targetID == notification.targetID && item.sourceID == notification.sourceID {
                NIMSDK.shared().systemNotificationManager.delete(item)
            }
        }
        self.filterNotifications.remove(at: indexPath.row)
        self.tableRefresh()
    }
}

// MARK: Group Notification Delegate
extension MessageRequestViewController: NIMSystemNotificationManagerDelegate {
    func onReceive(_ notification: NIMSystemNotification) {
        self.notifications.insert(notification, at: 0)
        if !self.filterNotifications.contains(where: {$0.targetID == notification.targetID &&
            $0.sourceID == notification.sourceID }) && notification.type.rawValue != 3 {
            //NIMSystemNotificationType = 3 (Group Reject Request)
            self.filterNotifications.insert(notification, at: 0)
        }
        self.tableRefresh()
    }
}

// MARK: Message Request Action Delegate (Accept & Reject)
extension MessageRequestViewController: MessageRequestTableViewCellDelegate {
    func buttonActionDelegate(isAccept: Bool, indexPath: IndexPath) {
        var isGroup = currentIndex == 1
        
        var name: String = ""

        if isGroup {
            if let noti = filterNotifications[safe: indexPath.row], let targetId = noti.targetID, let team = NIMSDK.shared().teamManager.team(byId: targetId) {
                name = team.teamName.orEmpty
            }
        } else {
            if let msgContent = ChatMessageManager.shared.requestList[safe: indexPath.row], msgContent.isInvalidated == false {
                let messageModel = MessageRequestModel.init(object: msgContent)
                if let userInfo = messageModel.user {
                    name = userInfo.name
                }
            }
        }
        
        let view = MessageRequestActionView(isAccept: isAccept, isGroup: isGroup, name: name)
        let popup = TSAlertController(style: .popup(customview: view), hideCloseButton: true)
        
        view.alertButtonClosure = {
            if isGroup {
                let notification = self.filterNotifications[indexPath.row]
                
                if isAccept {
                    self.acceptGroupInvitation(indexPath: indexPath, notification: notification)
                } else {
                    self.rejectGroupInvitaton(indexPath: indexPath, notification: notification)
                }
            } else {
                let msgContent = ChatMessageManager.shared.requestList[indexPath.row]
                guard msgContent.isInvalidated == false else { return }
                
                if isAccept {
                    self.acceptFriendRequest(data: MessageRequestModel.init(object: msgContent))
                } else {
                    self.rejectFriendRequest(data: MessageRequestModel.init(object: msgContent))
                }
            }
            popup.dismiss()
        }
        
        view.cancelButtonClosure = {
            popup.dismiss()
        }
        
        self.present(popup, animated: false)
    }
}

// MARK: - Collection view delegate & data source
extension MessageRequestViewController:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let numberOfCells = tabs.count
        let edgeInsets = CGFloat((Int(collectionView.layer.frame.size.width) - (numberOfCells * 100)) / (numberOfCells + 1))

        return UIEdgeInsets(top: 0, left: edgeInsets, bottom: 0, right: edgeInsets)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabCollectionViewCell.cellIdentifier, for: indexPath) as! TabCollectionViewCell
        cell.updateUI(tab: tabs[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for (index, element) in tabs.enumerated() {
            if index == indexPath.row {
                element.isSelected = true
            } else {
                element.isSelected = false
            }
        }
        self.currentIndex = indexPath.row
        self.tableRefresh()
    }
}


// MARK: - Table view delegate & data source
extension MessageRequestViewController:  UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentIndex == 0 {
            return ChatMessageManager.shared.requestList.count
        }

        return filterNotifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageRequestTableViewCell.cellReuseIdentifier) as! MessageRequestTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        
        if currentIndex == 0 {
            if ChatMessageManager.shared.requestList.count > 0 && indexPath.row < ChatMessageManager.shared.requestList.count {
                let msgContent = ChatMessageManager.shared.requestList[indexPath.row]
                guard msgContent.isInvalidated == false else {
                    return UITableViewCell()
                }
                
                let messageData = MessageRequestModel.init(object: msgContent)
                guard let userInfo = messageData.user else {
                    return UITableViewCell()
                }
                
                cell.updatePersonalCell(data: messageData)
                return cell
            }
        }

        if currentIndex == 1 {
            cell.updateGroupCell(data: filterNotifications[indexPath.row])
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentIndex == 0 {
            if indexPath.row >= ChatMessageManager.shared.requestList.count { return }
            let msgContent = ChatMessageManager.shared.requestList[indexPath.row]
            guard msgContent.isInvalidated == false else {
                return
            }
            handleMessageRowFunction(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if currentIndex == 0 {
            if indexPath.row >= ChatMessageManager.shared.requestList.count { return 120 }
            let msgContent = ChatMessageManager.shared.requestList[indexPath.row]
            guard msgContent.isInvalidated == false else {
                return 0
            }
            
            let messageData = MessageRequestModel.init(object: msgContent)
            guard let userInfo = messageData.user else {
               return 0
            }
            
            return 120
        }
        
        return 120
    }
}
