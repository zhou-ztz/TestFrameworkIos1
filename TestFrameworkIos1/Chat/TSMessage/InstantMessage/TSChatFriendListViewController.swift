//
//  TSChatFriendListViewController.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2018/1/12.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import SDWebImage

enum FriendsActionType: String {
    case add = "add"
    case map = "map"
    case delete = "delete"
    case createChat = ""
    case singleSwitchGroup = "singleswitchgroup"
}

class TSChatFriendListViewController: TSViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, TSChatChooseFriendCellDelegate, UIScrollViewDelegate {

    /// 数据源
    var dataSource: [UserInfoModel] = []
    /// 当前页面新选择的数据
    var choosedDataSource = NSMutableArray()
    /// 进入当前页面之前就已经选择的数据（主要是存储从群详情页和查看群成员页面跳转过来的时候一并传递过来的已有群成员数据）
    var originDataSource = NSMutableArray()
    /// 删除成员时候自己检索出来的成员数据数组
    var searchDataSource = NSMutableArray()
    /// 当前操作之前的群 ID
    var currenGroupId: String? = ""

    var collectionView: UICollectionView!
    var friendListTableView: TSTableView!
    var searchView = UIView()
    var searchTextfield = UITextField()
    var choosedScrollView = UIScrollView()
    let headerSpace: Int = 8
    let headerWidth: Int = 32
    /// 屏幕比例
    let scale = UIScreen.main.scale
    /// 聊天按钮
    var chatItem: UIButton?
    /// 占位图
    let occupiedView = UIImageView()
    /// 右上确定聊天按钮
    fileprivate weak var chatSureButton: UIButton!

    var chatType: String? = ""
    /// 搜索关键词
    var keyword = ""
    /// 是否是增删成员才进入这个页面的 "" 为正常创建聊天 add 为增加成员  delete 为删减成员
    var ischangeGroupMember: FriendsActionType? = .createChat
    /// 右上角按钮显示内容文字（增加页面 “添加“ 删减页面 “删除” 创建聊天页面 “聊天” 默认是 “聊天”）
    var rightButtonTitle: String = "display_chat".localized
    /// 如果是删除群成员的页面，这个群主 ID 必须传
    var ownerId: String = ""

    var stackview = UIStackView()
    
