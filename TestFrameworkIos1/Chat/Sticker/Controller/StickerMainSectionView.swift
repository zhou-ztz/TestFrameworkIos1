//
//  StickerMainSectionView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 22/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class StickerMainSectionView: UIView {
    
    private let titleLabel = UILabel().configure {
        $0.applyStyle(.semibold(size: 18, color: .black))
    }
    
    let seeAllButton = UIButton().configure {
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitle("sticker_see_all".localized, for: .normal)
        $0.titleLabel?.font = UIFont.systemRegularFont(ofSize: 14)
        $0.horizontalHuggingPriority = .defaultHigh
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(seeAllButton)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.bottom.equalToSuperview()
            $0.trailing.greaterThanOrEqualTo(seeAllButton.snp.leading).offset(-8)
        }
        seeAllButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}
