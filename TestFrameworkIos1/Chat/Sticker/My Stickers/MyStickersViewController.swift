//
//  MyStickersViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 11/12/2018.
//  Copyright © 2018 Toga Capital. All rights reserved.
//

import UIKit
import MBProgressHUD

class MyStickersViewController: TSTableViewController {
    
    private let kPageSize: Int = 20
    private var stickers: [GrphSticker] = []
    var selectArray: [GrphSticker] = []
    var isEdit = false
    var rightBtn = UIButton()
    var editBtn = UIButton()
    var deleteBtn = UIButton()
    var bottomView = UIView()
    var tipLable = UILabel()

    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "text_my_sticker".localized
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.set_image(named: "iconsArrowCaretleftBlack"), action: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })
        configureView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "Notification_StickerBundleDownloaded"), object: nil)
        tableView.mj_header.beginRefreshing()
        
        rightBtn.setImage(UIImage.set_image(named: "sort"), for: .normal)
        rightBtn.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        
        editBtn.setTitle("done".localized, for: .normal)
        editBtn.setTitleColor(UIColor(red: 155, green: 155, blue: 155), for: .normal)
        editBtn.titleLabel?.setFontSize(with: 15, weight: .norm)
        editBtn.addTarget(self, action: #selector(editBtnAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        self.setUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("Notification_StickerBundleDownloaded"), object: nil)
        bottomView.removeFromSuperview()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bottomView.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        isEdit = false
        self.selectArray.removeAll()
        tableView.height = ScreenHeight - TSNavigationBarHeight
        tableView.reloadData()
    }
    
    private func configureView() {
        tableView.register(StickerTableCell.nib(), forCellReuseIdentifier: StickerTableCell.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.mj_footer = nil
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
    }
    
    func setUI(){
        bottomView.isHidden = true
        bottomView.backgroundColor = .white
        bottomView.frame = CGRect(x: 0, y: ScreenHeight - 50 - TSBottomSafeAreaHeight , width: ScreenWidth, height: 50 + TSBottomSafeAreaHeight)
        UIApplication.shared.windows[0].addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(50 + TSBottomSafeAreaHeight)
        }
        let lable = UILabel()
        lable.text = "text_move_to_front".localized
        lable.textColor = UIColor(red: 155, green: 155, blue: 155)
        lable.setFontSize(with: 14, weight: .norm)
        bottomView.addSubview(lable)
        lable.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(15)
            make.height.equalTo(50)
        }
        lable.addTap { [weak self] (_) in
            self?.moveToFront()
        }
        self.tipLable = lable
        //self.tipLable.isHidden = true
        let delete = UIButton()
        delete.setImage(UIImage.set_image(named: "ic_delete_sticker")?.withRenderingMode(.alwaysOriginal), for: .normal)
       
        bottomView.addSubview(delete)
        delete.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        delete.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.height.equalTo(50)
            make.right.equalTo(-2)
            make.width.equalTo(47)
        }
        self.deleteBtn = delete
        self.deleteBtn.isEnabled = false
        
        let line = UIView()
        line.backgroundColor = UIColor(red: 247, green: 247, blue: 247)
        bottomView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(0)
            make.height.equalTo(1)
        }
        
    }
    
    override func refresh() {
        defer {
            DispatchQueue.main.async {
                self.tableView.mj_header.endRefreshing()
                self.tableView.reloadData()
            }
        }
        
        guard let localBundles = StickerManager.shared.loadOwnStickerBundle() as? [Dictionary<String, Any>], localBundles.count > 0 else {
            self.show(placeholderView: .empty, margin: Constants.Layout.stickerCellHeight + 60, height: self.tableView.height - Constants.Layout.stickerCellHeight - 60)
            return
        }
        var localStickerBundles = [GrphSticker]()
        localBundles.forEach({ (bundle) in
            if let bundleID = bundle["bundle_id"] as? String,
                let bundleIcon = bundle["bundle_icon"] as? String,
                let bundleName = bundle["bundle_name"] as? String {
                    let tempSticker = GrphSticker(bundleId: bundleID, bundleIcon: bundleIcon, bundleName: bundleName)
                localStickerBundles.append(tempSticker)
            }
        })
        self.stickers = localStickerBundles
        self.removePlaceholderViews()
    }
    
    @objc func editBtnAction(){
        isEdit = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        tableView.height = ScreenHeight - TSNavigationBarHeight
        bottomView.isHidden = true
        tableView.reloadData()
       
    }

    //编辑
    @objc func editAction(){
        isEdit = true
        UIApplication.shared.windows[0].bringSubviewToFront(bottomView)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editBtn)
        tableView.height = ScreenHeight - TSNavigationBarHeight  - 50 - TSBottomSafeAreaHeight
        bottomView.isHidden = false
        tableView.reloadData()
        
    }
    
    @objc func deleteAction(){
        
        var temArray = [String]()
        for sticker in selectArray {
            temArray.append(sticker.bundleId )
        }
        
        if temArray.count == 0 {
            return
        }
        //self.displayActivityIndicator(shouldDisplay: true)
        StickerManager.shared.removeStickers(stickerIds: temArray) { [weak self] (complete) in
            //self?.displayActivityIndicator(shouldDisplay: false)
            if complete {
                DispatchQueue.main.async {
                    
                    if let array = self?.selectArray {
                        //删除数据源
                        for sticker in array {
                            if let stickerIndex = self?.stickers.firstIndex(where: { $0.bundleId == sticker.bundleId }) {
                                self?.stickers.remove(at: stickerIndex)
                            }
                        }
                    }
                    
                    self?.selectArray.removeAll()
                    self?.deleteBtn.isEnabled = self?.selectArray.count ?? 0 > 0
                    self?.tipLable.textColor = self?.selectArray.count ?? 0 > 0 ? .black : UIColor(red: 155, green: 155, blue: 155)
                    self?.tableView.reloadData()
                }
                
                
            }
        }
        
    }
    
    func selectSticker(indexPath: IndexPath){
        
        let sticker = self.stickers[indexPath.row]
        if let stickerIndex = self.selectArray.firstIndex(where: { $0.bundleId == sticker.bundleId }) {
            self.selectArray.remove(at: stickerIndex)
        }else{
            self.selectArray.append(sticker)
        }

        if self.selectArray.count > 0 {
            editBtn.setTitleColor(UIColor(red: 59, green: 179, blue: 255), for: .normal)
            self.tipLable.textColor = .black
            
        }else{
            editBtn.setTitleColor(UIColor(red: 155, green: 155, blue: 155), for: .normal)
            self.tipLable.textColor = UIColor(red: 155, green: 155, blue: 155)
        }
        
        self.deleteBtn.isEnabled = self.selectArray.count > 0
        self.tableView.reloadRow(at: indexPath, with: .none)
    }
    
    func moveToFront(){
        var temArray = [StickerInput]()
        var index = selectArray.count
        for sticker in selectArray.reversed() {
            let stickerInput = StickerInput(bundleId: sticker.bundleId, sequence: index)
            temArray.append(stickerInput)
            index = index - 1
        }
        if temArray.count == 0 {
            return
        }
        print("temArr = \(temArray)")
        //self.displayActivityIndicator(shouldDisplay: true)
        StickerManager.shared.sortStickers(stickers: temArray ){ [weak self] (complete) in
            //self?.displayActivityIndicator(shouldDisplay: false)
            if complete {
                DispatchQueue.main.async {
                    
                    if let array = self?.selectArray {
                        //sort数据源
                        for sticker in array {
                            if let stickerIndex = self?.stickers.firstIndex(where: { $0.bundleId == sticker.bundleId }) {
                                self?.stickers.remove(at: stickerIndex)
                            }
                          
                        }
                        self?.stickers.insert(contentsOf: array, at: 0)
                        
                        //sort本地
                        guard let localBundles = StickerManager.shared.loadOwnStickerBundle() as? [Dictionary<String, Any>], localBundles.count > 0 else {
                            return
                        }
                        var temBundles: [Dictionary<String, Any>]? = []
                        var temList: [Dictionary<String, Any>]? = localBundles
                        for sticker in array {
                            for bundle in localBundles {
                                if sticker.bundleId == bundle["bundle_id"] as? String {
                                    temBundles?.append(bundle)
                                }
                            }
                            
                            if let index = temList?.firstIndex(where: { $0["bundle_id"] as? String == sticker.bundleId
                            }) {
                                temList?.remove(at: index)
                            }
                            
                        }
                        temList?.insert(contentsOf: temBundles!, at: 0)
                        StickerManager.shared.saveDownloadedStickerBundle(temList)
                    }
                    
                    //刷新UI
                    self?.tableView.reloadData()
                    self?.selectArray.removeAll()
                    self?.deleteBtn.isEnabled = self?.selectArray.count ?? 0 > 0
                    self?.tipLable.textColor = self?.selectArray.count ?? 0 > 0 ? .black : UIColor(red: 155, green: 155, blue: 155)
                    
                    
                }
                
                
                
            }
        }
        
    }
    
   
}

