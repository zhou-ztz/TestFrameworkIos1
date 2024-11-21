//
//  TSAtpeopleListVC.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司-zhi on 2023/7/28.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class TSAtpeopleListVC: TSViewController , UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, TSMyFriendListCellDelegate {
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
    var keyword: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        createSearchView()
        
        friendListTableView = TSTableView(frame: CGRect(x: 0, y: 60, width: ScreenWidth, height: ScreenHeight - 64 - 60), style: UITableView.Style.plain)
        friendListTableView.delegate = self
        friendListTableView.dataSource = self
        friendListTableView.separatorStyle = .none
        friendListTableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        friendListTableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        
        view.addSubview(friendListTableView)
        friendListTableView.mj_header.beginRefreshing()
        friendListTableView.snp_makeConstraints { make in
            make.top.equalTo(60)
            make.bottom.left.right.equalTo(0)
        }
        occupiedView.contentMode = .center
        
        var request = UserNetworkRequest().readCounts
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = ["type": "mutual"]
        RequestNetworkData.share.text(request: request) { (_) in }
    }

    // MARK: - 创建搜索一系列视图
    func createSearchView() {
        searchView.backgroundColor = UIColor.white
        
        searchTextfield.font = UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
        searchTextfield.textColor = .black
        searchTextfield.placeholder = "placeholder_search_message".localized
        searchTextfield.backgroundColor = TSColor.normal.placeholder
        searchTextfield.layer.cornerRadius = 20
        searchTextfield.isUserInteractionEnabled = true
        searchTextfield.returnKeyType = .search
        searchView.addSubview(searchTextfield)
        searchTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchTextfield.delegate = self
        let leftView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let searchIcon = FadeImageView()
        searchIcon.image = UIImage.set_image(named: "IMG_search_icon_search")
        searchIcon.contentMode = .center
        searchIcon.frame = CGRect(x: 5, y: 6, width: 35, height: 28)
        leftView.addSubview(searchIcon)
        searchTextfield.leftView = leftView
        searchTextfield.leftViewMode = .always
        searchTextfield.clearButtonMode = .whileEditing
        
        
        // 占位图
        occupiedView.backgroundColor = UIColor.white
        occupiedView.contentMode = .center
        searchTextfield.snp.makeConstraints { (make) in make.edges.equalToSuperview() }

        let wrapper = CustomTitleView()
        wrapper.addSubview(searchView)
        self.view.addSubview(wrapper)
        wrapper.snp.makeConstraints {
            $0.left.right.top.centerY.equalToSuperview()
            $0.height.equalTo(60)
        }
        searchView.snp.makeConstraints {
            $0.left.equalTo(15)
            $0.right.equalTo(-15)
            $0.top.equalTo(10)
            $0.height.equalTo(40)
        }
        
    }
   
    @objc func refresh() {
        if !isSearching {
            TSUserNetworkingManager().friendList(offset: nil, keyWordString: keyword, filterMerchants: "1", complete: { (userModels, networkError) in
                // 如果是第一次进入
                self.friendListTableView.mj_header.endRefreshing()
                self.processRefresh(datas: userModels, message: networkError)
            })
        }
    }

    @objc func loadMore() {
        TSUserNetworkingManager().friendList(offset: dataSource.count, keyWordString: keyword, filterMerchants: "1", complete: { (userModels, networkError) in
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
        
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.keyword = textField.text
        self.refresh()
        searchTextfield.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count == 0 {
            self.keyword = ""
            self.refresh()
        }
        
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
        cell?.chatButton.isHidden = true
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]

        if self.selectedBlock != nil {
            self.selectedBlock!(model)
            return
        }
    }

    func processRefresh(datas: [UserInfoModel]?, message: NetworkError?) {
        friendListTableView.mj_footer.resetNoMoreData()
        // 获取数据成功
        if let datas = datas {
            dataSource = datas
            if dataSource.isEmpty {
                friendListTableView.show(placeholderView: .emptyResult)
            }else{
                friendListTableView.removePlaceholderViews()
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
        
    }

    /// 跳转到搜索页
    func pushSearchPeopleVC() {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
