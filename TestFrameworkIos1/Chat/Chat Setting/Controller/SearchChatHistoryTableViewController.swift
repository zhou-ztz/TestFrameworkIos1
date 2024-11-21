//
//  SearchChatHistoryTableViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 02/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
//import NIMPrivate

class SearchChatHistoryTableViewController: TSViewController, UISearchBarDelegate {
    /// IM第二版聊天列表页面
    var tableView: TSTableView!
    /// 搜索框
    var searchBar: TSSearchBar!
    var dataSource = [NIMMessage]()
    
    let session: NIMSession
    var lastOption: NIMMessageSearchOption?
    var searchData = [SearchLocalHistoryObject]()
    var members = [String]()
    
    init(session: NIMSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        searchBar?.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setCloseButton(backImage: true, titleStr: "search_message".localized)
        setSearchBarUI()
        self.tableView = TSTableView(frame: .zero, style: .plain)
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(self.loadMore))
        self.tableView.mj_footer.isHidden = true
        self.tableView.register(TSConversationTableViewCell.nib(), forCellReuseIdentifier: TSConversationTableViewCell.cellReuseIdentifier)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        self.prepareMember()
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

    // MARK: - Actions
    @objc func refresh() {
        guard let data = searchData.first else {return}
        let obj: SearchLocalHistoryObject = data
        if BundleSetting.sharedConfig().localSearchOrderByTimeDesc() == false {
            self.lastOption?.startTime = 0
            self.lastOption?.endTime = obj.message?.timestamp ?? 0
        } else {
            self.lastOption?.startTime  = obj.message?.timestamp ?? 0
            self.lastOption?.endTime = 0
        }
        searchHistory(lastOption, loadMore: false)
    }
    
    @objc func loadMore() {
        guard let data = searchData.last else {return}
        let obj: SearchLocalHistoryObject = data
        if BundleSetting.sharedConfig().localSearchOrderByTimeDesc() == false {
            self.lastOption?.startTime = obj.message?.timestamp ?? 0
            self.lastOption?.endTime = 0
        } else {
            self.lastOption?.startTime = 0
            self.lastOption?.endTime  = obj.message?.timestamp ?? 0
        }
        searchHistory(lastOption, loadMore: true)
    }
    
    func searchUsers(byKeyword keyword: String?, users: [AnyHashable]?) -> [AnyHashable]? {
        var data: [AnyHashable] = []
//        for uid in users ?? [] {
//            guard let uid = uid as? String else {
//                continue
//            }
//            let info: NIMKitInfo = NIMBridgeManager.sharedInstance().getUserInfo(uid)
//            data.append(info)
//        }
//        let predicate = NSPredicate(format: "SELF.showName CONTAINS[cd] %@", keyword ?? "")
//        let array = (data as NSArray).filtered(using: predicate)
        var output: [AnyHashable] = []
//        for info in array {
//            guard let info = info as? NIMKitInfo else {
//                continue
//            }
//            output.append(info.infoId)
//        }
        return output
    }
    
    func prepareMember() {
        if session == nil {
            return
        }
        if self.session.sessionType == .team {
            NIMSDK.shared().teamManager.fetchTeamMembers(self.session.sessionId) {[weak self] (error, teamMembers) in
                guard let self = self , let members = teamMembers else { return }
                var memberIds = [String]()
                memberIds = members.filter({ $0.userId != nil }).map({ $0.userId ?? "" })
                self.members = memberIds
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchData.count > 0 {
            self.searchData.removeAll()
            self.tableView.reloadData()
        }
     
        if searchText.count == 0 {
            self.tableView.mj_footer.isHidden = true
        }
        let option = NIMMessageSearchOption()
        option.searchContent = searchText
        let uids = searchUsers(byKeyword: self.searchBar.text, users: members)
        option.fromIds = uids as! [String]
        option.limit = 10
        option.order = BundleSetting.sharedConfig().localSearchOrderByTimeDesc() ? .desc : .asc
        option.allMessageTypes = true
        self.lastOption = option
        searchHistory(lastOption, loadMore: true)
    }
    
    func searchHistory(_ option: NIMMessageSearchOption?, loadMore: Bool) {
        if searchBar.text.orEmpty.isEmpty {
            self.searchData = []
           // self.dataSource = []
            self.tableView.reloadData()
            return
        }
        
        if let option = option  {
            option.order = .asc
            NIMSDK.shared().conversationManager.searchMessages(session, option: option) { [weak self] (error, messages) in
                guard let self = self, var messages = messages else { return }
                self.tableView.mj_footer.isHidden = false
                if self.tableView.mj_header.isRefreshing {
                    self.tableView.mj_header.endRefreshing()
                }
                if self.tableView.mj_footer.isRefreshing {
                    self.tableView.mj_footer.endRefreshing()
                }
                
                var array = [SearchLocalHistoryObject]()
                for message in messages {
                    let obj = SearchLocalHistoryObject(message: message)
                    obj.type = .searchLocalHistoryTypeContent
                    array.append(obj)
                }
                
                if loadMore {
                    self.searchData.append(contentsOf: array)
                    self.tableView.tableFooterView = array.count == 10 ? self.tableView.tableFooterView : UIView()
                } else {
                    array.append(contentsOf: self.searchData)
                    self.searchData = array
                }
                self.tableView.reloadData()
            }
        }
    }
}

extension SearchChatHistoryTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = searchData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: TSConversationTableViewCell.cellReuseIdentifier, for: indexPath) as! TSConversationTableViewCell
        cell.message = data.message
        cell.delegate = self
        cell.currentIndex = indexPath.row
        cell.pinIcon.isHidden = true
        cell.muteIcon.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kTSConversationTableViewCellDefaltHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = searchData[indexPath.row]
        let vc = IMSessionHistoryViewController(session: self.session, message: data.message!)
        self.navigationController?.pushViewController(vc, animated: false)

    }
}

extension SearchChatHistoryTableViewController: TSConversationTableViewCellDelegate {
    func headButtonDidPress(for userId: Int) {
        
    }
}
