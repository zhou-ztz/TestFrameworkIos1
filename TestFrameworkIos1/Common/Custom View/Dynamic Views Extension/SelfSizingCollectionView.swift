//
//  SelfSizingCollectionView.swift
//  Yippi
//
//  Created by ChuenWai on 21/05/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class SelfSizingCollectionView: UICollectionView {
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        isScrollEnabled = false
    }

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        contentSize.height += contentInset.top + contentInset.bottom
        return contentSize
    }
}
