//
//  AddGroupSettingViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/4/12.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
import MobileCoreServices

class AddGroupSettingViewController: TSViewController {
    
    ///选中的数据
    var choosedDataSource: [ContactData] = []
    var members: [String] = []
    var groupNames: ((Bool)->())?
    var opneAction: (()->())?
    
    
    
    lazy var headImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.backgroundColor = UIColor(hex: "#EBEBEB")
        return imageview
    }()
    
    lazy var cameraImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFit
        imageview.image = UIImage.set_image(named: "camera_group")
        return imageview
    }()
    
    lazy var nameT: UITextField = {
        let textfield = UITextField()
        textfield.font = UIFont.systemRegularFont(ofSize: 14)
        textfield.placeholder = "chat_set_group_name".localized
        return textfield
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(GroupMembersCell.self, forCellReuseIdentifier: "GroupMembersCell")
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 72
        table.tableFooterView = UIView()
        table.tableHeaderView = UIView()
        return table
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        setupUI()
        getMembers()
    }
    
    func setupUI(){

        
        let headView = UIView()
        headView.backgroundColor = UIColor(hex: "#F7F8FA")
        headView.layer.cornerRadius = 10
        headView.clipsToBounds = true
        self.view.addSubview(headView)
        headView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(10)
            make.height.equalTo(85)
        }
        headView.addSubview(headImageView)
        headImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(25)
            make.height.width.equalTo(45)
        }
        headImageView.layer.cornerRadius = 22.5
        headImageView.clipsToBounds = true
        headImageView.isUserInteractionEnabled = true
        headImageView.addAction {
            self.nameT.resignFirstResponder()
            self.opneAction?()
        }
        headImageView.addSubview(cameraImageView)
        cameraImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(20)
        }
        
        headView.addSubview(nameT)
        nameT.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(headImageView.snp_right).offset(15)
            make.height.width.equalTo(45)
            make.right.equalTo(-10)
        }
        
        let memberL = UILabel()
        memberL.textColor = UIColor(hex: "#212121")
        memberL.font = UIFont.systemRegularFont(ofSize: 17)
        memberL.textAlignment = .left
        memberL.text = "members".localized
        self.view.addSubview(memberL)
        memberL.snp.makeConstraints { make in
            make.top.equalTo(headView.snp_bottom).offset(15)
            make.left.equalTo(15)
        }
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(memberL.snp_bottom).offset(15)
            make.left.right.bottom.equalTo(0)
        }
        
        nameT.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        
    }
    
    func getMembers(){
        members.append(NIMSDK.shared().loginManager.currentAccount())
        for model in choosedDataSource {
            members.append(model.userName)
        }
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if (textField.text?.count ?? 0) > 0 {
            self.groupNames?(true)

        }else {
            self.groupNames?(false)

        }
        
    }
    
    

}

extension AddGroupSettingViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return choosedDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMembersCell", for: indexPath) as! GroupMembersCell
        
        cell.setData(model: choosedDataSource[indexPath.row])
        cell.selectionStyle = .none
        
        return cell
    }
    
}

