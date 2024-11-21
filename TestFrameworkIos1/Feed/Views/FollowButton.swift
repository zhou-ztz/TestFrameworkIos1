//
//  FollowButton.swift
//  Yippi
//
//  Created by Francis Yeap on 16/11/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit


class FollowButton: LoadableButton {

    private let widthInset: CGFloat = 12.0
    private let heightInset: CGFloat = 3.5

//    override var intrinsicContentSize: CGSize {
//        let current = super.intrinsicContentSize
//
//        return CGSize(width: widthInset*2 + current.width, height: heightInset*2 + current.height)
//    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setTitle("display_follow".localized)
        self.setTitleColor(.white, for: .normal)

        // Set button contents
        self.titleLabel?.font = UIFont.systemRegularFont(ofSize: 12)
        self.bgColor = TSColor.main.theme
        self.backgroundColor =  TSColor.main.theme
        self.contentEdgeInsets = UIEdgeInsets(top: heightInset, left: widthInset, bottom: heightInset, right: widthInset)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.cornerRadius = self.bounds.height / 2
        self.roundCorner(self.cornerRadius)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        layoutSubviews()
    }
}
