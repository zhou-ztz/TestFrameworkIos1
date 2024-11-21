//
//  FeedResendButton.swift
//  Yippi
//
//  Created by Alan Lee on 14/11/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit

class FeedResendButton: UIButton {
    
    
    override var intrinsicContentSize: CGSize {
        get {
            return titleLabel?.intrinsicContentSize ?? CGSize.zero
        }
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    override func layoutSubviews() {
        titleLabel?.preferredMaxLayoutWidth = titleLabel?.frame.size.width ?? 0
        super.layoutSubviews()
    }
}
