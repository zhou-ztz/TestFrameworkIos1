//
//  TSRefreshFooter.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/20.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  上拉加载更多 footer

import UIKit
import SnapKit
import MJRefresh

class TSRefreshFooter: MJRefreshAutoFooter {
    var detailInfoLabel = UILabel(text: "load_more".localized, font: UIFont.systemFont(ofSize: 12), textColor: UIColor(hex: 0xb3b3b3))
    var indicator = UIActivityIndicatorView()
    
    override var state: MJRefreshState {
        didSet {
            switch state {
            case .noMoreData:
                detailInfoLabel.textAlignment = .center
                detailInfoLabel.text = "no_more_data_tips".localized
                indicator.isHidden = true
                indicator.stopAnimating()
                layoutIfNeeded()
            case .idle:
                detailInfoLabel.textAlignment = .center
                detailInfoLabel.text = "pull_for_refresh".localized
                indicator.isHidden = true
                indicator.stopAnimating()
                layoutIfNeeded()
            default:
                indicator.isHidden = false
                indicator.startAnimating()
                detailInfoLabel.textAlignment = .right
                detailInfoLabel.text = "load_more".localized
                layoutIfNeeded()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonSetup()
    }
    
    private func commonSetup() {
        
        let stackview = UIStackView(arrangedSubviews: [indicator, detailInfoLabel]).build { v in
            v.axis = .horizontal
            v.alignment = .fill
            v.distribution = .fill
            v.spacing = 3
        }
        
        self.addSubview(stackview)
        indicator.startAnimating()
        
        let noticeLabelTap = UITapGestureRecognizer(target: self, action: #selector(footerDidTap))
        addGestureRecognizer(noticeLabelTap)
        
        stackview.snp.makeConstraints { c in
            c.center.equalToSuperview()
            //c.left.top.greaterThanOrEqualToSuperview().inset(10)
        }
        
        self.layoutIfNeeded()
    }
    
    @objc func footerDidTap() {
        beginRefreshing()
    }
}

extension MJRefreshFooter {
    /// 网络异常
    func endRefreshingWithWeakNetwork() {
        endRefreshing()
    }
}
