//
//  HashtagMiniVideoViewController.swift
//  Yippi
//
//  Created by Jerry Ng on 22/03/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class HashtagMiniVideoCollectionView: TSViewController {
    
    private(set) var hashtagId : Int
    weak var scrollDelegate: TSScrollDelegate?
    private lazy var viewModel: HashtagMiniVideoViewModel = {
        return HashtagMiniVideoViewModel(hashtagId: self.hashtagId)
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
        collection.register(HashtagMiniVideoCell.self, forCellWithReuseIdentifier: HashtagMiniVideoCell.identifier)
        collection.mj_header = nil
        collection.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        collection.setPlaceholderBackgroundGrey()
        return collection
    }()
    
    public var onChildFetched: ((HashtagDetailModel?)->())? = nil
    public var onBannerLoaded: ((HashtagBannerModel)->())? = nil
    
    init(hashtagId: Int) {
        self.hashtagId = hashtagId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(collectionView)
        collectionView.bindToEdges()
        
        collectionView.delegate = self
        collectionView.dataSource = self

        viewModel.onFailFetchData = { [weak self] in
            DispatchQueue.main.async {
                self?.onChildFetched?(nil)
                if self?.viewModel.currentCount ?? 0 > 0 {
                    self?.collectionView.mj_footer.endRefreshingWithWeakNetwork()
                } else {
                    self?.collectionView.show(placeholderView: .network)
                }
                self?.collectionView.reloadData()
            }
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadData()
    }
    
    func loadData() {
        viewModel.fetchData { [weak self] hasData in
            DispatchQueue.main.async {
                self?.onChildFetched?(nil)
                if hasData {
                    self?.collectionView.removePlaceholderView()
                } else {
                    self?.collectionView.show(placeholderView: .empty)
                }
                self?.collectionView.reloadData()
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
        }
    }
}

extension HashtagMiniVideoCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.currentCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HashtagMiniVideoCell.identifier, for: indexPath) as! HashtagMiniVideoCell
        cell.set(model: viewModel.videos[indexPath.row])
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
        let player = MiniVideoPageViewController(type: .hot, videos: viewModel.videos, focus: indexPath.item, onToolbarUpdate: nil, tagVoucher: viewModel.videos[indexPath.row].tagVoucher)
        player.onDataChanged = { [weak self] model in
            if let index = self?.viewModel.videos.firstIndex(where: { $0.idindex == model.idindex }) {
                self?.viewModel.videos[index] = model
            }
        }
        self.present(TSNavigationController(rootViewController: player).fullScreenRepresentation, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
}

class HashtagMiniVideoCell: UICollectionViewCell {
    
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
    }
    
    func set(model: FeedListCellModel) {
        if let image = model.pictures.first?.url {
            thumbnail.sd_setImage(with: URL(string: image), placeholderImage: UIImage.set_image(named: "icPicturePostPlaceholder"), completed: nil)
        }
        
        if let viewCount = model.toolModel?.viewCount {
            viewsLabel.attributedText  = setAttributes(viewCount.abbStartFrom5Digit)
        }
    }
    
    func setAttributes(_ count: String) -> NSMutableAttributedString {
        let count = NSMutableAttributedString(string: count, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemMediumFont(ofSize: 12)])
        
        let viewer = NSAttributedString(string: "number_of_browsed".localized, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemMediumFont(ofSize: 8)])
        
        count.append(viewer)
        return count
    }
}
