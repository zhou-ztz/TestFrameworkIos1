//
//  GroupNotificationTableVC.swift
//  Yippi
//
//  Created by Yong Tze Ling on 28/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

enum NotificationHandleType: Int {
    case pending = 0
    case ok /// approved by admin or accepted by current user
    case no /// rejected by admin or rejected by current user
    case outOfDate
}

class GroupNotificationTableVC: TSTableViewController {
    
    var notifications: [NIMSystemNotification] = []

    let maxNotificationCount: Int = 20
    var filter: NIMSystemNotificationFilter {
        let filter = NIMSystemNotificationFilter()
        filter.notificationTypes = [NIMSystemNotificationType.teamInvite.rawValue, NIMSystemNotificationType.teamApply.rawValue] as [NSNumber]
        return filter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "title_notification_team".localized
        NIMSDK.shared().systemNotificationManager.add(self)
        
        tableView.register(GroupNotificationCell.nib(), forCellReuseIdentifier: GroupNotificationCell.cellIdentifier)
        tableView.mj_header.beginRefreshing()
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
        
        self.rightButton?.frame = CGRect(x: 0, y: 0, width: TSViewRightCustomViewUX.MaxWidth, height: 44)
        self.rightButton?.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
    }
    
    deinit {
        NIMSDK.shared().systemNotificationManager.remove(self)
        NIMSDK.shared().systemNotificationManager.markAllNotificationsAsRead()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setRightButton(title: "clear".localized, img: nil)
        self.setRightButtonTextColor(color: TSColor.main.theme)
    }
    
    override func refresh() {
        tableView.mj_header.endRefreshing()
        guard let notis = NIMSDK.shared().systemNotificationManager.fetchSystemNotifications(nil, limit: maxNotificationCount, filter: filter), notis.count > 0 else {
            self.notifications.removeAll()
            self.tableView.reloadData()
            self.show(placeholderView: .empty)
            self.rightButtonEnable(enable: false)
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
            return
        }
        
        notifications = notis
        self.removePlaceholderViews()
        // By Kit Foong (hide footer when done refresh)
        self.tableView.mj_footer.endRefreshing()
        self.tableView.reloadData()
        self.rightButtonEnable(enable: true)
    }

    override func rightButtonClicked() {
        NIMSDK.shared().systemNotificationManager.deleteAllNotifications()
        refresh()
    }
    
    override func loadMore() {
        guard let notis = NIMSDK.shared().systemNotificationManager.fetchSystemNotifications(notifications.last, limit: maxNotificationCount, filter: filter), notis.count > 0 else {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
            return
        }
        notifications.append(contentsOf: notis)
        self.tableView.mj_footer.endRefreshing()
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupNotificationCell.cellIdentifier, for: indexPath) as! GroupNotificationCell
        cell.delegate = self
        cell.notification = notifications[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let notification = notifications[indexPath.row]
            NIMSDK.shared().systemNotificationManager.delete(notification)
            notifications.remove(at: indexPath.row)
            tableView.deleteRow(at: indexPath, with: .automatic)
        }
    }
}

extension GroupNotificationTableVC: GroupNotificationCellDelegate {
    