    private lazy var numberOfSelectionView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.bounds.width, height: 30)))
        return view
    }()
    
    private lazy var numberOfSelectionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.applyStyle(.regular(size: 14, color: UIColor(hex: 0x9b9b9b)))
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        configureNavTitle()
        createLeftButton()
        createRightButton()
        setupStackView()
        creatTopSubView()
        createCollectionView()
        creatTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    func setupStackView() {
        stackview.axis = .vertical
        stackview.spacing = 0
        stackview.distribution = .fill
        self.view.addSubview(stackview)
        stackview.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    func configureNavTitle() {
        if ischangeGroupMember == .createChat {
            rightButtonTitle = "display_chat".localized
            title = "select_contact".localized
        } else if ischangeGroupMember == .add {
            rightButtonTitle = "add".localized
            title = "add_member".localized
        } else if ischangeGroupMember == .map {
            rightButtonTitle = "send".localized
            title = "select_contact".localized
        } else if ischangeGroupMember == .delete {
            rightButtonTitle = "choice_delete".localized
            title = "group_remove_member".localized
            for (index, item) in originDataSource.enumerated().reversed() {
                let userinfo: UserInfoModel = item as! UserInfoModel
                if userinfo.userIdentity == Int(ownerId) {
                    originDataSource.removeObject(at: index)
                }
            }
            searchDataSource.addObjects(from: originDataSource as! [Any])
        }
    }
    
    func createLeftButton() {
        self.setCloseButton(backImage: true, titleStr: "", completion: {
            self.leftBtnClick()
        })
        
//        let leftItemBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
//        leftItemBtn.setTitle("cancel".localized, for: .normal)
//        leftItemBtn.set(font: UIFont.systemFont(ofSize: 16))
//        leftItemBtn.setTitleColor(AppTheme.red, for: .normal)
//        leftItemBtn.setTarget(self, action: #selector(leftBtnClick(btn:)), for: .touchUpInside)
//        let letfItem = UIBarButtonItem(customView: leftItemBtn)
//        self.navigationItem.leftBarButtonItem = letfItem
    }
    
    func createRightButton() {
        chatItem = UIButton(type: .custom)
        chatItem?.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)
        self.setupNavigationTitleItem(chatItem!, title: rightButtonTitle)
        chatItem?.setTitleColor(AppTheme.headerTitleGrey, for: .normal)
        chatItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: chatItem!)
    }
    
    // MARK: - 创建顶部视图
    func creatTopSubView() {
        numberOfSelectionLabel.text = String(format: "friend_select_selection_count".localized, 0)
        numberOfSelectionView.addSubview(numberOfSelectionLabel)
        numberOfSelectionLabel.snp.makeConstraints {
            $0.top.bottom.right.left.equalToSuperview().inset(15)
            $0.height.equalTo(18)
        }
        stackview.addArrangedSubview(numberOfSelectionView)
        
        occupiedView.contentMode = .center
        /// 搜索试图
        searchView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 49.5))
        searchView.backgroundColor = UIColor.white
        searchView.isHidden = true

        choosedScrollView = UIScrollView()
        choosedScrollView.isScrollEnabled = true
        choosedScrollView.isPagingEnabled = true
        choosedScrollView.showsHorizontalScrollIndicator = false
        searchView.addSubview(choosedScrollView)
        choosedScrollView.isHidden = true

        searchTextfield = UITextField(frame: CGRect(x: 15, y: 0, width: ScreenWidth - 15 * 2, height: 34))
        searchTextfield.font = UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
        searchTextfield.textColor = TSColor.normal.minor
        searchTextfield.placeholder = "placeholder_search_message".localized
        searchTextfield.returnKeyType = .search
        searchTextfield.backgroundColor = UIColor(hex: 0xF5F5F5)
        searchTextfield.layer.cornerRadius = 16
        searchTextfield.delegate = self
        searchTextfield.autocorrectionType = .no

        let paddingView = UIView(frame: CGRect(x:0, y:0, width: 32, height: searchTextfield.height))
        let searchIcon = UIImageView()
        searchIcon.image = UIImage.set_image(named: "IMG_search_icon_search")
        searchIcon.contentMode = .center
        searchIcon.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        searchIcon.center = paddingView.center
        paddingView.addSubview(searchIcon)
        searchTextfield.leftView = paddingView
        searchTextfield.leftViewMode = .always
        searchView.addSubview(searchTextfield)

