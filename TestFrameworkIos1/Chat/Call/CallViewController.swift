//
//  CallViewController.swift
//  Yippi
//
//  Created by Wong Jin Lun on 06/03/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class CallViewController: TSTableViewController {
    
    private var dataSource: [CallListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //loadCallList()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupView() {
        setTableView()
    }
    
    private func loadCallList() {
        CallRequest().getCallList(){ [weak self] (responseModel) in
            guard let self = self, let model = responseModel else { return }
            self.updateCallList(data: model.data)
            
        } onFailure: { [weak self] (errorMessage) in
            guard let self = self else { return }
            
        }
    }
    
    override func refresh() {
        loadCallList()
    }
    
    private func updateCallList(data: [CallListModel]?) {
        if let data = data {
            dataSource = data
            if data.isEmpty == true {
                show(placeholderView: .empty)
            }
        }
        tableView.reloadData()
        tableView.mj_header.endRefreshing()
    }
    
    private func setTableView(){
        tableView.register(CallTableViewCell.nib(), forCellReuseIdentifier: CallTableViewCell.cellIdentifier)
        tableView.mj_footer.isHidden = true
    }
    
}

extension CallViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CallTableViewCell.cellIdentifier, for: indexPath) as! CallTableViewCell
        cell.setModel(model: self.dataSource[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = self.dataSource[indexPath.row]
        let vc = CallDetaillViewController()
        vc.filterId = data.filterId ?? ""
        vc.userId = data.filterData?.user?.id ?? 0
        vc.groupType = data.filterData?.groupType ?? ""
        if let type = data.filterData?.groupType {
            if type == "individual"{
                vc.username = data.filterData?.user?.username ?? ""
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
