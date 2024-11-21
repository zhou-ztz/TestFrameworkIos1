//
//  TopicNewListVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/23.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TopicNewListVC: TSViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var topicCollectionView: TSCollectionView!
    /// 数据源
    var dataSource: [TopicListModel] = []
    /// 占位图
    let occupiedView = FadeImageView()
    var listLimit = TSAppConfig.share.localInfo.limit
    
    internal let occupiedText = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 50, height: 50))

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTopicList(notice:)), name: NSNotification.Name(rawValue: "reloadTopicList"), object: nil)
        self.view.backgroundColor = UIColor.white
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: ScreenWidth, height: 195)
        layout.scrollDirection = .vertical
        // 3.设置滚动方向
        topicCollectionView = TSCollectionView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - TSNavigationBarHeight), collectionViewLayout: layout)
        topicCollectionView.backgroundColor = UIColor.white
        topicCollectionView.delegate = self
        topicCollectionView.dataSource = self
        topicCollectionView.register(TopicCollectionCell.self, forCellWithReuseIdentifier: TopicCollectionCell.identifier)
        self.view.addSubview(topicCollectionView)
        topicCollectionView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        topicCollectionView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        topicCollectionView.mj_header.beginRefreshing()
        // Do any additional setup after loading the view.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !dataSource.isEmpty {
            topicCollectionView.removePlaceholderView()
        }
        if topicCollectionView.mj_footer != nil {
            topicCollectionView.mj_footer.isHidden = dataSource.count < listLimit
        }
        return dataSource.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TopicCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: TopicCollectionCell.identifier, for: indexPath) as! TopicCollectionCell
        cell.setInfo(model: dataSource[indexPath.row], index: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 游客触发登录
        if !TSCurrentUserInfo.share.isLogin {
            TSRootViewController.share.guestJoinLandingVC()
            return
        }
        let postListVC = TopicPostListVC(groupId: dataSource[indexPath.row].topicId)
        navigationController?.pushViewController(postListVC, animated: true)
    }

    @objc func refresh() {
        TSUserNetworkingManager().getTopicList(index: nil, keyWordString: nil, limit: 15, direction: "desc", only: nil) { (topicModel, networkError) in
            self.processRefresh(datas: topicModel, message: networkError)
            self.topicCollectionView.mj_header.endRefreshing()
        }
    }

    func processRefresh(datas: [TopicListModel]?, message: NetworkError?) {
        topicCollectionView.mj_footer.resetNoMoreData()
        // 获取数据成功
        if let datas = datas {
            dataSource = datas
            if dataSource.isEmpty {
                topicCollectionView.show(placeholderView: .empty)
            }
        }
        topicCollectionView.mj_footer.resetNoMoreData()
        // 获取数据失败
        if message != nil {
            dataSource = []
            topicCollectionView.show(placeholderView: .network)
        }
        topicCollectionView.reloadData()
    }

    @objc func loadMore() {
        // 游客模式下不能刷新
        if  !TSCurrentUserInfo.share.isLogin {
            TSRootViewController.share.guestJoinLandingVC()
            topicCollectionView.mj_footer.endRefreshing()
            return
        }
        guard let indexId = dataSource.last?.topicId else {
            topicCollectionView.mj_footer.endRefreshingWithNoMoreData()
            return
        }
        TSUserNetworkingManager().getTopicList(index: indexId, keyWordString: nil, limit: 15, direction: "desc", only: nil) { (topicModel, networkError) in
            guard let datas = topicModel else {
                self.topicCollectionView.mj_footer.endRefreshing()
                return
            }
            if datas.count < TSNewFriendsNetworkManager.limit {
                self.topicCollectionView.mj_footer.endRefreshingWithNoMoreData()
            } else {
                self.topicCollectionView.mj_footer.endRefreshing()
            }
            self.dataSource = self.dataSource + datas
            self.topicCollectionView.reloadData()
        }
        topicCollectionView.mj_footer.endRefreshing()
    }

    @objc func reloadTopicList(notice: Notification) {
        let dict: NSDictionary = notice.userInfo! as NSDictionary
        guard let topicId = dict["topicId"] else {
            return
        }
        let topicIIID = "\(topicId)"
        let follow = "\(dict["follow"] ?? "")"
        let followStatus = follow == "1" ? true : false
        for (index, item) in self.dataSource.enumerated() {
            if "\(item.topicId)" == topicIIID {
                item.topicFollow = followStatus
                self.dataSource.insert(item, at: index)
                self.dataSource.remove(at: index + 1)
                break
            }
        }
        self.topicCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
