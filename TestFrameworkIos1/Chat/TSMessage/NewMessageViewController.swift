//
//  NewMessageViewController.swift
//  Yippi
//
//  Created by Wong Jin Lun on 24/02/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
//import NIMPrivate
import NIMSDK

class NewMessageViewController: TSViewController {
    override var moduleType: ModuleType {
        return .im
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
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
    
    var tabs: [TabHeaderdModal] = []
    var currentIndex = 0
    
    var chatListNewVC = ChatListViewController()
    var messageRequestListVC = MessageRequestListTableViewController()
    var callVC = CallViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkWebIsOnline()
        refreshAfterTeenChanged()
    
        setupUI()
        NIMSDK.shared().systemNotificationManager.add(self)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAfterTeenChanged), name: Notification.Name.DashBoard.teenModeChanged, object: nil)
    }
    
    deinit{
        NIMSDK.shared().loginManager.remove(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setLeftNavTitle(titleStr:  "message".localized)
        NotificationCenter.default.addObserver(self, selector: #selector(collectionViewRefresh), name: Notification.Name(rawValue: "updateBadge"), object: nil)
        NIMSDK.shared().loginManager.add(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateBadge"), object: nil)
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(TabCollectionViewCell.nib(), forCellWithReuseIdentifier: TabCollectionViewCell.cellIdentifier)
        tabs = [TabHeaderdModal(titleString: "rw_text_chats".localized, messageCount: 0, bubbleColor: TSColor.main.theme, isSelected: true),
                //TabHeaderdModal(titleString: "calls".localized, messageCount: 0, bubbleColor: TSColor.main.blue, isSelected: false),
                TabHeaderdModal(titleString: "title_requests".localized, messageCount: 0, bubbleColor: TSColor.main.theme, isSelected: false)]
        collectionViewRefresh()
        
        //        addChild(callVC)
        //        callVC.view.frame = containerView.bounds
        //        containerView.addSubview(callVC.view)
        
        if currentIndex == 0 {
            addChild(chatListNewVC)
            chatListNewVC.view.frame = containerView.bounds
            chatListNewVC.isWebLoggedIn = isWebLoggedIn
            containerView.addSubview(chatListNewVC.view)
            chatListNewVC.didMove(toParent: self)
        }
    }
    
    // MARK: - 设置发起聊天按钮（设置右上角按钮）
    func setChatButton() {
        let chatItem = UIButton(type: .custom)
        chatItem.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)
        self.chatButton = chatItem
        self.chatButton.setImage(UIImage.set_image(named: "iconsSearchBlack"), for: UIControl.State.normal)
        let moreItem = UIButton(type: .custom)
        moreItem.addTarget(self, action: #selector(moreButtonClick), for: .touchUpInside)
        self.moreButton = moreItem
        self.moreButton.setImage(UIImage.set_image(named: "iconsAddmomentBlack"), for: UIControl.State.normal)
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 12
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: moreItem), space,  UIBarButtonItem(customView: chatItem)]
        //        badge.backgroundColor = TSColor.main.warn
        //        badge.clipsToBounds = true
        //        badge.layer.cornerRadius = 3.5
        //        badge.isHidden = true
        //moreButton.addSubview(badge)
        //        badge.snp.makeConstraints { (make) in
        //            make.width.height.equalTo(7)
        //            make.top.equalTo(3.5)
        //            make.right.equalTo(0)
        //        }
    }
    
    @objc func collectionViewRefresh() {
        for (index, element) in self.tabs.enumerated() {
            if (element.titleString == "rw_text_chats".localized) {
                element.messageCount = NIMSDK.shared().conversationManager.allUnreadCount()
            } else if (element.titleString == "title_requests".localized)  {
                element.messageCount = ChatMessageManager.shared.getRequestCount(getGroupCount: true)
            }
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        self.unreadCountNetworkManager.updateTabbarBadge()
    }
    
    @objc func refreshAfterTeenChanged() {
        if !UserDefaults.teenModeIsEnable {
            collectionView.isHidden = false
            setChatButton()
        } else {
            collectionView.isHidden = true
            self.navigationItem.rightBarButtonItems = nil
        }
    }
    
    @objc func loadUnreadInfo() {
        self.unreadCountNetworkManager.unreadCount { [weak self] (_) in
            guard let weakSelf = self else {
                return
            }
            // 整合数据给子视图 然后刷新
            DispatchQueue.main.async {
                weakSelf.collectionViewRefresh()
            }
        }
    }
    
    // MARK: - 发起聊天按钮点击事件（右上角按钮点击事件）
    @objc func rightButtonClick() {
//        let vc = NTESSessionSearchListVC()
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func moreButtonClick(){
        var data = [TSToolModel]()
        let titles = ["scan_qr".localized, "new_chat_title".localized, "meeting_kit".localized, "people_nearby".localized, "contact".localized, "title_favourite_message".localized]
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
        preference.drawing.background.color = .clear
        self.moreButton.showToolChoose(identifier: "", data: data, arrowPosition: .none, preferences: preference, delegate: self, isMessage: true)
    }
}

// MARK: - Collection view delegate & data source
extension NewMessageViewController:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        if indexPath.row == 0 { //|| indexPath.row == 1
            for (index, element) in tabs.enumerated() {
                if index == indexPath.row {
                    element.isSelected = true
                } else {
                    element.isSelected = false
                }
            }
            
            //            if indexPath.row == 1 {
            //                chatListNewVC.view.isHidden = true
            //                callVC.view.isHidden = false
            //            }else {
            //                callVC.view.isHidden = true
            //                chatListNewVC.view.isHidden = false
            //            }
            self.currentIndex = indexPath.row
            self.collectionViewRefresh()
        } else {
            let vc = MessageRequestViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension NewMessageViewController {
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

extension NewMessageViewController: NIMSystemNotificationManagerDelegate {
    func onReceive(_ notification: NIMSystemNotification) {
        loadUnreadInfo()
    }
    
    func onSystemNotificationCountChanged(_ unreadCount: Int) {
        loadUnreadInfo()
    }
}

extension NewMessageViewController:  ToolChooseDelegate{
    func didSelectedItem(type: TSToolType, title: String) {
        switch type {
        case .scan:
           // TSRootViewController.share.presentScan(tabType: .scan, previousIndex: 3)
            //self.presentScanQRViewController()
            FeedIMSDKManager.shared.delegate?.didClickScanQR()
            break
        case .newChat:
            EventTrackingManager.instance.track(event: .viewContacts)
            let vc = AddChatViewController(isShowCol: false, cancelType: .allwayShow)
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .nearBy:
//            EventTrackingManager.instance.track(event: .viewNearbyPeople)
//            let vc = DiscoverUserTableController(type: .nearby)
//            let newNav = TSNavigationController(rootViewController: vc)
//            newNav.setCloseButton(backImage: true, titleStr: "people_nearby".localized)
//            self.present(newNav.fullScreenRepresentation, animated: true, completion: nil)
            FeedIMSDKManager.shared.delegate?.didClickNearbyPeople()
        case .contact:
//            EventTrackingManager.instance.track(event: .viewContactPeople)
            //self.handlesShowContacts()
            FeedIMSDKManager.shared.delegate?.didClickContacts()
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

extension NewMessageViewController: NIMLoginManagerDelegate {
    func onMultiLoginClientsChanged() {
        checkWebIsOnline()
    }
}

