//
//  StickerListViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 07/12/2018.
//  Copyright © 2018 Toga Capital. All rights reserved.
//

import UIKit

import Toast

class StickerListViewController: TSTableViewController {

    private var stickers: [Sticker] = []
    private var stickerType: StickerType
    private var categoryId: Int? = nil
    
    private var hasMoreData = true
    
    private var selectedIndex: IndexPath?
    private var offset: Int = 0
    
    init(type: StickerType, title: String, categoryId: Int? = nil) {
        self.stickerType = type
        self.categoryId = categoryId
        super.init(style: .grouped)
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StickerManager.shared.delegate = self
        guard let selectedIndex = selectedIndex else { return }
        
        self.tableView.reloadRows(at: [selectedIndex], with: UITableView.RowAnimation.automatic)
    }

    private func configureView() {
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.mj_footer.isHidden = true
        tableView.register(StickerTableCell.nib(), forCellReuseIdentifier: StickerTableCell.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.mj_header.beginRefreshing()
        tableView.tableFooterView = UIView()
    }
    
    override func refresh() {
        hasMoreData = true
        offset = 0
        stickers.removeAll()
        getStickers()
    }
    
    override func loadMore() {
        offset = stickers.count
        getStickers()
    }
    
    private func getStickers() {
        guard hasMoreData == true else { return }
        
        GetStickerByType(type: stickerType, limit: offset == 0 ? 20 : TSAppConfig.share.localInfo.limit, offset: offset, catId: categoryId).execute { [weak self] (model) in
            guard let self = self else { return }

            defer {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.mj_header.endRefreshing()
                    if self.hasMoreData == false {
                        self.tableView.mj_footer.isHidden = false
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_footer.isHidden = false
                        self.tableView.mj_footer.endRefreshing()
                    }
                }
            }
            
            guard let model = model, model.data.data.count > 0 else {
                if self.offset == 0 {
                    DispatchQueue.main.async {
                        self.show(placeholderView: .empty)
                    }
                }
                return
            }
            
            DispatchQueue.main.async {
                if self.offset == 0 {
                    self.stickers = model.data.data
                } else {
                    self.stickers.append(contentsOf: model.data.data)
                }
                self.removePlaceholderViews()
                self.hasMoreData = model.data.hasMoreData
            }
            
        } onError: { [weak self] (error) in
            DispatchQueue.main.async {
                self?.tableView.mj_header.endRefreshing()
                self?.tableView.mj_footer.endRefreshing()
                self?.show(placeholderView: .network)
                
                if case let YPErrorType.carriesMessage(message, _, _) = error {
                    self?.showError(message: message)
                }
            }
        }

    }
}

extension StickerListViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.stickerType == .stickers_of_the_day {
            return max(stickers.count, 3) - 3
        }
        return stickers.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: StickerTableCell.cellIdentifier, for: indexPath) as! StickerTableCell

        let sticker = stickers[indexPath.row]
        
        switch stickerType {
        case .stickers_of_the_day:
            let newIndex = indexPath.row + 3
            let currentSticker = stickers[newIndex]
            cell.configureSOTD(currentSticker, row: newIndex, delegate: self)
            cell.SOTDRightStackView.addAction { [weak self] in
                DispatchQueue.main.async {
                    if let stat = currentSticker.todayStats {
                        let view = LiveScoreResultView(from: .sticker, type: .ranked, views: stat.downloadCount, tips: stat.tipsAmount, score: stat.totalPoints, isButtonHidden: true)
                        let popup = TSAlertController(style: .popup(customview: view))
                        popup.modalPresentationStyle = .overFullScreen
                        self?.present(popup, animated: false)
                    }
                }
            }
            
        case .hot_stickers, .new_sticker, .stickerByCategory:
            cell.configureSticker(sticker, delegate: self)
            
        case .new_artist, .recomended_artist:
            cell.configureArtist(sticker, delegate: self)
            
        case .featured_category:
            cell.configureCategory(sticker, delegate: self)
            
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        switch stickerType {
        case .new_artist, .recomended_artist:
            let sticker = stickers[indexPath.row]
            if let artistId = sticker.artistID, let name = sticker.artistName {
                let vc = ArtistCollectionViewController(artistId: artistId.stringValue, artistName: name)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case .hot_stickers, .new_sticker, .stickerByCategory:
            if let bundleId = stickers[indexPath.row].bundleID {
                let vc = StickerDetailViewController(bundleId: bundleId.stringValue)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case .stickers_of_the_day:
            if let bundleId = stickers[indexPath.row + 3].bundleID {
                let vc = StickerDetailViewController(bundleId: bundleId.stringValue)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case .featured_category:
            let category = stickers[indexPath.row]
            let vc = StickerListViewController(type: .stickerByCategory, title: category.name.orEmpty, categoryId: category.id)
            self.navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Layout.stickerCellHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard stickerType == .stickers_of_the_day else {
            return nil
        }
        
        let sotdView = StickerTopRankView()
        sotdView.backgroundColor = .white
        sotdView.setData(stickers)
        sotdView.onTapItem = { [weak self] sticker in
            DispatchQueue.main.async {
                if let stat = sticker.todayStats {
                    let view = LiveScoreResultView(from: .sticker, type: .ranked, views: stat.downloadCount, tips: stat.tipsAmount, score: stat.totalPoints, isButtonHidden: true)
                    let popup = TSAlertController(style: .popup(customview: view))
                    popup.modalPresentationStyle = .overFullScreen
                    self?.present(popup, animated: false)
                }
            }
        }
        sotdView.onTapAvatar = { [weak self] sticker in
            guard let bundleId = sticker.bundleID else {
                return
            }
            let vc = StickerDetailViewController(bundleId: bundleId.stringValue)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        return sotdView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if stickerType == .stickers_of_the_day {
            return 180
        }
        return CGFloat.leastNormalMagnitude
    }
}

extension StickerListViewController: StickerTableCellDelegate {
    func stickerDidRemoved(id: String, sender: UIButton) {
        
    }
    
    func stickerDidPurchased(id: String, sender: UIButton) {
        PopupDialogManager.presentEnterPasswordDialog(viewController: self, animated: true) { (password) in
            StickerManager.shared.purchaseSticker(for: id, password: password, completion: nil)
        }
    }
    
    
    func stickerDidDownload(id: String, sender: UIButton) {
        StickerManager.shared.downloadSticker(for: id) {
            self.tableView.reloadData()
        } onError: { [weak self] errMsg in
            self?.view.makeToast(errMsg, duration: 1.5, position: CSToastPositionCenter)
        }
    }
}

extension StickerListViewController: StickerManagerDelegate {
    func stickerDidRemoved(id: String) {
        self.tableView.reloadData()
    }
    
    func stickerDidDownloaded(id: String) {
        self.tableView.reloadData()
    }
}
