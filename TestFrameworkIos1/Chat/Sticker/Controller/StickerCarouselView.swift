//
//  StickerCarouselView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 22/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit


class StickerCarouselView: UIView {
    
    private let whiteBackground = UIView().configure {
        $0.backgroundColor = .white
    }

    private let titleLabel = UILabel().configure {
        $0.applyStyle(.semibold(size: 18, color: .white))
    }
    
    private let seeAllButton = UIButton().configure {
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("sticker_see_all".localized, for: .normal)
        $0.titleLabel?.font = UIFont.systemRegularFont(ofSize: 14)
    }
    
    private lazy var collectionView: UICollectionView = {
        let width = (min(UIScreen.main.bounds.height, UIScreen.main.bounds.width) - 16) / 2
        let layout = CarouselFlowLayout(minimumLineSpacing: 50, itemSize: CGSize(width: width, height: width))
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .always
        } else {
            // Fallback on earlier versions
        }
        collectionView.register(StickerCarouselCell.self, forCellWithReuseIdentifier: StickerCarouselCell.cellIdentifier)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    weak var delegate: StickerMainDelegate?
    
    private var model: StickerCollectionSection?
    
    var onColorChanged: ((UIColor?) -> Void)?
    
    init() {
        super.init(frame: .zero)
        addSubview(whiteBackground)
        addSubview(collectionView)
        addSubview(titleLabel)
        addSubview(seeAllButton)
        
        whiteBackground.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(110)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(280)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(15)
            $0.bottom.equalTo(collectionView.snp.top).offset(-16)
        }
        
        seeAllButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(15)
            $0.centerY.equalTo(titleLabel)
        }
        
        seeAllButton.addAction { [weak self] in
            guard let self = self, let model = self.model else { return }
            self.delegate?.seeMoreButtonTapped(section: model)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setModel(_ model: StickerCollectionSection) {
        self.model = model
        self.titleLabel.text = model.title
        self.collectionView.reloadData()
    }
}



extension StickerCarouselView: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.data.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerCarouselCell.cellIdentifier, for: indexPath) as! StickerCarouselCell
        let data = model?.data[indexPath.row]
        cell.set(data)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let center = self.convert(collectionView.center, to: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: center) {
            let sticker = model?.data[indexPath.row]
            if let color = sticker?.backgroundColor {
                onColorChanged?(UIColor(hex: color))
            } else {
                onColorChanged?(.random)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let sticker = model?.data[indexPath.row] {
            self.delegate?.stickerDidTapped(sticker: sticker)
        }
    }
}

class CarouselFlowLayout: UICollectionViewFlowLayout {
    
    let activeDistance: CGFloat = 200
    var zoomFactor: CGFloat = 0.3

    init(minimumLineSpacing: CGFloat, itemSize: CGSize, zoomFactor: CGFloat = 0.3) {
        super.init()
        
        scrollDirection = .horizontal
        self.minimumLineSpacing = minimumLineSpacing
        self.itemSize = itemSize
        self.zoomFactor = zoomFactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { fatalError() }
        if #available(iOS 11.0, *) {
            let verticalInsets = (collectionView.frame.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom - itemSize.height) / 2
            let horizontalInsets = (collectionView.frame.width - collectionView.adjustedContentInset.right - collectionView.adjustedContentInset.left - itemSize.width) / 2
            sectionInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
        } else {
            let verticalInsets = (collectionView.frame.height - collectionView.contentInset.top - collectionView.contentInset.bottom - itemSize.height) / 2
            let horizontalInsets = (collectionView.frame.width - collectionView.contentInset.right - collectionView.contentInset.left - itemSize.width) / 2
            sectionInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
        }
        super.prepare()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let rectAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
        
        // Make the cells be zoomed when they reach the center of the screen
        
        for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {
            let distance = visibleRect.midX - attributes.center.x
            let normalizedDistance = distance / activeDistance
            
            if distance.magnitude < activeDistance {
                let zoom = 1 + zoomFactor * (1 - normalizedDistance.magnitude)
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
                attributes.zIndex = Int(zoom.rounded())
            }
        }
        
        return rectAttributes
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }
        
        // Add some snapping behaviour so that the zoomed cell is always centered
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }
        
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2
        
        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Invalidate layout so that every cell get a chance to be zoomed when it reaches the center of the screen
        return true
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}

class StickerCarouselCell: UICollectionViewCell, BaseCellProtocol {
    
    private let downloadCountLabel = UILabel().configure {
        $0.applyStyle(.regular(size: 10, color: .darkGray))
    }
    
    private let stickerLabel = UILabel().configure {
        $0.applyStyle(.bold(size: 24, color: .black))
        $0.lineBreakMode = .byWordWrapping
        $0.numberOfLines = 2
    }
    
    private let stickerIcon = UIImageView().configure {
        $0.contentMode = .scaleAspectFit
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.roundCorner(12)
        backgroundColor = .clear
        dropShadow(shadowColor: .black, opacity: 0.17, height: 3, shadowRadius: 3)
        
        contentView.addSubview(downloadCountLabel)
        contentView.addSubview(stickerLabel)
        contentView.addSubview(stickerIcon)

        downloadCountLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview().inset(12)
            $0.bottom.equalTo(stickerLabel.snp.top).offset(-6)
        }
        stickerLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
//            $0.bottom.greaterThanOrEqualTo(stickerIcon.snp.top).offset(-8)
        }
        stickerIcon.snp.makeConstraints {
            $0.height.width.equalToSuperview().dividedBy(2.5)
            $0.bottom.trailing.equalToSuperview().inset(12)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ data: Sticker?) {
        guard let data = data else { return }
        let count = data.downloadCount ?? 0
        downloadCountLabel.text = String(format: "text_sticker_total_download".localized, count.abbreviated)
        stickerLabel.text = data.bundleName
        stickerIcon.sd_setImage(with: URL(string: data.bundleIcon.orEmpty), placeholderImage: UIImage.set_image(named: "rl_placeholder_icon"))
    }
}
