//
//  TSLikeListTableVCTableViewController.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  点赞列表控制器
//  注：该界面应完全自定义，而不是考虑继承。那边写的乱七八糟的，反而不利于维护和自定义扩展。

import UIKit

typealias TSLikeListType = TSFavorTargetType

class TSLikeListTableVC: TSRankingListTableViewController {
    /// 点赞用户列表
    var likeUserModels: [TSLikeUserModel] = []
    /// 是否是下拉刷新
    var isRefresh = false
    /// 点赞列表类型
    let type: TSLikeListType
    /// 点赞资源id
    let sourceId: Int
    /// 请求列表中最后一个的id
    var lastId: Int = 0
    
    var selectedCell: IndexPath? = nil
    
    // MARK: - Lifecycle
    /// 注：圈子的点赞列表需传入groupId
    init(type: TSLikeListType, sourceId: Int) {
        self.type = type
        self.sourceId = sourceId
        super.init(cellType: .concernCell)
        self.isEnabledHeaderButton = false
        self.userId = (CurrentUserSessionInfo?.userIdentity)!
        self.title = "title_notification_like".localized
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshFollowButton), name: Notification.Name("UpdateFollowInfo"), object: nil)
        self.tableView.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedCell = nil
    }
    
    // MARK: - refresh
    override func refresh() {
        self.requestData(.refresh)
    }

    override func loadMore() {
        self.requestData(.loadmore)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCell = indexPath
//        let userId = self.listData[indexPath.row].userIdentity
//        let userHomPage = HomePageViewController(userId: userId)
//        navigationController?.pushViewController(userHomPage, animated: true)
    }

    override func cell(_ cell: TSTableViewCell, operateBtn: TSButton, indexPathRow: NSInteger) {
//        let userModel = listData[indexPathRow]
//        userModel.follower = !userModel.follower
//        listData[indexPathRow] = userModel
//        operateBtn.setTitle("Loading...".localized, for: .normal)
//        TSDataQueueManager.share.moment.start(follow: userModel.userIdentity, isFollow: userModel.follower)
//        self.tableView.reloadData()
//        self.tableView.setNeedsLayout()
    }
    
    @objc func refreshFollowButton() {
//        guard let selectedCell = self.selectedCell else {
//            return
//        }
//        let userModel = listData[selectedCell.row]
//        userModel.follower = !userModel.follower
//        listData[selectedCell.row] = userModel
//        self.tableView.reloadRows(at: [selectedCell], with: .none)
//        TSDataQueueManager.share.moment.start(follow: userModel.userIdentity, isFollow: userModel.follower)
    }

}

extension TSLikeListTableVC {
    func requestData(_ loadType: TSListDataLoadType) -> Void {
        switch loadType {
        case .initial:
            fallthrough
        case .refresh:
            TSFavorNetworkManager.favorList(targetId: self.sourceId, targetType: self.type, afterId: 0, limit: self.showFootDataCount, complete: { [weak self] (likeList, msg, status) in
                
                guard let weakSelf = self else {
                    return
                }
                
                self?.tableView.mj_header.endRefreshing()
                
                // 网络请求失败处理
                guard status, let likeList = likeList else {
                    weakSelf.show(placeholderView: .network)
                    return
                }
                
                // 列表为空处理
                if likeList.isEmpty {
                    weakSelf.show(placeholderView: .empty)
                    return
                } else {
                    weakSelf.lastId = likeList.last!.id
                    weakSelf.removePlaceholderViews()
                }
                /// 正常数据处理
                weakSelf.likeUserModels = likeList
                var userList = [UserInfoModel]()
                for likeUser in likeList {
                    userList.append(likeUser.userDetail)
                }
                weakSelf.listData = userList
                //self?.dismissIndicatorA()
                weakSelf.tableView.reloadData()
            })
        case .loadmore:
            TSFavorNetworkManager.favorList(targetId: self.sourceId, targetType: self.type, afterId: self.lastId, limit: self.showFootDataCount, complete: { [weak self] (likeList, _, status) in
                
                guard let weakSelf = self else {
                    return
                }
                // 网络请求失败处理
                guard status, let likeList = likeList else {
                    weakSelf.tableView.mj_footer.endRefreshingWithWeakNetwork()
                    return
                }
                // 列表为空处理
                if likeList.isEmpty {
                    weakSelf.tableView.mj_footer.endRefreshingWithNoMoreData()
                    return
                } else {
                    weakSelf.lastId = likeList.last!.id
                    weakSelf.tableView.mj_footer.endRefreshing()
                }
                /// 正常数据处理
                weakSelf.likeUserModels += likeList
                var userList = [UserInfoModel]()
                for likeUser in weakSelf.likeUserModels {
                    userList.append(likeUser.userDetail)
                }
                weakSelf.listData = userList
                weakSelf.tableView.reloadData()
            })
        }
    }
}
