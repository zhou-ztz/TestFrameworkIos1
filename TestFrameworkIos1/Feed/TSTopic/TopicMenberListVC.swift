//
//  TopicMenberListVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/1.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TopicMenberListVC: TSRankingListTableViewController {

    /// 话题ID
    var topicId: Int = 0
    // MARK: - Lifecycle
    init(topicId: Int) {
        super.init(cellType: .concernCell)
        self.topicId = topicId
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    func setUI() {
        title = "topics_people_involved".localized
        self.view.backgroundColor = TSColor.inconspicuous.background
        self.isEnabledHeaderButton = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.mj_header.beginRefreshing()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - process refresh
    override func refresh() {
        TSUserNetworkingManager().getTopicMenberList(groupId: self.topicId, limit: 15, offset: nil) { [weak self] (userModels, _, status) in
            self?.removePlaceholderViews()
            
            if status {
                self?.tableView.mj_header.endRefreshing()
                if let userModels = userModels {
                    if userModels.isEmpty {
                        self?.show(placeholderView: .empty)
                        return
                    }
                    self?.listData = userModels
                    self?.tableView.reloadData()
                }
            } else {
                self?.show(placeholderView: .network)
                self?.tableView.mj_header.endRefreshing()
            }
        }
    }

    override func loadMore() {
        let offset = self.listData.count
        TSUserNetworkingManager().getTopicMenberList(groupId: self.topicId, limit: 15, offset: offset) { [weak self] (userModels, _, status) in
            if status {
                if let userModels = userModels {
                    if userModels.isEmpty {
                        self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                        return
                    }
                    if let weakSelf = self {
                        weakSelf.listData = weakSelf.listData + userModels
                        weakSelf.tableView.reloadData()
                        self?.tableView.mj_footer.endRefreshing()
                    }
                }
            } else {
                self?.tableView.mj_footer.endRefreshingWithWeakNetwork()
            }
        }
    }

    // MARK: - tableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let userId = self.listData[indexPath.row].userIdentity
//        let userHomPage = HomePageViewController(userId: userId)
//        navigationController?.pushViewController(userHomPage, animated: true)
    }

    // MAKR: - cell delegate
    override func cell(_ cell: TSTableViewCell, operateBtn: TSButton, indexPathRow: NSInteger) {
//        let userInfo = self.listData[indexPathRow]
//        userInfo.follower = !userInfo.follower
//        self.listData[indexPathRow] = userInfo
//        let indexPath = IndexPath(row: indexPathRow, section: 0)
//        self.tableView.reloadRows(at: [indexPath], with: .none)
//        TSDataQueueManager.share.moment.start(follow: userInfo.userIdentity, isFollow: userInfo.follower)
    }

}
