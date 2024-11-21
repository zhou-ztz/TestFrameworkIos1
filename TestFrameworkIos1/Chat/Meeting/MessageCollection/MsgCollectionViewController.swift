//
//  MsgCollectionViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/12.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
//import NIMPrivate
import NIMSDK
import SVProgressHUD


class MsgCollectionViewController: TSViewController {
    var dataArray = [FavoriteMsgModel]()
    var selectData = [FavoriteMsgModel]()
    var selectModel: FavoriteMsgModel?
    let limit = 15
    var excludeId = 0 //上一页最后一条ID，第一条传0
    var selectedType: MessageCollectionType = .all // 收藏类型
    var edit: Bool = false //编辑状态
    private var selectorView: IMCategorySelectView?
    private lazy var msgCategoryView = { return UIView() }()
    let optionView = FeedCategoryOptions()
    var categoryList = [CategoryMsgModel]()
    var isShow: Bool = false
    var isFirstLoad: Bool = true
    
    lazy var placehoderView: UIView = {
        let placehoder = UIView(frame: self.view.bounds)
        placehoder.backgroundColor = .white
        placehoder.isHidden = true
        return placehoder
    }()
    
    lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.text = "favourite_msg_type".localized
        label.textColor = UIColor(red: 136, green: 136, blue: 136)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    lazy var topView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 40))
        view.backgroundColor = .white
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        //layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.estimatedItemSize = CGSize(width: 120, height: 30)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(UINib(nibName: "MsgCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: MsgCollectionViewCell.cellIdentifier)
        collection.dataSource = self
        collection.delegate = self
        collection.isUserInteractionEnabled = true
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.backgroundColor = .white
        tableView.register(UINib(nibName: "MessageCollectCell", bundle: nil), forCellReuseIdentifier: MessageCollectCell.cellIdentifier)
        return tableView
    }()
    
    lazy var cancel: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        btn.setTitle("cancel".localized, for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    lazy var selectedItem: UIButton = {
        let button = UIButton()
        button.setTitle("msg_number_of_selected".localized, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        //button.tintColor = UIColor.black
        return button
    }()
    
    lazy var selectActionToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.tintColor = AppTheme.white
        toolbar.isTranslucent = false
        toolbar.isHidden = true
        return toolbar
    }()
    
    lazy var deleteBarButton: UIBarButtonItem = {
        let button = UIButton()
        button.setImage(UIImage.set_image(named: "msg_select_delete"), for: .normal)
        button.addTarget(self, action: #selector(deleteCollectMessages), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height : -5.0)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 3
        view.isHidden = true
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("favourite_msg_delete".localized, for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = AppTheme.Font.semibold(16)
        button.addTarget(self, action: #selector(deleteCollectMessages), for: .touchUpInside)
        return button
    }()
    
    lazy var fowardButton: UIButton = {
        let button = UIButton()
        button.setTitle("favourite_msg_forward".localized, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = AppTheme.Font.semibold(16)
        button.addTarget(self, action: #selector(forwardAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setCloseButton(backImage: true, titleStr: "title_favourite_message".localized, completion: {
            if !self.isShow {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.isShow = false
                self.shadowView.isHidden = true
            }
            self.selectData.removeAll()
            self.tableView.reloadData()
        }, needPop: false)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancel)
        self.setPlacehoderView()
        self.setRightBarButton()
        self.setUI()
        self.setData()
        self.getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        //showShouldhideTip()
    }
    
    func setUI() {
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.shadowView)
        self.shadowView.addSubview(self.stackView)
        self.stackView.addArrangedSubview(fowardButton)
        self.stackView.addArrangedSubview(deleteButton)
        
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom)
            $0.bottom.left.right.equalToSuperview()
        }
        
        shadowView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            // $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            $0.height.equalTo(90)
        }
        stackView.bindToEdges(inset: 12)
        
        fowardButton.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.height.equalTo(30)
        }
        
        deleteButton.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.height.equalTo(30)
        }
        
        //        topView.addSubview(msgCategoryView)
        //        msgCategoryView.snp.makeConstraints { (make) in
        //            make.top.bottom.right.equalToSuperview()
        //        }
        //        msgCategoryView.addSubview(optionView)
        //        optionView.snp.makeConstraints { (make) in
        //            make.centerY.equalToSuperview()
        //            make.left.equalTo(10)
        //            make.right.equalTo(-10)
        //        }
        
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(getData))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(self.loadMore))
        //        topView.addSubview(typeLabel)
        //        typeLabel.snp.makeConstraints { (make) in
        //            make.left.equalTo(12)
        //            make.top.bottom.equalToSuperview()
        //        }
        //        self.optionView.label.text = "filter_favourite_chats".localized
        //        msgCategoryView.addTap(action: { [weak self] (view) in
        //            guard let self = self else { return }
        //            guard self.selectorView == nil else {
        //                self.selectorView?.hide()
        //                return
        //            }
        //            UIView.animate(withDuration: 0.2) {
        //                self.optionView.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        //            }
        //
        //            self.selectorView = IMCategorySelectView(selectedType: self.selectedType, animatable: true)
        //            self.view.addSubview(self.selectorView!)
        //            self.selectorView?.selectionHandler = { [weak self] (type, name) in
        //                self?.optionView.label.text = name
        //                self?.selectedType = type
        //                self?.excludeId = 0
        //                self?.getData()
        //            }
        //
        //            self.selectorView!.snp.makeConstraints { (v) in
        //                v.top.equalTo(self.topView.snp.bottom)
        //                v.left.bottom.right.equalToSuperview()
        //            }
        //
        //            self.selectorView!.notifyComplete = { [weak self] in
        //                self?.selectorView = nil
        //                UIView.animate(withDuration: 0.2) {
        //                    self?.optionView.arrowImageView.transform = .identity
        //                }
        //            }
        //        })
        self.view.addSubview(selectActionToolbar)
        selectActionToolbar.snp.makeConstraints { make in
            make.height.equalTo(50 + TSBottomSafeAreaHeight)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.view.layer.layoutIfNeeded()
    }
    
    private func setRightBarButton() {
        let button = UIBarButtonItem(title: "edit".localized, style: .plain, target: self, action: #selector(editAction))
        button.tintColor = TSColor.main.theme
        navigationItem.rightBarButtonItems = [button]
    }
    
    func setPlacehoderView() {
        self.view.addSubview(placehoderView)
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 21
        stackView.alignment = .center
        placehoderView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(210)
        }
        
        let imageView = UIImageView()
        imageView.image = UIImage.set_image(named: "placeholder_no_result")
        imageView.contentMode = .scaleAspectFill
        stackView.addArrangedSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.width.equalTo(240)
            make.height.equalTo(200)
        }
        
        let tipLab = UILabel()
        tipLab.text = "favourite_msg_empty_state".localized
        tipLab.textAlignment = .center
        tipLab.textColor = UIColor(red: 155, green: 155, blue: 155)
        tipLab.font = UIFont.systemFont(ofSize: 14)
        stackView.addArrangedSubview(tipLab)
        
        let typeBtn = UIButton()
        typeBtn.setTitle("favourite_msg_button_other_types".localized, for: .normal)
        typeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        typeBtn.setTitleColor(UIColor.white, for: .normal)
        typeBtn.backgroundColor = UIColor(red: 59, green: 179, blue: 255)
        typeBtn.layer.cornerRadius = 22.5
        typeBtn.clipsToBounds = true
        stackView.addArrangedSubview(typeBtn)
        typeBtn.snp.makeConstraints { (make) in
            make.height.equalTo(45)
            make.width.equalTo(159)
        }
        typeBtn.addTarget(self, action: #selector(otherTypeAction), for: .touchUpInside)
        typeBtn.isHidden = true
    }
    
    private func setData() {
        let types: [MessageCollectionType] = [.all, .text, .image, .video, .audio, .link, .location, .file, .nameCard, .voucher]
        let names: [String] = ["filter_favourite_all".localized,"filter_favourite_chats".localized,
                               "filter_favourite_photos".localized, "filter_favourite_videos".localized,
                               "filter_favourite_audios".localized, "filter_favourite_links".localized,
                               "filter_favourite_locations".localized, "filter_favourite_files".localized,
                               "filter_favourite_contacts".localized, "filter_favourite_voucher".localized]
        let images: [UIImage] = [UIImage(), UIImage.set_image(named: "chat")!, UIImage.set_image(named: "album")!, UIImage.set_image(named: "video")!,UIImage.set_image(named: "ic_fav_msg_audio")!, UIImage.set_image(named: "link")!,  UIImage.set_image(named: "location_new")!,  UIImage.set_image(named: "files")!,  UIImage.set_image(named: "ic_contact")!,  UIImage.set_image(named: "ic_voucher")!]
        
        for i in 0..<types.count {
            let model = CategoryMsgModel(type: types[i], name: names[i], image: images[i])
            categoryList.append(model)
    
        }
        collectionView.reloadData()
    }
    
    @objc func otherTypeAction() {
        guard self.selectorView == nil else {
            self.selectorView?.hide()
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            self.optionView.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        }
        
        self.selectorView = IMCategorySelectView(selectedType: self.selectedType, animatable: true)
        self.view.addSubview(self.selectorView!)
        self.selectorView?.selectionHandler = { [weak self] (type, name) in
            guard let self = self else { return }
            self.optionView.label.text = name
            self.selectedType = type
            self.excludeId = 0
            self.getData()
        }
        
        self.selectorView!.snp.makeConstraints { (v) in
            v.top.equalTo(self.topView.snp.bottom)
            v.left.bottom.right.equalToSuperview()
        }
        
        self.selectorView!.notifyComplete = { [weak self] in
            guard let self = self else { return }
            self.selectorView = nil
            UIView.animate(withDuration: 0.2) {
                self.optionView.arrowImageView.transform = .identity
            }
        }
    }
    
    @objc func editAction() {
        if !isShow {
            isShow = true
            self.shadowView.isHidden = false
        } else {
            isShow = false
            self.shadowView.isHidden = true
        }
        self.selectData.removeAll()
        self.tableView.reloadData()
    }
    
    @objc func forwardAction() {
        forwardTextIM()
    }
    
    func showShouldhideTip() {
        if UserDefaults.messageCollectionFilterTooltipShouldHide == false {
            let tooltip = ToolTipPreferences()
            tooltip.drawing.bubble.color = UIColor(red: 37, green: 37, blue: 37)
            tooltip.drawing.message.color = .white
            tooltip.drawing.background.color = .clear
            
            self.optionView.showToolTip(identifier: "", title: "title_tooltips_filter".localized, message: "desc_tooltips_filter".localized, button: nil, arrowPosition: .top, preferences: tooltip, delegate: nil)
            
            UserDefaults.messageCollectionFilterTooltipShouldHide = true
        }
    }
    
    @objc func cancelAction() {
        self.selectData.removeAll()
        cancel.isHidden = true
        self.edit = false
        self.tableView.reloadData()
        self.topView.isHidden = false
        self.tableView.frame = CGRect(x: 0, y: self.topView.height, width: ScreenWidth, height: ScreenHeight - TSNavigationBarHeight - self.topView.height)
        self.updateSelectedItem()
        self.selectActionToolbar.setToolbarHidden(true)
    }
    
    @objc func getData() {
        let option = NIMCollectQueryOptions()
        option.limit = limit //15
        option.excludeId = excludeId //0
        option.type = self.selectedType.rawValue //default type is set to all = 0
        option.reverse = false
        NIMSDK.shared().chatExtendManager.queryCollect(option) { [weak self] (error, collections, totalCount) in
            guard let self = self else { return }
            self.dataArray.removeAll()
            self.tableView.mj_header.endRefreshing()
            if let error = error {
                self.showError(message: error.localizedDescription)
                return
            }
            
            guard let array = collections else {
                return
            }
            
            for item in array {
                if let type = MessageCollectionType(rawValue: item.type) {
                    let model = FavoriteMsgModel(Id: Int(item.id), type: type, data: item.data , ext: item.ext , uniqueId: item.uniqueId , createTime: item.createTime , updateTime: item.updateTime)
                    self.dataArray.append(model)
                }
            }
            
            self.excludeId = self.dataArray.last?.Id ?? 0
            if totalCount < self.limit {
                self.tableView.mj_footer.isHidden = true
            }
            self.tableView.isHidden = self.dataArray.count == 0
            self.placehoderView.isHidden = self.dataArray.count ?? 0 > 0
            self.tableView.reloadData()
        }
    }
    
    @objc func loadMore() {
        let option = NIMCollectQueryOptions()
        option.limit = limit
        option.excludeId = excludeId
        option.type = 5
        option.reverse = false
        NIMSDK.shared().chatExtendManager.queryCollect(option) { [weak self] (error, collections, totalCount) in
            guard let self = self else { return }
            self.tableView.mj_footer.endRefreshing()
            if let error = error {
                self.showError(message: error.localizedDescription)
                return
            }
            guard let array = collections else {
                return
            }
            for item in array {
                let model = FavoriteMsgModel(Id: Int(item.id), type: MessageCollectionType(rawValue: item.type)! , data: item.data , ext: item.ext , uniqueId: item.uniqueId , createTime: item.createTime , updateTime: item.updateTime)
                self.dataArray.append(model)
            }
            
            self.excludeId = self.dataArray.last?.Id ?? 0
            if totalCount >= self.limit {
                self.tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(self.loadMore))
            } else{
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
            self.tableView.mj_footer.isHidden = totalCount != self.limit
            self.tableView.reloadData()
        }
    }
    
    func collectionMsgContentView(_ message: FavoriteMsgModel, indexPath: IndexPath) -> BaseCollectView {
        let msgType = message.type
        switch msgType {
        case .text:
            return TextCollectView(collectModel: message, indexPath: indexPath)
        case .image:
            return ImageVideoCollectView(collectModel: message, indexPath: indexPath)
        case .audio:
            return AudioCollectView(collectModel: message, indexPath: indexPath)
        case .video:
            return ImageVideoCollectView(collectModel: message, indexPath: indexPath)
        case .file:
            return FileCollectView(collectModel: message, indexPath: indexPath)
        case .location:
            return LocaltionCollectView(collectModel: message, indexPath: indexPath)
        case .nameCard:
            return ContactCardCollectView(collectModel: message, indexPath: indexPath)
        case .sticker:
            return StickerCollectView(collectModel: message, indexPath: indexPath)
        case .link:
            return WebLinkCollectView(collectModel: message, indexPath: indexPath)
        case .miniProgram:
            return MiniProgramCollectView(collectModel: message, indexPath: indexPath)
        case .voucher:
            return VoucherCollectView(collectModel: message, indexPath: indexPath)
        default:
            return UnkonwCollectView(collectModel: message, indexPath: indexPath)
        }
    }
    
    func moreViewAction() {
        let items: [IMActionItem] = [.forward, .delete]
//        if (items.count > 0 ) {
//            let view = IMActionListView(actions: items)
//            view.delegate = self
//        }
    }
    
    // MARK: delete
    @objc func deleteCollectMessages() {
        deleteAction()
    }
    
    func deleteAction() {
        if self.selectData.count == 0 {
            self.showError(message: "favourite_msg_delete_at_least".localized)
            return
        }
        
        self.showDialog(title: "favourite_msg_delete".localized, message:  String(format: "favourite_msg_delete_desc".localized, selectData.count ?? 0), dismissedButtonTitle: "favourite_msg_delete".localized, onDismissed: { [weak self] in
            guard let self = self else { return }
            self.deleteMsg()
        }, onCancelled: { [weak self] in
            guard let self = self else { return }
        }, cancelButtonTitle: "cancel".localized, isRedPacket: true, isFavouriteMessage: true)
        
        //        let alert = TSAlertController(title: "favourite_msg_dialog_title_delete".localized, message: String(format: "favourite_msg_dialog_desc_delete".localized, self.selectData.count.stringValue), style: .alert,  hideCloseButton: false, animateView: false)
        //
        //        alert.addAction(TSAlertAction(title: "done".localized, style: TSAlertActionStyle.default, handler: { [weak self] _ in
        //            DispatchQueue.main.async {
        //                self?.deleteMsg()
        //            }
        //        }))
        //
        //        self.present(alert, animated: false, completion: nil)
    }
    
    func deleteMsg() {
        var array = [NIMCollectInfo]()
        for model in self.selectData {
            let collectInfo = NIMCollectInfo()
            collectInfo.createTime = model.createTime
            collectInfo.id = UInt(model.Id)
            array.append(collectInfo)
        }
        NIMSDK.shared().chatExtendManager.removeCollect(array) { [weak self] (error, total) in
            guard let self = self else { return }
            if let error = error {
                self.showError(message: error.localizedDescription)
            } else {
                self.showError(message: "favourite_msg_delete_success".localized)
                for model in self.selectData {
                    if let index = self.dataArray.firstIndex(where: { $0.Id == model.Id }) {
                        self.dataArray.remove(at: index)
                    }
                }
                self.selectData.removeAll()
                self.tableView.reloadData()
                self.tableView.isHidden = self.dataArray.count == 0
                self.placehoderView.isHidden = self.dataArray.count ?? 0 > 0
            }
        }
    }
    
    func updateSelectedItem() {
        selectedItem.setTitle(String(format: "msg_number_of_selected".localized, String(format: "%i", selectData.count)), for: .normal)
    }
    
    private func showShareContent(_ urlAddress: String) {
        guard let url = URL(string: urlAddress) else { return }
        
        if url.host?.lowercased().contains("yippi") ?? false {
            if url.pathComponents.containsIgnoringCase("feeds") {
                if let detailIDString = url.pathComponents.last, let detailID = Int(detailIDString) {
                    self.navigateLive(feedId: detailID, isDeepLink: true)
                }
            }else {
                FeedIMSDKManager.shared.delegate?.didShowDeeplink(urlString: url.absoluteString)
               // self.deeplink(urlString: url.absoluteString)
            }
            
//            let itemID = Int(url.lastPathComponent) ?? 0
//            if url.absoluteString.contains("users") {
//                let vc = HomePageViewController(userId: itemID, username: "")
//                self.navigationController?.pushViewController(vc, animated: true)
//            } else if url.absoluteString.contains("feeds") {
//                SVProgressHUD.show()
//                DependencyContainer.shared.resolveUtilityFactory().navigateToLive(feedId: itemID, viewController: self) { suceess in
//                    SVProgressHUD.dismiss()
//                    if !suceess {
//                        DispatchQueue.main.async {
//                            //self.liveEndAlert()
//                            //self.liveEndAlert()
//                            let vc = NoContentController()
//                            self.navigationController?.pushViewController(vc, animated: true)
//                        }
//                    }
//                }
//            } else {
//                if UIApplication.shared.canOpenURL(url) {
//                    UIApplication.shared.open(url)
//                }
//            }
        } else {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func liveEndAlert() {
        let alertController = UIAlertController(title: nil, message: "text_livestream_ended".localized, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "ok".localized, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
}

extension MsgCollectionViewController:  MessageCollectDelegate {
    func checkBoxClicked(model: FavoriteMsgModel) {
        // let model = self.dataArray[indexPath.section]
        self.selectModel = model
        if let index = self.selectData.firstIndex(where: { $0.Id == model.Id }){
            self.selectData.remove(at: index)
        } else {
            self.selectData.append(model)
        }
        printIfDebug("select dataaa \(selectData.count)")
    }
}

extension MsgCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MsgCollectionViewCell.cellIdentifier, for: indexPath) as! MsgCollectionViewCell
        cell.setData(data: categoryList[indexPath.row])
        
        if !collectionView.isDragging && !collectionView.isDecelerating {
            if indexPath.section == 0 && indexPath.row == 0 {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
            } else {
                cell.contentView.backgroundColor = UIColor(hex: 0xededed)
                cell.cateLabel.textColor = .lightGray
                cell.cateImageView.image = cell.cateImageView.image?.withRenderingMode(.alwaysTemplate)
                cell.cateImageView.tintColor = .lightGray
            }
        }
        
        if cell.isSelected {
            cell.contentView.backgroundColor = AppTheme.red
            cell.cateLabel.textColor = .white
            cell.cateImageView.image = cell.cateImageView.image?.withRenderingMode(.alwaysTemplate)
            cell.cateImageView.tintColor = .white
        } else {
            cell.contentView.backgroundColor = UIColor(hex: 0xededed)
            cell.cateLabel.textColor = .lightGray
            cell.cateImageView.image = cell.cateImageView.image?.withRenderingMode(.alwaysTemplate)
            cell.cateImageView.tintColor = .lightGray
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let data = categoryList[safe: indexPath.row] {
            self.selectedType = data.type
            self.excludeId = 0
            self.selectData.removeAll()
            self.isShow = false
            self.shadowView.isHidden = true
            self.getData()
        }
    }
}

extension MsgCollectionViewController: BaseCollectViewDelegate {
    // MARK: Text
    func baseViewTextMsgTap(indexPath: IndexPath, favoriteModel: FavoriteMsgModel?) {
        guard let model = favoriteModel else {
            return
        }
        let vc = CollectionTextMsgViewController(model: model)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.collectionMsgCall = { [weak self] (model) in
            guard let self = self else { return }
            if let faModel = model {
                if let index = self.dataArray.firstIndex(where: { $0.Id == faModel.Id }){
                    self.dataArray.remove(at: index)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: Audio
    func baseViewAudioMsgTap(indexPath: IndexPath, favoriteModel: FavoriteMsgModel?) {
        guard let model = favoriteModel else {
            return
        }
        let vc = CollectionAudioMsgViewController(model: model)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.collectionMsgCall = { [weak self] (model) in
            guard let self = self else { return }
            if let faModel = model {
                if let index = self.dataArray.firstIndex(where: { $0.Id == faModel.Id }){
                    self.dataArray.remove(at: index)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: Image,Video
    func baseViewImageVideoTap(indexPath: IndexPath, favoriteModel: FavoriteMsgModel?) {
        guard let model = favoriteModel else {
            return
        }
        let vc = CollectionImageVideoMsgViewController(model: model)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.collectionMsgCall = { [weak self] (model) in
            guard let self = self else { return }
            if let faModel = model {
                if let index = self.dataArray.firstIndex(where: { $0.Id == faModel.Id }){
                    self.dataArray.remove(at: index)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK: Location
    func baseViewLocaltionoMsgTap(indexPath: IndexPath, favoriteModel: IMLocationCollectionAttachment?) {
        guard let model = favoriteModel else {
            return
        }
        let object: NIMLocationObject = NIMLocationObject(latitude: model.lat, longitude: model.lng, title: model.title)
        
//        let locationPoint: NIMKitLocationPoint = NIMKitLocationPoint.init(locationObject: object)
//        guard let vc = NIMLocationViewController.init(locationPoint: locationPoint) else { return }
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func baseViewFileMsgTap(indexPath: IndexPath, favoriteModel: IMFileCollectionAttachment?) {
        guard let model = favoriteModel else {
            return
        }
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        let name = model.name
        let path = "\(documentsPath)/collectionFile/\(name)"
        
        if FileManager.default.fileExists(atPath: path) {
            let url = URL(fileURLWithPath: path)
            let vc = TSWebViewController(url: url, type: .defaultType, title: model.name)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc: CollectionFileMsgViewController = CollectionFileMsgViewController(model: model)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func baseViewLinkMsgTap(url: String?) {
        guard let url = url else {
            return
        }
        self.showShareContent(url)
    }
    
    //MARK: Mini Program
    func baseViewMiniProgromMsgTap(appId: String?, path: String?) {
        guard let appId = appId else {
            return
        }
        
        guard let path = path else {
            return
        }
        
        DependencyContainer.shared.resolveUtilityFactory().openMiniProgram(appId: appId, path: path , parentVC: self) { (status, error) in
            if let error = error {
                self.showError(message: error.localizedDescription)
            }
            if status {
                // DependencyContainer.shared.resolveUtilityFactory().registerMiniProgramExt()
            }
        }
    }

    func baseViewMoreEditTap(indexPath: IndexPath) {
        let model = self.dataArray[indexPath.section]
        self.selectModel = model
        if self.edit {
            if let index = self.selectData.firstIndex(where: { $0.Id == model.Id }){
                self.selectData.remove(at: index)
            } else {
                self.selectData.append(model)
            }
            
            self.tableView.reloadRow(at: indexPath, with: .none)
            self.updateSelectedItem()
        } else {
            self.moreViewAction()
        }
    }
    
    //MARK: Name Card
    func baseViewContactTap(memberId: String) {
        FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: 0, username: memberId, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
//        let vc = HomePageViewController(userId: 0, username: memberId)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Sticker
    func baseViewStickerTap(bundleId: String) {
        let vc = StickerDetailViewController(bundleId: bundleId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Unknown
    func baseViewUnknownTap() {
        if let lastCheckModel = TSCurrentUserInfo.share.lastCheckAppVesin {
            TSRootViewController.share.checkAppVersion(lastCheckModel: lastCheckModel, forceShowAlert: true)
        }
    }

    //MARK: Voucher
    func baseViewVoucherMsgTap(url: String?) {
        guard let url = url else { return }
        self.showShareContent(url)
    }
}

extension MsgCollectionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCollectCell.cellIdentifier, for: indexPath) as! MessageCollectCell
        cell.selectionStyle = .none
        cell.delegate = self
        cell.isChecked = false
        cell.checkBoxButton.isSelected = false
        let model = self.dataArray[indexPath.section]
        let contentV = self.collectionMsgContentView(model, indexPath: indexPath)
        contentV.delegate = self
        if self.edit, model.type.rawValue != -1 {
            contentV.moreBtn.setImage(nil, for: .normal)
            contentV.moreBtn.layer.cornerRadius = 18 / 2.0
            contentV.moreBtn.layer.masksToBounds = true
            contentV.moreBtn.layer.borderWidth = 1
            contentV.moreBtn.layer.borderColor = UIColor(hex: 0xededed).cgColor
            contentV.moreBtn.setImage(UIImage.set_image(named: "ic_rl_checkbox_selected"), for: .selected)
            if let _ = self.selectData.firstIndex(where: { $0.Id == model.Id }){
                contentV.moreBtn.isSelected = true
            } else {
                contentV.moreBtn.isSelected = false
            }
        } else {
            contentV.moreBtn.layer.cornerRadius = 0
            contentV.moreBtn.layer.masksToBounds = false
            contentV.moreBtn.layer.borderWidth = 0
            contentV.moreBtn.setImage(UIImage.set_image(named: "buttonsMoreDotGrey"), for: .normal)
        }
       
        cell.dataUpdate(dataModel: model, collectView: contentV)
        
        if isShow {
            cell.checkBoxButton.isHidden = false
            if let _ = self.selectData.firstIndex(where: { $0.Id == model.Id }){
                cell.checkBoxButton.isSelected = true
            } else {
                cell.checkBoxButton.isSelected = false
            }
        } else {
            cell.checkBoxButton.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let model = self.dataArray[safe: indexPath.section], model.type.rawValue != -1 {
            let forward = UIContextualAction(style: .normal, title: "") { [weak self] (action, sourceView, completionHandler) in
                guard let self = self else { return }
                if let index = self.selectData.firstIndex(where: { $0.Id == model.Id }) {
                    self.selectData.remove(at: index)
                } else {
                    self.selectData.append(model)
                }
                self.forwardTextIM()
                completionHandler(true)
            }
            
            let forwardLabel = UILabel()
            forwardLabel.sizeToFit()
            forwardLabel.textColor = .white
            forwardLabel.text = "favourite_msg_forward".localized
            forward.backgroundColor = UIColor(hex: 0xFFB516)
            
            if let forwardImage = UIImage.set_image(named: "ic_fav_msg_forward") {
                forward.image = resizeActionRow(image: forwardImage, label: forwardLabel)
            }
            
            let delete = UIContextualAction(style: .normal, title: "") { [weak self] (action, sourceView, completionHandler)  in
                guard let self = self else { return }
                if let index = self.selectData.firstIndex(where: { $0.Id == model.Id }) {
                    self.selectData.remove(at: index)
                } else {
                    self.selectData.append(model)
                }
                self.deleteAction()
                completionHandler(true)
            }
            
            let deleteLabel = UILabel()
            deleteLabel.sizeToFit()
            deleteLabel.textColor = .white
            deleteLabel.text = "favourite_msg_delete".localized
            
            if let deleteImage = UIImage.set_image(named: "iconsDeleteWhite") {
                delete.image = resizeActionRow(image: deleteImage, label: deleteLabel)
            }
            delete.backgroundColor = UIColor(hex: 0xED2121)
            
            let swipeAction = UISwipeActionsConfiguration(actions: [delete, forward])
            swipeAction.performsFirstActionWithFullSwipe = false
            return swipeAction
        }
        
        return nil
    }
}

extension MsgCollectionViewController {
    func copyTextIM() {}
    
    func copyImageIM() {}
    
    func forwardTextIM() {
        if self.selectData.count == 0 {
            self.showError(message: "favourite_msg_delete_at_least".localized)
            return
        }
        
        let configuration = ContactsPickerConfig(title: "select_contact".localized, rightButtonTitle: "done".localized, allowMultiSelect: true, enableTeam: true, enableRecent: true, enableRobot: false, maximumSelectCount: Constants.maximumSendContactCount, excludeIds: [], members: nil, enableButtons: false, allowSearchForOtherPeople: true)
        
        let picker = NewContactPickerViewController(configuration: configuration, finishClosure: { [weak self] (contacts) in
            guard let self = self else { return }
            for contact in contacts {
                for model in self.selectData ?? [] {
                    let session = NIMSession(contact.userName, type: contact.isTeam ? NIMSessionType.team : NIMSessionType.P2P)
                    guard let message = CollectionMsgDataManager().messageModel(model: model) else {
                        return
                    }
                    do {
                        try NIMSDK.shared().chatManager.send(message, to: session)
                    } catch {
                        printIfDebug("error---= \(error.localizedDescription)")
                    }
                }
            }
            self.showError(message: "Forward Successful".localized)
        })
        self.navigationController?.pushViewController(picker, animated: true)
    }
    
    func revokeTextIM() {}
    
    func deleteTextIM() {
        self.edit = true
        self.tableView.reloadData()
        self.topView.isHidden = true
        self.tableView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - TSNavigationBarHeight - 50 - TSBottomSafeAreaHeight)
        cancel.isHidden = false
        
        self.selectActionToolbar.setToolbarHidden(false)
        let spacing = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, action: {})
        self.selectedItem.bounds = CGRect(x: 0, y: 0, width: self.selectActionToolbar.bounds.width / 4, height: self.selectActionToolbar.bounds.height)
        let selectedItem1 = UIBarButtonItem(customView: self.selectedItem)
        self.selectActionToolbar.setItems([self.deleteBarButton, spacing, selectedItem1, spacing], animated: true)
        self.updateSelectedItem()
    }
    
    func translateTextIM() {}
    
    func replyTextIM() {}
    
    func handleStickerIM() {}
    
    func cancelUploadIM() {}
    
    func stickerCollectionIM() {}
    
    func voiceToTextIM() {}
    
    func messageCollectionIM() {}
    
    func saveMsgCollectionIM() {}
    
    func forwardAllImageIM() {}
    
    func deleteAllImageIM() {}
}

extension MsgCollectionViewController {
    private func resizeActionRow(image: UIImage, label: UILabel) -> UIImage? {
        let tempView = UIStackView(frame: CGRect(x: 0, y: 0, width: 80, height: 50))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.height))
        tempView.axis = .vertical
        tempView.alignment = .center
        tempView.spacing = 8
        imageView.image = image
        tempView.addArrangedSubview(imageView)
        tempView.addArrangedSubview(label)
        let renderer = UIGraphicsImageRenderer(bounds: tempView.bounds)
        let image = renderer.image { rendererContext in
            tempView.layer.render(in: rendererContext.cgContext)
        }
        return image
    }
}

