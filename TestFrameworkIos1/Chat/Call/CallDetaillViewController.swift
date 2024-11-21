//
//  CallDetaillViewController.swift
//  Yippi
//
//  Created by Wong Jin Lun on 28/03/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
class CallDetaillViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource: [CallDetailData] = []
    
    var filterId: String = ""
    var username: String = ""
    var userId: Int = 0
    var groupType: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if groupType == "individual" {
            setRightBarButton()
            self.title = username
        } else {
            if let team: NIMTeam = NIMSDK.shared().teamManager.team(byId: String(userId ?? 0) ?? "") {
                self.title = team.teamName
            }
        }
        setupView()
        retrieveCallDetail(filterId: filterId)
    }
    
    private func setRightBarButton() {
        let button = UIBarButtonItem(title: "dashboard_profile".localized, style: .plain, target: self, action: #selector(profileAction))
        button.tintColor = TSColor.main.theme
        navigationItem.rightBarButtonItems = [button]
    }
    
    private func setupView() {

        setTableView()
    }
    
    private func retrieveCallDetail(filterId: String) {
        CallRequest().retrieveCallDetail(filterId: filterId){ [weak self] (responseModel) in
            guard let self = self, let model = responseModel else { return }
            self.updateCallDetailList(data: model.data)
        } onFailure: { [weak self] (errorMessage) in
            guard let self = self else { return }
            
        }
    }
    
    private func updateCallDetailList(data: [CallDetailData]?) {
        if let data = data {
            dataSource = data
        }
        tableView.reloadData()
    }
    
    private func setTableView(){
        tableView.register(CallDetailHeaderTableViewCell.nib(), forCellReuseIdentifier: CallDetailHeaderTableViewCell.cellIdentifier)
        tableView.register(CallTableViewCell.nib(), forCellReuseIdentifier: CallTableViewCell.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
    }
    
    @objc func profileAction() {
//        let userHomPage = HomePageViewController(userId: userId)
//        self.navigationController?.pushViewController(userHomPage, animated: true)
        FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: userId, username: nil, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
    }
    
}

extension CallDetaillViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: CallDetailHeaderTableViewCell.cellIdentifier) as! CallDetailHeaderTableViewCell
        headerCell.username = username
        headerCell.setUserInfo(userId: userId, groupType: groupType)
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 270
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CallTableViewCell.cellIdentifier, for: indexPath) as! CallTableViewCell
        cell.setDetailModel(model: dataSource[indexPath.row], userId: userId)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
