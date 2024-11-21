//
//  TSGroupNewOwnerVC.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2018/1/26.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSGroupNewOwnerVC: TSViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    var dismissBlock: (() -> Void)?
    /// 进入当前页面之前就已经选择的数据（主要是存储从群详情页和查看群成员页面跳转过来的时候一并传递过来的已有群成员数据）
    var originDataSource = NSMutableArray()
    /// 删除成员时候自己检索出来的成员数据数组
    var searchDataSource = NSMutableArray()
    /// 当前操作之前的群 ID
    var currenGroupId: String? = ""
    /// 从群信息页面传递过来的群信息原始数据
    var originData = NSDictionary()
    /// 如果是删除群成员的页面，这个群主 ID 必须传
    var ownerId: String = ""
    /// 模态弹出的VC 因为一时不知道怎么获取那就直接传吧
    var bePresentVC: UIViewController?

    /// 占位图
    let occupiedView = FadeImageView()
    /// 搜索关键词
    var keyword = ""

    var friendListTableView: TSTableView!
    var searchbarView = TSSearchBarView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TSColor.inconspicuous.background
        title = "chat_edit_group_owner_edit".localized
        /// 剔除群主自己
        for (index, item) in originDataSource.enumerated().reversed() {
            let userinfo: UserInfoModel = item as! UserInfoModel
            if userinfo.userIdentity == Int(ownerId) {
                originDataSource.removeObject(at: index)
            }
        }
        searchDataSource.addObjects(from: originDataSource as! [Any])
        creatSubView()
        // Do any additional setup after loading the view.
    }

    // MARK: - 布局子视图
    func creatSubView() {
        searchbarView = TSSearchBarView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 64))
        self.view.addSubview(searchbarView)
        searchbarView.rightButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        searchbarView.searchTextFiled.placeholder = "placeholder_search_message".localized
        searchbarView.searchTextFiled.returnKeyType = .search
        searchbarView.searchTextFiled.delegate = self
        let noticeLab = TSLabel(frame: CGRect(x: 14, y: self.searchbarView.bottom, width: ScreenWidth - 14, height: 36))
        self.view.addSubview(noticeLab)
        noticeLab.backgroundColor = TSColor.inconspicuous.background
        noticeLab.textColor = TSColor.normal.minor
        noticeLab.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
        noticeLab.text = "chat_edit_group_owner_edit".localized
        friendListTableView = TSTableView(frame: CGRect(x: 0, y:noticeLab.bottom, width: ScreenWidth, height: ScreenHeight - 64 - 36), style: UITableView.Style.plain)
        friendListTableView.delegate = self
        friendListTableView.dataSource = self
        friendListTableView.separatorStyle = .none
        friendListTableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.view.addSubview(friendListTableView)
        friendListTableView.mj_footer = nil
        friendListTableView.mj_header.beginRefreshing()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchDataSource.count > 0 {
            occupiedView.removeFromSuperview()
        }
        return searchDataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "changegroupownercell"
        var cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as? TSGroupNewOwnerCell
        if cell == nil {
            cell = TSGroupNewOwnerCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: indentifier)
        }
        cell?.setUserInfoData(model: searchDataSource[indexPath.row] as! UserInfoModel)
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.5
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let actionsheetView = TSCustomActionsheetView(titles: ["tips_confirm_transfer".localized, "confirm".localized])
        actionsheetView.setColor(color: TSColor.main.warn, index: 1)
        actionsheetView.notClickIndexs = [0]
        actionsheetView.show()
        actionsheetView.finishBlock = { (actionsheet: TSCustomActionsheetView, title: String, btnTag: Int) in
        }
    }

    @objc func refresh() {
        keyword = searchbarView.searchTextFiled.text ?? ""
        keyword = keyword.replacingOccurrences(of: " ", with: "")
        view.endEditing(true)
        if keyword == "" {
            self.friendListTableView.mj_header.endRefreshing()
            searchDataSource.removeAllObjects()
            searchDataSource.addObjects(from: originDataSource as! [Any])
            friendListTableView.reloadData()
        } else {
            self.friendListTableView.mj_header.endRefreshing()
            searchDataSource.removeAllObjects()
            for (index, item) in originDataSource.enumerated() {
                let usermodel: UserInfoModel = item as! UserInfoModel
                if usermodel.name.range(of: keyword) != nil {
                    searchDataSource.add(usermodel)
                }
            }
            friendListTableView.reloadData()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keyword = searchbarView.searchTextFiled.text ?? ""
        keyword = keyword.replacingOccurrences(of: " ", with: "")
        view.endEditing(true)
        if keyword == "" {
            searchDataSource.removeAllObjects()
            searchDataSource.addObjects(from: originDataSource as! [Any])
            friendListTableView.reloadData()
        } else {
            searchDataSource.removeAllObjects()
            for (index, item) in originDataSource.enumerated() {
                let usermodel: UserInfoModel = item as! UserInfoModel
                if usermodel.name.range(of: keyword) != nil {
                    searchDataSource.add(usermodel)
                }
            }
            friendListTableView.reloadData()
        }
        self.view.endEditing(true)
        return true
    }

    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
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
