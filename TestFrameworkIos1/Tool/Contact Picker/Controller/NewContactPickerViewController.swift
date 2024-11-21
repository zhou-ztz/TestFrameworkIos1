//
//  NewContactPickerViewController.swift
//  Yippi
//
//  Created by Wong Jin Lun on 06/07/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
import SDWebImage
//import NIMPrivate


class NewContactPickerViewController: TSViewController {
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: TSTableView!
    
    var currentIndex = 0
    var searchResults = [ContactData]()
    var keyword: String = ""
    var friendOffset = 0
    
    /// 右上角二维码扫描按钮
    fileprivate weak var saoyisaoBtn: UIButton!
    
    ///索引
    var indexDataSource = [String]()
    /// 数据源
    var dataSource: [UserInfoModel] = []
    /// 分组好的数据源
    var sortedDataSource: [[ContactData]] = []
    var allData = [ContactData]()
    var friendData: [ContactData] = []
    var recentChatData: [ContactData] = []
    var teamData: [ContactData] = []
    
    var apiDebouncer = Debouncer(delay: 0.5)
    
    var model: TSmessagePopModel?
    var session: NIMSession?
    var postContent = PostContentView(frame: .zero)
    let configuration: ContactsPickerConfig
    var finishClosure: ContactPickerFinishClosure?
    var cancelClosure: ContactPickerCancelClosure?
    
    var isCreatNewChat = false //是否新建会话
    var isP2PInvite = false //是否p2p邀请其他人加入
    var isMiniProgram: Bool = false
    var isInnerFeed: Bool = false
    var isSearching: Bool = false
    var allowSearchForOtherPeople: Bool = true
    var rightButtonTitle: String = ""
    
    var originDataSource = NSMutableArray()
    var choosedDataSource = NSMutableArray()
    
    var searchView = UIView()
    var chatItem = UIButton()
    
    init(model: TSmessagePopModel? = nil,
         configuration: ContactsPickerConfig,
         isInnerFeed: Bool = false,
         finishClosure: ContactPickerFinishClosure?, cancelClosure: ContactPickerCancelClosure? = nil) {
        
        self.model = model
        self.configuration = configuration
        self.isInnerFeed = isInnerFeed
        self.finishClosure = finishClosure
        self.cancelClosure = cancelClosure
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        chatItem.isEnabled =  choosedDataSource.count > 0 ? true : false
        self.allowSearchForOtherPeople = configuration.allowSearchForOtherPeople
        
        configureNavTitle()
        createRightButton()
        setupTableView()
        setupView()
    }
    
    func configureNavTitle() {
        rightButtonTitle = "share".localized
        setCloseButton(backImage: true, titleStr: "text_share_to".localized)
    }
    
