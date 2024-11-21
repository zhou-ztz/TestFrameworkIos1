//
//  VoucherViewController.swift
//  RewardsLink
//
//  Created by Wong Jin Lun on 13/05/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit

import FSPagerView

class VoucherViewController: TSViewController {
    @IBOutlet weak var thatsAll: UILabel!
    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var voucherView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var discoverAllLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewConstantH: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var constantH: NSLayoutConstraint!
    @IBOutlet weak var tableView: TSTableView!
    
    var banners: [RewardsLinkDashboardResponse] = []
    var vouchers: [VoucherResponse] = []
    var voucherSummary: [VoucherSummaryResponse] = []
    var isFirst: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setWhiteNavBar(normal: true)
        setCloseButton(backImage: true, titleStr: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notifyCollectionViewsParentWillDismiss()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.isInfinite = true
        pagerView.removesInfiniteLoopForSingleItem = true
        pagerView.automaticSlidingInterval = 3.0
        pagerView.interitemSpacing = 16
        pagerView.register(BannerCollectionViewCell.nib(), forCellWithReuseIdentifier: BannerCollectionViewCell.cellIdentifier)
        
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.register(VoucherViewCell.nib(), forCellReuseIdentifier: VoucherViewCell.cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.layoutIfNeeded()
        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 283
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = nil
        tableView.mj_header.beginRefreshing()
                
        scrollView.delegate = self
        
        searchView.layer.cornerRadius = searchView.frame.size.width / 2
        searchView.backgroundColor = UIColor(hex: 0xEAEAEA)
        let searchTap = UITapGestureRecognizer(target: self, action: #selector(onSearchAction))
        searchView.addGestureRecognizer(searchTap)
        
        voucherView.layer.cornerRadius = voucherView.frame.size.width / 2
        voucherView.backgroundColor = UIColor(hex: 0xEAEAEA)
        let voucherTap = UITapGestureRecognizer(target: self, action: #selector(onVoucherAction))
        voucherView.addGestureRecognizer(voucherTap)
        
        discoverAllLabel.text = "rw_discover_all_the_voucher_here".localized  
        thatsAll.text = "rw_thats_all_for_now".localized
        thatsAll.textColor = UIColor(hex: 0xA5A5A5)
    }
    
    func notifyCollectionViewsParentWillDismiss() {
        for dict in VoucherViewCell.timerDictionary.values {
            dict.timer.invalidate()
            
            let stay = Date().timeStamp.toInt() - dict.startTime
            if Double(stay) >= Utils.getStayEventTimerValue() {
                printIfDebug("\(VoucherViewCell.cellIdentifier)'s timer stopped for cell at indexPath: \(dict.indexPath), item Id: \(dict.itemId.stringValue), seconds: \(stay)")
                EventTrackingManager.instance.trackEvent(itemId: dict.itemId.stringValue, itemType: ItemType.voucherDashboard.rawValue, behaviorType: BehaviorType.stay, sceneId: "", moduleId: ModuleId.voucher.rawValue, pageId: PageId.voucherDashboardCategory.rawValue, behaviorValue: stay.stringValue)
            }
        }
        VoucherViewCell.timerDictionary.removeAll()
        
        for dict in VoucherCollectionCell.timerDictionary.values {
            dict.timer.invalidate()
            
            let stay = Date().timeStamp.toInt() - dict.startTime
            if Double(stay) >= Utils.getStayEventTimerValue() {
                printIfDebug("\(VoucherCollectionCell.cellIdentifier)'s timer stopped for cell at indexPath: \(dict.indexPath), item Id: \(dict.itemId.stringValue), seconds: \(stay)")
                EventTrackingManager.instance.trackEvent(itemId: dict.itemId.stringValue, itemType: ItemType.voucherDashboard.rawValue, behaviorType: BehaviorType.stay, sceneId: "", moduleId: ModuleId.voucher.rawValue, pageId: PageId.voucherDashboardVoucher.rawValue, behaviorValue: stay.stringValue)
            }
        }
        VoucherCollectionCell.timerDictionary.removeAll()
    }
    
    @objc func refresh() {
        self.isFirst = true
        self.tableView.removePlaceholderViews()
        
        let request = VoucherSummaryRequest(type: .voucher, region: LocationManager.shared.getCountryCode(), isSummary: 1)
        request.execute(
            onSuccess: { [weak self] (response) in
                defer {
                    self?.tableView.mj_header.endRefreshing()
                }
                
                guard let self = self , let items = response else { return }
                DispatchQueue.main.async {
                    defer {
                        DispatchQueue.main.async {
                            self.tableView.mj_header.endRefreshing()
                            self.tableView.reloadData()
                        }
                    }
                    
                    guard let vouchers = items, !vouchers.isEmpty else {
                        self.tableView.show(placeholderView: .noVoucher)
                        self.constantH.constant = ScreenHeight - self.topView.frame.height - 80
                        self.thatsAll.isHidden = true
                        self.tableView.mj_header.endRefreshing()
                        return
                    }
                    
                    self.voucherSummary = []
                    
                    for item in vouchers {
                        if !item.data.isEmpty {
                            self.voucherSummary.append(item)
                        }
                    }
                    
                    if self.voucherSummary.isEmpty {
                        self.tableView.show(placeholderView: .noVoucher)
                        self.constantH.constant = ScreenHeight - self.topView.frame.height - 80
                        self.thatsAll.isHidden = true
                        self.tableView.mj_header.endRefreshing()
                        return
                    }
                    
                    //self.voucherSummary = vouchers
                    //self.constantH.constant = CGFloat(320 * self.voucherSummary.count)
                    self.tableView.reloadData()
                    self.thatsAll.isHidden = false
                    self.tableView.mj_header.endRefreshing()
                }
            }) { [weak self] (error) in
                printIfDebug(error)
                guard let self = self else { return }
                self.constantH.constant = ScreenHeight - topView.frame.height - 80
                self.tableView.mj_header.endRefreshing()
                self.tableView.show(placeholderView: .network)
                self.thatsAll.isHidden = true
            }
    }
}

// MARK: - UITableView Delegate
extension VoucherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: VoucherViewCell.cellIdentifier, for: indexPath) as? VoucherViewCell, let voucher = voucherSummary[safe: indexPath.row] {
            cell.delegate = self
            cell.configureCell(voucher: voucher, indexPath: indexPath)
            cell.lineView.isHidden = indexPath.row == (voucherSummary.count - 1)
            
            cell.navigateToVoucherDetail = { [weak self] voucherId in
                guard let self = self else { return }    
                EventTrackingManager.instance.trackEvent(itemId: voucherId.stringValue, itemType: ItemType.voucherDashboard.rawValue, behaviorType: BehaviorType.click, sceneId: "", moduleId: ModuleId.voucher.rawValue, pageId: PageId.voucherDashboardVoucher.rawValue)
                let vc = VoucherDetailViewController()
                vc.voucherId = voucherId
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var width : CGFloat = ScreenWidth * 0.65
        var height : CGFloat = ((width * 30) / 45) + 110 + 16
        if isFirst {
            isFirst = false
            self.constantH.constant = height * CGFloat(self.voucherSummary.count)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        return height
        //        return UITableView.automaticDimension
    }
}

extension VoucherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voucherSummary.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? VoucherViewCell, let voucher = voucherSummary[safe: indexPath.row] else { return }
//        printIfDebug("\(VoucherViewCell.cellIdentifier) will display at \(indexPath)")
        EventTrackingManager.instance.trackEvent(
            itemId: (voucher.categoryID ?? 0).stringValue,
            itemType: ItemType.voucherDashboard.rawValue,
            behaviorType: BehaviorType.expose,
            sceneId: "",
            moduleId: ModuleId.voucher.rawValue,
            pageId: PageId.voucherDashboardCategory.rawValue)
        cell.viewStayEvent(indexPath: indexPath, itemId: voucher.categoryID ?? 0)
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? VoucherViewCell else { return }
//        printIfDebug("\(VoucherViewCell.cellIdentifier) did end displaying at \(indexPath)")
        cell.stopStayEvent(indexPath: indexPath)
    }
}

// MARK: - UIScorllView Delegate
extension VoucherViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = scrollView.contentOffset.y / 80
        if offset > 1 {
            let searchBtn = UIBarButtonItem(image: UIImage.set_image(named: "ic_rl_search_grey"), style: .plain, target: self, action: #selector(onSearchAction))
            let voucherBtn = UIBarButtonItem(image: UIImage.set_image(named: "ic_rl_voucher_grey"), style: .plain, target: self, action: #selector(onVoucherAction))
            
            self.navigationItem.rightBarButtonItems = [voucherBtn, searchBtn]
            setCloseButton(backImage: true, titleStr: "rw_voucher_text".localized)
        } else {
            self.navigationItem.rightBarButtonItem = nil
            setCloseButton(backImage: true, titleStr: "")
        }
        
        var reverseOffset = 1 - offset
        if reverseOffset <= 0 {
            reverseOffset = 0
        }
        
        if reverseOffset >= 1 {
            reverseOffset = 1
        }
        topView.alpha = reverseOffset
        topViewConstantH.constant = 75 * reverseOffset
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y <= -50 {
            DispatchQueue.main.async {
                self.tableView.mj_header.beginRefreshing()
                self.refresh()
            }
        }
    }
    
    @objc func onSearchAction() {
//        let vc = RLSearchViewController()
//        vc.isVoucher = true
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onVoucherAction() {
//        let vc = UIStoryboard(name: "Voucher", bundle: Bundle.main).instantiateViewController(withIdentifier: "myVoucher") as! MyVoucherViewController
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension VoucherViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return banners.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: BannerCollectionViewCell.cellIdentifier, at: index) as! BannerCollectionViewCell
        if banners.count > 0 {
            let model = banners[index]
            if let imageUrl = model.imageURL {
                if imageUrl.contains("localhost") {
                    cell.bannerImage.backgroundColor = UIColor(hex: 0xB4B4B4)
                    cell.bannerImage.image = UIImage.set_image(named: "rl_placeholder_icon")
                    cell.bannerImage.contentMode = .scaleAspectFit
                } else {
                    cell.bannerImage.sd_setImage(with: URL(string: imageUrl))
                    cell.bannerImage.contentMode = .scaleToFill
                }
            } else {
                cell.bannerImage.backgroundColor = UIColor(hex: 0xB4B4B4)
                cell.bannerImage.image = UIImage.set_image(named: "rl_placeholder_icon")
                cell.bannerImage.contentMode = .scaleAspectFit
            }
            cell.imageView?.contentMode = .scaleAspectFit
            cell.contentView.layer.shadowRadius = 0.0
        }
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        if let data = banners[safe: index] {

        }
    }
}

extension VoucherViewController: VoucherDelegate {    
    func onMoreAction(_ categoryName: String) {
        let vc = VoucherSegmentController()
        vc.categoryName = categoryName
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

