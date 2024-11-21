//
//  NTESChatListTableViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 29/04/2019.
//  Copyright © 2019 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper
import SwiftyJSON
//import NIMPrivate
import NIMSDK
import SVProgressHUD

class SessionListTableViewController: TSTableViewController {
    func messageUnreadCount(total: Int) {
        
    }
    
    var noticeCellModel: [NoticeConversationCellModel]
    private var conversationNotificationToken: NotificationToken?
    private let allMessages = DatabaseManager().chat.allMessages()
    private var messageListNotifictionToken: NotificationToken?
    weak var pViewController: ChatListViewController?
    var copyTableView: UITableView?
    
    /// 环信需要保存的数量
    var groupArray = NSMutableArray()
    var groupInfoDic = NSMutableDictionary()
    var conversationArray = [NIMRecentSession]()
    
    var searchChat: UISearchBar?
    /// 直接从数据库能拿到的用户信息的聊天会话
    var searchSession = [NIMRecentSession]()
    /// 没有存在于数据库里面的用户
    var searchNewUserIDArray = NSMutableArray()
    /// 需要请求用户信息接口拿到用户昵称去匹配搜索框关键字拿到的聊天会话
    var searchData = [SearchLocalHistoryObject]()
    /// 当前控制器是否显示
    var isCurrentVCAppear: Bool = false
    /// 是否出于搜索状态
    var isSearching: Bool = false
    
    /// 消息页以及子页面的头像尺寸
    let avatarSizeType = AvatarType.width38(showBorderLine: false)
    
    var friendSectionFirstLoad: Bool = false
    
    var searchUserList = [String]()
    var keyword:String = ""
    var searchLimit = 10
    var lastOption : NIMMessageSearchOption?
    
    var searchController: UISearchController?
    var searchResultController: UITableViewController?
    
    var supportsForceTouch: Bool = false
    
    var previews = NSMutableArray()
    
    var object : SearchLocalHistoryObject?
    
    var notificationList: [[String : Any]]?
    var p2PSessions = [String]()
    
    // refresh web log in header
    var isWebLoggedIn: Bool = false
    
    var totalCount = [Int]()
    
