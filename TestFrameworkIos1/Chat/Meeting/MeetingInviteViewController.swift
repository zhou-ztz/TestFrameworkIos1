//
//  MeetingInviteViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司-zhi on 2023/9/7.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class MeetingInviteViewController: TSViewController  {
    
    var searchBar: MeetingSearchView!
    var inviteBnt: UIButton!
    ///搜索关键词
    var keyword: String = ""
    /// 数据源
    var dataSource: [ContactData] = []
    ///选中的数据
    var choosedDataSource: [ContactData] = []
    ///群组
    var groups: [ContactData] = []
    ///已经邀请的成员
    var membersAndGroups: [String] = []
    var members: [String] = []
    var groupIDs: [String] = []
    var offset: Int = 0
    var meetingNum: String = ""
    //会议信息
    var meetingInfo: QuertMeetingInfoModel?
    
    lazy var tableView: TSTableView = {
        let table = TSTableView(frame: .zero, style: .plain)
        table.register(MeetingFriendsListCell.self, forCellReuseIdentifier: "MeetingFriendsListCell")
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 60
        return table
    }()
    
    init(meetingNum: String) {
        self.meetingNum = meetingNum
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        getInviteMembers()
        if let teams = NIMSDK.shared().teamManager.allMyTeams() {
            groups = teams.compactMap {
                ContactData(team: $0)
            }
        }
        tableView.mj_header.beginRefreshing()
    }

    func setUI(){
        searchBar = MeetingSearchView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 40))
        searchBar.delegate = self
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(17)
            make.right.equalTo(0)
            make.height.equalTo(40)
        }
        searchBar.rightButton.isHidden = true
        searchBar.searchTextFiled.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1)
        view.addSubview(self.tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(self.searchBar.snp_bottom).offset(10)
            make.bottom.equalTo(-86 - TSBottomSafeAreaHeight)
        }
        createBottomBtn()
        view.addSubview(inviteBnt)
        inviteBnt.snp.makeConstraints { make in
            make.left.equalTo(40)
            make.right.equalTo(-40)
            make.bottom.equalTo(-20 - TSBottomSafeAreaHeight)
            make.height.equalTo(56)
        }
        
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreFriends))
        tableView.mj_footer.makeHidden()
    }
    
    func createBottomBtn(){
        inviteBnt = UIButton()
        inviteBnt.backgroundColor = .lightGray//UIColor(hex: "#3BB3FF", alpha: 1)
        inviteBnt.setTitle("meeting_invite_now".localized, for: .normal)
        inviteBnt.setTitleColor(.white, for: .normal)
        inviteBnt.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        inviteBnt.layer.cornerRadius = 28
        inviteBnt.clipsToBounds = true
        inviteBnt.addTarget(self, action: #selector(inviteAction), for: .touchUpInside)
    }
    
    @objc func inviteAction(){
        if choosedDataSource.count == 0 {
            return
        }
        var invitedMembers: [String] = [] //新邀请的成员
        var memberList: [String] = members
        var groupIds: [String] = groupIDs
        var newGroupIds: [String] = []
        //
        for source in choosedDataSource {
            if source.isTeam {
                groupIds.append(source.userName)
                newGroupIds.append(source.userName)
            }else{
                invitedMembers.append(source.userName)
                memberList.append(source.userName)
            }
        }
        //遍历新邀请的群成员
        for username in newGroupIds {
            SessionUtil().fetchMembersTeam(teamId: username) { users in
                invitedMembers.append(contentsOf: users)
                memberList.append(contentsOf: users)
            }
        }
        //去掉重复数据
        let invitedMembers1 = Array(Set(invitedMembers))
        let memberList1 = Array(Set(memberList))
        
        let dict: [String : Any]? = ["meetingNum": self.meetingNum, "privateOption": ["members": memberList1, "groupIds": groupIds], "invitedMembers": invitedMembers]
        print("dict = \(dict)")
        MeetingInvitedRequest.init(params: dict).execute { response in
            DispatchQueue.main.async {
                self.sendMessage()
                self.dismiss(animated: true)
            }
        } onError: { error  in
            DispatchQueue.main.async {
                self.showError(message: error.localizedDescription)
            }
        }
        
        
    }
    
    func getInviteMembers(){
        TSIMNetworkManager.quertMeetingInfo(meetingId: 0, meetingNum: self.meetingNum) {[weak self] model, error in
            guard let self = self else {
                return
            }
            if let model = model {
                self.meetingInfo = model
                self.groupIDs = model.privateOption?.groupIds ?? []
                self.members = model.privateOption?.members ?? []
                self.membersAndGroups = model.privateOption?.groupIds ?? []
                self.membersAndGroups.append(contentsOf: model.privateOption?.members ?? [])
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func refresh(){
        self.tableView.mj_footer.isHidden = true
        offset = 0
        TSUserNetworkingManager().friendList(offset: offset, keyWordString: keyword, complete: { (userModels, networkError) in
            self.tableView.mj_header.endRefreshing()
            if networkError != nil && self.groups.isEmpty {
                self.tableView.show(placeholderView: .network)
            }else {
                if let datas = userModels {
                    self.dataSource = datas.compactMap {
                        ContactData(model: $0)
                    }
                    if self.dataSource.isEmpty && self.groups.isEmpty  {
                        self.tableView.show(placeholderView: .empty)
                    } else {
                        self.tableView.removePlaceholderViews()
                        self.tableView.mj_footer.isHidden = false
                    }
                    if datas.count < TSNewFriendsNetworkManager.limit {
                        self.tableView.mj_footer.makeVisible()
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_footer.makeVisible()
                        self.tableView.mj_footer.endRefreshing()
                    }
                    self.offset = datas.count
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
            }
        })
    }
    
    @objc func loadMoreFriends(){
        offset = offset + 1
        self.tableView.mj_footer.makeVisible()
        TSUserNetworkingManager().friendList(offset: offset, keyWordString: keyword, complete: { (userModels, networkError) in
            self.tableView.mj_header.endRefreshing()
            if networkError != nil  {
                self.tableView.mj_footer.endRefreshing()
                self.tableView.show(placeholderView: .network)
            }else {
                if let datas = userModels {
                    self.offset = self.offset + datas.count
                    let users = datas.compactMap {
                        ContactData(model: $0)
                    }
                    self.dataSource = self.dataSource + users
                    if self.dataSource.isEmpty && self.keyword.isEmpty {
                        self.tableView.show(placeholderView: .empty)
                    } else {
                        
                    }
                    if datas.count < TSNewFriendsNetworkManager.limit {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_footer.endRefreshing()
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }else{
                    self.tableView.mj_footer.endRefreshing()
                }
            }
        })
    }
    
    func searchGroupName(){
        if let teams = NIMSDK.shared().teamManager.allMyTeams() {
            groups = teams.compactMap {
                ContactData(team: $0)
            }
        }
        if keyword.count == 0 {
            return
        }
        let results = self.groups.filter { data in
            let name = data.displayname ?? ""
            if name.uppercased().contains(keyword.uppercased()) {
                return true
            }
            return false
        }
        self.groups.removeAll()
        self.groups = results
    }
    
    func updateUI(){
        
        if choosedDataSource.count == 0 {
            inviteBnt.isEnabled = false
            //inviteBnt.setTitleColor(.lightGray, for: .normal)
            inviteBnt.backgroundColor = .lightGray
        }else{
            inviteBnt.isEnabled = true
            //inviteBnt.setTitleColor(UIColor(hex: "#3BB3FF"), for: .normal)
            inviteBnt.backgroundColor = AppTheme.red
        }
        
    }
    
    //发送IM信息
    func sendMessage(){
        guard let meetingInfo = self.meetingInfo else { return }
        for source in choosedDataSource {
            
            let attachment = IMMeetingRoomAttachment()
            attachment.meetingId = "\(meetingInfo.meetingId)"
            attachment.meetingNum = meetingInfo.meetingNum ?? ""
            attachment.meetingShortNum = meetingInfo.meetingNum ?? ""
            attachment.meetingPassword = meetingInfo.password ?? ""
            attachment.meetingStatus = "\(meetingInfo.status ?? 0)"
            attachment.meetingSubject = meetingInfo.subject
            attachment.meetingType = meetingInfo.type ?? 0
            attachment.roomArchiveId = meetingInfo.roomArchiveId ?? ""
            attachment.roomUuid = meetingInfo.roomUuid ?? ""

            let message = NIMMessage()
            let customObject = NIMCustomObject()
            customObject.attachment = attachment
            message.messageObject = customObject
            message.apnsContent = "recent_msg_desc_meeting".localized
            var session: NIMSession!
            if !source.isTeam {
                session = NIMSession.init(source.userName, type: .P2P)
            }else{
                session = NIMSession.init(source.userName, type: .team)
            
            }
            do {
                try NIMSDK.shared().chatManager.send(message, to: session)
            } catch {
                
            }
                
            
        }
       
        
    }

}

extension MeetingInviteViewController: MeetingSearchViewDelegate{
    func searchDidClickReturn(text: String) {
        keyword = text
        searchGroupName()
        self.refresh()
        self.searchBar.searchTextFiled.resignFirstResponder()
    }
    
    func searchDidClickCancel() {
        keyword = ""
        searchGroupName()
        self.refresh()
        searchBar.searchTextFiled.text = ""
        self.searchBar.searchTextFiled.resignFirstResponder()
    }
    
}

extension MeetingInviteViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return groups.count + dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingFriendsListCell", for: indexPath) as! MeetingFriendsListCell
        cell.currentChooseArray = self.choosedDataSource
        var originData: NSMutableArray = NSMutableArray()
        for item in membersAndGroups {
            originData.add(item)
        }
        cell.originData = originData
        if indexPath.row < groups.count {
            cell.contactData = groups[indexPath.row]
        }else{
            cell.contactData = dataSource[indexPath.row - groups.count]
        }
        cell.selectionStyle = .none
        return cell
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell: MeetingFriendsListCell = tableView.cellForRow(at: indexPath) as! MeetingFriendsListCell
        
        for (_, name) in membersAndGroups.enumerated() {
            if name == cell.contactData?.userName {
                return
            }
        }
        cell.chatButton.setImage(UIImage.set_image(named: "ic_rl_checkbox_selected"), for: UIControl.State.selected)
        if cell.chatButton.isSelected {
            for (index, model) in choosedDataSource.enumerated() {
                let userinfo: ContactData = model as! ContactData
                if userinfo.userName == cell.contactData?.userName {
                    choosedDataSource.remove(at: index)
                    break
                }
            }
            cell.chatButton.isSelected = !cell.chatButton.isSelected
            
        } else {
            if let contactData = cell.contactData {
                choosedDataSource.append(contactData)
            
            }
            cell.chatButton.isSelected = !cell.chatButton.isSelected
            
        }
        updateUI()
    }
    
    
}
