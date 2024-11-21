//
//  TSRejectListController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/7/21.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class TSRejectListController: TSViewController {
    var dataArray : [RejectListModel] = []
    var after: Int? = nil
    let limit: Int = 15
    /// 分页
    var page = 1
    private lazy var rejectListTableView: TSTableView = {
        let tableView = TSTableView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height - TSNavigationBarHeight), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        tableView.rowHeight = 60
        tableView.backgroundColor = .white
        
        tableView.register(TSRejectedListTableViewCell.self, forCellReuseIdentifier: TSRejectedListTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(rejectListTableView)
        rejectListTableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(getData))
        rejectListTableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreList))
        rejectListTableView.mj_footer.isHidden = true
        rejectListTableView.mj_header.beginRefreshing()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func getData() {
        var request = RejectNetworkRequestTypes().rejectList
        request.urlPath = request.fullPathWith(replacers: [])
        page = 1
        let parameter: [String : Any] = ["page":page, "limit": limit]
        request.parameter = parameter
        let readGroup = DispatchGroup()
        readGroup.enter()
        RequestNetworkData.share.text(request: request) { [unowned self] (networkResult) in
            self.page += 1
            self.rejectListTableView.mj_header.endRefreshing()
            switch networkResult {
            case .error(_):
                self.page -= 1
                self.rejectListTableView.show(placeholderView: .network)
            case .failure(let response):
                self.page -= 1
                self.rejectListTableView.show(placeholderView: .network)
            case .success(let reponse):
                guard let data = reponse.model?.data, !data.isEmpty else {
                    self.rejectListTableView.show(placeholderView: .empty)
                    return
                }
                self.rejectListTableView.removePlaceholderViews()
                self.dataArray = data
                
                if data.count < limit {
                    self.rejectListTableView.mj_footer.isHidden = true
                    self.rejectListTableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.rejectListTableView.mj_footer.isHidden = false
                    self.rejectListTableView.mj_footer.resetNoMoreData()
                }
                self.rejectListTableView.reloadData()
                readGroup.leave()
            }
        }
        
        readGroup.notify(queue: .main) { // 当获取完数据成功后,标记该数据已读,移除小红点
            if self.dataArray.isEmpty {
                return
            }
            
            RejectNetworkRequest().readAllNoti { [weak self] (responseModel) in
                TSCurrentUserInfo.share.unreadCount.reject = 0
                NotificationCenter.default.post(name: NSNotification.Name.DashBoard.reloadNotificationBadge, object: nil)
            } onFailure: {  [weak self] (errorMessage) in
                
            }
        }
    }
    
    @objc func loadMoreList() {
        var request = RejectNetworkRequestTypes().rejectList
        request.urlPath = request.fullPathWith(replacers: [])
        
        let parameter: [String: Any] = ["limit": limit, "page": page, "type": "system"]
        request.parameter = parameter
        RequestNetworkData.share.text(request: request) { [unowned self] (networkResult) in
            self.page += 1
            self.rejectListTableView.mj_header.endRefreshing()
            switch networkResult {
            case .error(_):
                self.page -= 1
            case .failure(let response):
                self.page -= 1
                self.rejectListTableView.show(placeholderView: .network)
            case .success(let reponse):
                if let data = reponse.model?.data {
                    self.dataArray = self.dataArray + data
                }
                if let data = reponse.model?.data {
                    if data.count < limit {
                        //                        self.rejectListTableView.mj_footer.isHidden = true
                        self.rejectListTableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        //                        self.rejectListTableView.mj_footer.isHidden = false
                        self.rejectListTableView.mj_footer.resetNoMoreData()
                    }
                }
                self.rejectListTableView.reloadData()
            }
        }
    }
}

extension TSRejectListController :UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TSRejectedListTableViewCell.identifier, for: indexPath) as! TSRejectedListTableViewCell
        cell.selectionStyle = .none
        cell.setReject(data: dataArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = TSRejectedDetailController(feedId: dataArray[indexPath.row].id.stringValue)
        vc.onDelete = {
            self.rejectListTableView.mj_header.beginRefreshing()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
