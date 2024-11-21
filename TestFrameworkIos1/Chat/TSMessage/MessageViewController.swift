//
//  MessageViewController.swift
//  ThinkSNS +
//
//  Created by lip on 2017/9/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  消息页面根控制器,持有切换2个子控制器

import UIKit
import NIMSDK

class MessageViewController: TSLabelViewController {
    override var moduleType: ModuleType {
        return .im
    }
    /// IM第二版聊天列表页面(新构造的)
    let chatListNewVC: ChatListViewController
    //let subscriptionGroupChatListVC: SubscriptionGroupListViewController

    /// 是否将通知控制器添加为子控制器
    var isAddNotiVC = false
    /// 网络控制器
    lazy var unreadCountNetworkManager = UnreadCountNetworkManager()
    /// 发起聊天按钮
    fileprivate weak var chatButton: UIButton!
    /// 更多
    fileprivate weak var moreButton: UIButton!
    private var contactsPickerVC: ContactsPickerViewController?
    var chatLab: UIButton!
    var fansLab: UIButton!
    var badge = UIView()
    var isWebLoggedIn: Bool = false
    
    override init(labelTitleArray: [String], scrollViewFrame: CGRect?, isChat: Bool = false) {
        self.chatListNewVC = ChatListViewController()
       // self.subscriptionGroupChatListVC = SubscriptionGroupListViewController()

        super.init(labelTitleArray: labelTitleArray, scrollViewFrame: scrollViewFrame, isChat: isChat)
        //self.chatListNewVC.superViewController = self
        self.chatListNewVC.isWebLoggedIn = isWebLoggedIn
        self.add(childViewController: chatListNewVC, At: 0)
       // self.add(childViewController: subscriptionGroupChatListVC, At: 1)
        self.scrollView.touchesShouldCancel(in: chatListNewVC.view)
        self.scrollView.canCancelContentTouches = false
        
        self.navigationItem.titleView = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("该控制器不支持")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        checkWebIsOnline()
        setChatButton()
        setupUI()
        setSelectView()
        NIMSDK.shared().systemNotificationManager.add(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatebadge), name: Notification.Name(rawValue: "updateBadge"), object: nil)
    }
    
    deinit{
        NIMSDK.shared().loginManager.remove(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let nav = self.navigationController as? TSNavigationController {
            nav.setCloseButton(backImage: true, titleStr: "chat".localized)
        }
        NIMSDK.shared().loginManager.add(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateBadge"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUnreadInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(loadUnreadInfo), name: NSNotification.Name.APNs.receiveNotice, object: nil)
        showShouldhideTip()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.APNs.receiveNotice, object: nil)
    }
    
    func setSelectView(){
        let selectView = UIStackView()
        selectView.axis = .horizontal
        selectView.spacing = 26
        selectView.frame = CGRect(x: 0, y: 0, width: 110, height: 44)
        
        chatLab = UIButton()
        chatLab.setTitle("chat".localized, for: .normal)
        chatLab.setTitle("chat".localized, for: .selected)
        chatLab.setTitleColor(.black, for: .selected)
        chatLab.setTitleColor(UIColor(red: 184, green: 184, blue: 184), for: .normal)
        chatLab.isSelected = true
        chatLab.titleLabel?.setFontSize(with: 18, weight: .bold)
        chatLab.addTarget(self, action: #selector(chatAction), for: .touchUpInside)
        selectView.addArrangedSubview(chatLab)

        
        fansLab = UIButton()
        fansLab.setTitle("fans_group".localized, for: .normal)
        fansLab.setTitle("fans_group".localized, for: .selected)
        fansLab.setTitleColor(.black, for: .selected)
        fansLab.setTitleColor(UIColor(red: 184, green: 184, blue: 184), for: .normal)
        fansLab.titleLabel?.setFontSize(with: 18, weight: .bold)
        fansLab.addTarget(self, action: #selector(fansAction), for: .touchUpInside)
        selectView.addArrangedSubview(fansLab)
        
        fansLab.isHidden = true
        fansLab.isUserInteractionEnabled = false
        self.scrollView.isScrollEnabled = false

        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: selectView)
        
        
    }
    
    @objc func chatAction(){
        fansLab.isSelected = false
        chatLab.isSelected = true
        setSelectedAt(0)
    }
    @objc func fansAction(){
        chatLab.isSelected = false
        fansLab.isSelected = true
        setSelectedAt(1)
    }

    // MARK: - 设置发起聊天按钮（设置右上角按钮）
    func setChatButton() {
        let chatItem = UIButton(type: .custom)
        chatItem.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)
        self.chatButton = chatItem
        self.chatButton.setImage(UIImage.set_image(named: "iconsNewSearch"), for: UIControl.State.normal)
        self.chatButton.size = CGSize(width: 24, height: 24)
        
        let moreItem = UIButton(type: .custom)
        moreItem.addTarget(self, action: #selector(moreButtonClick), for: .touchUpInside)
        
        self.moreButton = moreItem
        self.moreButton.setImage(UIImage.set_image(named: "iconsNewChat"), for: UIControl.State.normal)
        self.moreButton.size = CGSize(width: 34, height: 34)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: moreItem), UIBarButtonItem(customView: chatItem)]
        badge.backgroundColor = TSColor.main.warn
        badge.clipsToBounds = true
        badge.layer.cornerRadius = 3.5
        badge.isHidden = true
        moreButton.addSubview(badge)
        badge.snp.makeConstraints { (make) in
            make.width.height.equalTo(7)
            make.top.equalTo(3.5)
            make.right.equalTo(0)
        }
    }
    
    @objc func updatebadge() {
        MessageRequestNetworkManager().getMessageReqList(specialRequest: true, complete: { [weak self] (result, status) in
            let msgCount = ChatMessageManager.shared.requestCount()
            let requestList = MessageRequestRealmManager().getChatRequest()
            let filter = NIMSystemNotificationFilter()
            filter.notificationTypes = [NSNumber(nonretainedObject: NIMSystemNotificationType.teamInvite), NSNumber(nonretainedObject: NIMSystemNotificationType.teamApply)]
            var notif = NIMSDK.shared().systemNotificationManager.fetchSystemNotifications(nil, limit: 20, filter: filter) ?? []
            notif = notif.filter { $0.type.rawValue == 0 || $0.type.rawValue == 2 }
            let groupInvateCount = notif.count
            let count = msgCount > 0 ? msgCount : requestList.count
            print("msgCount = \(msgCount), count = \(count), request list = \(requestList.count), group Invate count = \(groupInvateCount)")
            
            self?.badge.isHidden = (count + groupInvateCount) > 0 ? false : true
        })
        
//        let msgCount = ChatMessageManager.shared.requestCount()
//        let requestList = MessageRequestRealmManager().getChatRequest()
//        let filter = NIMSystemNotificationFilter()
//        filter.notificationTypes = [NSNumber(nonretainedObject: NIMSystemNotificationType.teamInvite), NSNumber(nonretainedObject: NIMSystemNotificationType.teamApply)]
//        let notif = NIMSDK.shared().systemNotificationManager.fetchSystemNotifications(nil, limit: 20, filter: filter)
//        let groupInvateCount = notif?.count
//        let count = msgCount > 0 ? msgCount : requestList.count
//
//        badge.isHidden = (count + groupInvateCount.orZero) > 0 ? false : true
    }

    @objc func loadUnreadInfo() {
        self.unreadCountNetworkManager.unreadCount { [weak self] (_) in
            guard let weakSelf = self else {
                return
            }
            // 整合数据给子视图 然后刷新
            DispatchQueue.main.async {
                weakSelf.updatebadge()
                weakSelf.countUnreadInfo()
            }
        }
    }

    open func countUnreadInfo() {
        DispatchQueue.main.async {
            let chatUnreadCount = NIMSDK.shared().conversationManager.allUnreadCount()
            self.badges[0].isHidden = chatUnreadCount == 0
            self.unreadCountNetworkManager.updateTabbarBadge()
        }
    }

    func setupUI() {
        scrollView.backgroundColor = TSColor.inconspicuous.background
    }

    override func selectedPageEndAt(index: Int) {
        if index == 0 { // 当视图切换到第一个时,刷新通知信息
            EventTrackingManager.instance.track(event: .viewChatList)
            chatListNewVC.searchBar?.resignFirstResponder()
            fansLab.isSelected = false
            chatLab.isSelected = true
        }else{
            chatLab.isSelected = false
            fansLab.isSelected = true
        }
    }
    
    //收藏首次提示浮窗
    func showShouldhideTip(){
        if UserDefaults.messageFirstCollectionFilterTooltipShouldHide == true {
            let tooltip = ToolTipPreferences()
            tooltip.drawing.bubble.color = UIColor(red: 37, green: 37, blue: 37)
            tooltip.drawing.message.color = .white
            tooltip.drawing.background.color = .clear

            self.moreButton.showToolTip(identifier: "", title: "favourite_msg_tooltips_title".localized, message: "favourite_msg_tooltips_desc".localized, button: nil, arrowPosition: .top, preferences: tooltip, delegate: nil)

            UserDefaults.messageFirstCollectionFilterTooltipShouldHide = false
        }
    }
    

    // MARK: - 发起聊天按钮点击事件（右上角按钮点击事件）
    @objc func rightButtonClick() {
//        let vc = NTESSessionSearchListVC()
//        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @objc func moreButtonClick(){
        var data = [TSToolModel]()

        let titles = ["scan_qr".localized, "new_chat_title".localized, "meeting".localized, "people_nearby".localized, "contact".localized, "title_favourite_message".localized]
        let images = ["iconsQrscanBlack", "iconsAddComment", "iconsGroupMeeting", "iconsPeopleNearbyBlack", "iconsContactBlack", "iconsFavouriteBlack"]
        let types = [TSToolType.scan, TSToolType.newChat, TSToolType.meeting, TSToolType.nearBy, TSToolType.contact, TSToolType.collection]

        for i in 0 ..< titles.count {
            let model = TSToolModel(title: titles[i], image: images[i], type: types[i])
            data.append(model)
        }
        let preference = ToolChoosePreferences()
        preference.drawing.bubble.color = .white
        preference.drawing.message.color = .lightGray
        preference.drawing.button.color = .lightGray
        self.moreButton.showToolChoose(identifier: "", data: data, arrowPosition: .top, preferences: preference, delegate: self, isMessage: false)
    }
}

