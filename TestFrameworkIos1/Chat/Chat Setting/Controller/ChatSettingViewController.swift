//
//  ChatSettingViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 06/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
//import NIMPrivate

class ChatSettingViewController: TSTableViewController {
    
    var members: [TeamMember] = []
    var datasource = [[SettingData]]()
    let session: NIMSession
    var isGroup: Bool = false
    
    var loadingAlert: TSIndicatorWindowTop?
    
    var isPinnedToTop: Bool {
//        if let recentSession = NIMSDK.shared().conversationManager.recentSession(by: session) {
//            return NTESSessionUtil.recentSessionIsMark(recentSession, type: .top)
//        }
        return false
    }
    
    init(session: NIMSession) {
        self.session = session
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "title_group_chat_info".localized
        setupTableView()
        getData()
        
        NIMSDK.shared().conversationManager.add(self)
    }
    
    func setupTableView() {
        self.tableView.backgroundColor = TSColor.inconspicuous.background
//        self.tableView.register(ChatSettingCell.self, forCellReuseIdentifier: ChatSettingCell.cellIdentifier)
        self.tableView.register(ChatSettingButton.self, forCellReuseIdentifier: ChatSettingButton.cellIdentifier)
        self.tableView.register(ChatSettingMemberCell.nib(), forCellReuseIdentifier: ChatSettingMemberCell.cellIdentifier)
        self.tableView.mj_header = nil
        self.tableView.mj_footer = nil
    }
    
    func getData() {
    }
    
    deinit {
        NIMSDK.shared().conversationManager.remove(self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.datasource[indexPath.section][indexPath.row]
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ChatSettingMemberCell.cellIdentifier, for: indexPath) as! ChatSettingMemberCell
            cell.collectionView.delegate = self
            cell.collectionView.dataSource = self
            cell.collectionView.reloadData()
            return cell
        } else {
//            if data.isButton {
                let cell = tableView.dequeueReusableCell(withIdentifier: ChatSettingButton.cellIdentifier, for: indexPath) as! ChatSettingButton
                cell.setTitle(data.name)
                return cell
//            } else {
//                let cell = tableView.dequeueReusableCell(withIdentifier: ChatSettingCell.cellIdentifier, for: indexPath) as! ChatSettingCell
//                cell.setInfo(data, isGroup: isGroup, delegate: self)
//                return cell
//            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section > 0 else { return }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    /// Privates
    
    func showFail() {
        loadingAlert = TSIndicatorWindowTop(state: .faild, title: "error_tips_fail".localized)
        loadingAlert?.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    
    func showSuccess() {
        loadingAlert = TSIndicatorWindowTop(state: .success, title: "change_success".localized)
        loadingAlert?.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    
    func showLoading() {
        loadingAlert = TSIndicatorWindowTop(state: .loading, title: "uploading".localized)
        loadingAlert?.show()
    }
    
    func dismissAlert() {
        loadingAlert?.dismiss()
    }
    
    /// Selectors
    
    @objc func onSetTopValueChange(_ sender: UISwitch) {
//        if sender.isOn {
//            NTESSessionUtil.addRecentSessionMark(self.session, type: .top)
//        } else {
//            NTESSessionUtil.removeRecentSessionMark(self.session, type: .top)
//        }
    }
    
    @objc func onClickClearChat() {
        let alert = TSAlertController(title: "confirm_delete_record".localized, message: nil, style: .alert)
        alert.addAction(TSAlertAction(title: "confirm".localized, style: TSAlertActionStyle.destructive, handler: { [weak self] _ in
            guard let self = self else {
                return
            }
            let option = NIMDeleteMessagesOption()
            option.removeSession = BundleSetting.sharedConfig().removeSessionWhenDeleteMessages()
            option.removeTable = BundleSetting.sharedConfig().dropTableWhenDeleteMessages()
            NIMSDK.shared().conversationManager.deleteAllmessages(in: self.session, option: option)
        }))
        self.presentPopup(alert: alert)
    }
    
    @objc func onClickSearchMessages() {
        let vc = SearchChatHistoryTableViewController(session: session)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showUserHomePage(_ userId: Any) {
        
       // var userHomPage: HomePageViewController? = nil
        
        if userId is Int {
          //  userHomPage = HomePageViewController(userId: userId as! Int)
            FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: userId as! Int, username: nil, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
        } else if userId is String {
            FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: 0, username: userId as? String, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
           // userHomPage = HomePageViewController(userId: 0, username: userId as! String)
        }
        
//        if userHomPage != nil  {
//            self.navigationController?.pushViewController(userHomPage!, animated: true)
//        } else {
//            self.showError(message: "please_retry_option".localized)
//        }
    }
    
    func showContactsPicker() {
        let vc = ChatFriendListViewController()
        vc.ischangeGroupMember = .add
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showViewMoreMembers() {
        
    }
    
    func showRemoveMemberSelector() {
        
    }
    
    func onTapMember(at index: Int) {
        
    }
}

extension ChatSettingViewController: NIMConversationManagerDelegate {
    func messagesDeleted(in session: NIMSession) {
        if session == self.session {
            let view = TSIndicatorWindowTop(state: .success, title: "change_success".localized)
            view.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
        }
    }
}

extension ChatSettingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatMemberCell.cellIdentifier, for: indexPath) as! ChatMemberCell
        cell.setData(members[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let member = members[indexPath.row]
        if member.isAdd {
            self.showContactsPicker()
        } else if member.isReduce {
            self.showRemoveMemberSelector()
        } else if member.isViewMore {
            self.showViewMoreMembers()
        } else {
            onTapMember(at: indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: tableView.bounds.width / 5, height: 70)
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
