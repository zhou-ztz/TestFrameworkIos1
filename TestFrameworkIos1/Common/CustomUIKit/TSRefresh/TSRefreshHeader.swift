//
//  TSRefreshHeader.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/20.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  下拉刷新 header

import UIKit
import MJRefresh
import SnapKit

class TSRefreshHeader: MJRefreshHeader {
    
    private let pulseIndicator = BallPulseIndicator(radius: 25.0, color: AppTheme.red)
    override var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                self.pulseIndicator.stopAnimating()
                
            case .pulling:
                self.pulseIndicator.startAnimating()
                                
            case .refreshing:
                self.pulseIndicator.startAnimating()
                
            default: break
            }
        }
    }
    
    override var pullingPercent: CGFloat {
        didSet {
        }
    }

    // MARK: - Custom user interface
    override func prepare() {
        super.prepare()
        
        addSubview(pulseIndicator)
        pulseIndicator.snp.makeConstraints { c in
            c.center.equalToSuperview()
            c.width.equalTo(45)
            c.height.equalTo(25)
            //c.top.left.greaterThanOrEqualToSuperview().inset(5)
        }

        self.backgroundColor = UIColor.clear
        
        self.layoutIfNeeded()
    }
    
    override func scrollViewPanStateDidChange(_ change: [AnyHashable : Any]!) {
        super.scrollViewPanStateDidChange(change)
    }
    
    override func scrollViewContentSizeDidChange(_ change: [AnyHashable : Any]!) {
        super.scrollViewContentSizeDidChange(change)
    }
    
    override func scrollViewContentOffsetDidChange(_ change: [AnyHashable : Any]!) {
        super.scrollViewContentOffsetDidChange(change)
    }
}
