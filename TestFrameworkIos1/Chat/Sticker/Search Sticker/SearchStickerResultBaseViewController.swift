//
//  SearchStickerResultViewController.swift
//  Yippi
//
//  Created by ChuenWai on 16/02/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit


enum StickerSearchType {
    case sticker
    case artist
}

class SearchStickerResultBaseViewController: TSViewController, UITableViewDelegate, UITableViewDataSource {

    var onSelectStickerCell: ((String?) -> Void)?
    var onSelectArtistCell: ((String?, String?) -> Void)?

    lazy var table: TSTableView = TSTableView(frame: .zero, style: .grouped).configure {
        $0.backgroundColor = .white
        $0.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        $0.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        $0.mj_footer.removeGestures()
        $0.mj_footer.makeHidden()
        $0.register(StickerTableCell.nib(), forCellReuseIdentifier: StickerTableCell.cellIdentifier)
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        $0.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        $0.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        $0.keyboardDismissMode = .onDrag
    }
    let headerStackView: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 9
    }
    private let emptySearchResultContainerView: UIView = UIView()
    private let emptySearchResultLabel: UILabel = UILabel().configure {
        $0.font = UIFont.systemMediumFont(ofSize: 14)
        $0.textColor = .black
        $0.textAlignment = .left
    }
    private let youMayLikeLabel: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 12, color: .lightGray))
        $0.textAlignment = .left
        $0.text = "text_you_might_like".localized
    }
    var stickerSearchResults: [StickerSearchQuery.Data.StickerSearch.Edge?] = [] {
        didSet {
            self.table.reloadData()
            self.table.mj_footer.isHidden = !(stickerSearchResults.count > 0)
        }
    }
    var artistSearchResults: [ArtistSearchQuery.Data.ArtistSearch.Edge?] = [] {
        didSet {
            self.table.reloadData()
            self.table.mj_footer.isHidden = !(artistSearchResults.count > 0)
        }
    }
    var delegate: StickerTableCellDelegate?
    var searchText: String? {
        didSet {
            self.refresh()
        }
    }
    var after: String? = nil

    init(delegate: StickerTableCellDelegate?) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        table.mj_header.beginRefreshing()
    }

    private func configureView() {
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        self.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .white
        view.addSubview(table)
        headerStackView.addArrangedSubview(emptySearchResultContainerView)
        headerStackView.addArrangedSubview(youMayLikeLabel)
        emptySearchResultContainerView.addSubview(emptySearchResultLabel)

        emptySearchResultContainerView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(35)
        }

        emptySearchResultLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.left.right.equalToSuperview()
        }

        youMayLikeLabel.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(20)
            $0.bottom.equalTo(headerStackView.bottom)
        }

        headerStackView.makeHidden()

        table.bindToEdges()
    }

    @objc func refresh() { }

    @objc func loadMore() { }

    func getCellCount() -> Int {
        return 0
    }

    func getCell(cell: StickerTableCell, indexPath: IndexPath) -> StickerTableCell {
        return cell
    }

    func didSelectItem(at indexPath: IndexPath) { }

    func showEmptyResultView() {
        headerStackView.makeVisible()
        table.makeVisible()
        emptySearchResultLabel.text = String(format: "text_sticker_no_result".localized, searchText.orEmpty)
    }

    func hideEmptyResultView() {
        headerStackView.makeHidden()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerStackView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerStackView.isHidden ? CGFloat.leastNormalMagnitude : 64
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCellCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StickerTableCell.cellIdentifier, for: indexPath) as! StickerTableCell

        return getCell(cell: cell, indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        didSelectItem(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Layout.stickerCellHeight
    }

}
