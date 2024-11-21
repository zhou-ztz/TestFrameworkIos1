//
//  StickerHomeBannerView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 22/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import FSPagerView


class StickerHomeBannerView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var wrapper = UIStackView().configure {
        $0.axis = .vertical
        $0.distribution = .fillProportionally
        $0.alignment = .fill
        $0.spacing = 0
    }
    
    private let header = StickerMainSectionView()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .always
        } else {
            // Fallback on earlier versions
        }
        collectionView.register(StickerHomeBannerCell.self, forCellWithReuseIdentifier: StickerHomeBannerCell.cellIdentifier)
        return collectionView
    }()
    
    private let pagerView = FSPagerView()
    private let pageControl = FSPageControl()
    
    private var data: [StickerBanner] = []
    
    private var collectionHeight: CGFloat { return 150 }
    private var flowLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: self.collectionHeight)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return layout
    }
    
    weak var delegate: StickerMainDelegate?
    
    init() {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
         
        addSubview(wrapper)
        wrapper.bindToEdges()
        wrapper.addArrangedSubview(header)
        header.snp.makeConstraints {
            $0.height.equalTo(40)
        }

        pageControl.currentPage = 0
        pageControl.contentHorizontalAlignment = .center
        
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.register(StickerHomeBannerCell.self, forCellWithReuseIdentifier: "cell")
        wrapper.addArrangedSubview(pagerView)
        pagerView.snp.makeConstraints {
            $0.height.equalTo(collectionHeight + 16)
        }
        
        pagerView.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: collectionHeight)
        pagerView.interitemSpacing = 16.0
        pagerView.automaticSlidingInterval = 3.0
        pagerView.isInfinite = false
        
        pagerView.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(15)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ section: StickerHomeBannerSection?) {
        guard let section = section, let list = section.bannerList else {
            self.makeHidden()
            return
        }
        self.makeVisible()
        header.setTitle(section.title.orEmpty)
        header.seeAllButton.makeHidden()
        
        data = list
        collectionView.reloadData()
        pagerView.reloadData()
        pageControl.numberOfPages = data.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerHomeBannerCell.cellIdentifier, for: indexPath) as! StickerHomeBannerCell
        cell.setData(data[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let banner = data[indexPath.row]
        delegate?.bannerDidTapped(banner: banner)
    }
}

class StickerHomeBannerCell: StickerSectionBaseCell {
    
    private let bannerView: UIImageView = UIImageView().configure {
        $0.contentMode = .scaleAspectFill
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.roundCorner(8)
        contentView.addSubview(bannerView)
        bannerView.bindToEdges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(_ data: StickerBanner) {
        bannerView.sd_setImage(with: URL(string: data.bannerUrl.orEmpty), placeholderImage: UIImage.set_image(named: "post_placeholder"), completed: nil)
    }
}


extension StickerHomeBannerView: FSPagerViewDelegate, FSPagerViewDataSource {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let banner = data[index]
        delegate?.bannerDidTapped(banner: banner)
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return data.count
    }
        
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index) as! StickerHomeBannerCell
        cell.setData(data[index])
        return cell
    }

}