//        let lineView = UIView(frame: CGRect(x: 0, y: 49, width: ScreenWidth, height: 0.5))
//        lineView.backgroundColor = UIColor(hex: 0xdedede)
//        searchView.addSubview(lineView)
        
        stackview.addArrangedSubview(searchView)
        searchView.snp.makeConstraints {
            $0.height.equalTo(50)
        }
    }
    
    func createCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 0.01
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        layout.itemSize = CGSize(width: 62, height: 80)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ContactsSelecletdCell.self, forCellWithReuseIdentifier: ContactsSelecletdCell.cellIdentifier)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isHidden = true
        stackview.addArrangedSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.height.equalTo(80)
        }
    }

    func creatTableView() {
        friendListTableView = TSTableView(frame: .zero, style: UITableView.Style.plain)
        friendListTableView.delegate = self
        friendListTableView.dataSource = self
        friendListTableView.separatorStyle = .none
        friendListTableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        if ischangeGroupMember != .delete {
//            friendListTableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
            friendListTableView.mj_footer.isHidden = true
        } else {
            friendListTableView.mj_footer = nil
        }
        
        stackview.addArrangedSubview(friendListTableView)
        friendListTableView.mj_header.beginRefreshing()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ischangeGroupMember == .delete {
            if searchDataSource.count > 0 {
                occupiedView.removeFromSuperview()
            }
            return searchDataSource.count
        } else {
            friendListTableView.mj_footer.isHidden = dataSource.count < TSNewFriendsNetworkManager.limit
            if !dataSource.isEmpty {
                occupiedView.removeFromSuperview()
            }
            return dataSource.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "chatfiendlistcell"
        var cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as? TSChatChooseFriendCell
        if cell == nil {
            cell = TSChatChooseFriendCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: indentifier)
        }
        cell?.currentChooseArray = choosedDataSource
        cell?.originData = originDataSource
        cell?.ischangeGroupMember = ischangeGroupMember
        cell?.selectionStyle = .none
        if ischangeGroupMember == .delete {
            cell?.setUserInfoData(model: searchDataSource[indexPath.row] as! UserInfoModel)
        } else {
            cell?.setUserInfoData(model: dataSource[indexPath.row])
        }
        cell?.delegate = self
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.5
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell: TSChatChooseFriendCell = tableView.cellForRow(at: indexPath) as! TSChatChooseFriendCell
        
        /// 需要先判断当前页面是不是增加成员页面
        if ischangeGroupMember == .add {
            for (_, model) in originDataSource.enumerated() {
                let userinfo: UserInfoModel = model as! UserInfoModel
                if userinfo.userIdentity == cell.userInfo?.userIdentity {
                    return
                }
            }
        }
        if cell.chatButton.isSelected {
            for (index, model) in choosedDataSource.enumerated() {
                let userinfo: UserInfoModel = model as! UserInfoModel
                if userinfo.userIdentity == cell.userInfo?.userIdentity {
                    choosedDataSource.removeObject(at: index)
                    break
                }
            }
            updateChoosedScrollViewUI(chooseArray: choosedDataSource)
        } else {
            choosedDataSource.add(cell.userInfo)
            updateChoosedScrollViewUI(chooseArray: choosedDataSource)
        }
        cell.chatButton.isSelected = !cell.chatButton.isSelected
        // 头像默认点击事件
//        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": model.userIdentity])
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Friends"
//    }
//    
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        let header = view as! UITableViewHeaderFooterView
//        header.textLabel?.font = UIFont.systemFont(ofSize: 14)
//        header.textLabel?.textColor = UIColor(hexString: "#9a9a9a")
//    }
    
    @objc func refresh() {
        if ischangeGroupMember == .delete {
            self.friendListTableView.mj_header.endRefreshing()

            keyword = searchTextfield.text ?? ""
            keyword = keyword.replacingOccurrences(of: " ", with: "")
            view.endEditing(true)
            if keyword == "" {
                searchDataSource.removeAllObjects()
                searchDataSource.addObjects(from: originDataSource as! [Any])
                friendListTableView.reloadData()
            } else {
                searchDataSource.removeAllObjects()
                for (_, item) in dataSource.enumerated() {
                    let usermodel: UserInfoModel = item as! UserInfoModel
                    if usermodel.name.range(of: keyword) != nil {
                        searchDataSource.add(usermodel)
                    }
                }
                friendListTableView.reloadData()
            }
        } else {
            keyword = searchTextfield.text ?? ""
            keyword = keyword.replacingOccurrences(of: " ", with: "")
            view.endEditing(true)
            TSUserNetworkingManager().friendList(offset: nil, keyWordString: keyword, complete: { (userModels, networkError) in
                // 如果是第一次进入
                self.friendListTableView.mj_header.endRefreshing()
                self.processRefresh(datas: userModels, message: networkError)
            })
        }
    }

    @objc func loadMore() {
        TSUserNetworkingManager().friendList(offset: dataSource.count, keyWordString: nil, complete: { [weak self] (userModels, networkError) in
            guard let weakSelf = self else {
                return
            }
            guard let datas = userModels else {
                weakSelf.friendListTableView.mj_footer.endRefreshing()
                return
            }
            if datas.count < TSNewFriendsNetworkManager.limit {
                weakSelf.friendListTableView.mj_footer.endRefreshingWithNoMoreData()
            } else {
                weakSelf.friendListTableView.mj_footer.endRefreshing()
            }
            weakSelf.dataSource = weakSelf.dataSource + datas
            weakSelf.friendListTableView.reloadData()
        })
    }

    func processRefresh(datas: [UserInfoModel]?, message: NetworkError?) {
        friendListTableView.mj_footer.resetNoMoreData()
        // 获取数据成功
        if let datas = datas {
            dataSource = datas
            if dataSource.isEmpty && keyword.isEmpty {
                friendListTableView.show(placeholderView: .empty)
            } else {
                searchView.isHidden = false
            }
        }
        // 获取数据失败
        if message != nil {
            dataSource = []
            friendListTableView.show(placeholderView: .network)
        }
        friendListTableView.reloadData()
    }

    @objc func rightButtonClick() {
        chatItem?.isUserInteractionEnabled = false
        if ischangeGroupMember == .createChat {
            creatNewChat()
        } else if ischangeGroupMember == .add {
            addMembersForGroup(addOrDelete: "add")
        } else if ischangeGroupMember == .delete {
            addMembersForGroup(addOrDelete: "delete")
        } else if ischangeGroupMember == .map {
              creatNewChat()
        }
    }

    // MARK: - 新创建聊天
    func creatNewChat() {
        /// implmentations in ChatFriendListViewController
    }

    // 显示创建失败提示
    func showFialMsg(msg: String) {
        let alert = TSIndicatorWindowTop(state: .faild, title: msg)
        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    // MARK: - 增加群成员
    /*
    移除群成员：
    /easemob/group/member
    delete
    参数：im_group_id
    members      多个用","隔开
    */
    func addMembersForGroup(addOrDelete: String) {
        // ChatFriendListViewController
    }

    // MARK: - TSChatChooseFriendCellDelegate
    func chatButtonClick(chatbutton: UIButton, userModel: UserInfoModel) {
        if ischangeGroupMember == .add {
            for (_, model) in originDataSource.enumerated() {
                let userinfo: UserInfoModel = model as! UserInfoModel
                if userinfo.userIdentity == userModel.userIdentity {
                    return
                }
            }
        }
        if chatbutton.isSelected {
            choosedDataSource.remove(userModel)
            updateChoosedScrollViewUI(chooseArray: choosedDataSource)
        } else {
            choosedDataSource.add(userModel)
            updateChoosedScrollViewUI(chooseArray: choosedDataSource)
        }
        chatbutton.isSelected = !chatbutton.isSelected
    }
 
    // MARK: - 修改已选好友排版视图 choosedScrollView
    func updateChoosedScrollViewUI(chooseArray: NSMutableArray) {
        let searchTextfieldMinWidth = (ScreenWidth - 35) * 0.3
        
        choosedScrollView.isHidden = false
        /// 首先要把所有子视图移除，避免重复添加
        choosedScrollView.removeAllSubViews()
        /// 处理 scrollView
        var choosedWidth: Int = 0
        if chooseArray.count <= 0 {
            choosedWidth = 0
            searchTextfield.leftViewMode = .always
        } else {
            // 第一个头像左边也得有一个间隔
            choosedWidth = chooseArray.count * headerWidth + (chooseArray.count - 1) * headerSpace + headerSpace
            searchTextfield.leftViewMode = .never
        }
        if choosedWidth > (Int)(ScreenWidth - searchTextfieldMinWidth) {
            choosedScrollView.frame = CGRect(x: 0, y: 0, width: ScreenWidth - searchTextfieldMinWidth, height: 49)
            searchTextfield.frame = CGRect(x: choosedScrollView.right + 5, y: (49 - 34) / 2.0, width: searchTextfieldMinWidth, height: 34)
        } else {
            choosedScrollView.frame = CGRect(x: 0, y: 0, width: choosedWidth, height: 49)
            if choosedWidth == 0 {
                searchTextfield.frame = CGRect(x: 15, y: (49 - 34) / 2.0, width: ScreenWidth - 15 * 2, height: 34)
            } else {
                searchTextfield.frame = CGRect(x: choosedScrollView.right + 5, y: (49 - 34) / 2.0, width: ScreenWidth - CGFloat(choosedWidth) - 15.0 - 5.0, height: 34)
            }
        }
        choosedScrollView.contentSize = CGSize(width: choosedWidth, height: 0)
        choosedScrollView.scrollToRight()
        /// 依次布局头像视图
        populateHeadImage(chooseArray)
        
        updateNumberOfSelection()
        chatItem?.isEnabled = choosedDataSource.count > 0 ? true : false
    }
    
    func populateHeadImage(_ chooseArray: NSMutableArray) {
        
        for (index, model) in chooseArray.enumerated() {
            let usermodel: UserInfoModel = model as! UserInfoModel
            let headerButton: UIButton = UIButton(frame: CGRect(x: index * (headerWidth + headerSpace) + headerSpace, y: (49 - headerWidth) / 2, width: headerWidth, height: headerWidth))
            headerButton.layer.masksToBounds = true
            headerButton.layer.cornerRadius = CGFloat(headerWidth) / 2.0
            headerButton.tag = index
            headerButton.addTarget(self, action: #selector(deleteUser(_:)), for: .touchUpInside)
            if let url = usermodel.avatarUrl, url.isEmpty == false,
               let imageUrl = URL(string: url) {
                headerButton.sd_setImage(with: imageUrl,
                                         for: .normal,
                                         placeholderImage: UIImage.set_image(named: "IMG_pic_default_secret"),
                                         options: .lowPriority,
                                         completed: nil)
            } else {
                if usermodel.sex == 1 {
                    headerButton.setImage(UIImage.set_image(named: "IMG_pic_default_man"), for: .normal)
                } else if usermodel.sex == 2 {
                    headerButton.setImage(UIImage.set_image(named: "IMG_pic_default_woman"), for: .normal)
                } else {
                    headerButton.setImage(UIImage.set_image(named: "IMG_pic_default_secret"), for: .normal)
                }
            }
            let iconImage: UIImageView = UIImageView(frame: CGRect(x: headerButton.left + headerButton.frame.width * 0.65, y: headerButton.top + headerButton.frame.width * 0.65, width: headerButton.frame.width * 0.35, height: headerButton.frame.width * 0.35)).configure { $0.contentMode = .scaleAspectFill }
            iconImage.layer.masksToBounds = true
            iconImage.layer.cornerRadius = headerButton.frame.width * 0.35 / 2.0
            if usermodel.verificationType.orEmpty.isEmpty {
                iconImage.isHidden = true
            } else {
                iconImage.isHidden = false
                if usermodel.verificationIcon.orEmpty.isEmpty {
                    switch usermodel.verificationType.orEmpty {
                    case "user":
                        iconImage.image = UIImage.set_image(named: "IMG_pic_identi_individual")
                    case "org":
                        iconImage.image = UIImage.set_image(named: "IMG_pic_identi_company")
                    default:
                        iconImage.image = nil
                    }
                } else {
                    let urlString = usermodel.verificationIcon.orEmpty.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    let iconURL = URL(string: urlString ?? "")
                    iconImage.sd_setImage(with: iconURL, completed: nil)                        
                }
            }
            choosedScrollView.addSubview(headerButton)
            choosedScrollView.addSubview(iconImage)
        }
    }
    
    func updateNumberOfSelection() {
        numberOfSelectionLabel.text = String(format: "friend_select_selection_count".localized, choosedDataSource.count)
    }
        
    func textFieldDidBeginEditing(_ textField: UITextField) {}
    func textFieldDidEndEditing(_ textField: UITextField) {}
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keyword = searchTextfield.text ?? ""
        keyword = keyword.replacingOccurrences(of: " ", with: "")
        view.endEditing(true)
        if ischangeGroupMember == .delete {
            searchDataSource.removeAllObjects()
            for (_, item) in dataSource.enumerated() {
                let usermodel: UserInfoModel = item as UserInfoModel
                if usermodel.name.range(of: keyword) != nil {
                    searchDataSource.add(usermodel)
                }
            }
            friendListTableView.reloadData()
            return true
        }
        TSUserNetworkingManager().friendList(offset: nil, keyWordString: keyword, complete: { (userModels, networkError) in
            self.processRefresh(datas: userModels, message: networkError)
        })
        return true
    }
    
    @objc func leftBtnClick() {
        if self.isModal {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

//    @objc func leftBtnClick(btn: UIButton) {
//        if self.isModal {
//            self.navigationController?.dismiss(animated: true, completion: nil)
//        } else {
//            self.navigationController?.popViewController(animated: true)
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    @objc func deleteUser(_ sender: ContactPickerHeaderButton) {
        searchTextfield.resignFirstResponder()
        choosedDataSource.removeObject(at: sender.tag)
        updateChoosedScrollViewUI(chooseArray: choosedDataSource)
        friendListTableView.reloadData()
    }
}

extension TSChatFriendListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return choosedDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactsSelecletdCell.cellIdentifier, for: indexPath) as! ContactsSelecletdCell
        //cell.delegate = self

        cell.setData(model: choosedDataSource[indexPath.item] as! ContactData)
        return cell
    }
    
}
