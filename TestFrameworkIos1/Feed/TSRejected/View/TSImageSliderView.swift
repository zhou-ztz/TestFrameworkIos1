//
//  TSImageSliderView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/7/27.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import SDWebImage

private let cellID = "TSImageBannerCell"

enum ScrollMode: Int {
    case horizontal = 0
    case vertical
}

class TSImageSliderView: UIView,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate {
    
    var placeholder: String?
    var imageModels: [RejectDetailModelImages] = [] {
        didSet {
            guard self.imageModels.count > 1 else {
                self.collectionView.isScrollEnabled = false
                self.collectionView.reloadData()
                return
            }
            scrollTo(crtPage: 0 + 1 , animated: false)
            self.pageControl.numberOfPages = imageModels.count
            self.collectionView.reloadData()
        }
    }
    var mode: ScrollMode = .horizontal {
        didSet {
            if mode == .horizontal {
                self.layout.scrollDirection = .horizontal
            } else {
                self.layout.scrollDirection = .vertical
                self.pageControl.removeFromSuperview()
            }
            self.collectionView.setCollectionViewLayout(self.layout, animated: true)
        }
    }
    fileprivate var collectionView: UICollectionView!
    fileprivate var pageControl: UIPageControl!
    // 懒加载layout
    lazy fileprivate var layout:UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.itemSize = CGSize.init(width: self.frame.size.width, height: self.frame.size.height)
        layout.minimumLineSpacing = 0
        return layout
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        setupCollectionView()
        setupPageControl()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else {
            return
        }
        super.willMove(toSuperview: newSuperview)
        if self.imageModels.count == 0 {
            return
        }
        guard self.imageModels.count > 1 else {
            self.collectionView.isScrollEnabled = false
            return
        }
        scrollTo(crtPage: 0 + 1 , animated: false)
    }
    
    fileprivate func setupCollectionView() {
        self.collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height), collectionViewLayout: self.layout)
        self.collectionView.bounces = false
        self.collectionView.register(BannerCollectionCell.self, forCellWithReuseIdentifier: cellID)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.isPagingEnabled = true
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.addSubview(self.collectionView)
    }
    
    fileprivate func setupPageControl() {
        self.pageControl = UIPageControl.init(frame: CGRect.init(x: 0, y: self.frame.size.height - 22, width: self.frame.size.width, height: 22))
        self.pageControl.currentPageIndicatorTintColor = UIColor.white
        self.pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        self.pageControl.contentHorizontalAlignment = .center
        self.addSubview(self.pageControl)
        self.pageControl.hidesForSinglePage = true
    }
    
    @objc fileprivate func nextPage() {
        if self.imageModels.count > 1 {
            var crtPage = 0
            if self.mode == .horizontal {
                crtPage = lroundf(Float(self.collectionView.contentOffset.x/self.frame.size.width))
            } else {
                crtPage = lroundf(Float(self.collectionView.contentOffset.y/self.frame.size.height))
            }
            scrollTo(crtPage: crtPage + 1, animated: true)
        }
    }
  
    fileprivate func scrollTo(crtPage: Int, animated: Bool) {
        if self.mode == .horizontal {
            self.collectionView.setContentOffset(CGPoint.init(x: self.frame.size.width * CGFloat(crtPage), y: 0), animated: animated)
        } else {
            self.collectionView.setContentOffset(CGPoint.init(x: 0, y: self.frame.size.height * CGFloat(crtPage)), animated: animated)
        }
    }

    // collectionView delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.imageModels.count == 0 {
            return 0
        }
        if self.imageModels.count > 1 {
           return self.imageModels.count + 2
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! BannerCollectionCell
        cell.placeholder = self.placeholder
    
        if indexPath.row == 0 {
            cell.imageModel = self.imageModels.last
        } else if indexPath.row == self.imageModels.count + 1 {
            cell.imageModel = self.imageModels.first
        } else {
            cell.imageModel = self.imageModels[safe: indexPath.row - 1]
        }
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = CGFloat(0)
        if self.mode == .horizontal {
            offset = scrollView.contentOffset.x
        } else {
            offset = scrollView.contentOffset.y
        }
        
        let x = self.mode == .horizontal ? self.frame.size.width : self.frame.size.height
        
        if offset == 0 {
            scrollTo(crtPage: self.imageModels.count, animated: false)
            self.pageControl.currentPage = self.imageModels.count - 1
        } else if offset == CGFloat(self.imageModels.count + 1) * x {
            scrollTo(crtPage: 1, animated: false)
            self.pageControl.currentPage = 0
        } else {
           self.pageControl.currentPage = lroundf(Float(offset/self.frame.size.width)) - 1
        }
    }
}

class BannerCollectionCell: UICollectionViewCell {
    var placeholder: String?
    
    private let imgView = UIImageView().configure {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let coverIssueView: UIView = UIView().configure {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
    }
    private let coverWarningContainer = UIView().configure {
        $0.backgroundColor = .clear
    }
    private let coverWarningImageView = UIImageView().configure {
        $0.image = UIImage.set_image(named: "ic_rejected_warning_icon")
        $0.clipsToBounds = true
    }
    private let coverIssueStackView: UIStackView = UIStackView(frame: .zero).configure {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 8
    }
    
    private let labelForCoverIssue = UILabel().configure {
        $0.setFontSize(with: 14, weight: .norm)
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.textColor = UIColor.white
    }
    
    var imageModel: RejectDetailModelImages? {
        didSet {
            self.imgView.sd_setImage(with: URL(string: imageModel?.imagePath ?? ""), placeholderImage: UIImage.set_image(named: placeholder ?? ""))
            self.coverIssueView.isHidden = !(imageModel?.isSensitive ?? false)
            
            self.labelForCoverIssue.text = self.imageModel?.sensitiveType ?? "rejected_reason".localized
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        setupContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupContent() {
        self.imgView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.contentView.addSubview(imgView)
      
        self.contentView.addSubview(coverIssueView)
        coverIssueView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalToSuperview()
        }
        coverIssueView.addSubview(coverIssueStackView)
        coverIssueStackView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(10)
            $0.trailing.bottom.equalToSuperview().offset(-10)
        }
        
        coverWarningContainer.addSubview(coverWarningImageView)
        coverWarningImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(CGSizeMake(24, 24))
        }
        
        coverIssueStackView.addArrangedSubview(coverWarningContainer)
        coverIssueStackView.addArrangedSubview(labelForCoverIssue)
        coverIssueView.addSubview(coverIssueStackView)
        coverWarningContainer.snp.makeConstraints {
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview()
        }
        
    }
}
