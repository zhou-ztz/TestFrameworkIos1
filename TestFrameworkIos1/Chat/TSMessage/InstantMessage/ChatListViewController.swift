//
//  ChatListViewController.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2018/1/3.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Contacts
import NIMSDK

private let heightOfSearchBar: CGFloat = 47
private let heightOfTitleBar: CGFloat = 30

class ChatListViewController: TSViewController, UISearchBarDelegate {

    /// IM第二版聊天列表页面
    var chatListVC: SessionListTableViewController!
    var superViewController: NewMessageViewController!
    /// 搜索框
    var searchBar: TSSearchBar?
    private var contactsPickerVC: ContactsPickerViewController?
    //弹窗是否显示
    //var chooseOpen: Bool = false
    var isWebLoggedIn: Bool = false
   
    lazy var floatyBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.set_image(named: "iconsNewchatWhite"))
        btn.backgroundColor = TSColor.main.theme
        return btn
    }()
    
    private var headerTitle: UILabel!
    private var msgRequestButton: UIButton!
    
    lazy private var bgView: UIView = {
        let view = UIView()
        self.view.backgroundColor = TSColor.inconspicuous.background
        var frame = UIScreen.main.bounds
        view.frame = frame
        return view
    }()
    private var shouldBeginEditing: Bool = true
    private var friendList: [ContactData] = []
    private var filteredFriendList: [String] = []
    var badge = UIView()
        
    private lazy var searchThrottler = {
        return Throttler(time: .seconds(3.0), queue: .main, mode: .fixed, immediateFire: true) { [unowned self] in
            
            self.fetchFriends {
                self.chatListVC.friendSectionFirstLoad = false
                self.fetchRecentChats {
                    self.chatListVC.searchFriend(withKeyword: self.searchBar?.text ?? "", contacts: self.filteredFriendList)
                }

            }
        }
    }()
    //var chooseView: TSChooseView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshAfterTeenChanged()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        searchBar?.resignFirstResponder()
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.chatListVC = SessionListTableViewController(style: .grouped, model: [NoticeConversationCellModel(title: "", content: "", badgeCount: 12, date: Date(), image: "ic_map")], isWebLoggedIn: isWebLoggedIn)
        
        //setSearchBarUI()
