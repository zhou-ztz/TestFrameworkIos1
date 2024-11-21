//
//  MessageRequestListTableViewController.swift
//  Yippi
//
//  Created by Tinnolab on 22/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit

import Reachability
import Alamofire

class MessageRequestListTableViewController: TSTableViewController {

    private var headerView: UIView!
    private var headerLbl: UILabel!
    
    private var loadDataCalled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigateBar()
        self.setupHeaderView()
        self.setupTableView()
        self.addObserver()
      
        self.tableView.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: Notification.Name.reachabilityChanged, object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavigateBar() {
        self.setRightButton(title: nil, img: UIImage.set_image(named: "icDeleteBlack"))
    }
    
    private func setupTableView() {
        self.title = "message_request_title".localized
        self.tableView.register(MsgRequestListTableViewCell.nib(), forCellReuseIdentifier: MsgRequestListTableViewCell.cellReuseIdentifier)
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.mj_footer.isHidden = true
    }
    
    private func setupHeaderView() {
        self.headerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 50))
        self.headerLbl = UILabel(frame: CGRect(x: 0, y: 0, width: ScreenWidth-16, height: 50))
        self.headerLbl.font = UIFont.systemFont(ofSize: YPCustomizer.FontSize.small)
        self.headerLbl.numberOfLines = 0
        self.headerLbl.lineBreakMode = .byWordWrapping
        self.headerLbl.textAlignment = .center
        self.headerView.addSubview(headerLbl)
        
        if !self.isConnected() {
            self.headerView.backgroundColor = UIColor.red
            self.headerLbl.textColor = UIColor.white
            self.headerLbl.text = "net_broken".localized
            self.headerLbl.sizeToFit()
        } else {
            self.headerView.backgroundColor = UIColor.clear
            self.headerLbl.textColor = UIColor.lightGray
            self.headerLbl.text = "request_mark_read_tip".localized
            self.headerLbl.sizeToFit()
        }
        
        self.headerView.snp_makeConstraints {(make) in
            make.height.equalTo(headerLbl.height + 20)
            make.width.equalTo(ScreenWidth)
        }
        headerLbl.snp_makeConstraints {(make) in
            make.bottom.top.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
    }
    
    // MARK: TSTableView Delegate
    override func refresh() {
        self.loadData()
    }
    
    override func loadMore() {
        self.loadMoreData()
    }
    
    @objc override func rightButtonClicked() {
        let alert = TSAlertController(title: nil, message: "delete_all_request".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        alert.addAction(TSAlertAction(title: "confirm".localized, style: TSAlertSheetActionStyle.default, handler: { _ in
            self.deleteAllMessageRequest()
        }))
        self.presentPopup(alert: alert)
    }
    
    @objc func reachabilityChanged(note: NSNotification) {
        guard let reachability = note.object as? Reachability else {
            return
        }
        if reachability.currentReachabilityStatus() != .ReachableViaWWAN && reachability.currentReachabilityStatus() != .ReachableViaWiFi {
            self.headerLbl.text = "net_broken".localized
            self.headerView.backgroundColor = UIColor.red
            self.headerLbl.textColor = UIColor.white
        } else {
            self.headerLbl.text = "request_mark_read_tip".localized
            self.headerView.backgroundColor = UIColor.clear
            self.headerLbl.textColor = UIColor.lightGray
        }
    }
    
    private func isConnected() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

// MARK: - Web Service
extension MessageRequestListTableViewController {
    private func loadData() {
        // By Kit Foong (Added flag there handle response code 429)
        MessageRequestNetworkManager().getMessageReqList(specialRequest: true, complete: { [weak self] (result, status) in
            DispatchQueue.main.async {
                self?.tableView.mj_header.endRefreshing()
                self?.tableView.mj_footer.resetNoMoreData()
            }
            if status {
                DispatchQueue.main.async {
                    self?.tableView.mj_footer.isHidden = (ChatMessageManager.shared.requestList.count <= 0 || ChatMessageManager.shared.requestList.count >= ChatMessageManager.shared.requestCount())
                    self?.tableRefresh()
                }
            }
        })
    }
    
    private func loadMoreData() {
        let id = ChatMessageManager.shared.requestList.last?.after
        
        MessageRequestNetworkManager().getMessageReqList(after: id, complete: {(result, status) in
            DispatchQueue.main.async {
                
                if status {
                    if ChatMessageManager.shared.requestList.count >= ChatMessageManager.shared.requestCount() {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_footer.endRefreshing()
                    }
                } else {
                    self.tableView.mj_footer.endRefreshing()
                }
                self.tableRefresh()
            }
        })
    }
    
    private func deleteAllMessageRequest() {
        MessageRequestNetworkManager().deleteAllMessageRequest(complete: {
            DispatchQueue.main.async {
                ChatMessageManager.shared.deleteAllRequestList()
                self.tableRefresh()
            }
        })
    }
    
    private func deleteSingleMessageRequest(requestId: Int, userId: Int) {
        
        MessageRequestNetworkManager().deleteSingleMessageRequest(requestId: requestId, complete: {
            DispatchQueue.main.async {
                ChatMessageManager.shared.deleteChatHistory(requestId: requestId, userId: userId)
                self.tableRefresh()
            }
        })
    }
    
    private func tableRefresh() {
        if ChatMessageManager.shared.requestList.count <= 0 {
            self.show(placeholderView: .empty)
        } else {
            self.removePlaceholderViews()
        }
        self.tableView.reloadData()
    }
}

    

// MARK: - Table view delegate & data source
extension MessageRequestListTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChatMessageManager.shared.requestList.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MsgRequestListTableViewCell.cellReuseIdentifier) as! MsgRequestListTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        if ChatMessageManager.shared.requestList.count > 0 && indexPath.row < ChatMessageManager.shared.requestList.count {
            let msgContent = ChatMessageManager.shared.requestList[indexPath.row]
            if msgContent.isInvalidated == false {
                cell.UISetup(data: MessageRequestModel.init(object: msgContent))
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= ChatMessageManager.shared.requestList.count { return }
        let msgContent = ChatMessageManager.shared.requestList[indexPath.row]
        guard msgContent.isInvalidated == false else {
            return
        }
        let vc = MsgRequestChatViewController()
        vc.messageInfo = MessageRequestModel.init(object: msgContent)
        // By Kit Foong (Will refresh table after perform action)
        vc.refreshList = { [weak self] in
            MessageRequestNetworkManager().getMessageReqList(specialRequest: true, complete: { [weak self] (result, status) in
                DispatchQueue.main.async {
                    self?.tableView.mj_footer.isHidden = (ChatMessageManager.shared.requestList.count <= 0 || ChatMessageManager.shared.requestList.count >= ChatMessageManager.shared.requestCount())
                    self?.tableRefresh()
                }
            })
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.row >= ChatMessageManager.shared.requestList.count { return }
        if editingStyle == .delete {
            let msgContent = ChatMessageManager.shared.requestList[indexPath.row]
            guard msgContent.isInvalidated == false else {
                return
            }
            let requestId = msgContent.requestID
            let toUserId = (msgContent.toUserID == CurrentUserSessionInfo?.userIdentity) ? msgContent.fromUserID : msgContent.toUserID
            self.deleteSingleMessageRequest(requestId: requestId, userId: toUserId)
        }
    }
}
