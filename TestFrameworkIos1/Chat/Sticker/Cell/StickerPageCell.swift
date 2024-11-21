//
//  StickerRankBannerCell.swift
//
//  Copyright © 2018 Toga Capital. All rights reserved.
//

import UIKit
import FSPagerView
import SDWebImage


class StickerPageCell: UITableViewCell, BaseCellProtocol {

    private var stickers: [Sticker] = []
    private var section: Int?
    private weak var delegate: StickerCollectionCellDelegate?

    @IBOutlet weak var pageControl: FSPageControl!
    @IBOutlet weak var pager: FSPagerView! {
        didSet {
            pager.register(FeaturedStickerFSPagerViewCell.nib(), forCellWithReuseIdentifier: FeaturedStickerFSPagerViewCell.cellIdentifier)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        pager.delegate = self
        pager.dataSource = self
        pager.automaticSlidingInterval = 3
        pager.isInfinite = true
        pager.removesInfiniteLoopForSingleItem = true
        pageControl.contentHorizontalAlignment = .center
        pageControl.setFillColor(AppTheme.lightGrey, for: .selected)
        pageControl.setFillColor(AppTheme.lightGrey.withAlphaComponent(0.5), for: .normal)
    }
    
    func configure(_ stickers: [Sticker], section: Int? = nil, delegate: StickerCollectionCellDelegate?) {
        self.stickers = stickers
        self.section = section
        self.delegate = delegate
        pageControl.numberOfPages = self.stickers.count
        pager.reloadData()
    }
}

extension StickerPageCell: FSPagerViewDelegate, FSPagerViewDataSource {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return stickers.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: FeaturedStickerFSPagerViewCell.cellIdentifier, at: index) as! FeaturedStickerFSPagerViewCell
        cell.configure(sticker: self.stickers[index], showDetailHandler: { sticker in
            self.delegate?.stickerCellDidSelect(sticker: sticker)
        })
        return cell
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }
}
