//
//  MiniVideoProfileCollectionView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 08/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

protocol ProfileRefreshProtocol {
    func profileDidRefresh()
    func updateUserId(_ userId: Int)
}

class MiniVideoProfileCollectionView: TSViewController, ProfileRefreshProtocol {
    
    private var shouldReloadDataSource = false
    private(set) var userId: Int {
        didSet {
            viewModel.setUserId(id: userId)
        }
    }
    weak var scrollDelegate: TSScrollDelegate?
    private lazy var viewModel: MiniVideoViewModel = {
        return MiniVideoViewModel(type: .user(userId: self.userId))
    }()
    
    private lazy var collectionView: TSCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        let collection = TSCollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        collection.isScrollEnabled = true
        collection.alwaysBounceVertical = true
        collection.contentInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        collection.register(MiniVideoProfileCell.self, forCellWithReuseIdentifier: MiniVideoProfileCell.identifier)
        collection.mj_header = nil
        collection.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        collection.setPlaceholderBackgroundGrey()
        return collection
    }()
    
    var refreshData: EmptyClosure?
    
    init(userId: Int) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldReloadDataSource {
            refreshData?()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePinnedCell(notice:)), name: NSNotification.Name(rawValue: "newPinnedFeed"), object: nil)
        
        self.view.addSubview(collectionView)
        collectionView.bindToEdges()
        
        collectionView.delegate = self
        collectionView.dataSource = self

        loadData()
    }
    
    @objc func updatePinnedCell(notice: NSNotification) {
        guard let userInfo = notice.userInfo else { return }
        guard let feedId = userInfo["feedId"] as? Int, let isPinned = userInfo["isPinned"] as? Bool else { return }
        guard let index = self.viewModel.videos.firstIndex(where: { $0.id["feedId"] == feedId }) else { return }
        self.viewModel.videos[index].isPinned = isPinned
        shouldReloadDataSource = true
    }
        
    func loadData() {
        viewModel.fetchData { [weak self] hasData in
            DispatchQueue.main.async {
                if hasData {
                    self?.collectionView.removePlaceholderView()
                    self?.collectionView.mj_footer.endRefreshing()
                } else if (TSReachability.share.isReachable()) {
                    self?.collectionView.show(placeholderView: .empty)
                    self?.collectionView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self?.collectionView.show(placeholderView: .network)
                    self?.collectionView.mj_footer.endRefreshingWithWeakNetwork()
                }
                self?.collectionView.reloadData()
            }
        } onNetworkFail: { [weak self] hasData in
            if hasData {
                self?.showError(message: "network_is_not_available".localized)
            } else {
                self?.collectionView.show(placeholderView: .network)
                self?.collectionView.mj_footer.endRefreshingWithWeakNetwork()
            }
        }
    }
    
    @objc func loadMore() {
        viewModel.loadMore { [weak self] hasData in
            DispatchQueue.main.async {
                defer {
                    self?.collectionView.reloadData()
                }
                if hasData {
                    self?.collectionView.mj_footer.endRefreshing()
                } else {
                    self?.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }
            }
        } onFail: { [weak self] in
            self?.collectionView.mj_footer.endRefreshingWithWeakNetwork()
        }
    }
    
    func profileDidRefresh() {
        loadData()
    }
    
    func updateUserId(_ userId: Int) {
        self.userId = userId
    }
}

extension MiniVideoProfileCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.currentCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MiniVideoProfileCell.identifier, for: indexPath) as! MiniVideoProfileCell
        cell.set(model: viewModel.videos[indexPath.row])
        cell.pinnedIconContainner.isHidden = !viewModel.videos[indexPath.row].isPinned
        cell.addAction {
            self.collectionView(collectionView, didSelectItemAt: indexPath)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 4) / 3
        return CGSize(width: width, height: 165)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let player = MiniVideoPageViewController(type: .user(userId: userId), videos: viewModel.videos, focus: indexPath.item, onToolbarUpdate: nil, tagVoucher: viewModel.videos[indexPath.row].tagVoucher)
        player.onDataChanged = { [weak self] model in
            if let index = self?.viewModel.videos.firstIndex(where: { $0.idindex == model.idindex }) {
                self?.viewModel.videos[index] = model
            }
        }
        player.isControllerPush = true
        if let navigationController = self.navigationController {
            self.navigationController?.pushViewController(player, animated: true)
        } else {
            let nav = TSNavigationController(rootViewController: player)
            nav.setCloseButton(backImage: true)
            self.present(nav.fullScreenRepresentation, animated: true, completion: nil)
        }
       // self.present(TSNavigationController(rootViewController: player).fullScreenRepresentation, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
}

class MiniVideoProfileCell: UICollectionViewCell {
    
    static let identifier = "MiniVideoProfileCell"
    
    private lazy var thumbnail: UIImageView = {
       let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    private lazy var viewsLabel: UILabel = {
       let label = UILabel()
        label.applyStyle(.regular(size: 11, color: .white))
        return label
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.6).cgColor]
        layer.locations = [0, 0.8, 1]
        return layer
    }()
    
    private lazy var pinnedIcon: UIImageView = UIImageView(image: UIImage.set_image(named: "icGalleryPinned"))
    private lazy var pinnedLabel: UILabel = UILabel(frame: .zero).configure {
        $0.text = "live_tab_filter_pinned".localized
        $0.font = AppFonts.Tag.medium10.font
        $0.textColor = .white
    }
    public var pinnedIconContainner: UIView = UIView().configure {
        $0.backgroundColor = .black.withAlphaComponent(0.5)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
        pinnedIconContainner.roundCorner(5)
    }
    
    private func setUI() {
        addSubview(thumbnail)
        addSubview(viewsLabel)
        
        thumbnail.bindToEdges()
        viewsLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        self.layer.insertSublayer(gradientLayer, above: thumbnail.layer)
        
        pinnedIconContainner.addSubview(pinnedIcon)
        pinnedIconContainner.addSubview(pinnedLabel)
        addSubview(pinnedIconContainner)
        
        pinnedIconContainner.isHidden = true
        
        pinnedIcon.snp.makeConstraints {
            $0.width.height.equalTo(15)
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().inset(8)
        }
        
        pinnedLabel.snp.makeConstraints {
            $0.left.equalTo(pinnedIcon.snp.right).offset(6)
            $0.top.bottom.equalToSuperview().inset(5)
            $0.right.equalToSuperview().inset(8)
        }
        
        pinnedIconContainner.snp.makeConstraints {
            $0.top.left.equalToSuperview().inset(8)
        }
    }
    
    func set(model: FeedListCellModel) {
        if let image = model.pictures.first?.url {
            thumbnail.sd_setImage(with: URL(string: image), placeholderImage: UIImage.set_image(named: "icPicturePostPlaceholder"), completed: nil)
        }
        
        if let viewCount = model.toolModel?.viewCount {
            viewsLabel.attributedText  = setAttributes(viewCount.abbStartFrom5Digit)
        }
        
        thumbnail.hero.id = model.idindex.stringValue
    }
    
    func setAttributes(_ count: String) -> NSMutableAttributedString {
        let count = NSMutableAttributedString(string: count, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemMediumFont(ofSize: 12)])
        
        let viewer = NSAttributedString(string: "number_of_browsed".localized, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemMediumFont(ofSize: 8)])
        
        count.append(viewer)
        return count
    }
}
