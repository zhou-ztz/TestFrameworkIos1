//
//  StickerSectionBaseView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 22/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

import FSPagerView

class StickerSectionBaseView<T: StickerSectionBaseCell>: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var wrapper = UIStackView().configure {
        $0.axis = .vertical
        $0.distribution = .fillProportionally
        $0.alignment = .fill
        $0.spacing = 0
    }
    
    private let header = StickerMainSectionView()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .always
        } else {
            // Fallback on earlier versions
        }
        collectionView.decelerationRate = .fast
        collectionView.register(T.self, forCellWithReuseIdentifier: T.cellIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 50)
        return collectionView
    }()
    
    var data: [Sticker] = []
    private var section: StickerCollectionSection?
    
    weak var delegate: StickerMainDelegate?
    
    var collectionHeight: CGFloat { return 100 }
    var flowLayout: UICollectionViewFlowLayout { return UICollectionViewFlowLayout() }
    
    init() {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        
        addSubview(wrapper)
        wrapper.bindToEdges()
        wrapper.addArrangedSubview(header)
        wrapper.addArrangedSubview(collectionView)
        header.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        collectionView.snp.makeConstraints {
            $0.height.equalTo(collectionHeight)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ section: StickerCollectionSection?) {
        guard let section = section else {
            self.makeHidden()
            return
        }
        self.section = section
        self.makeVisible()
        header.setTitle(section.title)
        data = section.data
        collectionView.reloadData()
                
        header.seeAllButton.addAction { [weak self] in
            self?.delegate?.seeMoreButtonTapped(section: section)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: T.cellIdentifier, for: indexPath) as! T
        cell.setData(data[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = section else { return }
        
        let sticker = data[indexPath.row]

        switch section.type {
        
        case .new_sticker, .stickers_of_the_day, .hot_stickers:
            self.delegate?.stickerDidTapped(sticker: sticker)
            
        case .featured_category:
            self.delegate?.categoryDidTapped(categoryId: sticker.id ?? 0, categoryName: sticker.name.orEmpty)
            
        case .new_artist, .recomended_artist:
            self.delegate?.artistDidTapped(artist: sticker)
            
        default:
            break
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let bounds = scrollView.bounds
        let xTarget = targetContentOffset.pointee.x

        // This is the max contentOffset.x to allow. With this as contentOffset.x, the right edge of the last column of cells is at the right edge of the collection view's frame.
        let xMax = scrollView.contentSize.width - (scrollView.bounds.width - 50)

        if abs(velocity.x) <= snapToMostVisibleColumnVelocityThreshold {
            let xCenter = scrollView.bounds.midX
            let poses = layout.layoutAttributesForElements(in: bounds) ?? []
            // Find the column whose center is closest to the collection view's visible rect's center.
            let x = poses.min(by: { abs($0.center.x - xCenter) < abs($1.center.x - xCenter) })?.frame.origin.x ?? 0
            targetContentOffset.pointee.x = x
        } else if velocity.x > 0 {
            let poses = layout.layoutAttributesForElements(in: CGRect(x: xTarget, y: 0, width: bounds.size.width, height: bounds.size.height)) ?? []
            // Find the leftmost column beyond the current position.
            let xCurrent = scrollView.contentOffset.x
            let x = poses.filter({ $0.frame.origin.x > xCurrent}).min(by: { $0.center.x < $1.center.x })?.frame.origin.x ?? xMax
            targetContentOffset.pointee.x = min(x, xMax)
        } else {
            let poses = layout.layoutAttributesForElements(in: CGRect(x: xTarget - bounds.size.width, y: 0, width: bounds.size.width, height: bounds.size.height)) ?? []
            // Find the rightmost column.
            let x = poses.max(by: { $0.center.x < $1.center.x })?.frame.origin.x ?? 0
            targetContentOffset.pointee.x = max(x, 0)
        }
    }
    
    private var snapToMostVisibleColumnVelocityThreshold: CGFloat { return 0.3 }
}

class StickerSectionBaseCell: FSPagerViewCell, BaseCellProtocol {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.shadowColor = UIColor.white.cgColor
        contentView.layer.shadowRadius = 0
        contentView.backgroundColor = .white
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.layer.shadowColor = UIColor.white.cgColor
        contentView.layer.shadowRadius = 0
        contentView.backgroundColor = .white
    }
    
    func setData(_ data: Sticker) {
        
    }
}