//        self.chatListVC = NTESSessionListViewController()
        self.chatListVC.hideShimmer(hide: true)
        self.addChild(chatListVC)
        chatListVC.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height )
        self.view.addSubview(chatListVC.view)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshRemarkName), name: Notification.Name(rawValue: "RefreshRemarkName"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAfterTeenChanged), name: Notification.Name.DashBoard.teenModeChanged, object: nil)
        shouldBeginEditing = true
        
        self.view.addSubview(floatyBtn)
        
        floatyBtn.layer.cornerRadius = 53.0 / 2.0
        floatyBtn.layer.shadowOffset = CGSize(width: 1, height: 1)
        floatyBtn.layer.shadowRadius = 2
        floatyBtn.layer.shadowColor = UIColor.black.cgColor
        floatyBtn.layer.shadowOpacity = 0.4
        floatyBtn.addTarget(self, action: #selector(floatyAction(_:)), for: .touchUpInside)
        floatyBtn.isHidden = true
//        badge.backgroundColor = TSColor.main.warn
//        badge.clipsToBounds = true
//        badge.layer.cornerRadius = 4
//        badge.isHidden = true
//        floatyBtn.addSubview(badge)
//        badge.snp.makeConstraints { (make) in
//            make.width.height.equalTo(8)
//            make.top.equalTo(4)
//            make.right.equalTo(-4)
//        }
        
        fetchRecentChats { }
        
        self.getRequestCountStatus()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        floatyBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo( -39 - TSBottomSafeAreaHeight)
            make.right.equalTo(-16)
            make.width.height.equalTo(53)
        }

        self.view.layer.layoutIfNeeded()
    }
    
    override func placeholderButtonDidTapped() {
        let vc = TeenModeViewController()
        vc.onGetSecurityPin = { [weak self] code in
            guard let self = self else { return }
            NotificationCenter.default.post(name: Notification.Name.DashBoard.teenModeChanged, object: nil)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func fetchFriends(_ completion: @escaping EmptyClosure) {
        TSUserNetworkingManager().friendList(offset: 0, keyWordString: searchBar?.text, complete: { [weak self] (userModels, networkError) in
            
            guard let self = self else {
                return
            }
            
            // 获取数据失败
            if networkError != nil {
                return
            }
            
            // 获取数据成功
            guard var datas = userModels else {
                completion()
                return
            }
            
            userModels?.enumerated().forEach { (index, userInfo) in
                if userInfo.isBannedUser {
                    let bannedUsername = String(format: "user_deleted_displayname".localized,userInfo.name)
                    datas[index].name = bannedUsername
                }
            }
            self.friendList = datas.compactMap {
                ContactData(model: $0)
            }
            completion()
        })
    }
    
    func setSearchBarUI() {
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: heightOfSearchBar))
        bgView.backgroundColor = UIColor.white
        self.view.addSubview(bgView)
        self.searchBar = TSSearchBar(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: bgView.height))
        self.searchBar?.layer.masksToBounds = true
        self.searchBar?.layer.cornerRadius = 5.0
        self.searchBar?.backgroundImage = nil
        self.searchBar?.backgroundColor = UIColor.white
        self.searchBar?.returnKeyType = .search
        self.searchBar?.barStyle = UIBarStyle.default
        self.searchBar?.barTintColor = UIColor.clear
        self.searchBar?.tintColor = TSColor.main.theme
        self.searchBar?.searchBarStyle = UISearchBar.Style.minimal
        self.searchBar?.delegate = self
        self.searchBar?.placeholder = "placeholder_search_message".localized
        bgView.addSubview(self.searchBar!)
        self.bgView.origin.y += bgView.frame.height
    }

    static func pasteNiticeModel() -> [NoticeConversationCellModel] {
        if TSCurrentUserInfo.share.isLogin == false {
            return []
        } else {
            let unreadInfo = TSCurrentUserInfo.share.unreadCount
            let systemModel = NoticeConversationCellModel(title: "chat_notification_system".localized, content: unreadInfo.commentsUsers ?? "chat_no_notification_system".localized, badgeCount: unreadInfo.comments, date: unreadInfo.commentsUsersDate, image: "ico_message_systerm")
            let commentModel = NoticeConversationCellModel(title: "chat_notification_comment".localized, content: unreadInfo.commentsUsers ?? "notification_no_comment_received".localized, badgeCount: unreadInfo.comments, date: unreadInfo.commentsUsersDate, image: "IMG_message_comment")
            let likeModel = NoticeConversationCellModel(title: "chat_notification_liked".localized, content: unreadInfo.likedUsers ?? "notification_no_like_received".localized, badgeCount: unreadInfo.like, date: unreadInfo.likeUsersDate, image: "IMG_message_good")
            let pendModel = NoticeConversationCellModel(title: "review_notificaiton".localized, content: unreadInfo.pendingUsers ?? "display_no_pending_application_placeholder".localized, badgeCount: unreadInfo.pending, date: unreadInfo.pendingUsersDate, image: "IMG_ico_message_check")

            return [systemModel, commentModel, likeModel, pendModel]
        }
    }
    
    private func getRequestCountStatus() {
//        LaunchManager.shared.updateLaunchConfigInfo { (status) in
//            DispatchQueue.main.async {
//                if status == true {
//                    MessageRequestNetworkManager().getMessageReqCount()
//                }
//            }
//        }
    }
    
    private func updateRequestCount() {

        var posY:CGFloat = heightOfSearchBar
        let tabBarHeight = self.tabBarController?.tabBar.height ?? 0
        if (self.searchBar?.text?.isEmpty ?? true) {
            posY = heightOfSearchBar
        }
        DispatchQueue.main.async {
            self.chatListVC.view.frame = CGRect(x: 0, y: posY, width: UIScreen.main.bounds.size.width, height: self.view.bounds.size.height - posY - tabBarHeight)
        }
    }
    
    private func fetchRecentChats(_ completion: @escaping EmptyClosure) {
        if let recents = NIMSDK.shared().conversationManager.allRecentSessions() {
            
            var tempRecentChatData = [ContactData]()

            let sessionIds = recents.filter { $0.session?.sessionType == .P2P }.compactMap { $0.session?.sessionId }
            
            sessionIds.forEach {
                let data = ContactData(userName: $0)
                tempRecentChatData.append(data)
            }
            
            let friendUserList = self.friendList.compactMap { $0.userName }
            let chatDataUserList = tempRecentChatData.compactMap { $0.userName }
            
            self.filteredFriendList = friendUserList.filter { !chatDataUserList.contains($0) }
            
            completion()
        }
    }
    
    private func friendListSearching() {
        self.chatListVC.friendSectionFirstLoad = true
        self.chatListVC.searchUserList = []
        self.searchThrottler.call()
    }
    
    @objc func refreshAfterTeenChanged() {
        if UserDefaults.teenModeIsEnable {
            self.show(placeholder: .teenMode)
        } else {
            self.removePlaceholderView()
        }
    }
    
    // MARK: - floatyAction
    @objc func floatyAction(_ sender: UIButton){
        EventTrackingManager.instance.track(event: .viewContacts)
        contactsPickerVC = ContactsPickerViewController(configuration: ContactsPickerConfig.selectFriendToChatConfig(), finishClosure: nil)
        contactsPickerVC?.isCreatNewChat = true
        contactsPickerVC?.finishClosure = { [weak self] contacts in
            guard let self = self else { return }
            guard contacts.count > 0 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                if contacts.count > 1 {
                    self.createTeam(contacts.map { $0.userName })
                } else {
                    let session = NIMSession(contacts[0].userName, type: .P2P)
                    self.createChatRoom(with: session)
                }
            }
            
            let msgCount = ChatMessageManager.shared.requestCount()
            let requestList = MessageRequestRealmManager().getChatRequest()
            let filter = NIMSystemNotificationFilter()
            filter.notificationTypes = [NSNumber(nonretainedObject: NIMSystemNotificationType.teamInvite), NSNumber(nonretainedObject: NIMSystemNotificationType.teamApply)]
            let notif = NIMSDK.shared().systemNotificationManager.fetchSystemNotifications(nil, limit: 20, filter: filter)
            let groupInvateCount = notif?.count
            let count = msgCount > 0 ? msgCount : requestList.count
            print("msgCount = \(msgCount), count = \(count), request list = \(requestList.count), group Invate count = \(groupInvateCount)")
            
            self.view.layer.layoutIfNeeded()
        }
        self.heroPush(contactsPickerVC!)
        
    }
    
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        chatListVC.searchConversation(withKeyword: searchBar.text ?? "")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.friendListSearching()
        chatListVC.searchConversation(withKeyword: searchBar.text ?? "")
        
        if searchBar.isFirstResponder == false {
            shouldBeginEditing = false
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.setChatListY(newY: heightOfSearchBar)
        self.view.addSubview(bgView);
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.setChatListY(newY: heightOfSearchBar)
        bgView.removeFromSuperview()
    }
    
    //To show/hide message request view
    private func setChatListY(newY: CGFloat) {
        let tabBarHeight = self.tabBarController?.tabBar.height ?? 0
        var newRect: CGRect = self.chatListVC.view.frame
        newRect.origin.y = newY
        newRect.size.height = self.view.bounds.size.height - newY - tabBarHeight
        self.chatListVC.view.frame = newRect
    }

    @objc internal func dismissKeyboard() {
        if searchBar?.isFirstResponder == true {
            searchBar?.resignFirstResponder()
        }
    }
    
    @objc func refreshRemarkName () {
        self.chatListVC.refresh()        
    }
}