    // MARK: - lifecycle
    init(style: UITableView.Style, model: [NoticeConversationCellModel], isWebLoggedIn: Bool) {
        self.noticeCellModel = model
        self.isWebLoggedIn = isWebLoggedIn
        super.init(style: style)
        self.setupTableView()
        self.helperCallback()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("不支持xib")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .clear
        self.tableView.mj_footer = nil
        
        supportsForceTouch = traitCollection.forceTouchCapability == .available
        supportsForceTouch = false //关闭 3D touch
        NIMSDK.shared().conversationManager.add(self)
        NIMSDK.shared().loginManager.add(self)
        
        // 在需要显示搜索结果的时候再设置frame并添加至父视图
        copyTableView = UITableView()
        copyTableView?.delegate = self
        copyTableView?.dataSource = self
        copyTableView?.tableFooterView = UIView()
        copyTableView?.isHidden = true
        SessionUtil().synchronizeServiceToLocal()
        fetchRecentSession()
        synchronizeLocalToService()
        NotificationCenter.default.addObserver(self, selector: #selector(updateWebLoggedInHeader(notice:)), name: Notification.Name(rawValue: "isWebLoggedIn"), object: nil)
    }
    
    @objc func updateWebLoggedInHeader(notice: NSNotification) {
        guard let flag: Bool = (notice.userInfo?["isLogIn"] ?? false) as? Bool else { return }
        
        isWebLoggedIn = flag
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isCurrentVCAppear = true
        EventTrackingManager.instance.track(event: .viewChats)
        /// 简单判断下当前会话列表没有数据则请求下会话列表 主要用于第一次加载这个页面的时候请求环信聊天列表
        guard self.conversationArray.count == 0 else {
            return
        }
        self.tableView.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.isCurrentVCAppear = true
        super.viewWillAppear(animated)
        if self.conversationArray.count != 0 {
            refresh()
        }
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        // self.refreshRequestCount()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.isCurrentVCAppear = false
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NIMSDK.shared().conversationManager.remove(self)
        NIMSDK.shared().loginManager.remove(self)
        conversationNotificationToken?.invalidate()
        messageListNotifictionToken?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    func fetchRecentSession () {
        conversationArray = NIMSDK.shared().conversationManager.allRecentSessions() ?? []
        sort()
        if conversationArray.count == 0 {
            self.show(placeholderView: .emptyChat)
        } else {
            self.removePlaceholderViews()
        }
        self.tableView.mj_header.endRefreshing()
        self.tableView.reloadData()
        
    }
    /// 同步本地pinned 到服务器
    func synchronizeLocalToService(){
        let isSynchronize = UserDefaults.standard.bool(forKey: "session_pinned_isSynchronize")
//        if !isSynchronize {
//            conversationArray.forEach{ conversation in
//                if let session = conversation.session {
//                    let isTop = NTESSessionUtil.recentSessionIsMark(conversation, type: .top)
//                    if isTop {
//                        let params = NIMAddStickTopSessionParams(session: session)
//                        // 同步到服务器
//                        NIMSDK.shared().chatExtendManager.addStickTopSession(params) { [weak self] (error, newInfo) in
//                            
//                        }
//                    }
//                }
//            }
//            UserDefaults.standard.setValue(true, forKey: "session_pinned_isSynchronize")
//            SessionUtil().synchronizeServiceToLocal()
//            fetchRecentSession()
//        }
      
    }
    
    func filterP2PSession() {
        self.p2PSessions.removeAll()
        for recentSession in conversationArray {
            if let session = recentSession.session {
                if session.sessionType == .P2P {
                    self.p2PSessions.append(session.sessionId)
                }
            }
        }
        
        if self.p2PSessions.count == 0 {
            return
        }
        
        //更新好友信息
        NIMSDK.shared().userManager.fetchUserInfos(self.p2PSessions) { [weak self] (users, error) in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    func setupTableView() {
        tableView.register(ChatNotificationCell.nib(), forCellReuseIdentifier: ChatNotificationCell.cellReuseIdentifier)
        tableView.register(SearchMessageContentCell.nib(), forCellReuseIdentifier: SearchMessageContentCell.cellReuseIdentifier)
        tableView.register(SearchFriendCell.nib(), forCellReuseIdentifier: SearchFriendCell.cellReuseIdentifier)
        tableView.register(SearchSessionCell.nib(), forCellReuseIdentifier: SearchSessionCell.cellReuseIdentifier)
        tableView.register(TSConversationTableViewCell.nib(), forCellReuseIdentifier: TSConversationTableViewCell.cellReuseIdentifier)
        tableView.register(NoticeConversationCell.self, forCellReuseIdentifier: "NoticeConversationCell")
        tableView.separatorStyle = .none
    }
    
    func setupObserver () {
        NotificationCenter.default.addObserver(self, selector: #selector(updataGroupInfo), name: Notification.Name(rawValue: "editgroupnameorimage"), object: nil)
        
        // NotificationCenter.default.addObserver(self, selector: #selector(refreshRequestCount), name: Notification.Name(rawValue: "RefreshRequestCount"), object: nil)
    }
    
    private func helperCallback() {
        TeamDetailHelper.shared.onShowSuccess = { [weak self] msg in
            guard let self = self else { return }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
                //self.refresh()
            }
        }
        
        TeamDetailHelper.shared.onShowFail = { [weak self] msg in
            guard let self = self else { return }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.showError(message: msg ?? "")
            }
        }
    }
    
    @objc func refreshRequestCount () {
        let messageRequestCount = ChatMessageManager.shared.requestCount()
        
        let filter = NIMSystemNotificationFilter()
        filter.notificationTypes = [
            NSNumber(value: Int(NIMSystemNotificationType.teamInvite.rawValue)),
            NSNumber(value: Int(NIMSystemNotificationType.teamApply.rawValue))
        ]
        
        let notif = NIMSDK.shared().systemNotificationManager.fetchSystemNotifications(nil, limit: 20, filter: filter)
        let totalGroupInvitationCount = notif?.count
        
        let groupInvitation = [
            "title": "chat_notification_team_invitation".localized,
            "desp": totalGroupInvitationCount ?? 0 > 0 ? "recent_chat_group_invitation".localized : "notification_no_group_invitation".localized,
            "icon": "IMG_noti_group_invitation",
            "count": NSNumber(value: totalGroupInvitationCount ?? 0)
        ] as [String : Any]
        
        let messageRequest = [
            "title": "message_request_title".localized,
            "desp": messageRequestCount > 0 ? "recent_chat_msg_request".localized : "recent_chat_no_msg_request".localized,
            "icon": "notificationMessageRequest",
            "count": NSNumber(value: messageRequestCount)
        ] as [String : Any]
        
        
        let showMR = TSAppConfig.share.launchInfo?.showMessageRequest ?? false && messageRequestCount > 0
        let showNotif = totalGroupInvitationCount ?? 0 > 0
        
        notificationList = [[String : Any]]()
        if showMR {
            notificationList?.append(messageRequest)
        }
        
        if showNotif {
            notificationList?.append(groupInvitation)
        }
        tableView.reloadData()
    }
        
    @objc func isWebLoggedInTapped () {
//        let vc = NTESClientsTableViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func processConversations(_ indexPath: IndexPath) -> UITableViewCell {
        if isSearching {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: SearchFriendCell.cellReuseIdentifier) as! SearchFriendCell
                cell.userId = self.searchUserList[indexPath.row]
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: SearchSessionCell.cellReuseIdentifier) as! SearchSessionCell
                cell.session = self.searchSession[indexPath.row]
                return cell
            case 2 :
                let cell = tableView.dequeueReusableCell(withIdentifier: SearchMessageContentCell.cellReuseIdentifier) as! SearchMessageContentCell
                if searchData.count > 0 {
                    let object = searchData[indexPath.row]
                    cell.refresh(object: object)
                }
                return cell
            default:
                break
            }
        }
        
        if indexPath.row >= (notificationList?.count ?? 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: TSConversationTableViewCell.cellReuseIdentifier) as! TSConversationTableViewCell
            /// 区分是群还是单聊  群聊需要群头像群昵称  单聊要去拿聊天对象的头像昵称
            let conver: NIMRecentSession
            if isSearching {
                conver = self.searchSession[indexPath.row-(notificationList?.count ?? 0)]
            } else {
                let index = indexPath.row - (notificationList?.count ?? 0)
                /// 异常情况
                if self.conversationArray.count <= index {
                    return cell
                }
                conver = self.conversationArray[index]
            }
            cell.isnewUser = false
            cell.tag = indexPath.row
            cell.session = conver
            cell.delegate = self
            cell.currentIndex = indexPath.row
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ChatNotificationCell.cellReuseIdentifier) as! ChatNotificationCell
            cell.refresh(data: (notificationList?[indexPath.row])!)
            
