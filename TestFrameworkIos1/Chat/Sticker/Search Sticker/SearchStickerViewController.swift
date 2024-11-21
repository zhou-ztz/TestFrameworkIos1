// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import UIKit

import Toast

class SearchStickerViewController: TSViewController {

    private lazy var searchBar = UISearchBar()
    private var searchResults: [StickerSearchQuery.Data.StickerSearch.Edge?] = []
    private var mainStackView: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .fill
        $0.spacing = 5
    }
    private let segmentPage = SegmentedPageViewController(titleStyle: .leftScrolling)
    private lazy var stickerSearchView: SearchStickerResultViewController = SearchStickerResultViewController(delegate: self)
    private lazy var artistSearchView: SearchArtistResultViewController = SearchArtistResultViewController(delegate: self)
    private lazy var segments: [SearchStickerResultBaseViewController] = [stickerSearchView, artistSearchView]
    private lazy var segmentTitles: [String] = ["text_stickers".localized, "text_artists".localized]
    private lazy var recentSearchTableView: UITableView = UITableView().configure {
        $0.register(StickerRecentSearchTableViewCell.self, forCellReuseIdentifier: StickerRecentSearchTableViewCell.cellIdentifier)
        $0.separatorStyle = .none
        $0.tableFooterView = UIView()
        $0.delegate = self
        $0.dataSource = self
    }
    private let emptySearchView: UIView = UIView()
    private let emptySearchLabel: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 12, color: UIColor(red: 145, green: 145, blue: 145)))
        $0.text = "sticker_no_recent_search".localized
        $0.textAlignment = .left
        
    }

    private let baseUserDefaultKey = "yippiuserstickerrecent:"
    private var searchHistoryDefaultKey: String? {
        get {
            guard let userinfo = CurrentUserSessionInfo else { return nil }
            return baseUserDefaultKey + userinfo.userIdentity.stringValue
        }
    }
    private var _searchHistory: [String]?
    public var searchHistory: [String]? {
        get {
            guard _searchHistory == nil else {
                return _searchHistory
            }
            guard let userDefaultKey = searchHistoryDefaultKey else { return nil }
            _searchHistory = UserDefaults.standard.array(forKey: userDefaultKey) as? [String]
            return _searchHistory
        }
        set {
            guard let userDefaultKey = searchHistoryDefaultKey else { return }
            _searchHistory = newValue
            UserDefaults.standard.setValue(_searchHistory, forKey: userDefaultKey)
            if (_searchHistory?.count).orZero > 0 {
                recentSearchTableView.makeVisible()
                recentSearchTableView.reloadData()
            } else {
                recentSearchTableView.makeHidden()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        StickerManager.shared.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (searchHistory?.count).orZero > 0 {
            recentSearchTableView.makeVisible()
            recentSearchTableView.reloadData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    private func configureView() {
        self.view.backgroundColor = .white
        self.view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.top.bottom.right.equalToSuperview()
            $0.left.equalToSuperview().inset(10)
        }

        mainStackView.addArrangedSubview(emptySearchView)
        emptySearchView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(35)
        }
        emptySearchView.addSubview(emptySearchLabel)
        emptySearchLabel.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.left.equalToSuperview().inset(6)
            $0.top.equalToSuperview().inset(10)
            $0.height.equalTo(25)
        }

        mainStackView.addArrangedSubview(recentSearchTableView)
        recentSearchTableView.snp.makeConstraints {
            $0.width.height.equalToSuperview()
        }
        recentSearchTableView.makeHidden()

        mainStackView.addArrangedSubview(segmentPage.view)
        segmentPage.view.snp.makeConstraints {
            $0.width.height.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        segmentPage.delegate = self
        segmentPage.datasource = self
        segmentPage.view.makeHidden()
        segmentPage.segmentedControl.segmentedControlHeight = 40

        searchBar.placeholder = "placeholder_sticker_search".localized
        searchBar.searchBarStyle = .minimal
        searchBar.returnKeyType = .search
        searchBar.delegate = self
        navigationItem.titleView = searchBar

        let closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage.set_image(named: "IMG_topbar_close"))
        closeButton.addAction { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        setLeftButton(button: closeButton)
    }
}

extension SearchStickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (searchHistory?.count).orZero
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StickerRecentSearchTableViewCell.cellIdentifier, for: indexPath) as! StickerRecentSearchTableViewCell

        cell.setTitle((_searchHistory?[indexPath.row]).orEmpty)

        cell.onDataReload = { [weak self] title in
            self?.searchHistory?.removeAll(where: { $0 == title })
            UserDefaults.standard.synchronize()
            self?.recentSearchTableView.reloadData()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keyword = searchHistory?[indexPath.row]
        searchBar.text = keyword
        searchBarSearchButtonClicked(searchBar)
    }
}

