//
//  TSCollectionViewController.swift
//  Yippi
//
//  Created by Jerry Ng on 17/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class TSCollectionViewController: UICollectionViewController {
    
    public var customScrollViewDelegate:TSScrollDelegate?
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        customScrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        customScrollViewDelegate?.scrollViewDidScroll(scrollView)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        customScrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
}
