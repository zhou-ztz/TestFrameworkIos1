//
//  VoucherListViewController.swift
//  RewardsLink
//
//  Created by Wong Jin Lun on 14/05/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit

class VoucherListViewController: TSViewController {
    @IBOutlet weak var tableView: TSTableView!
    
    weak var parentVC: UIViewController?
    var after: Int = 0
    var offset: Int = 0
    
    public var didReload: (() -> ())? = nil
    var onNavigateView: ((UIViewController) -> Void)?
    var vouchers: [VoucherSummaryResponse] = []
    var voucherData: [VoucherSummaryData] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var categoryId: Int = 0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewStayEvent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopStayEvent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(VoucherListViewCell.nib(), forCellReuseIdentifier: VoucherListViewCell.cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_header.beginRefreshing()

        self.extendedLayoutIncludesOpaqueBars = true
        
        printIfDebug("\(className(self))'s expose category Id: \(categoryId.stringValue)")
        EventTrackingManager.instance.trackEvent(itemId: categoryId.stringValue, itemType: ItemType.voucherCategory.rawValue, behaviorType: BehaviorType.expose, sceneId: "", moduleId: ModuleId.voucher.rawValue, pageId: PageId.voucherCategoryListCategory.rawValue)
    }
    
    override func viewStayEvent() {
        eventStartTime = self.getCurrentTime()
        stayTimer?.invalidate()
        stayTimer = Timer.scheduledTimer(timeInterval: Utils.getStayEventTimerValue(), target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    override func stopStayEvent() {
        stayTimer?.invalidate()
        let stay = getCurrentTime() - eventStartTime
        if Double(stay) >= Utils.getStayEventTimerValue() {
            printIfDebug("\(className(self))'s timer stopped category id: \(categoryId), seconds: \(stay)")
            EventTrackingManager.instance.trackEvent(itemId: categoryId.stringValue, itemType: ItemType.voucherCategory.rawValue, behaviorType: BehaviorType.stay, sceneId: "", moduleId: ModuleId.voucher.rawValue, pageId: PageId.voucherCategoryListCategory.rawValue, behaviorValue: stay.stringValue)
            eventStartTime = 0
        }
    }
    
    @objc func updateTimer(timer: Timer) {
        stopStayEvent()
    }
    
    @objc func refresh() {
        self.tableView.removePlaceholderViews()
        
        VoucherProductRequest(type: .voucher, region: LocationManager.shared.getCountryCode(), categoryId: categoryId).execute(onSuccess: { [weak self] (response) in
            defer {
                self?.tableView.mj_header.endRefreshing()
            }

            guard let data = response, let wself = self else {
                self?.voucherData = []
                self?.tableView.show(placeholderView: .network)
                self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
            wself.vouchers = data
            
            for item in wself.vouchers {
                if item.data.count > 0 {
                    wself.voucherData = item.data
                }
            }
            
            if (wself.voucherData ?? []).count == TSAppConfig.share.localInfo.limit {
                wself.tableView.mj_footer.endRefreshing()
            } else {
                wself.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
            
            if (wself.voucherData ?? []).count == 0 {
                wself.tableView.show(placeholderView: .noVoucher)
            }
        }) { [weak self] (error) in
            printIfDebug(error)
            guard let wself = self else { return }
            wself.voucherData = []
            wself.tableView.mj_header.endRefreshing()
            wself.tableView.show(placeholderView: .network)
        }
    }
    
    @objc func loadMore() {
        self.tableView.mj_footer.endRefreshing()
        self.tableView.mj_footer.endRefreshingWithNoMoreData()
    }
}

extension VoucherListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: VoucherListViewCell.cellIdentifier, for: indexPath) as? VoucherListViewCell, let payment = voucherData[safe: indexPath.row] {
            cell.configureCell(payment, expiringTag: 0, indexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let model = voucherData[safe: indexPath.row], let voucherId = model.id {
            EventTrackingManager.instance.trackEvent(itemId: voucherId.stringValue, itemType: ItemType.voucherCategory.rawValue, behaviorType: BehaviorType.click, sceneId: "", moduleId: ModuleId.voucher.rawValue, pageId: PageId.voucherCategoryListVoucher.rawValue)
            
            let vc = VoucherDetailViewController()
            vc.voucherId = voucherId
            self.onNavigateView?(vc)
        }
    }
}

extension VoucherListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voucherData.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? VoucherListViewCell, let voucher = voucherData[safe: indexPath.row] else { return }
//        printIfDebug("\(VoucherListViewCell.cellIdentifier) will display at \(indexPath)")
        EventTrackingManager.instance.trackEvent(
            itemId: (voucher.id ?? 0).stringValue,
            itemType: ItemType.voucherCategory.rawValue,
            behaviorType: BehaviorType.expose,
            sceneId: "",
            moduleId: ModuleId.voucher.rawValue,
            pageId: PageId.voucherCategoryListVoucher.rawValue)
        cell.viewStayEvent(indexPath: indexPath, itemId: voucher.id ?? 0)
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? VoucherListViewCell else { return }
//        printIfDebug("\(VoucherListViewCell.cellIdentifier) did end displaying at \(indexPath)")
        cell.stopStayEvent(indexPath: indexPath)
    }
}

class VoucherSegmentController: TSViewController {
    private lazy var segmentTitles: [String] = []
    lazy var viewControllers: [VoucherListViewController] = []
    private lazy var segmentPage: SegmentedPageViewController = {
        return SegmentedPageViewController(initialIndex: self.selectedIndex)
    }()
    