extension MessageViewController {

    func createTeam(_ selectedUsernames: [String]) {
        guard let currentUsername = CurrentUserSessionInfo?.username else {
            contactsPickerVC?.dismiss(animated: true, completion: nil)
            self.presentAuthentication(isDismissBtnHidden: false, isGuestBtnHidden: true)
            return
        }
        
        let members = selectedUsernames + [currentUsername]

        let createGroupController = DependencyContainer.shared.resolveViewControllerFactory().makeCreateGroupViewController(member: members, completion: { [weak self] (teamId) in
            guard let strongself = self else { return }

            strongself.navigationController?.popViewController(animated: false)
            let session = NIMSession(teamId as String, type: .team)
            let vc = IMChatViewController(session: session, unread: 0)
            let teamObject = NIMSDK.shared().teamManager.team(byId: teamId as String)
            do {
                let message = IMSessionMsgConverter.shared.msgWithTip(tip: String(format: "%@ %@", (teamObject?.teamName ?? "new_group".localized),"created".localized))

                try NIMSDK.shared().chatManager.send(message!, to: session)

            } catch {
                assert(false, "Send group created message failed!")
            }
            strongself.navigationController?.pushViewController(vc, animated: true)
        })
        self.navigationController?.pushViewController(createGroupController, animated: true)
    }