extension SearchStickerViewController: SegmentedPageViewControllerDelegate, SegmentedPageViewControllerDatasource {
    func segmentedPageView(pageViewController: UIPageViewController, didChangeToPageAtIndex index: Int) {

    }

    func segmentedPageView(pageViewController: UIPageViewController, viewForPageSegmentAtIndex index: Int) -> UIView? {
        let title = segmentTitles[index]
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.backgroundColor = .white
        titleLabel.textAlignment = .center
        titleLabel.textColor = TSColor.normal.minor
        titleLabel.text = title
        return titleLabel
    }

    func numberOfPages(in pageViewController: UIPageViewController) -> Int {
        return segments.count
    }

    func segmentedPageView(pageViewController: UIPageViewController, viewControllerForPageAtIndex index: Int) -> UIViewController? {
        let vc = segments[index]
        
        vc.onSelectStickerCell = { [weak self] (bundleId) in
            guard let bundleId = bundleId else { return }
            let vc = StickerDetailViewController(bundleId: bundleId)
            self?.heroPush(vc)
        }

        vc.onSelectArtistCell = { [weak self] (artistId, artistName) in
            guard let id = artistId, let name = artistName else {
                return
            }
            let vc = ArtistCollectionViewController(artistId: id, artistName: name)
            self?.heroPush(vc)
        }

        return segments[index]
    }
}

extension SearchStickerViewController: StickerManagerDelegate {

    func stickerDidRemoved(id: String) {
    }
    
    func stickerDidDownloaded(id: String) {
    }
}

extension SearchStickerViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count > 0 else {
            return
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        segmentPage.view.makeVisible()
        recentSearchTableView.makeHidden()
        stickerSearchView.searchText = searchBar.text
//        artistSearchView.searchText = searchBar.text
        setNewSearchKeyword(keyword: searchBar.text.orEmpty)
    }

    func setNewSearchKeyword(keyword: String) {
        var newKeyWord = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard newKeyWord.count > 0 else { return }
        guard let userDefaultKey = searchHistoryDefaultKey else { return }
        guard searchHistory != nil else {
            UserDefaults.standard.set([newKeyWord], forKey: userDefaultKey)
            UserDefaults.standard.synchronize()
            return
        }
        if let idx = searchHistory!.firstIndex(where: { $0 == newKeyWord }) {
            searchHistory!.remove(at: idx)
        }
        if searchHistory!.count >= 5 {
            searchHistory!.removeLast()
        }
        searchHistory!.insert(newKeyWord, at: 0)
        UserDefaults.standard.set(searchHistory!, forKey: userDefaultKey)
        UserDefaults.standard.synchronize()
    }

}

extension SearchStickerViewController: StickerTableCellDelegate {
    func stickerDidRemoved(id: String, sender: UIButton) {
        
    }
    
    func stickerDidDownload(id: String, sender: UIButton) {
        StickerManager.shared.downloadSticker(for: id) { [weak self] in
            self?.stickerSearchView.table.reloadData()
        } onError: { [weak self] errMsg in
            self?.view.makeToast(errMsg, duration: 1.5, position: CSToastPositionCenter)
        }
    }
    
    func stickerDidPurchased(id: String, sender: UIButton) {
        PopupDialogManager.presentEnterPasswordDialog(viewController: self, animated: true) { password in
            StickerManager.shared.purchaseSticker(for: id, password: password, completion: nil)
        }
    }
}
