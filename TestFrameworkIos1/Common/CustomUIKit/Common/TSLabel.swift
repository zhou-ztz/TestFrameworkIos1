//
//  TSLabel.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/1/20.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  基类

import UIKit

class TSLabel: UILabel {
    
    var textInsets:UIEdgeInsets = .zero

    // MARK: - lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }

    // MARK: - setup
    func setupUI() {

    }
}