    func createChatRoom(with session: NIMSession) {
        //self.navigationController?.popViewController(animated: false)
        let vc = IMChatViewController(session: session, unread: 0)
        self.chatListNewVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func checkWebIsOnline(){
        if let clients:Array = NIMSDK.shared().loginManager.currentLoginClients(), clients.count > 0 {
            for client in clients {
                if client.type == .typeWeb {
                    //is web login
                    isWebLoggedIn = true
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "isWebLoggedIn"), object: nil,
                                                    userInfo: ["isLogIn": true])
                    break
                }
            }
        } else {
            isWebLoggedIn = false
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "isWebLoggedIn"), object: nil,
                                            userInfo:  ["isLogIn": false])
        }
    }
}

extension MessageViewController: NIMSystemNotificationManagerDelegate {
    func onReceive(_ notification: NIMSystemNotification) {
        loadUnreadInfo()
    }
    
    func onSystemNotificationCountChanged(_ unreadCount: Int) {
        loadUnreadInfo()
    }
}

extension MessageViewController:  ToolChooseDelegate{
    func didSelectedItem(type: TSToolType, title: String) {
        switch type {
        case .scan: break
//            let qrCodeVC = TSQRCodeVC(qrType: .user, qrContent: (TSCurrentUserInfo.share.userInfo?.username).orEmpty, descStr: "qr_scan_alert".localized)
//            qrCodeVC.qrType = TSQRType.group
//            qrCodeVC.avatarString = CurrentUserSessionInfo?.avatarUrl
//            qrCodeVC.nameString = TSCurrentUserInfo.share.userInfo?.name
//            qrCodeVC.introString = TSCurrentUserInfo.share.userInfo?.bio
//            qrCodeVC.uidStirng = (TSCurrentUserInfo.share.userInfo?.userIdentity)!
//            qrCodeVC.isIMorProfile = true
//            self.navigationController?.pushViewController(qrCodeVC, animated: true)
            
        case .newChat:
            let chatContactPickerVC = ChatContactPickerViewController()
            self.navigationController?.pushViewController(chatContactPickerVC, animated: true)
            
        case .nearBy:
//            EventTrackingManager.instance.track(event: .viewNearbyPeople)
            let vc = DiscoverUserTableController(type: .nearby)
            vc.title = "people_nearby".localized
            let newNav = TSNavigationController(rootViewController: vc)
            newNav.setCloseButton(backImage: true)
            self.present(newNav.fullScreenRepresentation, animated: true, completion: nil)
            
        case .contact:
//            EventTrackingManager.instance.track(event: .viewContactPeople)
            self.handlesShowContacts()
            
        case .groupInvate: break
//            let vc = GroupNotificationTableVC()
//            self.navigationController?.pushViewController(vc, animated: true)
            
        case .note:
            //let vc = MessageRequestListTableViewController()
            let vc = MessageRequestViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case .collection:
            let vc = MsgCollectionViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case .meeting:
            let vc = MeetingListViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}

extension MessageViewController: NIMLoginManagerDelegate {
    func onMultiLoginClientsChanged() {
        checkWebIsOnline()
    }
}