    func createRightButton() {
        chatItem = UIButton(type: .custom)
        chatItem.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)
        self.setupNavigationTitleItem(chatItem, title: rightButtonTitle)
        chatItem.setTitleColor(AppTheme.red, for: .normal)
        chatItem.titleLabel?.font = AppTheme.Font.semibold(17)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: chatItem)
        chatItem.isUserInteractionEnabled = false
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewContactTableViewCell.nib(), forCellReuseIdentifier: NewContactTableViewCell.cellReuseIdentifier)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.allowsMultipleSelection = configuration.allowMultiSelect
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_header.beginRefreshing()
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreFriends))
    }
    
    private func setupView() {
        textFieldView.roundCorner(20)
        textFieldView.dropShadow()
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchTextField.placeholder = "txt_search_id_name".localized
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.delegate = self
    }
    
    @objc func rightButtonClick() {
        guard TSReachability.share.isReachable() else {
            showError(message: "network_is_not_available".localized)
            return
        }
        
        guard let model = model else {
            let array = choosedDataSource as! [ContactData]
            
            if self.isModal {
                if self.isCreatNewChat {
                    self.dismiss(animated: false, completion: nil)
                } else{
                    self.dismiss(animated: true, completion: nil)
                }
                
                self.finishClosure?(array)
            } else {
                if self.isCreatNewChat && array.count > 1 {
                    self.finishClosure?(array)
                    return
                }
                if self.isP2PInvite {
                    self.finishClosure?(array)
                    return
                }
                self.navigationController?.popViewController(animated: true)
                self.finishClosure?(array)
            }
            return
        }
        
        if finishClosure != nil {
            let array = choosedDataSource as! [ContactData]
            self.finishClosure?(array)
            return
        }
        
        switch model.contentType {
        case .sticker:
            shareStickerToChat()
            
        case .miniProgram:
            shareMiniProgramToChat()
        case .pic:
            if model.isQRCode { //发送二维码图片
                sharePicToChat()
            } else {
                sharePostToChat()
            }
        default:
            sharePostToChat()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            if self.isModal {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func refresh() {
        friendOffset = 0
        if !isSearching {
            friendData.removeAll()
            searchResults.removeAll()
            isSearching = false
            searchTextField.text = nil
            keyword = ""
            view.endEditing(true)
            fetchDatas()
        } else {
            friendData.removeAll()
            self.searchResults = allData.filter { $0.displayname.lowercased().contains(keyword.lowercased())}
            
            if allowSearchForOtherPeople == false {
                self.tableView.mj_header.endRefreshing()
                self.tableView.reloadData()
                return
            }
            
            let extras = TSUtil.getUserID(remarkName: keyword)
            
            apiDebouncer.handler = {
                TSUserNetworkingManager().friendList(offset: 0, keyWordString: self.keyword, extras: extras, complete: { [weak self] (userModels, networkError) in
                    defer { self?.tableView.mj_header.endRefreshing() }
                    guard let weakSelf = self else {
                        return
                    }
                    DispatchQueue.main.async {
                        weakSelf.tableView.mj_footer?.resetNoMoreData()
                    }
                    
                    guard let datas = userModels else {
                        weakSelf.tableView.show(placeholderView: .empty)
                        return
                    }
                    weakSelf.friendOffset = datas.count
                    weakSelf.updateFriendListData(model: datas)
                    
                    if networkError != nil {
                        weakSelf.tableView.show(placeholderView: .network)
                        return
                    }
                    
                    weakSelf.searchResults = weakSelf.searchResults + datas.compactMap { result in
                        if weakSelf.searchResults.contains( where: { $0.userId == ContactData(model: result).userId}) {
                            return nil
                        }
                        return ContactData(model: result)
                    }
                    
                    DispatchQueue.main.async {
                        weakSelf.sortUserList(userList: weakSelf.searchResults)
                    }
                })
            }
            apiDebouncer.execute()
        }
    }
    
    @objc func loadMoreFriends() {
        if configuration.members != nil {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            let topTeam = recentChatData.filter{ $0.isTeam == true }
            let offset = isSearching ? searchResults.filter { $0.isTeam == false }.count : allData.count - teamData.count - topTeam.count
            let extras = TSUtil.getUserID(remarkName: keyword)
            
            TSUserNetworkingManager().friendList(offset: friendOffset, keyWordString: keyword.count > 0 ? keyword : nil, extras: extras,  complete: { [weak self] (userModels, networkError) in
                guard let weakSelf = self else {
                    return
                }
                
                guard var datas = userModels else {
                    weakSelf.tableView.mj_footer.endRefreshing()
                    return
                }
                
                weakSelf.friendOffset = weakSelf.friendOffset + datas.count
                weakSelf.updateFriendListData(model: datas)
                
//                datas.enumerated().forEach { (index, userInfo) in
//                    if userInfo.isBannedUser {
//                        let bannedUsername = String(format: "user_deleted_displayname".localized,userInfo.name)
//                        datas[index].name = bannedUsername
//                    }
//                }
                
                if datas.count < TSNewFriendsNetworkManager.limit {
                    weakSelf.tableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    weakSelf.tableView.mj_footer.endRefreshing()
                }
                
                if weakSelf.isSearching {
                    weakSelf.searchResults = weakSelf.searchResults + datas.compactMap { ContactData(model: $0) }
                    weakSelf.sortUserList(userList: weakSelf.searchResults)
                } else {
                    var friends = datas.compactMap { ContactData(model: $0) }
                    
                    if weakSelf.recentChatData.count > 0 {
                        let existingFriendIds = weakSelf.recentChatData.filter { !$0.isTeam }.compactMap { $0.userName }
                        friends.removeAll(where: { existingFriendIds.contains($0.userName) })
                    }
                    
                    weakSelf.allData = weakSelf.allData + friends
                    weakSelf.sortUserList(userList: weakSelf.allData)
                }
            })
        }
    }
    
    func fetchDatas() {
        if let members = configuration.members {
            allData = members.compactMap { ContactData(userName: $0) }
            sortUserList(userList: allData)
            updateTable()
        } else {
            let dispatchGroup = DispatchGroup()
            
            if configuration.enableRecent {
                dispatchGroup.enter()
                fetchRecentChats {
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.enter()
            
            fetchFriends {
                dispatchGroup.leave()
            }
            
            
            if configuration.enableTeam {
                dispatchGroup.enter()
                fetchTeams {
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.configureData()
            }
        }
    }
    
    func configureData() {
        allData.removeAll()
        
        self.updateFriendListData(model: nil)
        
        if configuration.enableRecent {
            allData.append(contentsOf: recentChatData)
        }
        
        if configuration.enableTeam {
            allData.append(contentsOf: teamData)
        }
        
        allData.append(contentsOf: friendData)
        
        sortUserList(userList: allData)
        updateTable()
    }
    
    private func updateTable() {
        if allData.count > 0 {
            searchView.isHidden = false
        } else {
            tableView.show(placeholderView: .empty)
        }
        tableView.mj_header.endRefreshing()
    }
    
    private func updateFriendListData(model: [UserInfoModel]?) {
        if let excludeIds = configuration.excludeIds {
            if var models = model {
                models.forEach { userInfo in
                    var userInfo = userInfo
                    if userInfo.isBannedUser {
                        let bannedUsername = String(format: "user_deleted_displayname".localized, userInfo.name)
                        userInfo.name = bannedUsername
                    }
                }
                self.friendData += models.compactMap { ContactData(model: $0) }
                //self.sortUserList(userList: models)
            }
            let friendList = self.friendData.compactMap { $0.userName } + self.recentChatData.filter{$0.isTeam == false}.compactMap{ $0.userName }
            let friendInGroup = friendList.filter { excludeIds.contains($0) }
            
            for(_, username) in friendInGroup.enumerated() {
                if friendList.contains(where: { $0 == username }) && !self.originDataSource.contains(username) {
                    self.originDataSource.append(username)
                }
            }
        }
    }
    
    func sortUserList(userList: [ContactData]) {
        if allData.count == 0 {
            self.indexDataSource.removeAll()
            self.sortedDataSource.removeAll()
            self.tableView.reloadData()
            return
        }
        
        // 抽取首字母
        var resultNames: [String] = [String]()
        let nameArray = userList.map({ $0.displayname.transformToPinYin().first?.description ?? ""})
        
        let nameSet: NSSet = NSSet(array: nameArray)
        for item in nameSet {
            resultNames.append("\(item)")
        }
        
        // 排序, 同时保证特殊字符在最后
        resultNames = resultNames.sorted(by: { (one, two) -> Bool in
            if (one.isNotLetter()) {
                return false
            } else if (two.isNotLetter()) {
                return true
            } else {
                return one < two
            }
        })
        
        // 替换特殊字符
        self.indexDataSource.removeAll()
        let special: String = "#"
        for value in resultNames {
            if (value.isNotLetter()) {
                self.indexDataSource.append(special)
                break
            } else {
                self.indexDataSource.append(value)
            }
        }
        
        // 分组
        self.sortedDataSource.removeAll()
        for object in self.indexDataSource {
            let users: [ContactData] = userList.filter { dataModel in
                if let pinYin = dataModel.displayname.transformToPinYin().first?.description {
                    if (pinYin.isNotLetter() && object == special) {
                        return true
                    } else {
                        return pinYin == object
                    }
                } else {
                    return false
                }
            }
            
            self.sortedDataSource.append(users)
            
        }
        self.tableView.reloadData()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        apiDebouncer.handler = {
            if (self.searchTextField.text ?? "").isEmpty {
                self.isSearching = false
                self.refresh()
                // self.tableView.reloadData()
            } else {
                self.searchResults.removeAll()
                self.keyword = self.searchTextField.text ?? ""
                self.refresh()
            }
        }
        apiDebouncer.execute()
    }
    
}

extension NewContactPickerViewController {
    func fetchTeams(_ completion: @escaping EmptyClosure) {
        if let teams = NIMSDK.shared().teamManager.allMyTeams() {
            
            teamData = teams.filter { $0.type == NIMTeamType.advanced }.compactMap { ContactData(team: $0) }
            
            if recentChatData.count > 0 {
                let existingTeamIds = recentChatData.filter { $0.isTeam }.compactMap { $0.userName }
                teamData.removeAll(where: { existingTeamIds.contains($0.userName)})
            }
            completion()
        }
    }
    
    func fetchRecentChats(_ completion: @escaping EmptyClosure) {
        recentChatData.removeAll()
        var recentsData = [String]()
        if let recents = NIMSDK.shared().conversationManager.allRecentSessions() {
            
            ///置顶的会话
//            for recent in recents {
//                let isTop = NTESSessionUtil.recentSessionIsMark(recent, type: .top)
//                if isTop {
//                    if recent.session?.sessionType == .team {
//                        if let sessionId = recent.session?.sessionId, let team = NIMSDK.shared().teamManager.team(byId: sessionId) {
//                            let data = ContactData(team: team)
//                            recentChatData.append(data)
//                        }
//                    } else if recent.session?.sessionType == .P2P{
//                        if let userName = recent.session?.sessionId {
//                            recentsData.append(userName)
//                        }
//                    }
//                }
//            }
            
            TSUserNetworkingManager().getUsersInfo(usersId: [], userNames: recentsData) { (userinfoModels, msg, status) in
                if status {
                    if let userinfos = userinfoModels {
                        for userinfo in userinfos {
                            let data = ContactData(model: userinfo)
                            
                            self.recentChatData.append(data)
                        }
                        completion()
                    }
                } else {
                    completion()
                }
            }
        }
    }
    
    func fetchFriends(_ completion: @escaping EmptyClosure) {
        TSUserNetworkingManager().friendList(offset: 0, keyWordString: nil, complete: { [weak self] (userModels, networkError) in
            guard let self = self else {
                return
            }
            
            defer {
                self.tableView.mj_header.endRefreshing()
            }
            
            // 获取数据失败
            if networkError != nil {
                self.tableView.show(placeholderView: .network)
                return
            }
            
            // 获取数据成功
            guard let datas = userModels else {
                completion()
                return
            }
            
            if datas.count < TSNewFriendsNetworkManager.limit {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            } else {
                self.tableView.mj_footer.endRefreshing()
            }
            
            self.friendOffset = datas.count
            self.updateFriendListData(model: datas)
//            datas.forEach { userInfo in
//                var userInfo = userInfo
//                if userInfo.isBannedUser {
//                    let bannedUsername = String(format: "user_deleted_displayname".localized,userInfo.name)
//                    userInfo.name = bannedUsername
//                }
//            }
//            self.friendData = datas.compactMap {
//                ContactData(model: $0)
//            }
            
            // Avoid duplicate contact from recent section
            if self.recentChatData.count > 0 {
                let existingFriendIds = self.recentChatData.filter { !$0.isTeam }.compactMap { $0.userName }
                self.friendData.removeAll(where: { existingFriendIds.contains($0.userName) })
            }
            completion()
        })
    }
}


// MARK: - Table view delegate & data source
extension NewContactPickerViewController:  UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexDataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedDataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "chatfiendlistcell"
        var cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as? ContactPickerCell
        if cell == nil {
            cell = ContactPickerCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: indentifier)
        }
        
        cell?.currentChooseArray = choosedDataSource
        cell?.originData = originDataSource
        cell?.selectionStyle = .none
        
        cell?.contactData = sortedDataSource[indexPath.section][indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell: ContactPickerCell = tableView.cellForRow(at: indexPath) as! ContactPickerCell
        
        for (_, model) in originDataSource.enumerated() {
            let username: String = model as! String
            if username == cell.contactData?.userName {
                return
            }
        }
        if cell.contactData!.isBannedUser {
            self.showTopIndicator(status: .faild, "alert_banned_description".localized)
            return
        }
        if cell.chatButton.isSelected {
            for (index, model) in choosedDataSource.enumerated() {
                let userinfo: ContactData = model as! ContactData
                if userinfo.userName == cell.contactData?.userName {
                    choosedDataSource.removeObject(at: index)
                    break
                }
            }
            cell.chatButton.isSelected = !cell.chatButton.isSelected
        } else {
            if choosedDataSource.count >= configuration.maximumSelectCount {
                self.showTopIndicator(status: .faild, String(format: "maximum_contact_select".localized, configuration.maximumSelectCount))
                return
            }
            choosedDataSource.add(cell.contactData)
            cell.chatButton.isSelected = !cell.chatButton.isSelected
        }
        
        if choosedDataSource.count > 0 {
            chatItem.setTitleColor(AppTheme.red, for: .normal)
            chatItem.isUserInteractionEnabled = true
        } else {
            chatItem.setTitleColor(UIColor(hex: 0xD9D9D9), for: .normal)
            chatItem.isUserInteractionEnabled = false
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F7F8FA")
        var lab = UILabel()
        lab.frame = CGRect(x: 15, y: 0, width: 100, height: 30)
        lab.text = indexDataSource[section]
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = UIColor(hex: "#808080")
        view.addSubview(lab)
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexDataSource
    }
}

extension NewContactPickerViewController {
    func shareStickerToChat() {
        guard let sticker = model else { return }
        
        let attachment = IMStickerCardAttachment()
        attachment.stickerCardAttachment(with: sticker)
        
        let custom = NIMCustomObject()
        custom.attachment = attachment
        
        choosedDataSource.forEach {
            let contact = $0 as! ContactData
            let session = NIMSession(contact.userName, type:  contact.isTeam ? .team : .P2P)
            let message = NIMMessage()
            message.messageObject = custom
            message.text = sticker.owner
            try? NIMSDK.shared().chatManager.send(self.updateApnsPayload(message, session.sessionId, contact.isTeam), to: session)
        }
        
        showTopIndicator(status: .success, "select_friend_success_sent".localized)
    }
    
    func shareMiniProgramToChat() {
        guard let model = model else { return }
        
        let content = IMMiniProgramAttachment()
        content.appId = model.appId
        content.path = model.path
        content.title = model.owner
        content.desc = model.content
        content.imageURL = model.coverImage
        content.contentType = "\(model.contentType.messageTypeID)"
        
        let custom = NIMCustomObject()
        custom.attachment = content
        
        choosedDataSource.forEach {
            let contact = $0 as! ContactData
            let message = NIMMessage()
            message.messageObject = custom
            let session = NIMSession(contact.userName, type:  contact.isTeam ? .team : .P2P)
            try? NIMSDK.shared().chatManager.send(self.updateApnsPayload(message, session.sessionId, contact.isTeam), to: session)
        }
        
        showTopIndicator(status: .success, "select_friend_success_sent".localized)
    }
    
    func sharePostToChat() {
        guard let model = model else { return }
        
        let content = IMSocialPostAttachment()
        content.socialPostMessage(with: model)
        
        let custom = NIMCustomObject()
        custom.attachment = content
        
        choosedDataSource.forEach {
            let contact = $0 as! ContactData
            let message = NIMMessage()
            message.messageObject = custom
            let session = NIMSession(contact.userName, type:  contact.isTeam ? .team : .P2P)
            try? NIMSDK.shared().chatManager.send(self.updateApnsPayload(message, session.sessionId, contact.isTeam), to: session)
        }
        
        showTopIndicator(status: .success, "select_friend_success_sent".localized)
    }
    
    func sharePicToChat(){
        guard let model = model else { return }
        
        choosedDataSource.forEach {
            let contact = $0 as! ContactData
            let message = NIMMessage()
            let messageObject = NIMImageObject(image: model.qrImage)
            message.messageObject = messageObject
            let session = NIMSession(contact.userName, type:  contact.isTeam ? .team : .P2P)
            try? NIMSDK.shared().chatManager.send(self.updateApnsPayload(message, session.sessionId, contact.isTeam), to: session)
            
            if !model.content.isEmpty {
                let textMessage = NIMMessage()
                textMessage.text = model.content
                try? NIMSDK.shared().chatManager.send(self.updateApnsPayload(textMessage, session.sessionId, contact.isTeam), to: session)
            }
        }
        
        showTopIndicator(status: .success, "select_friend_success_sent".localized)
    }
    
    // By Kit Foong (Update message session id and type into apns payload)
    func updateApnsPayload(_ message: NIMMessage, _ sessionIdString: String, _ isTeam: Bool) -> NIMMessage {
        var sessionId: String = ""
        var sessionType: Int = 0
        
        sessionType = isTeam ? 1 : 0
        
        if (sessionType == 0) {
            sessionId =  NIMSDK.shared().loginManager.currentAccount() ?? ""
        } else {
            sessionId = sessionIdString
            let setting = NIMMessageSetting()
            setting.teamReceiptEnabled = true
            message.setting = setting
        }
        
        if sessionId.isEmpty == false {
            var parameters: String = ""
            parameters = String(format: "{\"sessionID\": \"%@\", \"sessionType\": \"%@\"}", sessionId, sessionType.stringValue)
            printIfDebug(parameters)
            
            if let data = parameters.data(using: String.Encoding.utf8) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                    message.apnsPayload = json
                } catch {
                    printIfDebug("Something went wrong")
                }
            }
        }
        
        return message
    }
}

extension NewContactPickerViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchResults.removeAll()
        isSearching = true
        tableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchResults.removeAll()
        
        keyword = searchTextField.text ?? ""
        keyword = keyword.replacingOccurrences(of: " ", with: "")
        view.endEditing(true)
        isSearching = !keyword.isEmpty
        if isSearching {
            self.tableView.mj_header.beginRefreshing()
            return true
        }
        tableView.reloadData()
        return true
    }
}
