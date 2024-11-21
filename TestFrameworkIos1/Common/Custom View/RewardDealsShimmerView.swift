//
//  RewardDealsShimmerView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 14/05/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class RewardDealsShimmerView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet var shimmerView: [UIView]!
    @IBOutlet var roundViews: [UIView]!
    @IBOutlet weak var shimmingMaskView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RewardDealsShimmerView", owner: self, options: nil)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(view)
        
        roundViews.forEach {
            $0.roundCorner(8)
            $0.backgroundColor = TSColor.inconspicuous.disabled
        }
        
        shimmerView.forEach {
            $0.backgroundColor = TSColor.inconspicuous.disabled
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shimmingMaskView.startShimmering(background: false)
    }
}