extension MyStickersViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : stickers.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StickerTableCell.cellIdentifier, for: indexPath) as! StickerTableCell
        cell.actionButton.isHidden = false
        if indexPath.section == 0 {
            cell.configureCustomSticker()
            cell.actionButton.isUserInteractionEnabled = false
            cell.actionButton.layer.borderWidth = 0
            cell.actionButton.layer.cornerRadius = 0
            cell.actionButton.layer.masksToBounds = false
            cell.actionButton.snp.makeConstraints { (make) in
                make.height.width.equalTo(24)
            }
        } else {
            cell.configureMySticker(sticker: stickers[indexPath.row], delegate: nil)
            cell.actionButton.isUserInteractionEnabled = true
            if isEdit {
                
                cell.actionButton.layer.cornerRadius = 18 / 2.0
                cell.actionButton.layer.masksToBounds = true
                
                cell.actionButton.setImage(UIImage.set_image(named: "ic_rl_checkbox_selected"), for: .selected)
                cell.actionButton.setImage(UIImage.set_image(named: "icon_accessory_normal"), for: .normal)
                cell.actionButton.snp.makeConstraints { (make) in
                    make.height.width.equalTo(18)
                }
                let id = self.stickers[indexPath.row].bundleId
                if self.selectArray.firstIndex(where: { $0.bundleId == id }) != nil {
                    cell.actionButton.isSelected = true
                }else{
                    cell.actionButton.isSelected = false
                }
               
            }else{
                cell.actionButton.isSelected = false
                cell.actionButton.layer.borderWidth = 0
                cell.actionButton.layer.cornerRadius = 0
                cell.actionButton.layer.masksToBounds = false
                cell.actionButton.snp.makeConstraints { (make) in
                    make.height.width.equalTo(24)
                }
                cell.actionButton.applyStyle(.deleteSticker(image: UIImage.set_image(named: "ic_delete_sticker")))
                // YIPPI-4307
                cell.actionButton.isHidden = true
            }
            cell.actionButton.addTap { [weak self] (_) in
                guard let self = self else { return }
                let id = self.stickers[indexPath.row].bundleId
                if self.isEdit {
                    self.selectSticker(indexPath: indexPath)
                    
                }else{
                    self.displayActivityIndicator(shouldDisplay: true)
 
                    StickerManager.shared.removeSticker(id: id) { [weak self] in
                        DispatchQueue.main.async {
                            self?.displayActivityIndicator(shouldDisplay: false)
                        }
                        if let stickerIndex = self?.stickers.firstIndex(where: { $0.bundleId == id }) {
                            self?.stickers.remove(at: stickerIndex)
                        }
                    } onError: { [weak self] error in
                        DispatchQueue.main.async {
                            self?.displayActivityIndicator(shouldDisplay: false)
                            if !(TSReachability.share.isReachable()) {
                                self?.showError(message: "network_is_not_available".localized)
                            } else {
                                self?.showError(message: error ?? "system_error_msg".localized)
                            }
                        }
                    }
                }
                
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 30)))
            let label = UILabel().configure {
                $0.applyStyle(.regular(size: 10, color: .lightGray))
                $0.text = "text_all_downloaded_sticker".localized
            }
            view.addSubview(label)
            label.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
            }
            
            return view
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Layout.stickerCellHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let vc = CustomerStickerViewController(sticker: "")
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            if isEdit {
                self.selectSticker(indexPath: indexPath)
                
            }
        }
        
    }
}
