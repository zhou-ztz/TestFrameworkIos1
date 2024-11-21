//
//  TSUserSearchView.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/6.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
protocol UserSearchViewDelegate: class {
    func didClickChatButton(_ username: String)
}

class TSUserSearchView: TSTableView, UITableViewDelegate, UITableViewDataSource {

    /// 占位图
    let occupiedView = UIImageView()
    /// 数据源
    var userDataSource: [UserInfoModel] = []
    /// 搜索关键词
    var keyword = "" {
        didSet {
            if keyword.isEmpty {
                show(placeholderView: .empty)
            } else {
                mj_header.beginRefreshing()
//                TSDatabaseManager().quora.deleteByContent(content: keyword)
//                TSDatabaseManager().quora.saveSearchObject(content: keyword, type: .homeSearch)
            }
        }
    }

    weak var customDelegate: UserSearchViewDelegate?

    init(frame: CGRect) {
        super.init(frame: frame, style: .plain)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    // MARK: - refresh
    override func refresh() {
        // 2.有搜索内容，展示与搜索内容相关的用户
        let extras = TSUtil.getUserID(remarkName: keyword)
        TSNewFriendsNetworkManager.searchUsers(keyword: keyword, extras: extras, offset: 0) { [weak self] (datas: [UserInfoModel]?, message: String?, _) in
            self?.processRefresh(datas: datas, message: message)
        }
    }

    override func loadMore() {
        guard userDataSource.count != 0 else {
            // 1.不输入搜索内容，显示的是后台推荐用户，后台推荐用户没有分页
            mj_footer.endRefreshingWithNoMoreData()
            return
        }
        let extras = TSUtil.getUserID(remarkName: keyword)
        TSNewFriendsNetworkManager.searchUsers(keyword: keyword, extras: extras, offset: userDataSource.count) { [weak self] (datas: [UserInfoModel]?, _, _) in
            guard let weakSelf = self else {
                return
            }
            guard let datas = datas else {
                weakSelf.mj_footer.endRefreshing()
                return
            }
            if datas.count < TSNewFriendsNetworkManager.limit {
                weakSelf.mj_footer.endRefreshingWithNoMoreData()
            } else {
                weakSelf.mj_footer.endRefreshing()
            }
            weakSelf.userDataSource = weakSelf.userDataSource + datas
            weakSelf.reloadData()
        }
    }
    

    func processRefresh(datas: [UserInfoModel]?, message: String?) {
        mj_footer.resetNoMoreData()
        // 获取数据成功
        if let datas = datas {
            userDataSource = datas
            if userDataSource.isEmpty {
                show(placeholderView: .empty)
            }
        }
        // 获取数据失败
        if message != nil {
            userDataSource = []
            show(placeholderView: .network)
        }
        if mj_header.isRefreshing {
            mj_header.endRefreshing()
        }
        reloadData()
    }

    // MARK: UI
    func setUI() {
        //tableview
        delegate = self
        dataSource = self
        rowHeight = 77.5
        separatorStyle = .none
        register(DiscoverUserTableViewCell.self, forCellReuseIdentifier: DiscoverUserTableViewCell.identifier)
        refresh()
    }

    private func updateFollowStatus(indexPath:IndexPath) {
        // 1.判断是否为游客模式
        if !TSCurrentUserInfo.share.isLogin {
            // 如果是游客模式，拦截操作显示登录界面
            TSRootViewController.share.guestJoinLandingVC()
            return
        }
        // 2.进行关注操作
         var userInfo = userDataSource[indexPath.row]

        guard let relationship = userInfo.relationshipWithCurrentUser else {
            TSRootViewController.share.guestJoinLandingVC()
            return
        }
        if relationship.status == .eachOther {
            self.customDelegate?.didClickChatButton(userInfo.username)
        } else {
//            userInfo.follower = !userInfo.follower
//            userDataSource[indexPath.row] = userInfo
//            self.reloadRows(at: [indexPath], with: .none)
//            TSDataQueueManager.share.moment.start(follow: userInfo.userIdentity, isFollow: userInfo.follower)
//            let followstatus = userInfo.follower == true ? "1" : "0"
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil, userInfo: ["follow": followstatus,"userid": "\(userInfo.userIdentity)"])
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mj_footer.isHidden = userDataSource.count < TSNewFriendsNetworkManager.limit
        if !userDataSource.isEmpty {
            self.removePlaceholderViews()
        }
        return userDataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiscoverUserTableViewCell.identifier, for: indexPath) as! DiscoverUserTableViewCell
        cell.setInfo(model: userDataSource[indexPath.row])
        cell.selectionStyle = .none
        cell.relationshipButton.addTap { [weak self] (button) in
            guard let self = self else { return }
            self.updateFollowStatus(indexPath: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = userDataSource[indexPath.row]
        // 头像默认点击事件
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": model.userIdentity])
    }
}