    func acceptDidTapped(_ cell: GroupNotificationCell, notification: NIMSystemNotification) {
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
                        if let indexPath = self.tableView.indexPath(for: cell) {
                            self.tableView.reloadRow(at: indexPath, with: .none)
                        }
                    }
                    return
                }
                
                notification.handleStatus = NotificationHandleType.ok.rawValue
                self.showTopIndicator(status: .success, "text_approved_success".localized)
                if let indexPath = self.tableView.indexPath(for: cell) {
                    let notification = self.notifications[indexPath.row]
                    NIMSDK.shared().systemNotificationManager.delete(notification)
                    self.notifications.remove(at: indexPath.row)
                    self.tableView.deleteRow(at: indexPath, with: .automatic)
                }
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
                        if let indexPath = self.tableView.indexPath(for: cell) {
                            self.tableView.reloadRow(at: indexPath, with: .none)
                        }
                    }
                    return
                }
                
                notification.handleStatus = NotificationHandleType.ok.rawValue
                self.showTopIndicator(status: .success, "text_accepted_success".localized)
                if let indexPath = self.tableView.indexPath(for: cell) {
                    let notification = self.notifications[indexPath.row]
                    NIMSDK.shared().systemNotificationManager.delete(notification)
                    self.notifications.remove(at: indexPath.row)
                    self.tableView.deleteRow(at: indexPath, with: .automatic)
                }
            }
        default:
            break
        }
    }
    
    func rejectDidTapped(_ cell: GroupNotificationCell, notification: NIMSystemNotification) {
        NIMSDK.shared().systemNotificationManager.markNotifications(asRead: notification)
        
        switch notification.type {
        case .teamApply:
            NIMSDK.shared().teamManager.rejectApply(toTeam: notification.targetID.orEmpty, userId: notification.sourceID.orEmpty, rejectReason: "") { error in
                if let error = error as NSError? {
                    if error.code == NIMRemoteErrorCode.codeTimeoutError.rawValue {
                        self.showTopIndicator(status: .faild, "network_problem".localized)
                    } else {
                        notification.handleStatus = NotificationHandleType.outOfDate.rawValue
                        self.showTopIndicator(status: .faild, "text_expired".localized)
                        if let indexPath = self.tableView.indexPath(for: cell) {
                            self.tableView.reloadRow(at: indexPath, with: .none)
                        }
                    }
                    return
                }
                notification.handleStatus = NotificationHandleType.no.rawValue
                self.showTopIndicator(status: .success, "text_reject_success".localized)
                if let indexPath = self.tableView.indexPath(for: cell) {
                    let notification = self.notifications[indexPath.row]
                    NIMSDK.shared().systemNotificationManager.delete(notification)
                    self.notifications.remove(at: indexPath.row)
                    self.tableView.deleteRow(at: indexPath, with: .automatic)
                }
            }
        case .teamInvite:
            NIMSDK.shared().teamManager.rejectInvite(withTeam: notification.targetID.orEmpty, invitorId: notification.sourceID.orEmpty, rejectReason: "") { error in
                if let error = error as NSError? {
                    if error.code == NIMRemoteErrorCode.codeTeamNotExists.rawValue {
                        self.showTopIndicator(status: .faild, "team_not_exist".localized)
                    } else if error.code == NIMRemoteErrorCode.codeTimeoutError.rawValue {
                        self.showTopIndicator(status: .faild, "network_problem".localized)
                    } else {
                        notification.handleStatus = NotificationHandleType.outOfDate.rawValue
                        self.showTopIndicator(status: .faild, "text_expired".localized)
                        if let indexPath = self.tableView.indexPath(for: cell) {
                            self.tableView.reloadRow(at: indexPath, with: .none)
                        }
                    }
                    return
                }
                
                notification.handleStatus = NotificationHandleType.no.rawValue
                self.showTopIndicator(status: .success, "text_reject_success".localized)
                if let indexPath = self.tableView.indexPath(for: cell) {
                    let notification = self.notifications[indexPath.row]
                    NIMSDK.shared().systemNotificationManager.delete(notification)
                    self.notifications.remove(at: indexPath.row)
                    self.tableView.deleteRow(at: indexPath, with: .automatic)
                }
            }
        default:
            break
        }
    }
    
    func headerDidTapped(notification: NIMSystemNotification) {
//        let vc = HomePageViewController(userId: 0, username: notification.sourceID.orEmpty, nickname: nil)
//        navigationController?.pushViewController(vc, animated: true)
        FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: 0, username: notification.sourceID.orEmpty, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
    }
}

extension GroupNotificationTableVC: NIMSystemNotificationManagerDelegate {
    
    func onReceive(_ notification: NIMSystemNotification) {
        self.notifications.insert(notification, at: 0)
        self.removePlaceholderViews()
        self.tableView.reloadData()
        self.rightButtonEnable(enable: true)
    }
}
