//
//  MiniVideoCollectionView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 07/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit


class MiniVideoCollectionView: TSViewController {
    
    private lazy var collectionView: TSCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 16
        
        let collection = TSCollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = true
        collection.isScrollEnabled = true
        collection.alwaysBounceVertical = true
        collection.delegate = self
        collection.dataSource = self
        collection.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        collection.register(UINib(nibName: "MiniVideoCollectionCell", bundle: nil), forCellWithReuseIdentifier: MiniVideoCollectionCell.identifier)
        collection.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        collection.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        collection.prefetchDataSource = self
        return collection
    }()
    
    private let shimmerView = MiniVideoCollectionShimmerView().configure {
        $0.makeHidden()
    }
    
    private let viewModel = MiniVideoViewModel(type: .hot)
    
    private var hashtagSectionView: HashtagSectionView = HashtagSectionView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.alignment = .fill
        contentStackView.spacing = 8
        
        contentStackView.addArrangedSubview(hashtagSectionView)
        contentStackView.addArrangedSubview(collectionView)
        
        self.view.addSubview(contentStackView)
        contentStackView.bindToEdges()
        self.view.addSubview(shimmerView)
        
        hashtagSectionView.onHashtagSelected = { [weak self] (model) in
            guard let hashtag = model, let id = hashtag.hashtagId else {
                return
            }
            let vc = HashtagDetailViewController(hashtagId: id, hashTagName: hashtag.name)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        shimmerView.bindToEdges()
        shimmerView.makeVisible()
        
        refresh()
        
        NotificationCenter.default.observe(Notification.Name.Setting.configUpdated) { [weak self] in
            self?.collectionView.mj_header.beginRefreshing()
            self?.refresh()
        }
    }
    
    @objc func refresh() {
        viewModel.fetchData { [weak self] hasData in
            self?.shimmerView.stopShimmering()
            self?.shimmerView.makeHidden()
            
            if hasData {
                self?.collectionView.removePlaceholderView()
            } else {
                self?.collectionView.show(placeholderView: .empty)
            }
            self?.collectionView.reloadData()
            self?.collectionView.mj_header.endRefreshing()
        } onNetworkFail: { [weak self] hasData in
            if hasData {
                self?.showError(message: "network_is_not_available".localized)
            } else {
                self?.collectionView.show(placeholderView: .network)
                self?.collectionView.mj_footer.endRefreshingWithWeakNetwork()
            }
        }
        
        hashtagSectionView.refresh(contryCode: (TSCurrentUserInfo.share.isLogin ?  UserConfig.default?.miniVideoCountry : (UserDefaults.standard.string(forKey: "MINICOUNTRYCODE"))) ?? "MY") { [weak self] (haveData) in
            if haveData {
                self?.hashtagSectionView.makeVisible()
            } else {
                self?.hashtagSectionView.makeHidden()
            }
        }
    }
    
    @objc func loadMore() {
        viewModel.loadMore { [weak self] hasData in
            defer {
                self?.collectionView.reloadData()
            }
            if hasData {
                self?.collectionView.mj_footer.endRefreshing()
            } else {
                self?.collectionView.mj_footer.endRefreshingWithNoMoreData()
            }
        } onFail: {
            self.collectionView.mj_footer.endRefreshingWithWeakNetwork()
        }
    }
}

extension MiniVideoCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.currentCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MiniVideoCollectionCell.identifier, for: indexPath) as! MiniVideoCollectionCell
        cell.set(model: viewModel.videos[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 24) / 2
        return CGSize(width: width, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard TSCurrentUserInfo.share.isLogin else {
            TSRootViewController.share.guestJoinLandingVC()
            return
        }
        let selectedModel = viewModel.videos[indexPath.row]
        let vc = MiniVideoPageViewController(type: viewModel.type, videos: viewModel.videos, focus: indexPath.item, onToolbarUpdate: nil, tagVoucher: selectedModel.tagVoucher)
        vc.onDataChanged = { [weak self] model in
            if let index = self?.viewModel.videos.firstIndex(where: { $0.idindex == model.idindex }) {
                self?.viewModel.videos[index] = model
            }
        }
        
        //self.navigationController?.pushViewController(vc, animated: true)
        // By Kit Foong (Changed navigate method)
        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
        self.present(nav, animated: true, completion: nil)
    }
}

extension MiniVideoCollectionView: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
    }
}

private extension MiniVideoCollectionView {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= viewModel.currentCount
    }
}
