//
//  ShareContactsViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/4/14.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class ShareContactsViewController: NewContactsListViewController {
    
    var recentChatData: [ContactData] = []
    var topview = UIView()
    var compleleHandle: (([ContactData]) -> ())?
    var isSearch: Bool = false
    
    let titleLabel = UILabel().configure {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        $0.textAlignment = .left
        $0.textColor = UIColor(hex: "#212121")
        $0.text = "recent_contacts".localized
    }
    
    let contactsLabel = UILabel().configure {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        $0.textAlignment = .left
        $0.textColor = UIColor(hex: "#212121")
        $0.text = "contacts_list".localized
    }
    
    lazy var recentTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(NewContactsListCell.self, forCellReuseIdentifier: "NewContactsListCell")
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        table.rowHeight = tableviewCellHeigt
        table.bounces = false
        return table
    }()
    
    lazy var sendBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("send".localized, for: .normal)
        btn.titleLabel?.font = UIFont.systemRegularFont(ofSize: 17)
        btn.setTitleColor(UIColor(hex: "#D9D9D9"), for: .normal)
        btn.isEnabled = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.setCloseButton(backImage: true, titleStr: "share_contact".localized, completion: {
            self.view.endEditing(true)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
                self.navigationController?.popViewController(animated: true)
            }
        }, needPop: false)
        setupUI()
        //fetchRecentSessions()
        self.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func fetchRecentSessions(){
        if let recentSessions = NIMSDK.shared().conversationManager.allRecentSessions(){
            recentChatData.removeAll()
            for recent in recentSessions {
                if recent.session?.sessionType == .P2P {
                    var contact = ContactData(userName: recent.session?.sessionId ?? "")
                    let avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: contact.userName)
                    contact.imageUrl = avatarInfo.avatarURL ?? ""
                    contact.verifiedIcon = avatarInfo.verifiedIcon
                    contact.verifiedType = avatarInfo.verifiedType
                    recentChatData.append(contact)
                }
            }
            recentTableView.reloadData()
        }
        var height: CGFloat = 0.0
        if recentChatData.count > 3 {
            height = 3.0 * tableviewCellHeigt
        }else {
            height = CGFloat(recentChatData.count) * tableviewCellHeigt
            
        }
        recentTableView.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
        
        topview.isHidden = recentChatData.count == 0 ? true : false
        
        let headview = UIStackView()
        headview.axis = .vertical
        headview.spacing = 5
        headview.distribution = .fill
        headview.alignment = .leading
        
        headview.addArrangedSubview(topview)
        headview.addArrangedSubview(contactsLabel)
        topview.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(20 + height)
        }
        contactsLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.height.equalTo(20)
            make.bottom.equalToSuperview()
        }
        let topH = recentChatData.count == 0 ? 0 : (25 + height)
        let head = UIView()
        head.backgroundColor = .white
        head.addSubview(headview)
        headview.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        head.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 25 + topH)
        self.tableView.tableHeaderView = head
    }
    
    func setupUI(){
        sendBtn.addTarget(self, action: #selector(sendBtnAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendBtn)
        
        topview.addSubview(titleLabel)
        topview.addSubview(recentTableView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.height.equalTo(20)
            make.left.equalTo(15)
        }
        recentTableView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(169)
            make.top.equalTo(titleLabel.snp_bottom)
        }
        
        
        self.searchBar.snp.remakeConstraints { make in
            make.left.equalTo(18)
            make.right.equalTo(-18)
            make.top.equalToSuperview()
            make.height.equalTo(36)
        }
        searchBar.searchTextFiled.placeholder = "search_name_id".localized
        
    }

    override func numSelectedChange() {
        if choosedDataSource.count > 0 {
            sendBtn.isEnabled = true
            sendBtn.setTitleColor(AppTheme.red, for: .normal)
        }else{
            sendBtn.isEnabled = false
            sendBtn.setTitleColor(UIColor(hex: "#D9D9D9"), for: .normal)
        }
    }
    ///发送
    @objc func sendBtnAction(){
        if choosedDataSource.count == 0 {
            return
        }
        self.navigationController?.popViewController(animated: true)
        self.compleleHandle?(choosedDataSource)
    }
    
    func listDeleteForContactData(userinfo: ContactData, isSelected: Bool = false){
        var section = 0
        var row = 0
        var flag = false
        for arr in sortedModelArr {
            if let index = arr.firstIndex(where: {$0.userName == userinfo.userName}) {
                row = index
                flag = true
                break
            }
            section = section + 1
        }
        
        if flag {
            let index = IndexPath(row: row, section: section)
            if let cell: NewContactsListCell = tableView.cellForRow(at: index) as? NewContactsListCell {
                cell.chatButton.isSelected = isSelected
            }
            
        }
    }
    
    func recentContactsDeleteForContactData(userinfo: ContactData, isSelected: Bool = false){
        if let index = recentChatData.firstIndex(where: {$0.userName == userinfo.userName}) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell: NewContactsListCell = recentTableView.cellForRow(at: indexPath) as? NewContactsListCell {
                cell.chatButton.isSelected = isSelected
            }
        }
    }
}
extension ShareContactsViewController{
    override func deleteButtonClick(model: ContactData?) {
        if let model = model, let indexCol = choosedDataSource.firstIndex(where: {$0.userName == model.userName}) {
            choosedDataSource.remove(at: indexCol)
            UIView.performWithoutAnimation {
                self.collectionView.performBatchUpdates {
                    self.collectionView.deleteItems(at: [IndexPath(row: indexCol, section: 0)])
                }
            }
            if self.isShowCol {
                collectionView.isHidden = choosedDataSource.count == 0
            }
            self.listDeleteForContactData(userinfo: model)
            self.recentContactsDeleteForContactData(userinfo: model)
            
            numSelectedChange()
        }
    }
}