    var vouchers: [VoucherResponse] = [] {
        didSet {
            viewControllers = vouchers.compactMap { (type) in
                let vc = UIStoryboard(name: "Voucher", bundle: Bundle.main).instantiateViewController(withIdentifier: "voucherList") as! VoucherListViewController
                vc.categoryId = type.categoryID ?? 0
                return vc
            }
        }
    }
    var categoryName: String = ""
    var selectedIndex: Int = 0
    var showMYAndCN: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = .white
        
        getVoucherCategory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let searchBtn = UIBarButtonItem(image: UIImage.set_image(named: "ic_rl_search_grey"), style: .plain, target: self, action: #selector(onSearchAction))
        self.navigationItem.rightBarButtonItems = [searchBtn]
        setCloseButton(backImage: true, titleStr: "rw_vouchers".localized)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func getVoucherCategory() {
        VoucherRequest(type: .voucher, region: LocationManager.shared.getCountryCode()).execute(onSuccess: { [weak self] (response) in
            guard let response = response, let wself = self else {
                self?.show(placeholder: .network)
                return
            }
            wself.vouchers = response
            
            if wself.vouchers.isEmpty {
                wself.show(placeholder: .empty)
                return
            }
            
            var arrName = [String]()
            for item in wself.vouchers {
                arrName.append(item.categoryName ?? "")
            }
            
            if let index = arrName.firstIndex(of: wself.categoryName) {
                wself.selectedIndex = index ?? 0
                //wself.segmentPage.segmentedControl.selectedSegmentIndex = wself.selectedIndex
                //wself.segmentPage.currentPageIndex = wself.selectedIndex
            }
            
            wself.segmentPage = SegmentedPageViewController(initialIndex: wself.selectedIndex)
            
            wself.view.addSubview(wself.segmentPage.view)
            wself.segmentPage.view.bindToEdges()
            
            wself.segmentPage.segmentedControl.selectedTitleColor = .black
            wself.segmentPage.segmentedControl.selectedTitleFont = UIFont.systemFont(ofSize: 15, weight: .medium)
            wself.segmentPage.delegate = self
            wself.segmentPage.datasource = self
            wself.segmentPage.segmentedControl.segmentedControlHeight = 40
            wself.segmentPage.segmentedControl.selectedSegmentIndex = wself.selectedIndex
        }) { [weak self] (error) in
            printIfDebug(error)
            guard let wself = self else { return }
            wself.show(placeholder: .network)
        }
    }
    
    override func placeholderButtonDidTapped() {
        self.removePlaceholderView()
        self.getVoucherCategory()
    }
    
    @objc func onSearchAction() {
//        let vc = RLSearchViewController()
//        vc.isVoucher = true
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension VoucherSegmentController: SegmentedPageViewControllerDelegate, SegmentedPageViewControllerDatasource {
    func segmentedPageView(pageViewController: UIPageViewController, didChangeToPageAtIndex index: Int) {
        if let vc = viewControllers[safe: index] {
            if let placeholderType = vc.tableView.placeholder.type, (placeholderType == .network || placeholderType == .networkWithRetry) {
                vc.tableView.mj_header.beginRefreshing()
            } else {
                EventTrackingManager.instance.trackEvent(itemId: vc.categoryId.stringValue, itemType: ItemType.voucherCategory.rawValue, behaviorType: BehaviorType.click, sceneId: "", moduleId: ModuleId.voucher.rawValue, pageId: PageId.voucherCategoryListCategory.rawValue)
            }
        }
    }
    
    func segmentedPageView(pageViewController: UIPageViewController, viewForPageSegmentAtIndex index: Int) -> UIView? {
        let title = vouchers[index]
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.backgroundColor = .white
        titleLabel.textAlignment = .center
        titleLabel.textColor = TSColor.normal.minor
        titleLabel.text = title.categoryName
        return titleLabel
    }
    
    func numberOfPages(in pageViewController: UIPageViewController) -> Int {
        return vouchers.count
    }

    func segmentedPageView(pageViewController: UIPageViewController, viewControllerForPageAtIndex index: Int) -> UIViewController? {
        if let vc = viewControllers[safe: index] {
            vc.onNavigateView = { [weak self] controller in
                guard let self = self else { return }
                self.setClearNavBar(shadowColor: .clear)
                self.navigationController?.pushViewController(controller, animated: true)
            }
            return vc
        }
        return nil
    }
}
