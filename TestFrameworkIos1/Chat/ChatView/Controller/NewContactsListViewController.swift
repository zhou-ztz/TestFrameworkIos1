//
//  NewContactsListViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/4/11.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit


let tableviewCellHeigt: CGFloat = 56.0

class NewContactsListViewController: TSViewController {

    var searchBar: ContactsSearchView!
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
    /// 是否需要显示 collectionView
    var isShowCol: Bool = true
    ///搜索 取消按钮样式
    var cancelType: SearchCancleType = .editingShow
    
    var didSelectData: (([ContactData])->())?
    
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
        layout.itemSize = CGSize(width: 62, height: 80)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.register(ContactsSelecletdCell.self, forCellWithReuseIdentifier: ContactsSelecletdCell.cellIdentifier)
        collection.backgroundColor = .white
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    
    lazy var tableView: TSTableView = {
        let table = TSTableView(frame: .zero, style: .grouped)
        table.register(NewContactsListCell.self, forCellReuseIdentifier: "NewContactsListCell")
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        table.rowHeight = tableviewCellHeigt
        return table
    }()
    
    init(isShowCol: Bool = true, cancelType: SearchCancleType = .editingShow) {
        super.init(nibName: nil, bundle: nil)
        self.isShowCol = isShowCol
        self.cancelType = cancelType
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        tableView.mj_header.beginRefreshing()
        collectionView.isHidden = true
    }
    
    func setUI(){
        
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(10)
        }
        searchBar = ContactsSearchView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 36), cancelType: self.cancelType)
        //searchBar.delegate = self
        
        stackView.addArrangedSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(36)
        }
        
        stackView.addArrangedSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(80)
        }
        
        stackView.addArrangedSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
        }
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreFriends))
        tableView.mj_footer.makeHidden()
    }
    

    @objc func refresh(){
        offset = 0
        TSUserNetworkingManager().friendList(offset: offset, keyWordString: keyword, complete: { (userModels, networkError) in
            self.tableView.mj_header.endRefreshing()
            if networkError != nil {
                self.tableView.show(placeholderView: .network)
            }else {
                if let datas = userModels {
                    self.dataSource = datas
                    if self.dataSource.isEmpty {
                        self.tableView.show(placeholderView: .empty)
                    } else {
                        self.tableView.removePlaceholderViews()
                    }
                
                    self.offset = datas.count
                    DispatchQueue.main.async {
                        self.sortUserList()
                        
                        if datas.count < TSNewFriendsNetworkManager.limit {
                            self.tableView.mj_footer.makeVisible()
                            self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        } else {
                            self.tableView.mj_footer.makeVisible()
                            self.tableView.mj_footer.endRefreshing()
                        }
                    }
                    
                }else{
                    self.indexDataSource.removeAll()
                    self.sortedModelArr.removeAll()
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    @objc func loadMoreFriends(){
        offset = offset + 1
        tableView.mj_footer.makeVisible()
        
        TSUserNetworkingManager().friendList(offset: offset, keyWordString: keyword, complete: { (userModels, networkError) in
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
            self.indexDataSource.removeAll()
            self.sortedModelArr.removeAll()
            self.tableView.reloadData()
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
    
    func numSelectedChange(){
        self.didSelectData?(choosedDataSource)
    }

}

extension NewContactsListViewController: ContactsSelecletdCellDelegate {
    @objc func deleteButtonClick(model: ContactData?) {
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
            
            var section = 0
            var row = 0
            var flag = false
            for arr in sortedModelArr {
                if let index = arr.firstIndex(where: {$0.userName == model.userName}) {
                    row = index
                    flag = true
                    break
                }
                section = section + 1
            }
            
            if flag {
                let index = IndexPath(row: row, section: section)
                if let cell: NewContactsListCell = tableView.cellForRow(at: index) as? NewContactsListCell {
                    cell.chatButton.isSelected = false
                }
            }
            
            numSelectedChange()
        }
    }
}


extension NewContactsListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return choosedDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactsSelecletdCell.cellIdentifier, for: indexPath) as? ContactsSelecletdCell, let data = choosedDataSource[indexPath.item] as? ContactData {
            cell.setData(model: data)
            cell.delegate = self
            return cell
        }
        return UICollectionViewCell()
    }
}

extension NewContactsListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return indexDataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sortedModelArr[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewContactsListCell", for: indexPath) as! NewContactsListCell
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
        view.backgroundColor = UIColor(hex: 0xF6F6F6)
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
        }
        numSelectedChange()
    }
}


