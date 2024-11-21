//
//  NewContactsViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/4/10.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit


class NewContactsViewController: TSViewController {
    
    var searchBar: MeetingSearchView!
    ///索引
    var indexDataSource = [String]()
    ///搜索关键词
    var keyword: String = ""
    /// 数据源
    var dataSource: [UserInfoModel] = []
    /// 分组好的数据源
    var sortedModelArr: [[ContactData]] = []
    ///选中的数据
    var choosedDataSource: [ContactData] = []
    
    var offset: Int = 0
    ///搜索中
    var isSearching: Bool = false
    var searchOffset: Int = 0
    ///搜索的数据
    var searchdDataSource: [ContactData] = []
    
    /// 防止快速点击导致 choosedDataSource错乱
    var canSelected: Bool = true
    
    var stackView: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = 14
        $0.distribution = .fill
        $0.alignment = .leading
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 0.01
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        layout.itemSize = CGSize(width: 62, height: 88)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.register(MeetingFriendCell.self, forCellWithReuseIdentifier: MeetingFriendCell.cellIdentifier)
        collection.backgroundColor = .white
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    
    lazy var tableView: TSTableView = {
        let table = TSTableView(frame: .zero, style: .grouped)
        table.register(MeetingFriendsListCell.self, forCellReuseIdentifier: "MeetingFriendsListCell")
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 56
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        tableView.mj_header.beginRefreshing()
        collectionView.isHidden = choosedDataSource.count == 0
        
    }
    
    func setUI(){
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(14)
        }
        searchBar = MeetingSearchView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 40))
        //searchBar.delegate = self
        
        stackView.addArrangedSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        stackView.addArrangedSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(100)
        }
        
        stackView.addArrangedSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
        }
        //self.tableView.mj_footer.isHidden = true
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreFriends))
        tableView.mj_footer.makeHidden()
    }
    

    @objc func refresh(){
        self.tableView.mj_footer.isHidden = true
        offset = 0
        TSUserNetworkingManager().friendList(offset: offset, keyWordString: "", complete: { (userModels, networkError) in
            self.tableView.mj_header.endRefreshing()
            if networkError != nil {
                self.tableView.show(placeholderView: .network)
            }else {
                if let datas = userModels {
                    self.dataSource = datas
                    if self.dataSource.isEmpty  {
                        self.tableView.show(placeholderView: .empty)
                    } else {
                        self.tableView.removePlaceholderViews()
                        self.tableView.mj_footer.isHidden = false
                    }
                    if datas.count < TSNewFriendsNetworkManager.limit {
                        self.tableView.mj_footer.makeVisible()
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_footer.makeVisible()
                        self.tableView.mj_footer.endRefreshing()
                    }
                    self.offset = datas.count
                    DispatchQueue.main.async {
                        self.sortUserList()
                    }
                    
                }
            }
        })
    }
    
    @objc func loadMoreFriends(){
        offset = offset + 1
        self.tableView.mj_footer.makeVisible()
        TSUserNetworkingManager().friendList(offset: offset, keyWordString: "", complete: { (userModels, networkError) in
            self.tableView.mj_header.endRefreshing()
            if networkError != nil {
                self.tableView.mj_footer.endRefreshing()
                self.tableView.show(placeholderView: .network)
            }else {
                if let datas = userModels {
                    self.offset = self.offset + datas.count
                    self.dataSource = self.dataSource + datas
                    if self.dataSource.isEmpty && self.keyword.isEmpty {
                        self.tableView.show(placeholderView: .empty)
                    } else {
                        
                    }
                    if datas.count < TSNewFriendsNetworkManager.limit {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_footer.endRefreshing()
                    }
                    DispatchQueue.main.async {
                        self.sortUserList()
                    }
                    
                }else{
                    self.tableView.mj_footer.endRefreshing()
                }
            }
        })
    }
    
    
    func sortUserList() {
        if self.dataSource.count == 0 {
            return
        }
        // 抽取首字母
        var resultNames: [String] = [String]()
        let nameArray = self.dataSource.map({ $0.name.transformToPinYin().first?.description ?? ""})
        
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
            
            let user: [UserInfoModel] = self.dataSource.filter { dataModel in
                if let pinYin = dataModel.name.transformToPinYin().first?.description {
                    if (pinYin.isNotLetter() && object == special) {
                        return true
                    } else {
                        return pinYin == object
                    }
                } else {
                    return false
                }
            }
            
            let users = user.compactMap {
                ContactData(model: $0)
            }
            self.sortedModelArr.append(users)
            
        }
        self.tableView.reloadData()
    }
    
    @objc func changeTableViewSelectedStatus(){
        canSelected = true
    }

    func reloadNumberUI(){}
}

extension NewContactsViewController: MeetingFriendtCellDelegate {
    func deleteButtonClick(model: ContactData) {
        let userinfo = model
        if let indexCol = choosedDataSource.firstIndex(where: {$0.userName == userinfo.userName}) {
            choosedDataSource.remove(at: indexCol)
            UIView.performWithoutAnimation {
                self.collectionView.performBatchUpdates {
                    self.collectionView.deleteItems(at: [IndexPath(row: indexCol, section: 0)])
                }
            }
            collectionView.isHidden = choosedDataSource.count == 0
            reloadNumberUI()
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
                if let cell: MeetingFriendsListCell = tableView.cellForRow(at: index) as? MeetingFriendsListCell {
                    cell.chatButton.isSelected = false
                }
  
            }
            
        }
  
    }
}


extension NewContactsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return choosedDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MeetingFriendCell.cellIdentifier, for: indexPath) as! MeetingFriendCell
        cell.delegate = self

        cell.setData(model: choosedDataSource[indexPath.item])
        return cell
    }
    
}

extension NewContactsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return indexDataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sortedModelArr[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingFriendsListCell", for: indexPath) as! MeetingFriendsListCell
        cell.currentChooseArray = self.choosedDataSource
        cell.contactData = sortedModelArr[indexPath.section][indexPath.row]
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
    
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        
//        return indexDataSource
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: MeetingFriendsListCell = tableView.cellForRow(at: indexPath) as! MeetingFriendsListCell
        ///防止快速点击 UI刷新错乱
        if !canSelected {
            return
        }
        self.perform(#selector(changeTableViewSelectedStatus), with: nil, afterDelay: 0.3)
        canSelected = false
        if cell.chatButton.isSelected {
            for (index, model) in choosedDataSource.enumerated() {
                let userinfo: ContactData = model as! ContactData
                if userinfo.userName == cell.contactData?.userName {
                    
                    if let collIndex = choosedDataSource.firstIndex(where: {$0.userName == cell.contactData?.userName}) {
                        let collectionIndexPath = IndexPath(row: collIndex, section: 0)
                        self.collectionView.performBatchUpdates {
                            self.collectionView.deleteItems(at: [collectionIndexPath])
                        }
                        
                    }
 
                    choosedDataSource.remove(at: index)
                    
                    collectionView.isHidden = choosedDataSource.count == 0
                    break
                }
            }
            cell.chatButton.isSelected = !cell.chatButton.isSelected
            
        } else {
            if let contactData = cell.contactData {
                choosedDataSource.insert(contactData, at: 0)
                collectionView.isHidden = choosedDataSource.count == 0
                let collectionIndexPath = IndexPath(row: 0, section: 0)
                self.collectionView.performBatchUpdates {
                    self.collectionView.insertItems(at: [collectionIndexPath])
                }
            }
            cell.chatButton.isSelected = !cell.chatButton.isSelected
            
        }
       
        
    }
    
    
}
