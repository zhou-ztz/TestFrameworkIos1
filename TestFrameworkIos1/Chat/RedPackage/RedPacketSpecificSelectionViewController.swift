//
//  RedPacketSpecificSelectionViewController.swift
//  Yippi
//
//  Created by Kit Foong on 18/10/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import UIKit
//import NIMPrivate
import NIMSDK
typealias SpecificSelectioFinishClosure = (ContactData) -> Void

class RedPacketSpecificSelectionViewController: TSViewController {
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: TSTableView!
    
    var teamId: String
    var keyword: String = ""
    var isSearching: Bool = false
    var teamMembers = [ContactData]()
    var displayList = [ContactData]()
    var apiDebouncer = Debouncer(delay: 0.5)
    var finishClosure: SpecificSelectioFinishClosure?
    
    init(teamId: String, finishClosure: SpecificSelectioFinishClosure? = nil) {
        self.teamId = teamId
        self.finishClosure = finishClosure
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.setCloseButton(backImage: true, titleStr: "team_member".localized)        
        setupView()
        setupTableView()
        getTeamMembers()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewContactTableViewCell.nib(), forCellReuseIdentifier: NewContactTableViewCell.cellReuseIdentifier)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.mj_header = nil
        tableView.mj_footer = nil
    }
    
    private func setupView() {
        textFieldView.roundCorner(20)
        textFieldView.dropShadow()
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchTextField.placeholder = "txt_search_id_name".localized
        searchTextField.clearButtonMode = .whileEditing
    }
    
    private func getTeamMembers() {
        NIMSDK.shared().teamManager.fetchTeamMembers(fromServer: self.teamId) { [weak self] (error, members) in
            guard let self = self else { return }
            guard error == nil else { return }
            
            if let members = members {
                for member in members {
                    if let userId = member.userId, userId != NIMSDK.shared().loginManager.currentAccount() {
                        self.teamMembers.append(ContactData(userName: userId))
                    }
                }
            }
            
            self.displayList = self.teamMembers
            self.tableView.reloadData()
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        apiDebouncer.handler = {
            let searchText = self.searchTextField.text ?? ""
                
            if searchText.isEmpty {
                self.displayList = self.teamMembers
            } else {
                self.displayList = self.teamMembers.filter { $0.userName.contains(searchText) || $0.displayname.contains(searchText) }
            }
            
            self.tableView.reloadData()
        }
        apiDebouncer.execute()
    }
}

// MARK: - Table view delegate & data source
extension RedPacketSpecificSelectionViewController:  UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NewContactTableViewCell.cellReuseIdentifier, for: indexPath) as? NewContactTableViewCell {
            cell.setContactData(model: displayList[indexPath.row])
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.displayList.indices.contains(indexPath.row) {
            if self.displayList[indexPath.row].isBannedUser {
                self.showTopIndicator(status: .faild, "alert_banned_description".localized)
                return
            }
            
            self.navigationController?.popViewController(animated: true)
            self.finishClosure?(displayList[indexPath.row])
        }
    }
}
