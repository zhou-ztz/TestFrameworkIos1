//
//  MembersViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 24/06/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import Toast
import NIMSDK
//import NIMPrivate

class MembersViewController: TSViewController, UISearchBarDelegate {
    var mainCollectionView: UICollectionView? = nil
    /// 搜索框
    var searchBar: TSSearchBar!
    let teamId: String
    let canEditTeamInfo: Bool
    var members: [TeamMember] = [] {
        didSet {
            teamMemberShowDataArray = members
        }
    }

    var teamMemberSearchArray: [TeamMember] = []
    var teamMemberShowDataArray: [TeamMember] = []
    
    init(teamId: String, canEditTeamInfo: Bool) {
        self.teamId = teamId
        self.canEditTeamInfo = canEditTeamInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NIMSDK.shared().teamManager.add(self)
        setSearchBarUI()
        createCollectionView()
        self.mainCollectionView?.mj_header.beginRefreshing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        searchBar?.resignFirstResponder()
    }

    deinit {
        NIMSDK.shared().teamManager.remove(self)
    }
    
    func setSearchBarUI() {
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 47))
        bgView.backgroundColor = UIColor.white
        self.view.addSubview(bgView)
        self.searchBar = TSSearchBar(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: bgView.height))
        self.searchBar.layer.masksToBounds = true
        self.searchBar.layer.cornerRadius = 5.0
        self.searchBar.backgroundImage = nil
        self.searchBar.backgroundColor = UIColor.white
        self.searchBar.returnKeyType = .search
        self.searchBar.barStyle = UIBarStyle.default
        self.searchBar.barTintColor = UIColor.clear
        self.searchBar.tintColor = TSColor.main.theme
        self.searchBar.searchBarStyle = UISearchBar.Style.minimal
        self.searchBar.delegate = self
        self.searchBar.placeholder = "placeholder_search_message".localized
        bgView.addSubview(self.searchBar)
    }
    
    func createCollectionView() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        self.mainCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64), collectionViewLayout: collectionViewLayout)
        self.mainCollectionView?.showsVerticalScrollIndicator = false
        self.mainCollectionView?.backgroundColor = UIColor.white
        self.mainCollectionView?.delegate = self
        self.mainCollectionView?.dataSource = self

        self.mainCollectionView?.mj_header = TSRefreshHeader(refreshingBlock: { [weak self] in
            guard let self = self else { return }
            self.fetchMembers()
        })

        self.mainCollectionView?.mj_footer = nil
        
        self.mainCollectionView?.register(ChatMemberCell.nib(), forCellWithReuseIdentifier: ChatMemberCell.cellIdentifier)
        self.view.addSubview(self.mainCollectionView!)
        mainCollectionView?.snp.makeConstraints({
            $0.top.equalTo(searchBar.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        })
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.searchMemberName(name: searchBar.text ?? "")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchMemberName(name: searchBar.text ?? "")
    }
    
    func searchMemberName(name: String) {
//        if name.isEmpty == true {
//            self.teamMemberShowDataArray = self.members
//            self.mainCollectionView?.reloadData()
//        } else {
//            self.teamMemberSearchArray = []
//            for item in self.members {
//                var chatName = item.memberInfo?.nickname
//                
//                if chatName == nil {
//                    let info = NIMBridgeManager.sharedInstance().getUserInfo(item.memberInfo?.userId ?? "")
//                    chatName = info.showName
//                }
//                // 忽略字母大小写
//                chatName = chatName?.lowercased()
//                let lowKey = name.lowercased()
//                if (chatName?.range(of: lowKey)) != nil {
//                    self.teamMemberSearchArray.append(item)
//                }
//            }
//            self.teamMemberShowDataArray = self.teamMemberSearchArray
//            self.mainCollectionView?.reloadData()
//        }
    }

    func fetchMembers() {
        NIMSDK.shared().teamManager.fetchTeamMembers(teamId) { [weak self] (error, members) in
            guard let self = self else { return }
            if let members = members {
                var teamMembers = [TeamMember]()
                teamMembers = members.filter { $0.type == .owner }.compactMap { TeamMember(memberInfo: $0) }
                teamMembers.append(contentsOf: members.filter { $0.type == .manager }.compactMap { TeamMember(memberInfo: $0) })
                teamMembers.append(contentsOf: members.filter { $0.type == .normal }.compactMap { TeamMember(memberInfo: $0) })
                
                self.members = teamMembers
                
                DispatchQueue.main.async {
                    self.setCloseButton(backImage: true, titleStr: String(format: "text_group_member".localized, "\(self.members.count)"))
                    self.mainCollectionView?.reloadData()
                    self.mainCollectionView?.mj_header.endRefreshing()
                }
            }
        }
    }
    
    func onTapMember(at index: Int) {
        guard let teamMember : TeamMember = teamMemberShowDataArray[safe: index], let member : NIMTeamMember = teamMember.memberInfo, let memberId = member.userId, let userId = CurrentUserSessionInfo?.userIdentity else { return }
        
        /// Show user profile if self is tapped
        if memberId == CurrentUserSessionInfo?.username {
            FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: 0, username: memberId, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
//            let vc = HomePageViewController(userId: 0, username: memberId)
//            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let teamHandler: NIMTeamHandler? = { [weak self] error in
            guard let self = self else { return }
            guard error == nil else {
                self.showTopIndicator(status: .faild, "error_tips_fail".localized)
                return
            }
            self.showTopIndicator(status: .success, "change_success".localized)
        }
        
        TSUserNetworkingManager().getUsersInfo(usersId: [], names: [], userNames: [memberId]) { [weak self] (models, msg, status) in
            guard let self = self else { return }
            guard let model = models?.first else {
                self.showError(message: "text_user_suspended".localized)
                return
            }
            
            var titles = [model.name, "group_view_profile".localized]
            
            if model.followStatus == .eachOther {
                titles.append("group_member_info_send_message".localized)
            }
            
            if self.canEditTeamInfo {
                if member.type == .normal {
                    titles.append("group_make_admin".localized)
                }
                
                if member.type == .manager {
                    titles.append("group_remove_admin".localized)
                }
                
                titles.append("group_remove_member".localized)
            }
            
            let actionsheetView = TSCustomActionsheetView(titles: titles)
            if self.canEditTeamInfo {
                actionsheetView.setColor(color: TSColor.main.warn, index: titles.count - 1)
            }
            actionsheetView.setColor(color: TSColor.normal.minor, index: 0)
            actionsheetView.tag = 1
            actionsheetView.notClickIndexs = [0]
            actionsheetView.show()
            actionsheetView.finishBlock = { [weak self] _, title, _ in
                guard let self = self else { return }
                switch title {
                case "group_view_profile".localized:
                    FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: model.userIdentity, username: memberId, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
//                    let vc = HomePageViewController(userId: model.userIdentity, username: memberId)
//                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "group_member_info_send_message".localized:
                    let vc = IMChatViewController(session: NIMSession(memberId, type: .P2P), unread: 0)
                    self.navigationController?.pushViewController(vc, animated: true)
                case "group_make_admin".localized:
                    NIMSDK.shared().teamManager.addManagers(toTeam: member.teamId.orEmpty, users: [memberId], completion: teamHandler)
                case "group_remove_admin".localized:
                    NIMSDK.shared().teamManager.removeManagers(fromTeam: member.teamId.orEmpty, users: [memberId], completion: teamHandler)
                case "group_remove_member".localized:
                    self.showAlert(title: nil, message: "team_member_remove_confirm".localized, buttonTitle: "confirm".localized, defaultAction: { _ in
                        NIMSDK.shared().teamManager.kickUsers([memberId], fromTeam: member.teamId.orEmpty, completion: { [weak self] error in
                            guard let self = self else { return }
                            guard error == nil else {
                                self.showTopIndicator(status: .faild, "remove_member_failed".localized)
                                return
                            }
                            self.showTopIndicator(status: .success, "change_success".localized)
                        })
                    }, cancelTitle: "cancel".localized, cancelAction: nil)
                default:
                    break
                }
            }
        }
    }
}

extension MembersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teamMemberShowDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatMemberCell.cellIdentifier, for: indexPath) as! ChatMemberCell
        cell.setData(teamMemberShowDataArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.searchBar?.resignFirstResponder()
        onTapMember(at: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width / 5, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension MembersViewController: NIMTeamManagerDelegate {
    func onTeamMemberChanged(_ team: NIMTeam) {
        self.mainCollectionView?.mj_header.beginRefreshing()
    }
}
