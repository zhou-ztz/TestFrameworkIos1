//
//  GroupListViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 30/04/2019.
//  Copyright © 2019 ZhiYiCX. All rights reserved.
//

import UIKit
import NIMSDK
class GroupListViewController: JoinedGroupListVC, UITableViewDelegate, UITableViewDataSource {

    var teamDataSource: [NIMTeam] = [] {
        didSet {
            teamShowDataArray = teamDataSource
        }
    }
    var teamSearchArray: [NIMTeam] = []
    var teamShowDataArray: [NIMTeam] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "group_chat".localized
        self.searchBar.placeholder = "placeholder_search_message".localized
        self.tableview.mj_footer = nil
        self.tableview.delegate = self
        self.tableview.dataSource = self
    }

    override func getGroupInfo() {
        self.tableview.mj_header.endRefreshing()

        if let teams = NIMSDK.shared().teamManager.allMyTeams() {
            self.tableview.removePlaceholderViews()
            self.teamDataSource = teams.filter { $0.type == NIMTeamType.advanced }
            
        } else {
            self.tableview.show(placeholderView: .empty)
        }
        
        self.tableview.reloadData()
    }
    
    override func loadMore() {}
    
    override func searchGroupName(name: String) {
        if name.isEmpty == true {
            self.isSearchResult = false
            self.teamShowDataArray = self.teamDataSource
            self.tableview.reloadData()
        } else {
            self.teamSearchArray = []
            for item in self.teamDataSource {
                var chatName = item.teamName
                // 忽略字母大小写
                chatName = chatName?.lowercased()
                let lowKey = name.lowercased()
                if (chatName?.range(of: lowKey)) != nil {
                    self.teamSearchArray.append(item)
                }
            }
            self.teamShowDataArray = self.teamSearchArray
            self.tableview.reloadData()
        }
    }
    
    override func refresh() {
        self.teamDataSource = []
        super.refresh()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = self.teamShowDataArray[indexPath.row]
        guard let teamId = team.teamId else {
            return
        }
        let session = NIMSession(teamId, type: NIMSessionType.team)
        let vc = IMChatViewController(session: session, unread: 0)
        navigationController?.pushViewController(vc, animated: true)

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "JoinedGroupListCell", for: indexPath) as! JoinedGroupListCell
        let infoModel = self.teamShowDataArray[indexPath.row]
        cell.nameLab.text = infoModel.teamName
        let avatarInfo = AvatarInfo()
        avatarInfo.verifiedIcon = ""
        avatarInfo.verifiedType = ""
        avatarInfo.avatarURL = infoModel.avatarUrl
        cell.avatarView.avatarPlaceholderType = .group
        cell.avatarView.avatarInfo = avatarInfo
        cell.gruopTagButton.isHidden = true  //!infoModel.isMyGroup
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamShowDataArray.count
    }
}
