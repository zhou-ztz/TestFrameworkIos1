//
//  SuggestVoucherViewController.swift
//  RewardsLink
//
//  Created by Wong Jin Lun on 22/07/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit
protocol SuggestVoucherDelegate: class {
    func selectedVoucher(voucherId: Int, voucherName: String)
}

class SuggestVoucherViewController: TSViewController {
    @IBOutlet weak var tableView: TSTableView!
    
    var currentKeyWord = ""
    var dataSource: [VoucherSearchData] = []
    var keyword: String = "" {
        didSet{
            if keyword.count == 0 {
                dataSource.removeAll()
                tableView.reloadData()
                //self.tableView.show(placeholderView: .emptyResult)
            }else{
                tableView.mj_header.beginRefreshing()
                
            }
        }
    }
    var isFeedSearch: Int = 1
    var headerView = SuggestHeaderView()
    var delegate: SuggestVoucherDelegate?
    var headerHeight: CGFloat = 80
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setCloseButton(backImage: true, titleStr: "rw_vouchers".localized)
        setupView()
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(VoucherListViewCell.nib(), forCellReuseIdentifier: VoucherListViewCell.cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_header.beginRefreshing()
    }
    
    func getRandomVoucher(isRefresh: Bool) {
//        if keyWord.count == 0 && isRefresh{
//            self.tableView.mj_header.endRefreshing()
//            self.showError(message: "rw_enter_search_key".localized)
//            return
//        }
    
        let offset = isRefresh ? 0 : dataSource.count
        
        VoucherRandomSearch(countryCode: LocationManager.shared.getCountryCode(), keyword: keyword, feedSearch: isFeedSearch).execute(onSuccess: { [weak self] (response) in
            defer {
                self?.tableView.mj_header.endRefreshing()
            }
            
            guard let data = response, let wself = self else {
                self?.tableView.show(placeholderView: .noVoucher, margin: self?.headerHeight ?? 0, height: self?.tableView.frame.size.height ?? 0 - (self?.headerHeight ?? 0) )
                self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
            if isRefresh {
                wself.tableView.mj_footer.makeVisible()
                wself.processReloadData(data: data.data)
            } else {
                wself.tableView.mj_footer.makeVisible()
                wself.tableView.mj_footer.endRefreshingWithNoMoreData()
                //wself.tableView.mj_footer.resetNoMoreData()
                //wself.processLoadMoreData(data: data.data)
            }
        }) { [weak self] (error) in
            printIfDebug(error)
            guard let self = self else { return }
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
            self.tableView.show(placeholderView: .network)
        }
    }
    
    private func processReloadData(data: [VoucherSearchData]?) {
        tableView.mj_footer.resetNoMoreData()
        tableView.removePlaceholderViews()
        if let data = data {
            dataSource = data
            if data.isEmpty == true {
                dataSource.removeAll()
                tableView.show(placeholderView: .noVoucher, margin: headerHeight, height: self.tableView.frame.size.height - headerHeight)
                tableView.mj_footer.makeHidden()
            } else {
                if data.count < TSAppConfig.share.localInfo.limit {
                    tableView.mj_footer.endRefreshingWithNoMoreData()
                    tableView.mj_footer.makeVisible()
                }
            }
        }
        headerView.updateLabelText(isSuggest: isFeedSearch)
        tableView.reloadData()
    }
    
//    private func processLoadMoreData(data: [VoucherSearchData]?) {
//        guard let data = data else {
//            tableView.mj_footer.endRefreshingWithNoMoreData()
//            return
//        }
//        dataSource = dataSource + data
//        tableView.reloadData()
//        if data.count < TSAppConfig.share.localInfo.limit {
//            tableView.mj_footer.endRefreshingWithNoMoreData()
//        } else {
//            tableView.mj_footer.endRefreshing()
//        }
//    }
    
    @objc func refresh() {
        dataSource.removeAll()
        getRandomVoucher(isRefresh: true)
    }
    
    @objc func loadMore() {
        getRandomVoucher(isRefresh: false)
    }
    
    override func placeholderButtonDidTapped() {
        getRandomVoucher(isRefresh: false)
    }
}

extension SuggestVoucherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: VoucherListViewCell.cellIdentifier, for: indexPath) as? VoucherListViewCell, let model = dataSource[safe: indexPath.row] {
            cell.configureSearchCell(model)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let data = self.dataSource[safe: indexPath.row] {
            delegate?.selectedVoucher(voucherId: data.id ?? 0, voucherName: data.name ?? "")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView.delegate = self
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

}

extension SuggestVoucherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}

extension SuggestVoucherViewController: SuggestSearchViewDelegate{
    func searchDidClickReturn(text: String) {
        if text.isEmpty {
            keyword = ""
            isFeedSearch = 1
        } else {
            keyword = text
            isFeedSearch = 0
        }
        self.refresh()
        headerView.searchTextField.resignFirstResponder()
    }
    
    func searchDidClickCancel() {
        keyword = ""
        isFeedSearch = 1
        self.refresh()
        //headerView?.searchTextField.text = ""
        headerView.searchTextField.resignFirstResponder()
    }
}

extension SuggestVoucherViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerView.searchTextField.resignFirstResponder()
    }
}