extension ShareContactsViewController: ContactsSearchViewDelegate {
    
    func searchDidClickCancel() {
        self.searchBar.searchTextFiled.resignFirstResponder()
    }
    func searchDidClickReturn(text: String) {
        if text.count == 0 {
            self.isSearch = false
        }else {
            self.isSearch = true
        }
        self.keyword = text
        self.refresh()
        self.searchBar.searchTextFiled.resignFirstResponder()
    }
    func searchTextDidChange(text: String) {
        if text.count == 0 {
            self.isSearch = false
            self.keyword = ""
            self.refresh()
        }
        
    }
}

extension ShareContactsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == recentTableView {
            return 1
        }
        
        return indexDataSource.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == recentTableView {
            return recentChatData.count > 3 ? 3 : recentChatData.count
        }
        
        return sortedModelArr[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == recentTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewContactsListCell", for: indexPath) as! NewContactsListCell
            cell.currentChooseArray = self.choosedDataSource
            cell.contactData = recentChatData[indexPath.row]
            cell.selectionStyle = .none
            print("userName = \(cell.contactData?.userName)")
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewContactsListCell", for: indexPath) as! NewContactsListCell
        cell.currentChooseArray = self.choosedDataSource
        
        cell.contactData = sortedModelArr[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        
        if isSearch {
            self.tableView.tableHeaderView = UIView()
        } else {
            self.fetchRecentSessions()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == recentTableView {
            return 0.01
        }
        return 30.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == recentTableView {
            return nil
        }
        
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#D9D9D9")
        var lab = UILabel()
        lab.frame = CGRect(x: 15, y: 0, width: 100, height: 30)
        lab.text = indexDataSource[section]
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = UIColor(hex: "#808080")
        view.addSubview(lab)
        return view
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return indexDataSource[section]
    //    }
    
    //    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    //        if tableView == recentTableView {
    //            return nil
    //        }
    //        return indexDataSource
    //    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: NewContactsListCell = tableView.cellForRow(at: indexPath) as! NewContactsListCell
        ///防止快速点击 UI刷新错乱
        if !canSelected {
            return
        }
        self.perform(#selector(changeTableViewSelectedStatus), with: nil, afterDelay: 0.3)
        canSelected = false

        guard let contactData = cell.contactData, contactData.isBannedUser == false else {
            self.showTopIndicator(status: .faild, "alert_banned_description".localized)
            return
        }
        
        if cell.chatButton.isSelected {
            if let indexCol = choosedDataSource.firstIndex(where: {$0.userName == contactData.userName}) {
                let collectionIndexPath = IndexPath(row: indexCol, section: 0)
                self.collectionView.performBatchUpdates {
                    choosedDataSource.remove(at: indexCol)
                    self.collectionView.deleteItems(at: [collectionIndexPath])
                }
            }
            cell.chatButton.isSelected = !cell.chatButton.isSelected
            if self.isShowCol {
                collectionView.isHidden = choosedDataSource.count == 0
            }
            
            if tableView == recentTableView {
                self.listDeleteForContactData(userinfo: cell.contactData!,isSelected: false)
            } else {
                self.recentContactsDeleteForContactData(userinfo: cell.contactData!,isSelected: false)
            }
        } else {
            choosedDataSource.insert(contactData, at: 0)
            let collectionIndexPath = IndexPath(row: 0, section: 0)
            self.collectionView.performBatchUpdates {
                self.collectionView.insertItems(at: [collectionIndexPath])
            }
            
            cell.chatButton.isSelected = !cell.chatButton.isSelected
            if self.isShowCol {
                collectionView.isHidden = choosedDataSource.count == 0
            }
            if tableView == recentTableView {
                self.listDeleteForContactData(userinfo: cell.contactData!,isSelected: true)
            } else {
                self.recentContactsDeleteForContactData(userinfo: cell.contactData!,isSelected: true)
            }
        }
        
        numSelectedChange()
    }
}
