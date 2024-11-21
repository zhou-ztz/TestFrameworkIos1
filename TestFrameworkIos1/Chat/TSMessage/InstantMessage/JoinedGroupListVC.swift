//
//  JoinedGroupListVC.swift
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/5/13.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class JoinedChatGroup: NSObject {
    var groupId: String = ""
    var face: String = ""
    var name: String = ""
    var groupOwnerId: Int = 0
    var isMyGroup: Bool = false
}

class JoinedGroupListVC: TSViewController, UISearchBarDelegate, UIScrollViewDelegate {
    var searchBar: TSSearchBar!
    var tableview: TSTableView!
    var dataSource: [JoinedChatGroup] = []
    var searchArray: [JoinedChatGroup] = []
    var showDataArray: [JoinedChatGroup] = []
    // 是否是显示搜索结果
    var isSearchResult: Bool = false
    fileprivate var currentPage: Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "build_notif_groups".localized
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 47))
        bgView.backgroundColor = UIColor.white
        self.view.addSubview(bgView)
        self.searchBar = TSSearchBar(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: bgView.height))
        self.searchBar.layer.masksToBounds = true
        self.searchBar.layer.cornerRadius = 5.0
        self.searchBar.backgroundImage = nil
        self.searchBar.backgroundColor = UIColor.white
        self.searchBar.returnKeyType = .search
        self.searchBar.barStyle = UIBarStyle.default
        self.searchBar.barTintColor = UIColor.clear
        self.searchBar.tintColor = TSColor.main.theme
        self.searchBar.searchBarStyle = UISearchBar.Style.minimal
        self.searchBar.delegate = self
        self.searchBar.placeholder = "placeholder_search_message".localized
        bgView.addSubview(self.searchBar!)

        self.tableview = TSTableView(frame: CGRect(x: 0, y: bgView.bottom, width: ScreenWidth, height: ScreenHeight - 64 - bgView.height))
        self.view.addSubview(self.tableview!)
        self.tableview.rowHeight = 65
        self.tableview.separatorStyle = .none
        self.tableview.register(UINib(nibName: "JoinedGroupListCell", bundle: nil), forCellReuseIdentifier: "JoinedGroupListCell")
        self.tableview.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(getGroupInfo))
        self.tableview.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.tableview.mj_footer.isHidden = true
        self.tableview.mj_header.beginRefreshing()
    }
    @objc func getGroupInfo() {
        // Overriden by GroupListViewController
    }
    // MARK: - 本地搜索群昵称
    func searchGroupName(name: String) {
        // Overriden by GroupListViewController
    }

    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.searchGroupName(name: searchBar.text ?? "")
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.searchGroupName(name: searchBar.text ?? "")
        }
    }

    @objc func loadMore() {
        // Overriden by GroupListViewController
    }

    func refresh() {
        // Overriden by GroupListViewController
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
