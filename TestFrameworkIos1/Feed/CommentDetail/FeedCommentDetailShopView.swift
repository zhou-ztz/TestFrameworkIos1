//
//  FeedCommentDetailShopView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/10/11.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

enum ShopSubViewType {
    case picture
    case darkPicture
    case video
}
class FeedCommentDetailShopView: UIView {
    let stackView: UIStackView = UIStackView().configure {
        $0.alignment = .fill
        $0.distribution = .fill
        $0.axis = .vertical
        $0.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        $0.spacing = 5
    }
    
    private lazy var feedShopListView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        //layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 30, height: 110)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(FeedShopListCollectionCell.self, forCellWithReuseIdentifier: FeedShopListCollectionCell.cellIdentifier)
        
        return collectionView
    }()
    
    private var currentVisibleIndex: Int {
        let centerPoint = CGPoint(x: feedShopListView.contentOffset.x + feedShopListView.bounds.width / 2, y: feedShopListView.bounds.height / 2)
        if let indexPath = feedShopListView.indexPathForItem(at: centerPoint) {
            return indexPath.item
        }
        return 0
    }
    
    private var multiplePicturePageControl = UIPageControl()
    
    var shopSubViewType: ShopSubViewType = .video
    
    var list: [TSRewardsLinkMerchantUserModel] = []
    
    var momentMerchantDidClick: ((_ merchantData: TSRewardsLinkMerchantUserModel) -> Void)?
    
    var isDarkBackground: Bool = false
    var isInnerFeed: Bool = false
    
    init(frame: CGRect, shopSubViewType: ShopSubViewType, isDarkBackground: Bool = false, isInnerFeed: Bool = false) {
        super.init(frame: frame)
        self.shopSubViewType = shopSubViewType
        self.isDarkBackground = isDarkBackground
        self.isInnerFeed = isInnerFeed
        self.backgroundColor = .clear
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(merchantList: [TSRewardsLinkMerchantUserModel]) {
        guard merchantList.count > 0 else {
            return
        }
        list = merchantList
        self.feedShopListView.reloadData()
        
        multiplePicturePageControl.numberOfPages = list.count
        multiplePicturePageControl.isHidden = list.count < 2
    }
    
    private func commonInit() {
        self.addSubview(stackView)
        stackView.roundCorner()
        stackView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(self.shopSubViewType == .picture ? 10 : 0)
            $0.top.bottom.equalToSuperview().inset(5)
        }
        
        stackView.addArrangedSubview(feedShopListView)
        
        multiplePicturePageControl.pageIndicatorTintColor = AppTheme.brownGrey
        multiplePicturePageControl.currentPageIndicatorTintColor = AppTheme.primaryColor
        stackView.addArrangedSubview(multiplePicturePageControl)
        multiplePicturePageControl.snp.makeConstraints {
            $0.height.equalTo(20)
        }
        
        updateUIView()
    }
    
    func updateUIView() {
        if isDarkBackground {
            stackView.backgroundColor = UIColor(red: 49/255, green: 49/255, blue: 49/255, alpha: 0.8)
        } else {
            stackView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        }
        
        if let layout = feedShopListView.collectionViewLayout as? UICollectionViewFlowLayout {
            if isInnerFeed {
                layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 110)
            } else {
                layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 30, height: 110)
            }
        }
    }
}

extension FeedCommentDetailShopView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedShopListCollectionCell.cellIdentifier, for: indexPath) as! FeedShopListCollectionCell
        let merchant = list[indexPath.item]
        cell.setData(merchant: merchant, isDarkBackground: isDarkBackground)
        cell.shopInfoBtn.addAction { [weak self] in
            guard TSCurrentUserInfo.share.isLogin else {
                TSRootViewController.share.guestJoinLandingVC()
                return
            }
            guard let self = self else { return }
            self.momentMerchantDidClick?(merchant)
            
        }
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handlePageChange()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        handlePageChange()
    }

    private func handlePageChange() {
        multiplePicturePageControl.currentPage = currentVisibleIndex
    }
}
