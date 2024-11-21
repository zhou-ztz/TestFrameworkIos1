//
//  MeetingGroupViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/3/7.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class MeetingGroupViewController: TSViewController {
    var searchBar: MeetingSearchView!
    
    lazy var nextBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("next".localized, for: .normal)
        btn.setTitleColor(AppTheme.red, for: .normal)
        btn.titleLabel?.font = UIFont.systemMediumFont(ofSize: 17)
        return btn
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(MeetingFriendsListCell.self, forCellReuseIdentifier: "MeetingFriendsListCell")
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 56
        return table
    }()
    var sortedModelArr: [[NIMTeam]] = []
    var teams: [NIMTeam] = []
    ///索引
    var indexDataSource = [String]()
    var choosedDataSource: [ContactData] = []
    
    var comfirmCall: (([ContactData]) -> ())?
    var meetingNumlimit = 50
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let nav = self.navigationController as? TSNavigationController {
            nav.setCloseButton(backImage: true, titleStr: "meeting_select_group".localized)
        }
        setUI()
        initData()
    }
    
    func initData(){
        if let teams = NIMSDK.shared().teamManager.allMyTeams() {
            self.teams = teams
            sortUserList(teams: self.teams)
        }
        
        
    }
    func sortUserList(teams: [NIMTeam] ) {
        
        // 抽取首字母
        var resultNames: [String] = [String]()
        let nameArray = teams.map({ ($0.teamName ?? " ").transformToPinYin().first?.description ?? " "})
        
        let nameSet: NSSet = NSSet(array: nameArray)
        for item in nameSet {
            resultNames.append("\(item)")
        }
        // 排序, 同时保证特殊字符在最后
        resultNames = resultNames.sorted(by: { (one, two) -> Bool in
            if (one.isNotLetter()) {
                return false
            } else if (two.isNotLetter()) {
                return true
            } else {
                return one < two
            }
        })
        
        // 替换特殊字符
        self.indexDataSource.removeAll()
        let special: String = "#"
        for value in resultNames {
            if (value.isNotLetter()) {
                self.indexDataSource.append(special)
                break
            } else {
                self.indexDataSource.append(value)
            }
        }
        
        // 分组
        self.sortedModelArr.removeAll()
        for object in self.indexDataSource {
            
            let user: [NIMTeam] = teams.filter { dataModel in
                if let pinYin = (dataModel.teamName ?? "").transformToPinYin().first?.description {
                    if (pinYin.isNotLetter() && object == special) {
                        return true
                    } else {
                        return pinYin == object
                    }
                } else {
                    return false
                }
            }
            
            
            
            self.sortedModelArr.append(user)
        
        }
        self.tableView.reloadData()
    }
    
    func setUI(){
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextBtn)
        setSearchBar()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(68)
        }
    }
    
    func setSearchBar(){
        searchBar = MeetingSearchView(frame: CGRect(x: 0, y: 14, width: ScreenWidth, height: 40))
        searchBar.delegate = self
        self.view.addSubview(searchBar)
    }
    
    
    @objc func nextAction(){
        self.view.endEditing(true)
        self.comfirmCall?(self.choosedDataSource)
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchNameFor(keyword: String){
        if keyword.count == 0 {
            self.sortUserList(teams: self.teams)
            return
        }
        
        let results = self.teams.filter { team in
            let name = team.teamName ?? ""
            if name.uppercased().contains(keyword.uppercased()) {
                return true
            }
            return false
        }
        self.sortUserList(teams: results)
    }
}
extension MeetingGroupViewController: MeetingSearchViewDelegate{
    func searchDidClickReturn(text: String) {
        self.searchNameFor(keyword: text)
    }
    
    func searchDidClickCancel() {
        self.searchBar.searchTextFiled.resignFirstResponder()
        
    }
}

extension MeetingGroupViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return indexDataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sortedModelArr[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingFriendsListCell", for: indexPath) as! MeetingFriendsListCell
        cell.currentChooseArray = self.choosedDataSource
        cell.team = sortedModelArr[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return indexDataSource[section]
//    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        return indexDataSource
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell: MeetingFriendsListCell = tableView.cellForRow(at: indexPath) as! MeetingFriendsListCell

        if cell.chatButton.isSelected {
            for (index, model) in choosedDataSource.enumerated() {
                let userinfo: ContactData = model as! ContactData
                if userinfo.userName == cell.team?.teamId {
                    choosedDataSource.remove(at: index)
                    break
                }
            }
            cell.chatButton.isSelected = !cell.chatButton.isSelected
            
        } else {
//            if choosedDataSource.count >= meetingNumlimit {
//                self.showError(message: String(format: "meeting_maximum_members_reached_ios".localized, "\(self.meetingNumlimit)"))
//                return
//            }
            if let team = cell.team {
                let model = ContactData(team: team)
                choosedDataSource.insert(model, at: 0)
                
            }
            cell.chatButton.isSelected = !cell.chatButton.isSelected
            
        }
        
    }
    
    
}
