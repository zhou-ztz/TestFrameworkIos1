//
//  MiniVideoCollectionShimmerView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 08/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class MiniVideoCollectionShimmerView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet var thumbnailViews: [UIView]!
    @IBOutlet var labelViews: [UIView]!
    @IBOutlet weak var shimmeringMaskView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MiniVideoCollectionShimmerView", owner: self, options: nil)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(view)
        
        thumbnailViews.forEach { (_view) in
            _view.roundCorner(8)
        }
        
        thumbnailViews.forEach { (_view) in
            _view.backgroundColor = TSColor.inconspicuous.disabled
        }
        
        labelViews.forEach { (_view) in
            _view.backgroundColor = TSColor.inconspicuous.disabled
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shimmeringMaskView.startShimmering(background: false)
    }
}
