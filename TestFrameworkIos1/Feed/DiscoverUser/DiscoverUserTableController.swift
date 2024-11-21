//
//  DiscoverUserTableController.swift
//  Yippi
//
//  Created by Jerry Ng on 29/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import CoreLocation

enum DiscoverUserType {
    /// 热门用户
    case hot
    /// 最新用户
    case new
    /// 推荐用户
    case recommend
    /// 附近
    case nearby
}

class DiscoverUserTableController: TSTableViewController {
    
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
    }()
    var location: CLLocation? {
        didSet {
            if location != nil {
                setLocationInfo()
            }
        }
    }
    var isLoadingLocation: Bool = false

    private var dataSource: [UserInfoModel] = []
    var selectedCell: IndexPath? = nil
    
    var currentDiscoverType: DiscoverUserType = .hot
    
    // MARK: - Lifecycle
    init(type: DiscoverUserType) {
        super.init(nibName: nil, bundle: nil)
        self.currentDiscoverType = type
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.mj_header.beginRefreshing()
        getLocation()
    }
    
    func setupUI() {
        tableView.rowHeight = 77.5
        tableView.separatorStyle = .none
        tableView.register(DiscoverUserTableViewCell.self, forCellReuseIdentifier: DiscoverUserTableViewCell.identifier)
        tableView.mj_footer.isHidden = true
    }
    
    func setLocationInfo() {
        guard let location = location else {
            return
        }
        self.isLoadingLocation = false
        self.refresh()
        TSNewFriendsNetworkManager.submitLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, complete: nil)
    }
    
    // MARK: - Data
    func loadHotOrNearbyData(isLoadMore:Bool) {
//        if currentDiscoverType == .nearby && isLoadingLocation {
//            return
//        }
//        let offset = isLoadMore ? dataSource.count : 0
//        TSDataQueueManager.share.findFriends.getNewFriends(type: currentDiscoverType, latitude: location?.coordinate.latitude, longitude: location?.coordinate.longitude, offset: offset) { [weak self] (data, message, _) in
//            if isLoadMore {
//                self?.processLoadMoreData(data: data, message: message)
//            } else {
//                self?.processRefreshData(data: data, message: message)
//            }
//        }
    }
    
    /// 处理下拉刷新的数据，并调整相关的交互视图
//    func processRefreshData(data: [UserInfoModel]?, message: String?, contactData:[TSContactModel]? = nil) {
//        tableView.mj_footer.resetNoMoreData()
//        // 1.网络失败
//        if let message = message {
//            // 1.1 结束 footer 动画
//            tableView.mj_header.endRefreshing()
//            // 1.2 如果界面上有数据，显示 indicatorA；如果界面上没有数据，显示 "placeholder_network_error".localized的占位图
//            dataSource.isEmpty ? show(placeholderView: .network) : show(indicatorA: message)
//            return
//        }
//        // 2.请求成功
//        // 2.1 更新 dataSource
//        if let data = data {
//            dataSource = data
//            if data.isEmpty == true {
//                // 2.2 如果数据为空，显示占位图
//                show(placeholderView: .empty)
//            } else {
//                removePlaceholderViews()
//            }
//        }
//        // 3.隐藏多余的指示器和刷新动画
//        dismissIndicatorA()
//        if tableView.mj_header.isRefreshing {
//            tableView.mj_header.endRefreshing()
//        }
//        // 4.刷新界面
//        tableView.reloadData()
//    }
//
//    /// 处理上拉加载更多的数据，并调整相关的交互视图
//    func processLoadMoreData(data: [UserInfoModel]?, message: String?) {
//        // 1.网络失败，显示"网络失败"的 footer
//        if message != nil {
//            tableView.mj_footer.endRefreshingWithWeakNetwork()
//            return
//        }
//        dismissIndicatorA()
//        // 2.请求成功
//        guard let data = data else {
//            tableView.mj_footer.endRefreshingWithNoMoreData()
//            return
//        }
//        dataSource = dataSource + data
//        tableView.reloadData()
//        // 3. 判断新数据数量是否够一页。不够一页显示"没有更多"的 footer；够一页仅结束 footer 动画
//        if data.count < TSAppConfig.share.localInfo.limit {
//            tableView.mj_footer.endRefreshingWithNoMoreData()
//        } else {
//            tableView.mj_footer.endRefreshing()
//        }
//    }
//    
//    /// 点击了关注按钮
//    private func updateFollowStatus(indexPath:IndexPath) {
//        // 1.判断是否为游客模式
//        if !TSCurrentUserInfo.share.isLogin {
//            // 如果是游客模式，拦截操作显示登录界面
//            TSRootViewController.share.guestJoinLandingVC()
//            return
//        }
//        // 2.进行关注操作
//        var userInfo = dataSource[indexPath.row]
//        
//        guard let relationship = userInfo.relationshipWithCurrentUser else {
//            TSRootViewController.share.guestJoinLandingVC()
//            return
//        }
//        if relationship.status == .eachOther {
//            let session = NIMSession(userInfo.username, type: .P2P)
//            let vc = IMChatViewController(session: session, unread: 0)
//            self.navigationController?.pushViewController(vc, animated: true)
//        } else {
//            userInfo.follower = !userInfo.follower
//            dataSource[indexPath.row] = userInfo
//            self.tableView.reloadRows(at: [indexPath], with: .none)
////            TSDataQueueManager.share.moment.start(follow: userInfo.userIdentity, isFollow: userInfo.follower)
//            let followstatus: FollowStatus = userInfo.follower == true ? .follow : .unfollow
//            TSUserNetworkingManager().operateWithClosure(followstatus, userID: userInfo.userIdentity) { (result) in
//                if result == true {
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil, userInfo: ["follow": followstatus,"userid": "\(userInfo.userIdentity)"])
//                }
//            }
//        }
//    }
}

// MARK: - TSTableView Delegate
extension DiscoverUserTableController {
    override func refresh() {
        loadHotOrNearbyData(isLoadMore: false)
    }

    override func loadMore() {
        loadHotOrNearbyData(isLoadMore: true)
    }
}

// MARK: - TableView Delegate
extension DiscoverUserTableController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !dataSource.isEmpty {
            removePlaceholderViews()
        }
        if tableView.mj_footer != nil {
            tableView.mj_footer.isHidden = dataSource.count < TSAppConfig.share.localInfo.limit
        }
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiscoverUserTableViewCell.identifier, for: indexPath) as! DiscoverUserTableViewCell
        cell.setInfo(model: dataSource[indexPath.row])
        cell.selectionStyle = .none
//        cell.relationshipButton.addTap { [weak self] (button) in
//            guard let self = self else { return }
//            self.updateFollowStatus(indexPath: indexPath)
//        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]
        // 头像默认点击事件
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": model.userIdentity])
        selectedCell = indexPath
    }
}

// MARK: - CLLocationManager Delegate
extension DiscoverUserTableController: CLLocationManagerDelegate {
    func getLocation() {
        locationManager.requestWhenInUseAuthorization()
        isLoadingLocation = true
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        TSUtil.checkAuthorizeStatusByType(type: .location, viewController: self, completion: {
            self.setLocationInfo()
        })
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.location = location
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
    }
}
