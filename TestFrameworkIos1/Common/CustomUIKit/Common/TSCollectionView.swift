//
//  TSCollectionView.swift
//  ThinkSNSPlus
//
//  Created by 小唐 on 14/03/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//

import UIKit

class TSCollectionView: UICollectionView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    lazy var placeholder = Placeholder()

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func show(placeholderView type: PlaceholderViewType, margin: CGFloat = 0.0, height: CGFloat? = nil) {
        if placeholder.superview == nil {
            // 将 placeholderView 放在 UICollectionReusableView 的后面
            if let headerView = self.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) {
                self.insertSubview(placeholder, belowSubview: headerView)
            }else{
                self.addSubview(placeholder)
            }
            placeholder.snp.makeConstraints {
                $0.left.right.equalToSuperview()
                if #available(iOS 11.0, *) {
                    $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottomMargin)
                } else {
                    $0.bottom.equalToSuperview()
                }
                $0.top.equalToSuperview().offset(margin)
                $0.width.equalToSuperview()
                if let height = height {
                    $0.height.equalTo(height)
                } else {
                    $0.height.equalToSuperview()
                }
            }
            
            placeholder.onTapActionButton = {[weak self] in
                self?.mj_header.beginRefreshing()
            }
        }
        
        placeholder.set(type)
        placeholder.backgroundColor = placeholder.customBackgroundColor ?? .white
    }
    
    func removePlaceholderView() {
        if placeholder.superview != nil {
            placeholder.removeFromSuperview()
        }
    }
    
    func setPlaceholderBackgroundGrey() {
        placeholder.customBackgroundColor = TSColor.inconspicuous.background
    }
}
