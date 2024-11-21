//
//  TSRankingListTableViewController.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/27.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import NIMSDK

enum AllKindsOfCell {
    /// 个人中心关注列表
    case concernCell
    /// 个人中心点赞排行列表
    case likeCell
    /// 动态点赞榜
    case momentLikeCell
    /// 黑名单列表
    case blackListCell
}

/// cell的高度
enum CellHeight: CGFloat {
    case shortCellHeight = 70.0
    case highCellHeight = 90.0
}

class TSRankingListTableViewController: TSTableViewController, AbstractRankingListTableViewCellDelegate {

    private let identifier = "cell"
    
    /// cell的高度
    enum CellHeight: CGFloat {
        case shortCellHeight = 70.0
        case highCellHeight = 90.0
    }
    /// 展示底部视图的数量
    let showFootDataCount = TSAppConfig.share.localInfo.limit

    var listData: Array<UserInfoModel> = Array()
    var cellHeight: CGFloat!
    var cellType: AllKindsOfCell = .concernCell
    var userId = 0
    var isEnabledHeaderButton: Bool = true
    init(cellType: AllKindsOfCell) {
        super.init(style: .plain)
        self.cellType = cellType
        self.tableView.register(AbstractRankingListTableViewCell.self, forCellReuseIdentifier: identifier)
        self.tableView.register(DiscoverUserTableViewCell.self, forCellReuseIdentifier: DiscoverUserTableViewCell.identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
        switch cellType {
        case .momentLikeCell, .concernCell:
            self.cellHeight = CellHeight.shortCellHeight.rawValue
        case .blackListCell:
            self.cellHeight = 70
        default:
            self.cellHeight = CellHeight.highCellHeight.rawValue
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name(rawValue: "RefreshRemarkName"), object: nil)
    }

    private func updateFollowStatus(indexPath:IndexPath) {
        // 1.判断是否为游客模式
        if !TSCurrentUserInfo.share.isLogin {
            // 如果是游客模式，拦截操作显示登录界面
            TSRootViewController.share.guestJoinLandingVC()
            return
        }
        // 2.进行关注操作
        var userInfo = listData[indexPath.row]

        guard let relationship = userInfo.relationshipWithCurrentUser else {
            TSRootViewController.share.guestJoinLandingVC()
            return
        }
        if relationship.status == .eachOther {
            let session = NIMSession(userInfo.username, type: .P2P)
            let vc = IMChatViewController(session: session, unread: 0)
            self.navigationController?.pushViewController(vc, animated: true)

        } else {
            userInfo.updateFollow { [weak self] success in
                DispatchQueue.main.async {
                    self?.listData[indexPath.row] = userInfo
                    self?.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    // MARK: - tableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.mj_footer != nil {
            tableView.mj_footer.isHidden = self.listData.count < showFootDataCount
        }
        return listData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AbstractRankingListTableViewCell!
        switch cellType {
        case .concernCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: DiscoverUserTableViewCell.identifier, for: indexPath) as! DiscoverUserTableViewCell
            cell.setInfo(model: listData[indexPath.row])
            cell.selectionStyle = .none
            cell.relationshipButton.addTap { [weak self] (button) in
                guard let self = self else { return }
                self.updateFollowStatus(indexPath: indexPath)
            }
            return cell
        case .likeCell:
            cell = LikeRankingListTableViewCell(style: .default, reuseIdentifier: identifier, userInfo: listData[indexPath.row])
        case .momentLikeCell:
            cell = MomentLikeCell(style: .default, reuseIdentifier: identifier, userInfo: listData[indexPath.row])
        case .blackListCell:
            cell = BlackListCell(style: .default, reuseIdentifier: identifier, userInfo: listData[indexPath.row])
        }
        if userId != (CurrentUserSessionInfo?.userIdentity)! {
            cell.praiseButton?.isHidden = true
        }
        cell.isEnabledHeaderButton(isEnabled: isEnabledHeaderButton)
        cell.delegate = self
        cell.userInfo = listData[indexPath.row]
        cell.indexPathRow = indexPath.row

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight!
    }

    // MARK: - didSelectRow
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    // MARK: delegate
    // 抽象方法需要子类实现
    func cell(_ cell: TSTableViewCell, operateBtn: TSButton, indexPathRow: NSInteger) {
    }
    // 抽象方法需要子类实现
    override func refresh() {
        super.refresh()
    }
    // 抽象方法需要子类实现
    override func loadMore() {
    }
}
