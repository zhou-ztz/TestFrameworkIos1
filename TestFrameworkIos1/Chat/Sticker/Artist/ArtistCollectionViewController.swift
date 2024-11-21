//
//  ArtistCollectionViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 10/12/2018.
//  Copyright © 2018 Toga Capital. All rights reserved.
//

import UIKit

import MJRefresh
import Toast

class ArtistCollectionViewController: TSTableViewController {
    
    private var detail: StickerArtistQuery.Data?
    private var selectedIndex: IndexPath?
    
    private var currentPage = 1
    private var hasMoreData = true
    
    private var stickers: [Sticker] = []
    
    private var artistId: String
    private var artistName: String
    
    init(artistId: String, artistName: String) {
        self.artistId = artistId
        self.artistName = artistName
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = artistName
        configureTableView()
        StickerManager.shared.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let selectedIndex = selectedIndex else { return }
        self.tableView.reloadRows(at: [selectedIndex], with: UITableView.RowAnimation.automatic)
    }
    
    override func refresh() {
        currentPage = 1
        hasMoreData = true
        stickers.removeAll()
        getStickers()
    }
    
    override func loadMore() {
        getStickers()
    }
    
    private func configureTableView() {
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(StickerTableCell.nib(), forCellReuseIdentifier: StickerTableCell.cellIdentifier)
        tableView.register(ArtistHeaderView.nib(), forHeaderFooterViewReuseIdentifier: ArtistHeaderView.cellIdentifier)
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.mj_header.beginRefreshing()
        tableView.mj_footer.isHidden = true
        tableView.mj_footer.removeGestures()
    }
    
    private func getStickers(closure: (() -> Void)? = nil) {
        guard hasMoreData == true else { return }
        let query = StickerArtistQuery(artist_id: artistId, count: 10, page: currentPage)
        
        YPApolloClient.fetch(query: query, queue: DispatchQueue.global()) { [weak self] (response, error) in
            
            guard let self = self else { return }
            
            defer {
                DispatchQueue.main.sync {
                    self.tableView.reloadData()
                    if self.hasMoreData == false {
                        self.tableView.mj_footer.isHidden = false
                        self.tableView.mj_header.endRefreshing()
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_header.endRefreshing()
                        self.tableView.mj_footer.isHidden = false
                        self.tableView.mj_footer.endRefreshing()
                    }
                }
            }
            
            guard error == nil else {
                if self.hasMoreData {
                    DispatchQueue.main.async {
                        self.show(placeholderView: .network)
                    }
                }
                return
            }
            
            guard let obj = response?.data?.stickerArtist?.stickers?.data.map({ $0.jsonObject.jsonValue }),
                  let data = try? JSONSerialization.data(withJSONObject: obj),
                  let stickers = try? JSONDecoder().decode([Sticker].self, from: data) else {
                
                if self.hasMoreData == false {
                    DispatchQueue.main.async {
                        self.show(placeholderView: .empty)
                    }
                }
                return
            }
            
            DispatchQueue.main.sync {
                self.removePlaceholderViews()
                self.detail = response?.data
                if self.hasMoreData == false {
                    self.stickers = stickers
                } else {
                    self.stickers.append(contentsOf: stickers)
                }
            }
            
            self.hasMoreData = (response?.data?.stickerArtist?.stickers?.paginatorInfo.hasMorePages) ?? true
            self.currentPage = (response?.data?.stickerArtist?.stickers?.paginatorInfo.currentPage ?? 1) + 1
        }
    }
    
    private func showDetail(_ bundleId: String) {
        let vc = StickerDetailViewController(bundleId: bundleId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ArtistCollectionViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stickers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StickerTableCell.cellIdentifier, for: indexPath) as! StickerTableCell
        cell.configureStickerbyArtist(stickers[indexPath.row], delegate: self)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ArtistHeaderView.cellIdentifier) as! ArtistHeaderView
        header.delegate = self
        
        if let artist = detail?.stickerArtist {
            header.configure(banner: artist.banner.orEmpty, artistName: artist.artistName, description: artist.description.orEmpty, hideMoment: artist.hideViewMoment ?? false, uid: "\(artist.uid ?? 0)")
            
            header.onTippingTap = { [weak self] in
                guard let self = self else { return }
                
                if TSCurrentUserInfo.share.isLogin == false {
                    TSRootViewController.share.guestJoinLandingVC()
                    return
                }
                
                guard let artistUserId = artist.uid else {
                    return
                }
                
                let isOwner = artistUserId == CurrentUserSessionInfo?.userIdentity
                
                if isOwner == true {
//                    let vc = TipsReceiveHistory()
//                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                   // self.presentTipping(target: artistUserId, type: .user)
                }
            }
        }
        return header
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDetail(stickers[indexPath.row].bundleID.stringValue)
        selectedIndex = indexPath
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Layout.stickerCellHeight
    }
}

extension ArtistCollectionViewController: StickerManagerDelegate {
    func stickerDidRemoved(id: String) {
        self.tableView.reloadData()
    }
    
    func stickerDidDownloaded(id: String) {
        self.tableView.reloadData()
    }
}

extension ArtistCollectionViewController: StickerTableCellDelegate {
    
    func stickerDidRemoved(id: String, sender: UIButton) {
        
    }
    
    func stickerDidPurchased(id: String, sender: UIButton) {
        PopupDialogManager.presentEnterPasswordDialog(viewController: self, animated: true) { (password) in
            StickerManager.shared.purchaseSticker(for: id, password: password, completion: nil)
        }
    }
    
    func stickerDidDownload(id: String, sender: UIButton) {
        StickerManager.shared.downloadSticker(for: id) {
            DispatchQueue.main.async { 
                self.tableView.reloadData()
            }
        } onError: { [weak self] errMsg in
            self?.view.makeToast(errMsg, duration: 1.5, position: CSToastPositionCenter)
        }
    }
}

extension ArtistCollectionViewController : ArtistHeaderViewDelegate {
    func viewMyMoments (uid : String) {
//        let userHomPage = HomePageViewController(userId: Int(uid)!)
//        navigationController?.pushViewController(userHomPage, animated: true)
    }
    func updateHeader() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
}