            return cell
        }
    }
    
    func searchConversation(withKeyword keyword: String?) {
        isSearching = (keyword?.count ?? 0) > 0
        
        if searchSession.count > 0 {
            searchSession.removeAll()
        }
        
        self.keyword = keyword ?? ""
        let option = NIMMessageSearchOption()
        option.searchContent = self.keyword
        let uids = searchUsers(byKeyword: self.keyword, users: [])
        option.fromIds = uids as! [String]
        option.limit = UInt(searchLimit)
        //option.order = NTESBundleSetting.sharedConfig().localSearchOrderByTimeDesc ? NIMMessageSearchOrderDesc : NIMMessageSearchOrderAsc
        option.allMessageTypes = true
        lastOption = option
        showSearchData(option, loadMore: true)
    }
    
    func searchFriend(withKeyword keyword: String?, contacts: [String]?) {
        isSearching = (keyword?.count ?? 0) > 0
        
        if contacts!.count > 0 {
            searchUserList = contacts ?? []
        }
        
        tableView.separatorStyle = .singleLine
        self.tableView.reloadData()
    }
    
    func searchUsers(byKeyword keyword: String?, users: [AnyHashable]?) -> [AnyHashable]? {
        var data: [AnyHashable] = []
//        for uid in users ?? [] {
//            guard let uid = uid as? String else {
//                continue
//            }
//            //let info = NIMKit.shared()(byUser: uid, option: nil)
//            let info: NIMKitInfo = NIMBridgeManager.sharedInstance().getUserInfo(uid)
//            data.append(info)
//        }
//        let predicate = NSPredicate(format: "SELF.showName CONTAINS[cd] %@", keyword ?? "")
//        let array = (data as NSArray).filtered(using: predicate)
//        var output: [AnyHashable] = []
//        for info in array {
//            guard let info = info as? NIMKitInfo else {
//                continue
//            }
//            output.append(info.infoId)
//        }
        return data
    }
    
    func showSearchData(_ option: NIMMessageSearchOption?, loadMore: Bool) {
        NIMSDK.shared().conversationManager.searchAllMessages(option!) { (error, messages) in
            var array = [SearchLocalHistoryObject]()
            for msgArray in messages!.values {
                for message in msgArray {
                    let obj = SearchLocalHistoryObject(message: message)
                    obj.type = .searchLocalHistoryTypeContent
                    array.append(obj)
                }
            }
            
            if loadMore {
                self.searchData.append(contentsOf: array)
                self.tableView.tableFooterView = array.count == self.searchLimit ? self.tableView.tableFooterView : UIView()
            } else {
                array.append(contentsOf: self.searchData)
                self.searchData = array
            }
            
            self.searchSession =  self.conversationArray.filter { return self.getChatName(conver: $0).lowercased().contains(self.keyword.lowercased())}
            self.keyword = ""
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pViewController?.searchBar?.resignFirstResponder()
    }
    
    func netStatusChange(noti: NSNotification) {
        switch TSReachability.share.reachabilityStatus {
        case .WIFI, .Cellular:
            break
        case .NotReachable:
            break
        }
    }
    
    func uploadGroupInfoDicFromGroupInfoArray(groupInfoArray: NSArray, isInit: Bool) {
        if isInit == true {
            self.groupInfoDic.removeAllObjects()
        }
        for item in groupInfoArray {
            let groupDic = item as! NSDictionary
            let groupID = groupDic["id"] as! NSString
            self.groupInfoDic.setValue(groupDic, forKey: groupID as String)
        }
    }
    
    // MARK: - 更新本地群缓存
    func uploadLocaGroupInfoFile(infos: NSArray) {
        for info in infos {
            let infoDic = info as! NSDictionary
            let infoID = infoDic["id"] as! String
            self.groupInfoDic.setValue(infoDic, forKey: infoID)
        }
        // 保存到本地
        let json = JSON(self.groupInfoDic)
        let patch = NSHomeDirectory() + "/Documents/groupInfo.data"
        try! FileManager.default.createFile(atPath: patch, contents: json.rawData(), attributes: nil)
    }
    
    // MARK: - 接收到修改群头像和群名称的通知;退群以及解散群 改变数据源（不刷新就改变数据源）(这段代码很冗余，望后继者优化 =。=)
    @objc func updataGroupInfo(notice: Notification) {
        refresh()
    }
    
    // MARK: - 搜索会话
    func searchChatList(keyWord: String) {
        if keyWord.isEmpty {
            isSearching = false
            copyTableView?.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        } else {
            self.searchSession.removeAll()
            if self.copyTableView?.superview == nil {
                self.copyTableView?.frame = self.tableView.frame
                self.pViewController?.view.addSubview(copyTableView!)
            }
            for item in self.conversationArray {
                let chatName = self.getChatName(conver: item).lowercased()
                if (chatName.range(of: keyWord.lowercased())) != nil {
                    self.searchSession.append(item)
                }
            }
            self.isSearching = true
            self.tableView.isHidden = true
        }
    }
    
    /// 获取显示的昵称(单聊&&群聊)
    func getChatName(conver: NIMRecentSession) -> String {
        var chatName = ""
        if conver.session?.sessionType == .P2P {
            chatName = ""
        } else {
            chatName = NIMSDK.shared().teamManager.team(byId: conver.session?.sessionId ?? "")?.teamName ?? ""
        }
        return chatName
    }
    
    /// 获取时间戳
    /// - Returns: 返回时间戳
    func getTimeStamp() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1_000)
    }
    
    private func showChatRoom(with session: NIMSession, unread: Int) {
        let vc = IMChatViewController(session: session, unread: unread)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onDeleteRecent(atIndexPath recent: NIMRecentSession?, at indexPath: IndexPath?) {
//        let isTop = NTESSessionUtil.recentSessionIsMark(recent, type: .top)
//        if isTop, let session = recent?.session {
//            let params = NIMStickTopSessionInfo()
//            params.session = session
//            NIMSDK.shared().chatExtendManager.removeStickTopSession(params) { [weak self] (error, newInfo) in
//            }
//        }
//        weak var manager = NIMSDK.shared().conversationManager
//        manager?.delete(recent!)
        
    }
    
    func onTopRecent(atIndexPath recent: NIMRecentSession?, at indexPath: IndexPath?, isTop: Bool) {
        guard let session = recent?.session  else {
            return
        }

//        if isTop {
//            NTESSessionUtil.removeRecentSessionMark(recent?.session, type: .top)
//            let params = NIMStickTopSessionInfo()
//            params.session = session
//            NIMSDK.shared().chatExtendManager.removeStickTopSession(params) { [weak self] (error, newInfo) in
//                DispatchQueue.main.async{
//                    self?.sort()
//                    self?.tableView.reloadData()
//                }
//            }
//            
//        } else {
//            NTESSessionUtil.addRecentSessionMark(recent?.session, type: .top)
//            let params = NIMAddStickTopSessionParams(session: session)
//            // 调用添加置顶会话的方法
//            NIMSDK.shared().chatExtendManager.addStickTopSession(params) { [weak self] (error, newInfo) in
//                DispatchQueue.main.async{
//                    self?.sort()
//                    self?.tableView.reloadData()
//                }
//            }
//        }
        
    }
    
    func needNotifyForUser(sessionId: String) -> Bool {
        return NIMSDK.shared().userManager.notify(forNewMsg: sessionId)
    }
    
    func needNotifyForGroup(sessionId: String) -> NIMTeamNotifyState  {
        return NIMSDK.shared().teamManager.notifyState(forNewMsg: sessionId)
    }
    
    func onMutePersonalNotification(needNotify : Bool, sessionId: String) {
        SVProgressHUD.show(withStatus: NSLocalizedString("loading", comment: ""))
        NIMSDK.shared().userManager.updateNotifyState(needNotify, forUser: sessionId) { [weak self] (error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                if(error != nil) {
                   // self.view.makeToast(NSLocalizedString("operation_failed", comment: ""), duration: 2, position: CSToastPositionCenter)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func onMuteGroupNotifiction(isMuted: Bool, teamId: String) {
        SVProgressHUD.show(withStatus: NSLocalizedString("loading", comment: ""))
        TeamDetailHelper.shared.muteNotification(isMute: isMuted, sessionId: teamId)
    }
}

// MARK: TSTableView Delegate
extension SessionListTableViewController {
    override func refresh() {
        fetchRecentSession()
        filterP2PSession()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateBadge"), object: nil, userInfo: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? 3 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            switch section {
            case 0:
                return self.searchUserList.count
            case 1:
                return self.searchSession.count
            case 2:
                return self.searchData.count
            default:
                return 0
            }
        } else {
            return self.conversationArray.count + (notificationList?.count ?? 0)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return processConversations(indexPath)
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearching {
            switch section {
            case 0:
                if friendSectionFirstLoad == false && searchUserList.count > 0 {
                    return 30
                }
            case 1:
                if searchSession.count > 0 {
                    return 30
                }
            case 2:
                if searchData.count > 0 {
                    return 30
                }
            default:
                return 0
            }
        } else if isWebLoggedIn {
            return 40
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isSearching {
            switch section {
            case 0:
                if searchUserList.count > 0 && (searchSession.count > 0) {
                    return 15
                }
            case 1:
                if searchSession.count > 0 && searchSession.count > 0 {
                    return 15
                }
            case 2:
                break
            default:
                break
            }
        }
        return 0.01
    }
    
    //    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    //        if isSearching {
    //            return nil
    //        } else {
    //            if indexPath.row >= (notificationList?.count ?? 0) {
    //                let recentSession = self.conversationArray[indexPath.row]
    //                var name = ""
    //                if let realSession = recentSession.session {
    //                    if realSession.sessionType == NIMSessionType.team {
    //                        name = NIMSDK.shared().teamManager.team(byId: realSession.sessionId ?? "")?.teamName ?? ""
    //                    } else {
    //                        name = NIMKitUtil.showNick(realSession.sessionId, in: realSession)
    //                    }
    //                }
    //
    //                let nameStr = String(format: "main_msg_list_delete_chatting_confirmation".localized, name)
    //
    //                let delete = UITableViewRowAction(style: .default, title: "choice_delete".localized) { (action, indexPath) in
    //                    DependencyContainer.shared.resolveViewControllerFactory().makeIMDeleteTSAlertController(name: nameStr, parentVC: self, title: "main_msg_list_delete_chatting".localized) { delete in
    //                        if delete {
    //                            self.onDeleteRecent(atIndexPath: recentSession, at: indexPath)
    //                            self.tableView.setEditing(false, animated: true)
    //                        }
    //                    }
    //
    //
    //                }
    //
    //                let isTop = NTESSessionUtil.recentSessionIsMark(recentSession, type: .top)
    //
    //                let top = UITableViewRowAction(style: .normal, title: isTop ? "main_msg_list_clear_sticky_on_top".localized : "main_msg_list_sticky_on_top".localized) { (action, indexPath) in
    //                    self.onTopRecent(atIndexPath: recentSession, at: indexPath, isTop: isTop)
    //                    self.tableView.setEditing(false, animated: true)
    //                }
    //                return [delete,top]
    //            }
    //
    //            return nil
    //        }
    //    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if isSearching {
            return nil
        } else {
            if indexPath.row >= (notificationList?.count ?? 0) {
                let recentSession = self.conversationArray[indexPath.row]
                var name = ""
//                if let realSession = recentSession.session {
//                    if realSession.sessionType == NIMSessionType.team {
//                        name = NIMSDK.shared().teamManager.team(byId: realSession.sessionId ?? "")?.teamName ?? ""
//                    } else {
//                        name = NIMKitUtil.showNick(realSession.sessionId, in: realSession)
//                    }
//                }
                let nameStr = String(format: "main_msg_list_delete_chatting_confirmation".localized, name)
                
                let delete = UIContextualAction(style: .destructive, title: "choice_delete") { (action, sourceView, completionHandler) in
                    DependencyContainer.shared.resolveViewControllerFactory().makeIMDeleteTSAlertController(name: nameStr, parentVC: self, title: "main_msg_list_delete_chatting".localized) { delete in
                        if delete {
                            self.onDeleteRecent(atIndexPath: recentSession, at: indexPath)
                            self.tableView.setEditing(false, animated: true)
                        }
                    }
                    
                    completionHandler(true)
                }
                delete.backgroundColor = UIColor(hex: 0xED1A3B)
                let deleteLabel = UILabel()
                deleteLabel.text = "choice_delete".localized
                deleteLabel.sizeToFit()
                deleteLabel.textColor = .white
                if let deleteImage = UIImage.set_image(named: "iconsDeleteWhite") {
                    delete.image = resizeActionRow(image: deleteImage, label: deleteLabel)
                }
                
//                let isTop = NTESSessionUtil.recentSessionIsMark(recentSession, type: .top)
//                let top = UIContextualAction(style: .normal, title: isTop ? "main_msg_list_clear_sticky_on_top".localized : "main_msg_list_sticky_on_top".localized) { [weak self] (action, sourceView, completionHandler)  in
//                    self?.onTopRecent(atIndexPath: recentSession, at: indexPath, isTop: isTop)
//                    self?.tableView.setEditing(false, animated: true)
//                    completionHandler(true)
//                }
                let pinLabel = UILabel()
//                pinLabel.text = isTop ? "main_msg_list_clear_sticky_on_top".localized : "main_msg_list_sticky_on_top".localized
//                pinLabel.sizeToFit()
//                pinLabel.textColor = .white
//                if let pinImage = UIImage.set_image(named: "iconsPinWhite"){
//                    top.image = resizeActionRow(image: pinImage, label: pinLabel)
//                }
//                if isTop {
//                    if let pinImage = UIImage.set_image(named: "iconsUnpinWhite") {
//                        top.image = resizeActionRow(image: pinImage, label: pinLabel)
//                    }
//                } else {
//                    if let unpinImage = UIImage.set_image(named: "iconsPinWhite") {
//                        top.image = resizeActionRow(image: unpinImage, label: pinLabel)
//                    }
//                }
//                top.backgroundColor = UIColor(hex: 0xFFB516)
                
                let mute = UIContextualAction(style: .normal, title: "") { [weak self] (action, sourceView, completionHandler) in
                    if recentSession.session?.sessionType == .team {
                        if let realSession = recentSession.session {
                            if let needNotify = self?.needNotifyForGroup(sessionId: realSession.sessionId) {
                                var isMute: Bool = false
                                if needNotify.rawValue == 1 {
                                    isMute = false
                                } else {
                                    isMute = true
                                }
                                self?.onMuteGroupNotifiction(isMuted: isMute, teamId: realSession.sessionId)
                            }
                        }
                    } else {
                        if let realSession = recentSession.session {
                            if let needNotify = self?.needNotifyForUser(sessionId: realSession.sessionId) {
                                var isMute: Bool = false
                                if needNotify {
                                    isMute = false
                                } else {
                                    isMute = true
                                }
                                self?.onMutePersonalNotification(needNotify: isMute, sessionId: realSession.sessionId)
                            }
                        }
                    }
                    completionHandler(true)
                }
                mute.backgroundColor = UIColor(hex: 0x808080)
                let muteLabel = UILabel()
                guard let realSession = recentSession.session else {return nil}
                if recentSession.session?.sessionType == .team {
                    let isMute = self.needNotifyForGroup(sessionId: realSession.sessionId)
                    muteLabel.text = isMute.rawValue == 0 ? "mute".localized : "unmute".localized
                    muteLabel.sizeToFit()
                    muteLabel.textColor = .white
                    if isMute.rawValue == 0 {
                        if let volumeImage = UIImage.set_image(named: "mute_white") {
                            mute.image = resizeActionRow(image: volumeImage, label: muteLabel)
                        }
                    } else {
                        if let volumeImage = UIImage.set_image(named: "unmute_white") {
                            mute.image = resizeActionRow(image: volumeImage, label: muteLabel)
                        }
                    }
                } else {
                    let isMute = self.needNotifyForUser(sessionId: realSession.sessionId)
                    muteLabel.text = isMute ? "mute".localized : "unmute".localized
                    muteLabel.sizeToFit()
                    muteLabel.textColor = .white
                    
                    if isMute {
                        if let volumeImage = UIImage.set_image(named: "mute_white") {
                            mute.image = resizeActionRow(image: volumeImage, label: muteLabel)
                        }
                    } else {
                        if let volumeImage = UIImage.set_image(named: "unmute_white") {
                            mute.image = resizeActionRow(image: volumeImage, label: muteLabel)
                        }
                    }
                }
                
//                let swipeAction = UISwipeActionsConfiguration(actions: [delete, top, mute])
//                swipeAction.performsFirstActionWithFullSwipe = false
//                return swipeAction
            }
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isSearching {
            switch indexPath.section {
            case 0:
                if friendSectionFirstLoad == false && searchUserList.count > 0 {
                    return kTSConversationTableViewCellDefaltHeight
                }
            case 1:
                if searchSession.count > 0 {
                    return kTSConversationTableViewCellDefaltHeight
                    
                }
            case 2:
                if searchData.count > 0 {
                    let object = searchData[indexPath.row]
                    return object.uiHeight
                }
            default:
                break
            }
            return kTSConversationTableViewCellDefaltHeight
        }
        return kTSConversationTableViewCellDefaltHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.tableView.mj_header.isRefreshing == true {
            return
        }
        /// 调试用环信详情页
        let chatCell: TSConversationTableViewCell? = tableView.cellForRow(at: indexPath) as? TSConversationTableViewCell
        chatCell?.countButtton.isHidden = true
        
        let chatConversation: NIMRecentSession
        if isSearching {
            switch indexPath.section {
            case 0:
                let session = NIMSession(self.searchUserList[indexPath.row], type: .P2P)
//                let vc = IMChatViewController(session: session, unread: 0)
//                self.navigationController?.pushViewController(vc, animated: true)
                self.showChatRoom(with: session, unread: 0)
                break
            case 1:
                chatConversation = self.searchSession[indexPath.row]
                if let session = chatConversation.session {
                    showChatRoom(with: session, unread: chatConversation.unreadCount)
                    NIMSDK.shared().conversationManager.markAllMessagesRead(in: session)
                }
                break
            case 2:
                if let session = self.searchData[indexPath.row].message?.session {
//                    let vc = IMChatViewController(session: session, unread: 0)
//                    self.navigationController?.pushViewController(vc, animated: true)
                    self.showChatRoom(with: session, unread: 0)
                }
                break
            default:
                break
            }
        } else {
            if indexPath.row >= (notificationList?.count ?? 0) {
                chatConversation = self.conversationArray[indexPath.row-(notificationList?.count ?? 0)]
                if let session = chatConversation.session {
                    showChatRoom(with: session, unread: chatConversation.unreadCount)
                    NIMSDK.shared().conversationManager.markAllMessagesRead(in: session)
                }
            } else {
                if let detailTitle = notificationList?[indexPath.row]["title"] as? String {
                    if detailTitle == "chat_notification_team_invitation".localized {
                        let vc = GroupNotificationTableVC()
                        navigationController?.pushViewController(vc, animated: true)
                    } else if detailTitle == "message_request_title".localized {
                        let vc = MessageRequestListTableViewController()
                        navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isSearching {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 30))
            headerView.backgroundColor = UIColor.white
            let label = UILabel(frame: CGRect(x: 16, y: 0, width: headerView.width, height: headerView.height))
            label.font = UIFont.boldSystemFont(ofSize: 14)
            label.textColor = UIColor(hex: 0xF6F6F6)
            
            switch section {
            case 0:
                label.text = "friends".localized
            case 1:
                label.text = "conversations".localized
            case 2:
                label.text = "messages".localized
            default:
                break
            }
            headerView.addSubview(label)
            return headerView
        } else {
            if isWebLoggedIn {
                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 40))
                headerView.backgroundColor = UIColor(hex: 0xefefef)
                let label = UILabel(frame: CGRect(x: 16, y: 0, width: headerView.width, height: headerView.height))
                label.font = UIFont.systemRegularFont(ofSize: 14)
                label.textColor = UIColor.lightGray
                label.text = String(format: "multiport_logged_in".localized, "rw_multiport_platform_web".localized)
                
                let imageView = UIImageView(frame: CGRect(x: headerView.width - 25, y: 8, width: 25, height: 25))
                imageView.image = UIImage.set_image(named: "ic_calendar_right_angle")
                imageView.contentMode = .scaleAspectFit
                
                headerView.addSubview(label)
                headerView.addSubview(imageView)
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(isWebLoggedInTapped))
                headerView.addGestureRecognizer(tap)
                
                return headerView
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if supportsForceTouch && !isSearching && indexPath.row >= (notificationList?.count ?? 0){
            let preview = registerForPreviewing(with: self, sourceView: cell)
            previews[indexPath.row - (notificationList?.count ?? 0)] = preview
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if supportsForceTouch && !isSearching && indexPath.row >= (notificationList?.count ?? 0) {
            weak var preview = previews[indexPath.row - (notificationList?.count ?? 0)] as? UIViewControllerPreviewing
            guard let previewCell = preview else { return }
            unregisterForPreviewing(withContext: previewCell)
            previews.remove(indexPath.row)
        }
    }
}

// MARK: - TSConversation TableViewCell Delegate
extension SessionListTableViewController: TSConversationTableViewCellDelegate {
    func headButtonDidPress(for userId: Int) {
        /// 调试用环信详情页
        let indexpath: NSIndexPath = NSIndexPath(row: userId, section: 0)
        let chatCell: TSConversationTableViewCell? = tableView.cellForRow(at: indexpath as IndexPath) as? TSConversationTableViewCell
        chatCell?.countButtton.isHidden = true
        var chatConversation: NIMRecentSession
        if isSearching {
            chatConversation = self.searchSession[userId]
        } else {
            chatConversation = self.conversationArray[userId]
            
            if indexpath.row >= (notificationList?.count ?? 0) {
                chatConversation = self.conversationArray[indexpath.row-(notificationList?.count ?? 0)]
                if let session = chatConversation.session {
                    showChatRoom(with: session, unread: chatConversation.unreadCount)
                    NIMSDK.shared().conversationManager.markAllMessagesRead(in: session)
                }
            } else {
                if let detailTitle = notificationList?[indexpath.row]["title"] as? String {
                    if detailTitle == "chat_notification_team_invitation".localized {
                        let vc = GroupNotificationTableVC()
                        navigationController?.pushViewController(vc, animated: true)
                    } else if detailTitle == "message_request_title".localized {
                        let vc = MessageRequestListTableViewController()
                        navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            
            if (self.conversationArray[indexpath.row].session!.sessionType == NIMSessionType.P2P) {
                
                FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: 0, username: self.conversationArray[indexpath.row].session!.sessionId, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
               // let userHomPage = HomePageViewController(userId: 0, username: self.conversationArray[indexpath.row].session!.sessionId)

                //TSHomepageVC(0,userName: self.conversationArray[indexpath.row].session!.sessionId)
               // self.navigationController?.pushViewController(userHomPage, animated: true)
            }
        }
    }
}

extension SessionListTableViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        let touchCell = previewingContext.sourceView as? UITableViewCell
        if (touchCell != nil) {
            var indexPath: IndexPath? = nil
            if let touchCell = touchCell {
                indexPath = tableView.indexPath(for: touchCell)
            }
            if let session = self.conversationArray[(indexPath?.row ?? 0) - (notificationList?.count ?? 0)].session {
//                let vc = IMChatViewController(session: session, unread: 0)
//                navigationController?.show(vc, sender: nil)
                self.showChatRoom(with: session, unread: 0)
            }
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let touchCell = previewingContext.sourceView as? UITableViewCell
        
        let indexPath = self.tableView.indexPath(for: touchCell!)
        let recent = self.conversationArray[indexPath!.row]
        let nav = SessionPeekNavigationViewController.instance(recent.session)
        
        return nav
    }
}

extension SessionListTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.keyword = searchController.searchBar.text ?? ""
        self.searchConversation(withKeyword: self.keyword)
    }
}

extension SessionListTableViewController: NIMLoginManagerDelegate {
    func onLogin(_ step: NIMLoginStep) {
        
    }
}

extension SessionListTableViewController: NIMConversationManagerDelegate {
    func didAdd(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        self.conversationArray.append(recentSession)
        sort()
        tableView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateBadge"), object: nil, userInfo: nil)
    }
    
    func didUpdate(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        self.conversationArray = self.conversationArray.map {
            var session = $0
            if $0.session?.sessionId == recentSession.session?.sessionId {
                session = recentSession
            }
            return session
        }
        sort()
        tableView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateBadge"), object: nil, userInfo: nil)
    }
    
    func didRemove(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        self.conversationArray.removeAll(where: { $0.session?.sessionId == recentSession.session?.sessionId })
        if let session = recentSession.session {
            NIMSDK.shared().conversationManager.deleteRemoteSessions([session], completion: nil)
        }
        tableView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateBadge"), object: nil, userInfo: nil)
    }
    
    func didLoadAllRecentSessionCompletion() {
        sort()
        tableView.reloadData()
    }
    
    func messagesDeleted(in session: NIMSession) {
        refresh()
    }
    
    func allMessagesDeleted() {
        refresh()
    }
    
    func allMessagesRead() {
        refresh()
    }
    
    private func sort() {
        var emptyTextArray: [NIMRecentSession] = []
        var notEmptyArray: [NIMRecentSession] = []

        for var item in self.conversationArray {
            if let message = item.lastMessage, let text = message.text, text.isEmpty {
                if message.messageType != .text {
                    notEmptyArray.append(item)
                } else {
                    emptyTextArray.append(item)
                }
            } else {
                notEmptyArray.append(item)
            }
        }
        
        self.conversationArray = notEmptyArray
        
//        self.conversationArray = self.conversationArray.sorted(by: {
//            var score = NTESSessionUtil.recentSessionIsMark($0, type: .top) ? 10 : 0
//            var score2 = NTESSessionUtil.recentSessionIsMark($1, type: .top) ? 10 : 0
//            
//            if let firstTimeStamp = $0.lastMessage?.timestamp, let secondTimeStamp = $1.lastMessage?.timestamp {
//                if firstTimeStamp > secondTimeStamp {
//                    score += 1
//                }
//                
//                if firstTimeStamp < secondTimeStamp {
//                    score2 += 1
//                }
//                
//                if score == score2 {
//                    return true
//                }
//                                
//                return score > score2
//            }
//            
//            return false
//        })
        
        self.conversationArray.append(contentsOf: emptyTextArray)
    }
}

extension SessionListTableViewController {
    private func resizeActionRow(image: UIImage, label: UILabel) -> UIImage? {
        let tempView = UIStackView(frame: CGRect(x: 0, y: 0, width: 80, height: 50))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.height))
        tempView.axis = .vertical
        tempView.alignment = .center
        tempView.spacing = 8
        imageView.image = image
        tempView.addArrangedSubview(imageView)
        tempView.addArrangedSubview(label)
        let renderer = UIGraphicsImageRenderer(bounds: tempView.bounds)
        let image = renderer.image { rendererContext in
            tempView.layer.render(in: rendererContext.cgContext)
        }
        return image
    }
}