extension ChatListViewController {

    func createTeam(_ selectedUsernames: [String]) {
        guard let currentUsername = CurrentUserSessionInfo?.username else {
            contactsPickerVC?.dismiss(animated: true, completion: nil)
            self.presentAuthentication(isDismissBtnHidden: false, isGuestBtnHidden: true)
            return
        }
        
        let members = selectedUsernames + [currentUsername]
        
        let vc = CreateGroupViewController(member: members) {[weak self] (teamId) in
            self?.navigationController?.popViewController(animated: false)
            let session = NIMSession(teamId as String, type: .team)
            let vc = IMChatViewController(session: session, unread: 0)
            let teamObject = NIMSDK.shared().teamManager.team(byId: teamId as String)
            do {
                let message = IMSessionMsgConverter.shared.msgWithTip(tip: String(format: "%@ %@", (teamObject?.teamName ?? "new_group".localized),"created".localized))
                
                try NIMSDK.shared().chatManager.send(message!, to: session)
                
            } catch {
                assert(false, "Send group created message failed!")
            }
            self?.navigationController?.pushViewController(vc, animated: true)

        }
        self.navigationController?.pushViewController(vc, animated: true)

    }

    func createChatRoom(with session: NIMSession) {
        //self.navigationController?.popViewController(animated: false)
        let vc = IMChatViewController(session: session, unread: 0)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

