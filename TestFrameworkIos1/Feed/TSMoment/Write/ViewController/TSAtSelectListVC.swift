//
//  TSAtSelectedListVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/22.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSAtSelectListVC: TSFriendsListVC {
    
    override func prepareViews() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 33))
        button.setTitle("cancel".localized, for: .normal)
        button.titleLabel?.setFontSize(with: 15.0, weight: .norm)
        button.setTitleColor(TSColor.main.theme, for: .normal)
        button.addTap { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let content = textField.text, content.isEmpty == false else { return true }
        isSearching = true
        friendListTableView.mj_header.beginRefreshing()
        /// 执行搜索API
        
        let extras = TSUtil.getUserID(remarkName: content)
        
        TSNewFriendsNetworkManager.searchUsers(keyword: textField.text!, extras: extras, offset: 0) { [weak self] (datas: [UserInfoModel]?, message: String?, _) in
            guard let self = self else { return }
            self.processRefresh(datas: datas, message: nil)
            self.isSearching = false
            self.friendListTableView.mj_header.endRefreshing()
        }
        searchTextfield.resignFirstResponder()
        return true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "fiendlistcell"
        var cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as? TSMyFriendListCell
        if cell == nil {
            cell = TSMyFriendListCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: indentifier)
        }
        cell?.setUserInfoData(model: dataSource[indexPath.row])
        cell?.delegate = self
        cell?.chatButton.isHidden = true
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]

        if self.selectedBlock != nil {
            self.selectedBlock!(model)
            self.navigationController?.popViewController(animated: true)
            return
        }
    }
    
    override func pushSearchPeopleVC() {
//        let vc = TSNewFriendsSearchVC.vc()
//        vc.isJustSearchFriends = true
//        vc.isTagging = true
//        vc.searchSelectedBlock = { [weak self] (userInfo) in
//            guard let self = self else { return } 
//            if self.selectedBlock != nil {
//                self.selectedBlock!(userInfo)
//                self.navigationController?.popViewController(animated: true)
//                return
//            }
//            /// 先移除光标所在前一个at
//        }
//
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
