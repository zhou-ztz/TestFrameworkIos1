//
//  TSFriendsListVC.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2017/12/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import NIMSDK

class CustomTitleView: UIView {
  override var intrinsicContentSize: CGSize {
    return UIView.layoutFittingExpandedSize
  }
}

class TSFriendsListVC: TSViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, TSMyFriendListCellDelegate {
    /// 数据源
    var dataSource: [UserInfoModel] = [] {
        willSet {
            if newValue.isEmpty {
                friendListTableView.removePlaceholderViews()
            }
        }
    }
    var friendListTableView: TSTableView!
    let searchView = CustomTitleView()
    var searchTextfield = UITextField()
    /// 占位图
    let occupiedView = FadeImageView()
    var selectedBlock: ((UserInfoModel) -> Void)?
    
    private let occupiedText = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 50, height: 50))
    var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSearchView()
        prepareViews()
        
        friendListTableView = TSTableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - 64), style: UITableView.Style.plain)
        friendListTableView.delegate = self
        friendListTableView.dataSource = self
        friendListTableView.separatorStyle = .none
        friendListTableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        friendListTableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
        view.addSubview(friendListTableView)
        friendListTableView.mj_header.beginRefreshing()
        
        occupiedView.contentMode = .center
        
        var request = UserNetworkRequest().readCounts
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = ["type": "mutual"]
        RequestNetworkData.share.text(request: request) { (_) in }
    }

    // MARK: - 创建搜索一系列视图
    func createSearchView() {
        searchView.backgroundColor = UIColor.white
        
        let tap = UITapGestureRecognizer { (_) in
            self.pushSearchPeopleVC()
        }
        searchView.addGestureRecognizer(tap)
        searchTextfield.font = UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
        searchTextfield.textColor = TSColor.normal.minor
        searchTextfield.placeholder = "placeholder_search_message".localized
        searchTextfield.backgroundColor = TSColor.normal.placeholder
        searchTextfield.layer.cornerRadius = 5
        searchTextfield.isUserInteractionEnabled = false
        
        searchView.addSubview(searchTextfield)


        let searchIcon = FadeImageView()
        searchIcon.image = UIImage.set_image(named: "IMG_search_icon_search")
        searchIcon.contentMode = .center
        searchIcon.frame = CGRect(x: 0, y: 0, width: 35, height: 27)
        searchTextfield.leftView = searchIcon
        searchTextfield.leftViewMode = .always
        
        
        // 占位图
        occupiedView.backgroundColor = UIColor.white
        occupiedView.contentMode = .center
        searchTextfield.snp.makeConstraints { (make) in make.edges.equalToSuperview() }

        if #available(iOS 11, *) {
            let wrapper = CustomTitleView()
            wrapper.addSubview(searchView)
            
            searchView.snp.makeConstraints {
                $0.left.right.centerY.equalToSuperview()
                $0.height.equalTo(27)
            }
            
            searchIcon.snp.makeConstraints {
                $0.height.equalTo(27)
                $0.width.equalTo(35)
            }
            
            self.navigationItem.titleView = wrapper
        } else {
            searchView.frame = CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 33)
            self.navigationItem.titleView = searchView
        }
    }
    
    func prepareViews() {
        let tap = UITapGestureRecognizer { [weak self] (_) in
            self?.pushSearchPeopleVC()
        }
        searchView.addGestureRecognizer(tap)
        
        let addFriendBt: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 27, height: 33))
        addFriendBt.setImage(UIImage.set_image(named: "ico_addfriends"), for: UIControl.State.normal)
        addFriendBt.addTarget(self, action: #selector(addFriendButtonClick), for: UIControl.Event.touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addFriendBt)
        
    }

    @objc func refresh() {
        if !isSearching {
            TSUserNetworkingManager().friendList(offset: nil, keyWordString: nil, complete: { (userModels, networkError) in
                // 如果是第一次进入
                self.friendListTableView.mj_header.endRefreshing()
                self.processRefresh(datas: userModels, message: networkError)
            })
        }
    }

    @objc func loadMore() {
        TSUserNetworkingManager().friendList(offset: dataSource.count, keyWordString: nil, complete: { (userModels, networkError) in
            guard let datas = userModels else {
                self.friendListTableView.mj_footer.endRefreshing()
                return
            }
            if datas.count < TSNewFriendsNetworkManager.limit {
                self.friendListTableView.mj_footer.endRefreshingWithNoMoreData()
            } else {
                self.friendListTableView.mj_footer.endRefreshing()
            }
            self.dataSource = self.dataSource + datas
            self.friendListTableView.reloadData()
        })
    }

    // MARK: - 添加好友按钮点击事件（跳转到找人页面）
    @objc func addFriendButtonClick() {
//        let vc = TSNewFriendsVC.vc()
//        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let vc = TSFriendSearchVC.vc()
        let nav = TSNavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
        return false
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friendListTableView.mj_footer.isHidden = dataSource.count < TSNewFriendsNetworkManager.limit
        if !dataSource.isEmpty {
            occupiedView.removeFromSuperview()
        }
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "fiendlistcell"
        var cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as? TSMyFriendListCell
        if cell == nil {
            cell = TSMyFriendListCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: indentifier)
        }
        cell?.setUserInfoData(model: dataSource[indexPath.row])
        cell?.delegate = self
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]

        if let block = self.selectedBlock {
            self.dismiss(animated: true) {
                block(model)
            }
            return
        }
        // 头像默认点击事件
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": model.userIdentity])
    }

    func processRefresh(datas: [UserInfoModel]?, message: NetworkError?) {
        friendListTableView.mj_footer.resetNoMoreData()
        // 获取数据成功
        if let datas = datas {
            dataSource = datas
            if dataSource.isEmpty {
                friendListTableView.show(placeholderView: .emptyResult)
            }
        }
        // 获取数据失败
        if message != nil {
            dataSource = []
            friendListTableView.show(placeholderView: .network)
        }
        friendListTableView.reloadData()
    }

    // MARK: - TSMyFriendListCellDelegate
    func chatWithUserName(userName: String) {
//        let session = NIMSession(userName, type: .P2P)
//        let vc = IMChatViewController(session: session, unread: 0)
//        navigationController?.pushViewController(vc, animated: true)
    }

    /// 跳转到搜索页
    func pushSearchPeopleVC() {
//        let vc = TSNewFriendsSearchVC.vc()
//        vc.isJustSearchFriends = true
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
